music_util = require("musicutil")

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
queue_add_param{ type = "number", id = "track link mode", name = "track link mode", min = 1, max = 3, default = 1 }
for i = 1,4,1
  do
queue_add_param{ type = "number", id = "midi channel " ..i, name = "midi channel " ..i, min = 1, max = 16, default = 1 }
queue_add_param{ type = "number", id = "track active " ..i, name = "track active " ..i, min = 0, max = 1, default = 1 }
end
  dequeue_param_group("meta")

for i = 1,4,1
  do
    queue_add_param{ type = "option", id = "output "..i, name = "output", options= VOICES, default=MIDI_VOICE}
queue_add_param{ type = "number", id = "gate div " ..i, name = "gate div " ..i, min = 1, max = 16, default = 1}
queue_add_param{ type = "number", id = "interval div " ..i, name = "interval div " ..i, min = 1, max = 16, default = 1}
queue_add_param{ type = "number", id = "octave div " ..i, name = "gate div " ..i, min = 1, max = 16, default = 1}
queue_add_param{ type = "number", id = "velocity div " ..i, name = "velocity div " ..i, min = 1, max = 16, default = 1}
queue_add_param{ type = "number", id = "length div " ..i, name = "length div " ..i, min = 1, max = 16, default = 1}
queue_add_param{ type = "number", id = "track active " ..i, name = "track active " ..i, min = 0, max = 1, default = 1 }
queue_add_param{ type = "number", id = "track octave " ..i, name = "track octave " ..i, min = 1, max = 6, default = i }
queue_add_param{ type = "number", id = "offset " ..i, name = "offset " ..i, min = 1, max = 5, default = 3}
queue_add_param{ type = "number", id = "transposition " ..i, name = "transposition " ..i, min = -2, max = 2, default = 0}
queue_add_param{ type = "number", id = "carving " ..i, name = "carving " ..i, min = 0, max = 3, default = 3}
queue_add_param{ type = "number", id = "probability " ..i, name = "probability " ..i, min = 0, max = 100, default = 100 }
queue_add_param{ type = "number", id = "clock channel " ..i, name = "clock channel " ..i, min = 1, max = 4, default = 1 }
queue_add_param{ type = "number", id = "gate sequence start " ..i, name = "gate sequence start " ..i, min = 1, max = 16, default = 1}
queue_add_param{ type = "number", id = "interval sequence start " ..i, name = "interval sequence start " ..i, min = 1, max = 16, default = 1}
queue_add_param{ type = "number", id = "octave sequence start " ..i, name = "octave sequence start " ..i, min = 1, max = 16, default = 1}
queue_add_param{ type = "number", id = "velocity sequence start " ..i, name = "velocity sequence start " ..i, min = 1, max = 16, default = 1}
queue_add_param{ type = "number", id = "length sequence start " ..i, name = "length sequence start " ..i, min = 1, max = 16, default = 1}
queue_add_param{ type = "number", id = "gate sequence end " ..i, name = "gate sequence end " ..i, min = 1, max = 16, default = 6}
queue_add_param{ type = "number", id = "interval sequence end " ..i, name = "interval sequence end " ..i, min = 1, max = 16, default = 6}
queue_add_param{ type = "number", id = "octave sequence end " ..i, name = "octave sequence end " ..i, min = 1, max = 16, default = 6}
queue_add_param{ type = "number", id = "velocity sequence end " ..i, name = "velocity sequence end " ..i, min = 1, max = 16, default = 6}
queue_add_param{ type = "number", id = "length sequence end " ..i, name = "length sequence end " ..i, min = 1, max = 16, default = 6}
queue_add_param{ type = "number", id = "current gate step " ..i, name = "current gate step " ..i, min = 1, max = 16, default = 1}
queue_add_param{ type = "number", id = "current interval step " ..i, name = "current interval step " ..i, min = 1, max = 16, default = 1}
queue_add_param{ type = "number", id = "current octave step " ..i, name = "current octave step " ..i, min = 1, max = 16, default = 1}
queue_add_param{ type = "number", id = "current velocity step " ..i, name = "current velocity step " ..i, min = 1, max = 16, default = 1}
queue_add_param{ type = "number", id = "current length step " ..i, name = "current length step " ..i, min = 1, max = 16, default = 1}

  dequeue_param_group("track " ..i)
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

