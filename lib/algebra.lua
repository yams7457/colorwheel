music_util = require("musicutil")

velocity_values = { 0, 32, 64, 96, 127 }
length_values = {.25, .5, 1, 2, 4}

note_traits = {
  ["current"] = {
    ["gate"] = {0,0,0,0},
    ["interval"] = {1,1,1,1},
    ["octave"] = {1,1,1,1},
    ["velocity"] = {1,1,1,1},
    ["length"] = {1,1,1,1},
    ["ratchet"] = {1,1,1,1},
    ["alt note"] = {0,0,0,0},
    --["glide"] = {0,0,0,0}
  },
  ["previous"] = {
    ["gate"] = {0,0,0,0},
    ["interval"] = {1,1,1,1},
    ["octave"] = {1,1,1,1},
    ["velocity"] = {1,1,1,1},
    ["length"] = {1,1,1,1},
    ["ratchet"] = {1,1,1,1},
    ["alt note"] = {0,0,0,0},
    ["glide"] = {0,0,0,0}
  },
  ["active"] = {
    ["gate"] = {0,0,0,0},
    ["interval"] = {1,1,1,1},
    ["octave"] = {1,1,1,1},
    ["velocity"] = {1,1,1,1},
    ["length"] = {1,1,1,1},
    ["ratchet"] = {1,1,1,1},
    ["alt note"] = {0,0,0,0},
    ["glide"] = {0,0,0,0}
  },
  ["calculated"] = {
    ["interval"] = {1,1,1,1}
  }
}

current_sequence_step = {
  ["interval"] = {},
  ["octave"] = {},
  ["gate"] = {}
}

current_note = {}

