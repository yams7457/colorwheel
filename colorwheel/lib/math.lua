music_util = require("musicutil")

m = midi.connect()

  params:add_group("meta",18)

params:add{ type = "number", id = "key", name = "key", min = 0, max = 11, default = 0 }
params:add{ type = "number", id = "offset", name = "offset", min = 0, max = 11, default = 0 }
params:add{ type = "number", id = "transpose", name = "transpose", min = 0, max = 11, default = 0 }
params:add{ type = "number", id = "offset mode", name = "offset mode", min = 1, max = 2, default = 2 }
params:add{ type = "number", id = "bernoulli chance", name = "Bernoulli Chance", min = 0, max = 100, default = 50 }
params:add{ type = "number", id = "track link mode", name = "track link mode", min = 1, max = 3, default = 1 }
for i = 1,4,1
  do
params:add{ type = "number", id = "midi channel " ..i, name = "midi channel " ..i, min = 1, max = 16, default = 1 }
params:add{ type = "number", id = "track active " ..i, name = "track active " ..i, min = 0, max = 1, default = 1 }
end

  params:add_group("tracks",56)

for i = 1,4,1
  do
params:add{ type = "number", id = "midi channel " ..i, name = "midi channel " ..i, min = 1, max = 16, default = 1 }
params:add{ type = "number", id = "track active " ..i, name = "track active " ..i, min = 0, max = 1, default = 1 }
params:add{ type = "number", id = "track octave " ..i, name = "track octave " ..i, min = 1, max = 6, default = i + 2 }
params:add{ type = "number", id = "offset " ..i, name = "offset " ..i, min = 1, max = 5, default = math.random(2, 4)}
params:add{ type = "number", id = "transposition " ..i, name = "transposition " ..i, min = -2, max = 2, default = math.random(-2, 2)}
params:add{ type = "number", id = "carving " ..i, name = "carving " ..i, min = 0, max = 3, default = math.random (0,3) }
params:add{ type = "number", id = "probabilities " ..i, name = "probabilities " ..i, min = 1, max = 5, default = 1 }
params:add{ type = "number", id = "clock channel " ..i, name = "clock channel " ..i, min = 1, max = 4, default = 1 }
params:add{ type = "number", id = "gate sequence start " ..i, name = "gate sequence start " ..i, min = 1, max = 16, default = math.random(1, 6)}
params:add{ type = "number", id = "interval sequence start " ..i, name = "interval sequence start " ..i, min = 1, max = 16, default = math.random(1, 6)}
params:add{ type = "number", id = "octave sequence start " ..i, name = "octave sequence start " ..i, min = 1, max = 16, default = math.random (1, 6) }
params:add{ type = "number", id = "gate sequence end " ..i, name = "gate sequence end " ..i, min = 1, max = 16, default = math.random(9, 16)}
params:add{ type = "number", id = "interval sequence end " ..i, name = "interval sequence end " ..i, min = 1, max = 16, default = math.random(9, 16)}
params:add{ type = "number", id = "octave sequence end " ..i, name = "octave sequence end " ..i, min = 1, max = 16, default = math.random (9, 16) }


end

  params:add_group("steps",192)

for i = 1,4,1 do

    for j = 1,16,1 do

      params:add{ type = "number", id = "gate " ..i .." "..j, name = "gate " ..i .." "..j, min = 0, max = 1, default = math.random(0, 1)}
      params:add{ type = "number", id = "interval " ..i .." "..j, name = "interval " ..i .." "..j, min = 1, max = 5, default = math.random (1, 5) }
      params:add{ type = "number", id = "octave " ..i .." "..j, name = "octave " ..i .." "..j, min = 1, max = 4, default = 1 }

    end

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

current_gate_step = {}
current_interval_step = {}
current_octave_step = {}
current_gate = {}
current_interval = {}
current_octave = {}
current_note = {}
current_channel = {}

function init()
  clock_id = clock.run(tick)
  params:set("clock_tempo",math.random(30, 200))
  m = midi.connect()
  for i = 1,4,1 do
  current_gate_step[i] = 0
  current_interval_step[i] = 0
  current_octave_step[i] = 0
  m:all_off()
  krit004.init()
end
end

function tick()
  while true do
  clock.sync(1/2)
  step = step + 1
  local current_inner_index = {}
  local current_octave = {}
  local current_offset = {}
  for i=1,4,1 do
  current_gate_step[i] = (((current_gate_step[i]) % (params:get("gate sequence end " ..i))) - (params:get("gate sequence start " ..i))) 
  + 1 + (params:get("gate sequence start " ..i))
  current_interval_step[i] = (((current_interval_step[i]) % (params:get("interval sequence end " ..i))) - (params:get("interval sequence start " ..i))) + 1 + (params:get("interval sequence start " ..i))
  current_octave_step[i] = (((current_octave_step[i]) % (params:get("octave sequence end " ..i))) - (params:get("octave sequence start " ..i))) + 1 + (params:get("octave sequence start " ..i))
    local outer_index = 1 + params:get("transpose")
    local carving = params:get("carving " ..i) * 7
    local interval = params:get("interval " .. i .. " " .. current_interval_step[i])
    local inner_index = (carving + interval)
    current_inner_index[i] = inner_index
    current_interval[i] = params:get("offset") + ((collection_0[outer_index][inner_index] + 24) + ( 7 * params:get("transposition " ..i))) % 12
    current_octave[i] = (params:get("track octave " ..i) + params:get("octave " ..i .. " " .. current_octave_step[i])) * 12
    current_offset[i] = offset_list[params:get("offset mode")][params:get("offset " ..i)]
    current_note[i] = current_interval[i] + current_octave[i] + current_offset[i]
    current_channel[i] = params:get("midi channel " ..i)
    play(current_note[i], math.random(60, 127) - current_note[i], current_channel[i], 1)

  end
end
end

function play(note, vel, channel, track)
  --print(note, vel, channel, track)
  m:note_on(note, vel, channel)
  clock.run(
    function()
      clock.sleep(1)
          m:note_off(note, vel, channel)
end
)
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