for i = 1,4,1 do

    for j = 1,16,1 do

      queue_add_param{ type = "number", id = "gate " ..i .." "..j, name = "gate " ..i .." "..j, min = 0, max = 1, default = 0 }
      queue_add_param{ type = "number", id = "interval " ..i .." "..j, name = "interval " ..i .." "..j, min = 1, max = 5, default = 1 }
      queue_add_param{ type = "number", id = "velocity " ..i .." "..j, name = "velocity " ..i .." "..j, min = 0, max = 127, default = 127 }
queue_add_param{ 
  type = "option", 
  id = "length " ..i .." "..j, 
  name = "length " ..i .." "..j, 
  options = {"1/4", "1/2", "1", "2", "4"}, 
  default = 1 
}      queue_add_param{ type = "number", id = "octave " ..i .." "..j, name = "octave " ..i .." "..j, min = 1, max = 4, default = 1 }
      queue_add_param{ type = "number", id = "gate probability " ..i .." "..j, name = "gate probability " ..i .." "..j, min = 0, max = 100, default = 100 }
      queue_add_param{ type = "number", id = "interval probability " ..i .." "..j, name = "interval probability " ..i .." "..j, min = 0, max = 100, default = 100 }
      queue_add_param{ type = "number", id = "octave probability " ..i .." "..j, name = "octave probability " ..i .." "..j, min = 0, max = 100, default = 100 }
      queue_add_param{ type = "number", id = "velocity probability " ..i .." "..j, name = "velocity probability " ..i .." "..j, min = 0, max = 100, default = 100 }
      queue_add_param{ type = "number", id = "length probability " ..i .." "..j, name = "velocity probability " ..i .." " ..j, min = 0, max = 100, default = 100 }
    end

dequeue_param_group("steps " ..i)

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

current_interval_step = {}
current_octave_step = {}
current_gate = {}
current_interval = {}
current_interval_1 = 1
current_interval_2 = 1
current_interval_3 = 1
current_interval_4 = 1
previous_interval_1 = 1
previous_interval_2 = 1
previous_interval_3 = 1
previous_interval_4 = 1
current_octave = {}
current_octave_1 = 1
current_octave_2 = 1
current_octave_3 = 1
current_octave_4 = 1
previous_octave_1 = 1
previous_octave_2 = 1
previous_octave_3 = 1
previous_octave_4 = 1

current_velocity_1 = 1
current_velocity_2 = 1
current_velocity_3 = 1
current_velocity_4 = 1
previous_velocity_1 = 1
previous_velocity_2 = 1
previous_velocity_3 = 1
previous_velocity_4 = 1

current_length_1 = 1
current_length_2 = 1
current_length_3 = 1
current_length_4 = 1
previous_length_1 = 1
previous_length_2 = 1
previous_length_3 = 1
previous_length_4 = 1

current_velocity = {}
current_length = {}
current_note = {}
current_channel = {}

algebra = {}

function algebra.init()
  params:set("clock_tempo", 120)
  m = midi.connect()
  for i = 1,4,1 do
  current_interval_step[i] = 0
  current_octave_step[i] = 0
  m:all_off()
end
end

function interval_tick(i)
if (params:get("interval sequence start " ..i) < params:get("current interval step " ..i)) and (params:get("current interval step " ..i) < params:get("interval sequence end " ..i))

  then

  params:set(("current interval step " ..i), params:get("current interval step " ..i) + 1)

