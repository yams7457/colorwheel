music_util = require("musicutil")

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
params:add{ type = "number", id = "track octave " ..i, name = "track octave " ..i, min = 0, max = 5, default = 0 }
end

  params:add_group("tracks",44)

for i = 1,4,1
  do
params:add{ type = "number", id = "midi channel " ..i, name = "midi channel " ..i, min = 1, max = 16, default = 1 }
params:add{ type = "number", id = "track active " ..i, name = "track active " ..i, min = 0, max = 1, default = 1 }
params:add{ type = "number", id = "track octave " ..i, name = "track octave " ..i, min = 0, max = 5, default = 0 }
params:add{ type = "number", id = "offset " ..i, name = "offset " ..i, min = 0, max = 4, default = 2 }
params:add{ type = "number", id = "transposition " ..i, name = "transposition " ..i, min = -2, max = 2, default = 0}
params:add{ type = "number", id = "carving " ..i, name = "carving " ..i, min = 0, max = 4, default = 4 }
params:add{ type = "number", id = "probabilities " ..i, name = "probabilities " ..i, min = 1, max = 5, default = 1 }
params:add{ type = "number", id = "clock channel " ..i, name = "clock channel " ..i, min = 1, max = 4, default = 1 }
params:add{ type = "number", id = "gate sequence length " ..i, name = "gate sequence length " ..i, min = 1, max = 16, default = math.random (1, 16) }
params:add{ type = "number", id = "interval sequence length " ..i, name = "interval sequence length " ..i, min = 1, max = 16, default = math.random (1, 16) }
params:add{ type = "number", id = "octave sequence length " ..i, name = "octave sequence length " ..i, min = 1, max = 16, default = math.random (1, 16) }
end

  params:add_group("steps",192)

for i = 1,4,1 do

    for j = 1,16,1 do

      params:add{ type = "number", id = "gate " ..i .." "..j, name = "gate " ..i .." "..j, min = 0, max = 1, default = math.random (0, 1) }
      params:add{ type = "number", id = "interval " ..i .." "..j, name = "interval " ..i .." "..j, min = 1, max = 7, default = math.random (1, 7) }
      params:add{ type = "number", id = "octave " ..i .." "..j, name = "octave " ..i .." "..j, min = 1, max = 7, default = math.random (1, 7) }

    end

end

step = 0

collection_0_1 =
  {{0,7,12,19,24,31,36},
  {2,7,14,19,26,31,38},
  {2,9,14,21,26,33,38},
  {4,9,16,21,28,33,40},
  {4,11,16,23,28,35,40},
  {6,11,18,23,30,35,42},
  {0,5,12,17,24,29,36},
  {5,10,17,22,29,34,41},
  {3,10,15,22,27,34,39},
  {3,8,15,20,27,32,39},
  {1,8,13,20,25,32,37},
  {1,6,13,18,25,30,37}}

collection_0_2 =
    {{0,2,7,12,14,19,24},
    {2,7,9,14,19,21,26},
    {2,4,9,14,16,21,26},
    {4,9,11,16,21,23,28},
    {4,6,11,16,18,23,28},
    {1,6,11,13,18,23,25},
    {0,5,7,12,17,19,24},
    {0,5,10,12,17,22,24},
    {3,5,10,15,17,22,27},
    {3,8,10,15,20,22,27},
    {1,3,8,13,15,20,25},
    {1,6,8,13,18,20,25}}

collection_0_3 =
      {{0,2,7,9,12,14,19},
      {2,4,7,9,14,16,19},
      {2,4,9,11,14,16,21},
      {4,6,9,11,16,18,21},
      {1,4,6,11,13,16,18},
      {1,6,8,11,13,18,20},
      {0,2,5,7,12,14,17},
      {0,5,7,10,12,17,19},
      {0,3,5,10,12,15,17},
      {3,5,8,10,15,17,20},
      {1,3,8,10,13,15,20},
      {1,3,6,8,13,15,18}}

  collection_0_4 =
        {{0,2,7,9,12,14,19},
        {2,4,7,9,14,16,19},
        {2,4,9,11,14,16,21},
        {4,6,9,11,16,18,21},
        {1,4,6,11,13,16,18},
        {1,6,8,11,13,18,20},
        {0,2,5,7,12,14,17},
        {0,5,7,10,12,17,19},
        {0,3,5,10,12,15,17},
        {3,5,8,10,15,17,20},
        {1,3,8,10,13,15,20},
        {1,3,6,8,13,15,18}}

        collection_0_5 =
          {{0,2,4,7,9,12,14},
          {2,4,7,9,11,14,16},
          {2,4,6,9,11,14,16},
          {1,4,6,9,11,13,16},
          {1,4,6,8,11,13,16},
          {1,3,6,8,1,13,15},
          {0,2,5,7,9,12,14},
          {0,2,5,7,10,12,14},
          {0,3,5,7,10,12,15},
          {0,3,5,8,10,12,15},
          {1,3,5,8,10,13,15},
          {1,3,6,8,10,13,15}}

offset_list = {{0,5,12,17,24},{0,7,12,19,24}}

current_gate_step = {}
current_interval_step = {}
current_octave_step = {}
current_gate = {}
current_interval = {}
current_octave = {}
current_note = {}

function init()
  clock_id = clock.run(tick)
  m = midi.connect()
  for i = 1,4,1 do
  current_gate_step[i] = 0
  current_interval_step[i] = 0
  current_octave_step[i] = 0
end
end

function tick()
  while true do
  clock.sync(1)
  step = step + 1
  local current_inner_index = {}
  for i=1,4,1 do
  current_gate_step[i] = (current_gate_step[i]) % params:get("gate sequence length " ..i) + 1
  current_interval_step[i] = (current_interval_step[i] ) % params:get("interval sequence length " ..i) + 1
  current_octave_step[i] = (current_octave_step[i] ) % params:get("octave sequence length " ..i)  + 1
  if current_gate_step[i] then
    local outer_index = 1 + params:get("transpose")
    local inner_index = params:get("interval " ..i .." " ..current_interval_step[i])
    current_inner_index[i] = inner_index
    current_interval[i] = (collection_0_..params:get("carving " ..i)[outer_index][current_inner_index[i]]) % 12
    print(current_interval[i])
    end
  end
end
end