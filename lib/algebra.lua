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

queue_add_param{ type = "number", id = "root", name = "root", min = 0, max = 11, default = 0 }
queue_add_param{ type = "number", id = "fifth", name = "fifth", min = 0, max = 11, default = 7 }
queue_add_param{ type = "number", id = "second", name = "second", min = 0, max = 11, default = 2 }
queue_add_param{ type = "number", id = "sixth", name = "sixth", min = 0, max = 11, default = 9 }
queue_add_param{ type = "number", id = "third", name = "third", min = 0, max = 11, default = 4 }

queue_add_param{ type = "number", id = "key", name = "key", min = 0, max = 11, default = 0 }
queue_add_param{ type = "number", id = "global clock div", name = "global clock div", min = 1, max = 8, default = 4 }
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

finish_output_setting = {nil, nil, nil, nil}

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
        if finish_output_setting[i] ~= nil then
          clock.cancel(finish_output_setting[i])
          finish_output_setting[i] = nil
        end
        currently_banging = true
        finish_output_setting[i] = clock.run(function ()
          clock.sleep(0.5)
          if param == JF_VOICE then
            crow.ii.jf.mode(1)
          end
          if not currently_banging then
            params:bang()
            currently_banging = false
          end
          finish_output_setting[i] = nil
        end)
      end)
      
      
    end

dequeue_param_group("steps " .. i)

end


step = 0

function create_the_collection()

collection_0 = {}

for i = 0,11 do
  collection_0[i] = {params:get("root") + i, params:get("fifth") + i, params:get("root") + i, params:get("fifth") + i, params:get("root") + i, params:get("fifth") + i, params:get("root") + i, params:get("root") + i, params:get("second") + i, params:get("fifth") + i, params:get("root") + i, params:get("second") + i, params:get("fifth") + i, params:get("root") + i, params:get("root") + i, params:get("second") + i, params:get("fifth") + i, params:get("sixth") + i, params:get("root") + i, params:get("second") + i, params:get("fifth") + i, params:get("root") + i, params:get("second") + i, params:get("third") + i, params:get("fifth") + i, params:get("sixth") + i, params:get("root") + i, params:get("second") + i}
end

end

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

function trait_tick(a_trait, track, source_lattice, t)
     if a_trait == "gate" 
      and params:get("gate " ..track.. " " ..params:get("current gate step " ..track)) == 1 
          and math.random(1,100) <= params:get("gate probability " .. track .. " " .. params:get("current gate step " ..track))
            then
              determine_traits(track)
            end
    params:set("current " .. a_trait .. " step " .. track, ((params:get("current " .. a_trait .. " step " .. track) - params:get(a_trait .. " sequence start " .. track)) + 1) % (params:get(a_trait .. " sequence end " .. track) - params:get(a_trait .. " sequence start " .. track) + 1) + params:get(a_trait .. " sequence start " .. track))
    grid_dirty = true
    source_lattice:set_division(params:get(a_trait..  ' div ' ..track) * params:get("global clock div") / 32)
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
  local outer_index = params:get("transpose")
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
  play(current_note[track] + params:get("key"), velocity_values[velocity], length_values[length], current_channel[track], track, flourish)
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
    --print(note, vel, channel)
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