-- store params until ready to add to group
local param_queue = {}
function queue_add_param(param)
  param_queue[#param_queue + 1] = param
end

-- count how many in queue, create group of that size
-- then actually add the parameters

function dequeue_param_group(group_name)
  print("creating group "..group_name.." with "..#param_queue.." params")
  params:add_group(group_name, #param_queue)
  print("adding "..#param_queue.." params")
  for queue_index=1, #param_queue do
    item = param_queue[queue_index]
    if item.type == "option" then
      params:add_option(item.id, item.name, item.options, item.default)
    else
      params:add(item)
    end
  end
  param_queue = {}
end

queue_add_param{ type = "number", id = "key", name = "key", min = 0, max = 11, default = 0 }
queue_add_param{ type = "number", id = "meta loop start", name = "meta loop start", min = 1, max = 16, default = 1 }
queue_add_param{ type = "number", id = "meta loop end", name = "meta loop end", min = 1, max = 16, default = 6 }
queue_add_param{ type = "number", id = "offset", name = "offset", min = 0, max = 11, default = 0 }
queue_add_param{ type = "number", id = "transpose", name = "transpose", min = 0, max = 11, default = 0 }
queue_add_param{ type = "number", id = "offset mode", name = "offset mode", min = 1, max = 2, default = 2 }
queue_add_param{ type = "number", id = "Bernoulli chance", name = "Bernoulli Chance", min = 0, max = 100, default = 50 }
for i = 1,4,1
  do
queue_add_param{ type = "number", id = "midi channel " ..i, name = "midi channel " ..i, min = 1, max = 16, default = 1 }
end
  dequeue_param_group("meta")

for i = 1,4,1 do
    queue_add_param{ type = "option", id = "output "..i, name = "output", options= VOICES, default=MIDI_VOICE}
    for key,value in pairs(note_traits.current) do
        queue_add_param{ type = "number", id = key.. " div " ..i, name = key.. " div " ..i, min = 1, max = 16, default = 1}
        queue_add_param{ type = "number", id = key.. " sequence start " ..i, name = key.. " sequence start " ..i, min = 1, max = 16, default = 1}
        queue_add_param{ type = "number", id = key.. " sequence end " ..i, name = key.. " sequence end " ..i, min = 1, max = 16, default = 6}
        queue_add_param{ type = "number", id = "current " ..key.. " step " ..i, name = "current " ..key.. " step " ..i, min = 1, max = 16, default = 1}
    end

    queue_add_param{ type = "number", id = "track active " ..i, name = "track active " ..i, min = 0, max = 1, default = 1 }
    queue_add_param{ type = "number", id = "track octave " ..i, name = "track octave " ..i, min = 1, max = 6, default = i }
    queue_add_param{ type = "number", id = "offset " ..i, name = "offset " ..i, min = 1, max = 5, default = 3}
    queue_add_param{ type = "number", id = "transposition " ..i, name = "transposition " ..i, min = -2, max = 2, default = 0}
    queue_add_param{ type = "number", id = "carving " ..i, name = "carving " ..i, min = 0, max = 3, default = 3}
    queue_add_param{ type = "number", id = "probability " ..i, name = "probability " ..i, min = 0, max = 100, default = 100 }
    queue_add_param{ type = "number", id = "clock channel " ..i, name = "clock channel " ..i, min = 1, max = 4, default = 1 }

    dequeue_param_group("track " ..i)

end

for i = 1,4,1 do

    for j = 1,16,1 do

      queue_add_param{ type = "number", id = "gate " ..i .." "..j, name = "gate " ..i .." "..j, min = 0, max = 1, default = 0 }
      queue_add_param{ type = "number", id = "interval " ..i .." "..j, name = "interval " ..i .." "..j, min = 1, max = 5, default = 1 }
      queue_add_param{ type = "number", id = "octave " ..i .." "..j, name = "octave " ..i .." "..j, min = 1, max = 4, default = 1 }
      queue_add_param{ type = "option", id = "velocity " ..i .." "..j, name = "velocity " ..i .." "..j, options = {"0", "32", "64", "96", "127"}, default = 5}
      queue_add_param{ type = "option", id = "length " .. i .. " " ..j, name = "length " .. i .. " " ..j, options = {"1/4", "1/2", "1", "2", "4"}, default = 1}
      queue_add_param{ type = "number", id = "alt note " ..i .." "..j, name = "alt note " ..i .." "..j, min = 0, max = 4, default = 0 }
      queue_add_param{ type = "number", id = "ratchet "  ..i .." "..j, name = "ratchet " ..i .." "..j, min = 0, max = 5, default = 0 }
      queue_add_param{ type = "number", id = "glide " ..i .." "..j, name = "glide " ..i .." "..j, min = 0, max = 5, default = 0 }
      for key,value in pairs(note_traits.current) do
          queue_add_param{ type = "number", id = key.. " probability " .. i .." " ..j, name = key .. " probability " .. i .. " " ..j, min = 0, max = 100, default = 100 }
      end
      
         params:set_action("output "..i, function(param)
     if param == JF_VOICE then
       crow.ii.jf.mode(1)
     end
     if not currently_banging then
       currently_banging = true
       params:bang()
       currently_banging = false
     end
   end)
      
      
    end

dequeue_param_group("steps " .. i)

end


step = 0

collection_0 =
  {{0,7,12,19,24,31,36,0,2,7,12,14,19,24,0,2,7,9,12,14,19,0,2,4,7,9,12,14},
  {2,7,14,19,26,31,38,2,7,9,14,19,21,26,2,4,7,9,14,16,19,2,4,7,9,11,14,16},
  {2,9,14,21,26,33,38,2,4,9,14,16,21,26,2,4,9,11,14,16,21,2,4,6,9,11,14,16},
  {4,9,16,21,28,33,40,4,9,11,16,21,23,28,4,6,9,11,16,18,21,1,4,6,9,11,13,16},
  {4,11,16,23,28,35,40,4,6,11,16,18,23,28,1,4,6,11,13,16,18,1,4,6,8,11,13,16},
  {6,11,18,23,30,35,42,1,6,11,13,18,23,25,1,6,8,11,13,18,20,1,3,6,8,1,13,15},
  {0,5,12,17,24,29,36,0,5,7,12,17,19,24,0,2,5,7,12,14,17,0,2,5,7,9,12,14},
  {5,10,17,22,29,34,41,0,5,10,12,17,22,24,0,5,7,10,12,17,19,0,2,5,7,10,12,14},
  {3,10,15,22,27,34,39,3,5,10,15,17,22,27,0,3,5,10,12,15,17,0,3,5,7,10,12,15},
  {3,8,15,20,27,32,39,3,8,10,15,20,22,27,3,5,8,10,15,17,20,0,3,5,8,10,12,15},
  {1,8,13,20,25,32,37,1,3,8,13,15,20,25,1,3,8,10,13,15,20,1,3,5,8,10,13,15},
  {1,6,13,18,25,30,37,1,6,8,13,18,20,25,1,3,6,8,13,15,18,1,3,6,8,10,13,15}}

offset_list = {{0,5,12,17,24},{0,7,12,19,24}}

algebra = {}
current_channel = {}

active_interval = {}

function algebra.init()
  params:set("clock_tempo", 20)
  m = midi.connect()
  for i = 1,4 do
    for key,value in pairs(current_sequence_step) do
      current_sequence_step[key][i] = 0
    end
  end
  m:all_off()
end

function m:all_off()
  for note = 1, 127 do
    for channel = 1, 16 do
      for device = 1, 4 do
        m:note_off(note, 0, channel)
      end
    end
  end
end

function trait_tick(a_trait, track, source_lattice)
     if a_trait == "gate" 
      and params:get("gate " ..track.. " " ..params:get("current gate step " ..track)) == 1 
          and math.random(1,100) <= params:get("gate probability " .. track .. " " .. params:get("current gate step " ..track))
            then
              determine_traits(track)
            end
    params:set("current " .. a_trait .. " step " .. track, ((params:get("current " .. a_trait .. " step " .. track) - params:get(a_trait .. " sequence start " .. track)) + 1) % (params:get(a_trait .. " sequence end " .. track) - params:get(a_trait .. " sequence start " .. track) + 1) + params:get(a_trait .. " sequence start " .. track))
    grid_dirty = true
    source_lattice:set_division(params:get(a_trait..  ' div ' ..track) / 8)
end

function determine_traits(track, flourish)
  if flourish ~= true then
    check_step_probability(track)
  end
  local interval = params:get('interval ' ..track.. ' '..params:get('current interval step ' ..track)) 
  if math.random(1,100) <= params:get("alt note probability " ..track.. ' ' ..params:get('current alt note step ' ..track)) then
    interval = (interval + params:get('alt note ' ..track.. ' ' ..params:get('current alt note step ' ..track)))
  end
  if interval >= 6 then
    interval = interval % 5
  end
  local octave = params:get('octave ' ..track.. ' ' ..params:get('current octave step ' ..track)) + params:get('track octave ' ..track)
  local length = params:get('length ' ..track.. ' ' ..params:get('current length step ' ..track))
  local velocity = params:get('velocity ' ..track.. ' ' ..params:get('current velocity step ' ..track))
  local current_inner_index = {} -- setting up some things for the algebra later
  local current_octave = {}
  local current_offset = {}
  local outer_index = 1 + params:get("transpose")
  local carving = params:get("carving " ..track) * 7
  local inner_index = (carving + interval)
  current_inner_index[track] = inner_index
  note_traits.calculated.interval[track] = params:get("offset") + (params:get('key') + (collection_0[outer_index][inner_index]) + ( 7 * params:get("transposition " ..track))) % 12
  current_offset[track] = offset_list[params:get("offset mode")][params:get("offset " ..track)]
  current_note[track] = note_traits.calculated.interval[track] + octave * 12 + current_offset[track]
  current_channel[track] = params:get("midi channel " ..track)
  for key,value in pairs(note_traits.current) do
      note_traits.previous[key][track] = note_traits.previous[key][track]
  end
  play(current_note[track], velocity_values[velocity], length_values[length], current_channel[track], track, flourish)
end

function check_step_probability(track)
  for key,value in pairs(note_traits.current) do
    if math.random(1,100) <= params:get( key.. " probability " ..track.. " " .. params:get("current " ..key.. " step " ..track))
      then note_traits.current[key][track] = params:get( key.. " " ..track.. " " .. params:get("current " ..key.. " step " ..track))
      else note_traits.current[key][track] = note_traits.previous[key][track]
    end
    note_traits.active[key][track] = note_traits.current[key][track]
  end
end

function play(note, vel, length, channel, track, flourish)
  if flourish or (math.random(1, 100) <= params:get('probability ' ..track) and params:get("track active " ..track) >= 1 ) then
    notes.play[params:get("output "..track)](note, vel, length, channel, track)
    print(note, vel, channel)
    end
    clock.run(note_off, note, vel, length, channel, track)
  end

function note_off(note, vel, length, channel)
  clock.sleep(clock.get_beat_sec() * length)
  m:note_off(note, vel, channel)
end

function offset_flourish(track)
  previous_offset[track] = params:get('offset ' ..track)
  determine_traits(track, true)
  grid_dirty = true
end