elseif params:get("current interval step " ..i) >= params:get("interval sequence end " ..i)

  then

  params:set(("current interval step " ..i), params:get("interval sequence start " ..i))

elseif params:get("current interval step " ..i) < params:get("interval sequence start " ..i)

  then

  params:set(("current interval step " ..i), params:get("interval sequence start " ..i))

elseif params:get("current interval step " ..i) == params:get("interval sequence start " ..i)

  then

  params:set(("current interval step " ..i), params:get("current interval step " ..i) + 1)

end
end

function octave_tick(i)
if (params:get("octave sequence start " ..i) < params:get("current octave step " ..i)) and (params:get("current octave step " ..i) < params:get("octave sequence end " ..i))

  then

  params:set(("current octave step " ..i), params:get("current octave step " ..i) + 1)

elseif params:get("current octave step " ..i) >= params:get("octave sequence end " ..i)

  then

  params:set(("current octave step " ..i), params:get("octave sequence start " ..i))

elseif params:get("current octave step " ..i) < params:get("octave sequence start " ..i)

  then

  params:set(("current octave step " ..i), params:get("octave sequence start " ..i))

elseif params:get("current octave step " ..i) == params:get("octave sequence start " ..i)

  then

  params:set(("current octave step " ..i), params:get("current octave step " ..i) + 1)

elseif params:get("current octave step " ..i) > params:get("octave sequence end " ..i)

  then

  params:set(("current octave step " ..i), params:get("octave sequence start " ..i))

params:get("octave sequence end " ..i)

end
end

function velocity_tick(i)
if (params:get("velocity sequence start " ..i) < params:get("current velocity step " ..i)) and (params:get("current velocity step " ..i) < params:get("velocity sequence end " ..i))

  then

  params:set(("current velocity step " ..i), params:get("current velocity step " ..i) + 1)

elseif params:get("current velocity step " ..i) >= params:get("velocity sequence end " ..i)

  then

  params:set(("current velocity step " ..i), params:get("velocity sequence start " ..i))

elseif params:get("current velocity step " ..i) < params:get("velocity sequence start " ..i)

  then

  params:set(("current velocity step " ..i), params:get("velocity sequence start " ..i))

elseif params:get("current velocity step " ..i) == params:get("velocity sequence start " ..i)

  then

  params:set(("current velocity step " ..i), params:get("current velocity step " ..i) + 1)

elseif params:get("current velocity step " ..i) > params:get("velocity sequence end " ..i)

  then

  params:set(("current velocity step " ..i), params:get("velocity sequence start " ..i))

end
end

function length_tick(i)
if (params:get("length sequence start " ..i) < params:get("current length step " ..i)) and (params:get("current length step " ..i) < params:get("length sequence end " ..i))

  then

  params:set(("current length step " ..i), params:get("current length step " ..i) + 1)

elseif params:get("current length step " ..i) >= params:get("length sequence end " ..i)

  then

  params:set(("current length step " ..i), params:get("length sequence start " ..i))

elseif params:get("current length step " ..i) < params:get("length sequence start " ..i)

  then

  params:set(("current length step " ..i), params:get("length sequence start " ..i))

elseif params:get("current length step " ..i) == params:get("length sequence start " ..i)

  then

  params:set(("current length step " ..i), params:get("current length step " ..i) + 1)

elseif params:get("current length step " ..i) > params:get("length sequence end " ..i)

  then

  params:set(("current length step " ..i), params:get("length sequence start " ..i))

end
end


function tick(i)
    step = step + 1
    local current_inner_index = {}
    local current_octave = {}
    local current_offset = {}
if (params:get("gate sequence start " ..i) < params:get("current gate step " ..i)) and (params:get("current gate step " ..i) < params:get("gate sequence end " ..i))

	then

	params:set(("current gate step " ..i), params:get("current gate step " ..i) + 1)

elseif params:get("current gate step " ..i) >= params:get("gate sequence end " ..i)

	then

	params:set(("current gate step " ..i), params:get("gate sequence start " ..i))

elseif params:get("current gate step " ..i) < params:get("gate sequence start " ..i)

	then

	params:set(("current gate step " ..i), params:get("gate sequence start " ..i))

elseif params:get("current gate step " ..i) == params:get("gate sequence start " ..i)

	then

	params:set(("current gate step " ..i), params:get("current gate step " ..i) + 1)

end

      local outer_index = 1 + params:get("transpose")
      local carving = params:get("carving " ..i) * 7
      
      if math.random(1,100) <= params:get("interval probability " ..i .." " .. params:get("current interval step " ..i)) and params:get("gate " ..i .." " ..params:get("current gate step " ..i)) == 1 then
      if i == 1 then
      current_interval_1 = params:get("interval " .. i .. " " .. params:get("current interval step " ..i))
      elseif i == 2 then
        current_interval_2 = params:get("interval " .. i .. " " .. params:get("current interval step " ..i))
      elseif i == 3 then
        current_interval_3 = params:get("interval " .. i .. " " .. params:get("current interval step " ..i))
      elseif i == 4 then
        current_interval_4 = params:get("interval " .. i .. " " .. params:get("current interval step " ..i))
      end
      elseif i == 1 then
      current_interval_1 = previous_interval_1
      elseif i == 2 then
      current_interval_2 = previous_interval_2
      elseif i == 3 then
      current_interval_3 = previous_interval_3
      elseif i == 4 then
      current_interval_4 = previous_interval_4
      end
      if i == 1 then interval = current_interval_1
      elseif i == 2 then interval = current_interval_2
      elseif i == 3 then interval = current_interval_3
      elseif i == 4 then interval = current_interval_4
      end
      
      if math.random(1,100) <= params:get("octave probability " ..i .." " .. params:get("current octave step " ..i)) and params:get("gate " ..i .." " ..params:get("current gate step " ..i)) == 1 then

          if i == 1 then
              current_octave_1 = params:get("track octave " ..i) + params:get("octave " .. i .. " " .. params:get("current octave step " ..i))
              elseif i == 2 then
              current_octave_2 = params:get("track octave " ..i) + params:get("octave " .. i .. " " .. params:get("current octave step " ..i))
              elseif i == 3 then
              current_octave_3 = params:get("track octave " ..i) + params:get("octave " .. i .. " " .. params:get("current octave step " ..i))
              elseif i == 4 then
              current_octave_4 = params:get("track octave " ..i) + params:get("octave " .. i .. " " .. params:get("current octave step " ..i))
          end
          
          elseif i == 1 then
          current_octave_1 = previous_octave_1
          elseif i == 2 then
          current_octave_2 = previous_octave_2
          elseif i == 3 then
          current_octave_3 = previous_octave_3
          elseif i == 4 then
          current_octave_4 = previous_octave_4
        
      end
      
      if i == 1 then octave = current_octave_1
          elseif i == 2 then octave = current_octave_2
          elseif i == 3 then octave = current_octave_3
          elseif i == 4 then octave = current_octave_4
          end
    
    if math.random(1,100) <= params:get("length probability " ..i .." " .. params:get("current length step " ..i)) and params:get("gate " ..i .." " ..params:get("current gate step " ..i)) == 1 then
if i == 1 then
current_length_1 = params:get("length " .. i .. " " .. params:get("current length step " ..i))
elseif i == 2 then
  current_length_2 = params:get("length " .. i .. " " .. params:get("current length step " ..i))
elseif i == 3 then
  current_length_3 = params:get("length " .. i .. " " .. params:get("current length step " ..i))
elseif i == 4 then
  current_length_4 = params:get("length " .. i .. " " .. params:get("current length step " ..i))
end
elseif i == 1 then
current_length_1 = previous_length_1
elseif i == 2 then
current_length_2 = previous_length_2
elseif i == 3 then
current_length_3 = previous_length_3
elseif i == 4 then
current_length_4 = previous_length_4
end
if i == 1 then length = current_length_1
elseif i == 2 then length = current_length_2
elseif i == 3 then length = current_length_3
elseif i == 4 then length = current_length_4
end

if math.random(1,100) <= params:get("velocity probability " ..i .." " .. params:get("current velocity step " ..i)) and params:get("gate " ..i .." " ..params:get("current gate step " ..i)) == 1 then
if i == 1 then
current_velocity_1 = params:get("velocity " .. i .. " " .. params:get("current velocity step " ..i))
elseif i == 2 then
  current_velocity_2 = params:get("velocity " .. i .. " " .. params:get("current velocity step " ..i))
elseif i == 3 then
  current_velocity_3 = params:get("velocity " .. i .. " " .. params:get("current velocity step " ..i))
elseif i == 4 then
  current_velocity_4 = params:get("velocity " .. i .. " " .. params:get("current velocity step " ..i))
end
elseif i == 1 then
current_velocity_1 = previous_velocity_1
elseif i == 2 then
current_velocity_2 = previous_velocity_2
elseif i == 3 then
current_velocity_3 = previous_velocity_3
elseif i == 4 then
current_velocity_4 = previous_velocity_4
end
if i == 1 then velocity = current_velocity_1
elseif i == 2 then velocity = current_velocity_2
elseif i == 3 then velocity = current_velocity_3
elseif i == 4 then velocity = current_velocity_4
end
      
      local inner_index = (carving + interval)
      current_inner_index[i] = inner_index
      current_interval[i] = params:get("offset") + (params:get('key') + (collection_0[outer_index][inner_index] + 24) + ( 7 * params:get("transposition " ..i))) % 12
      current_offset[i] = offset_list[params:get("offset mode")][params:get("offset " ..i)]
      current_note[i] = current_interval[i] + octave * 12 + current_offset[i]
      current_channel[i] = params:get("midi channel " ..i)
            if  i == 1 then
        if
        params:get("gate 1 " ..params:get("current gate step 1")) == 1 then play(current_note[i], velocity, length_values[length], current_channel[i], 1)
          end
              previous_interval_1 = current_interval_1
              previous_octave_1 = current_octave_1
              previous_length_1 = current_length_1
              previous_velocity_1 = current_velocity_1
      elseif i == 2 then
        if
        params:get("gate 2 " ..params:get("current gate step 2")) == 1 then play(current_note[i], velocity, length_values[length]
, current_channel[i], 2)
      end
previous_interval_2 = current_interval_2
previous_octave_2 = current_octave_2
previous_length_2 = current_length_2
previous_velocity_2 = current_velocity_2

      elseif i == 3 then
        if
        params:get("gate 3 " ..params:get("current gate step 3")) == 1 then play(current_note[i], velocity, length_values[length]
, current_channel[i], 3) 
      end
previous_interval_3 = current_interval_3
previous_octave_3 = current_octave_3
previous_length_3 = current_length_3
previous_velocity_3 = current_velocity_3

      elseif i == 4 then
        if
        params:get("gate 4 " ..params:get("current gate step 4")) == 1 then play(current_note[i], velocity, length_values[length], current_channel[i], 4) end
previous_interval_4 = current_interval_4
previous_octave_4 = current_octave_4
previous_length_4 = current_length_4
previous_velocity_4 = current_velocity_4

      end

end

function play(note, vel, length, channel, track)
  if math.random(1, 100) <= params:get('probability ' ..track) and params:get("track active " ..track) >= 1 then
    if math.random(1,100) <= params:get('gate probability 1 ' ..params:get("current gate step 1" )) then
      notes.play[params:get('output '..track)](note, vel, length, channel, track)
    end 
  end
  print(velocity, current_velocity_1, previous_velocity_1, current_velocity_2, previous_velocity_2)
end
