-- cw v 0.2
--
-- k2 to randomize
-- k3 to spin that shit
--
-- or stop it spinning
--
-- if you get the spins

include 'lib/notes'
include 'lib/algebra'
lattice = require("lattice")
include 'lib/pset_sequencer'

transposition_center = 0
write_preset = 0
change_preset = 0

g = grid.connect()

function init()
  pset_seq.init()
  notes.init()
  create_the_collection()
  grid_dirty = true
  clock.run(grid_redraw_clock)
  for i = 1,4 do
    previous_offset[i] = params:get('offset ' ..i)
  end
  range = {}
    for trait = 1,7 do
      range[trait] = {}
        for track = 1,4 do
          range[trait][track] = {1, 6, held = 0}
        end
    end

  colorwheel_lattice = lattice:new{
    auto = true,
    meter = 4,
    ppqn = 96
  }

  tracks = {}
  for x = 1, 4 do
    tracks[x] = {}
    tracks[x].gate = {}
    tracks[x].interval = {}
    tracks[x].octave = {}
    tracks[x].velocity = {}
    tracks[x].length = {}
    tracks[x].alt = {}
  end


  for x = 1, 4 do
    tracks[x].gate = colorwheel_lattice:new_pattern{
      action = function(t) trait_tick("gate", x, tracks[x].gate, t)
        if change_preset >= 1 then
          params:set('load_pset', change_preset)
          change_preset = 0
          create_the_collection()
        end
      end,
      division = params:get("gate div " ..x) * params:get("global clock div") / 32
    }
    tracks[x].interval = colorwheel_lattice:new_pattern{
      action = function(t) trait_tick("interval", x, tracks[x].interval, t) end,
      division = params:get("interval div " ..x) * params:get("global clock div") / 32
    }
   tracks[x].octave = colorwheel_lattice:new_pattern{
      action = function(t) trait_tick("octave", x, tracks[x].octave, t) end,
      division = params:get("octave div " ..x) * params:get("global clock div") / 32
    }
    tracks[x].velocity = colorwheel_lattice:new_pattern{
      action = function(t) trait_tick("velocity", x, tracks[x].velocity, t) end,
      division = params:get("velocity div " ..x) * params:get("global clock div") / 32
    }
    tracks[x].length = colorwheel_lattice:new_pattern{
      action = function(t) trait_tick("length", x, tracks[x].length, t) end,
      division = params:get('length div ' ..x) * params:get("global clock div") / 32
    }
    tracks[x].alt = colorwheel_lattice:new_pattern{
      action = function(t) trait_tick("alt note", x, tracks[x].alt, t) end,
      division = params:get('alt note div ' ..x) * params:get("global clock div") / 32
    }


  end
  
  midi_delay_clock = colorwheel_lattice:new_pattern{
    action = function(t) delay_tick() end,
    division = params:get("global clock div") / 8
    
  }
  
  -- start the lattice
  colorwheel_lattice:start()

for i = 1,4,1 do
    for key,value in pairs(note_traits.current) do
      params:set("current " ..key.. " step " ..i, 0)
    end
end

end

function grid_redraw_clock()
  while true do
    clock.sleep(1/30)
    if grid_dirty then
      grid_redraw()
      grid_dirty = false
    end
    for i = 1,4 do
      if previous_offset[i] ~= params:get('offset ' ..i)
        then offset_flourish(i)
      end
    end
  end
end

function redraw()
      screen.move(0, 10)
      screen.font_size(8)
    screen.text("You are now spinning" )
    screen.move(20,37)
    screen.font_size(16)
    screen.text("colorwheel")
    screen.move(0, 60)
    screen.font_size(8)
    screen.text("the wheeeeeeeeeeel of color.")
    screen.update()
end

navigation_bar = {
  ["displayed_track"] = 1,
  ["displayed_trait"] = 1,
  ["mod_keys"] = {0,0,0},
  ["sequence_or_live"] = 0,
  ["backlights"] = {5,5,5,5,0,5,5,5,5,5,0,5,5,5,0,5}
}

trait_dummies = { "gate", "interval", "octave", "velocity", "length", "ratchet", "alt note" }

global_transpose = {
  ["x"] = {},
  ["y"] = {}
}

momentary_jumps = {}
for x = 9,12 do
  momentary_jumps[x] = {}
end

inverted_transpose = {}

previous_offset = {}

for x = 9,14 do
  inverted_transpose[x] = {}
    for y = 7,8 do
      inverted_transpose[x][y] = {}
    end
  end

global_transpose.x[0] = 9
global_transpose.y[0] = 7
global_transpose.x[1] = 13
global_transpose.y[1] = 8
global_transpose.x[2] = 11
global_transpose.y[2] = 7
global_transpose.x[3] = 11
global_transpose.y[3] = 8
global_transpose.x[4] = 13
global_transpose.y[4] = 7
global_transpose.x[5] = 9
global_transpose.y[5] = 8
global_transpose.x[6] = 14
global_transpose.y[6] = 8
global_transpose.x[7] = 10
global_transpose.y[7] = 7
global_transpose.x[8] = 12
global_transpose.y[8] = 8
global_transpose.x[9] = 12
global_transpose.y[9] = 7
global_transpose.x[10] = 10
global_transpose.y[10] = 8
global_transpose.x[11] = 14
global_transpose.y[11] = 7

inverted_transpose[9][7] = 0
inverted_transpose[13][8] = 1
inverted_transpose[11][7] = 2
inverted_transpose[11][8] = 3
inverted_transpose[13][7] = 4
inverted_transpose[9][8] = 5
inverted_transpose[14][8] = 6
inverted_transpose[10][7] = 7
inverted_transpose[12][8] = 8
inverted_transpose[12][7] = 9
inverted_transpose[10][8] = 10
inverted_transpose[14][7] = 11

momentary_loop = false
momentary_time = false
momentary_prob = false

function return_to_root()
    params:set('key', 0)
    params:set('transpose', 0)
    print("Live transposition nullified!")
end

function restart_sequences()
  for i = 1,4,1 do
    params:set("current gate step " ..i, 0)
    params:set("current interval step " ..i, 0)
    params:set("current octave step " ..i, 0)
    params:set("current velocity step " ..i, 0)
    params:set("current length step " ..i, 0)
  end
  print('back to the one!')
  end

  function clock_sync()
  for i = 1,4,1
  do params:set("gate div " ..i, 4)
     params:set("interval div " ..i, 4)
     params:set("octave div " ..i, 4)
     params:set("length div " ..i, 4)
     params:set("velocity div " ..i, 4)
  end
  print('clocks aligned!')
  end

function grid_redraw()
  if navigation_bar.sequence_or_live == 0 then -- seq page should be under this

    set_up_the_nav_bar()

    if navigation_bar.displayed_trait == 1 then
      set_up_the_gate_page()

      elseif navigation_bar.displayed_trait == 2 then
        set_up_the_interval_page(navigation_bar.displayed_track)

      elseif navigation_bar.displayed_trait == 3 then
        set_up_the_octave_page(navigation_bar.displayed_track)

      elseif navigation_bar.displayed_trait == 4 then
        set_up_the_velocity_page(navigation_bar.displayed_track)

      elseif navigation_bar.displayed_trait == 5 then
        set_up_the_length_page(navigation_bar.displayed_track)

      elseif navigation_bar.displayed_trait == 7 then
        set_up_the_alt_note_page(navigation_bar.displayed_track)

    end

    if momentary_prob then
      set_up_the_prob_page(trait_dummies[navigation_bar.displayed_trait], navigation_bar.displayed_track)
    end

    if momentary_time then
      set_up_the_gate_clock_page()
    end

  end -- seq page should be above this

  if navigation_bar.sequence_or_live == 1 then

    g:all(0)
    g:led(16, 8, 5)

    set_up_the_live_page()

  end -- live page should be above this

  if navigation_bar.sequence_or_live == 2 then

    set_up_the_meta_sequencer_page()

  end

  g:refresh()

end

function randomize()
  transposition_center = math.random(-2,2)
  -- for i = 1,4,1 do
  --   for key,value in pairs(note_traits.current) do
  --     params:set(key.. " sequence end " ..i, math.random(1,16))
  --     params:set(key.. " div " ..i, math.random(1,5))
  --   end

  for j = 1,16,1 do
      params:set("gate " ..i .." "..j, math.random(0,1))
      params:set("interval " ..i .." "..j, math.random (1, 5))
      params:set("alt note " ..i .." " ..j, math.random(0,4))
      params:set("octave " ..i .." "..j, math.random(1,2))
      params:set("velocity " ..i .." "..j, math.random(2, 5))
      -- params:set("length " ..i .." "..j, math.random(1,5))
      -- params:set("carving " ..i, math.random(1,4))
      -- params:set("offset " ..i, params:get("offset " ..i) + math.random(-1,1))
      -- params:set("transposition " ..i, transposition_center + math.random(-1,1))
  end
      params:set("gate " ..i .." 1", 1)

  end
end

function key(n,z)
  if n == 2 and z == 1 then
    randomize()
    print('randomizing!')
  end
  if n == 3 and z == 1 then
    if colorwheel_lattice.enabled then
      clock.transport.stop()
    else
      clock.transport.start()
    end
  end
  grid_dirty = true
end

function clock.transport.stop()
  colorwheel_lattice:stop()
end


function clock.transport.start()
  colorwheel_lattice:start()
end


position = clock.get_tempo()

function enc(n,d)
  if n == 2 then
    position = util.clamp(position + d,1,300)
    params:set("clock_tempo",position)
    print("clock tempo is now " ..clock.get_tempo())
  end
end

function g.key(x,y,z)

  if x == 16 and y == 8 and z == 1 then -- toggle between sequence, live, and 'meta-sequence'
    sequence_or_live_toggle()
  end

  if navigation_bar.sequence_or_live == 0 then -- this is all for the sequencer pages!

      if y == 8 then -- this is all for the seq nav bar!
        if x <= 4 and z == 1 then
          navigation_bar.displayed_track = x
        elseif x == 7 and navigation_bar.displayed_trait == 2 and z == 1 then
          navigation_bar.displayed_trait = 7
        elseif x <= 10 and x >= 6 and z == 1 then
          navigation_bar.displayed_trait = x - 5
        elseif x == 12 then
          if z == 1 then
            momentary_loop = true
          else
            momentary_loop = false
          end
        elseif x == 13 then
          if z == 1 and momentary_time == false then
            momentary_time = true
          elseif z == 1 and momentary_time == true then
            momentary_time = false
          end
        elseif x == 14 then
          if z == 1 then
            momentary_prob = true
          else
            momentary_prob = false
          end
        end
     end

  if not momentary_time and not momentary_prob then -- if no mod keys are pressed

    if momentary_loop and navigation_bar.displayed_trait == 1 and y <= 4 then
      change_start_point(x,y,z,1,y)

    elseif z == 1 then
      if navigation_bar.displayed_trait == 1 then -- this is all for the 'traits' pages
        if y <= 4 then
          gate_toggle(x, y, z)
        end

        if y == 8 and x >= 12 and x <= 14 then
          activate_modifier(x,y,z)
        end

      elseif navigation_bar.displayed_trait == 2 then
        if y <= 5 then
          change_interval(x, y, z, navigation_bar.displayed_track)
        end

      elseif navigation_bar.displayed_trait == 3 then
        if y >= 2 and y <= 5 then
          change_octave(x,y,z,navigation_bar.displayed_track)
        end

        if y == 1 and x <= 6 then
          change_track_octave(x,z,navigation_bar.displayed_track)
        end

      elseif navigation_bar.displayed_trait == 4 then
        if y <= 5 then
          change_velocity(x,y,z,navigation_bar.displayed_track)
        end

      elseif navigation_bar.displayed_trait == 5 then
        if y <= 5 then
          change_length(x,y,z,navigation_bar.displayed_track)
        end

      elseif navigation_bar.displayed_trait == 7 then
        if y <= 5 then
          change_alt_note(x,y,z, navigation_bar.displayed_track)
        end
     end
    end

    if navigation_bar.displayed_trait >= 2 then
      if y == 6 then
        change_start_point(x,y,z,navigation_bar.displayed_trait,navigation_bar.displayed_track)
      end
      if y == 7 and z == 1 then
        change_div(x,y,z,navigation_bar.displayed_trait,navigation_bar.displayed_track)
      end
    end

  elseif momentary_time and navigation_bar.displayed_trait == 1 then
    if y <= 4 then
      change_gate_clock_div(x, y)
    end
    if y == 6 then
      params:set("output slot " ..math.floor((x - 1) / 4) + 1, (x - math.floor((x - 1) / 4) * 4) % 5)
    end
  elseif momentary_prob then
    change_the_step_probability(x, y, z, trait_dummies[navigation_bar.displayed_trait], navigation_bar.displayed_track)
  end
end -- all seq stuff should be above this line

  if navigation_bar.sequence_or_live == 1 then
    if z == 1 then

    if x == 5 and y == 7 then
      clock_sync()
    end

    if x == 6 and y == 7 then
      restart_sequences()
    end

    if x == 7 and y == 7 then
      return_to_root()
    end

    if y <= 6 and y >= 2 and x <= 4
      then params:set('offset ' ..x, 7 - y)
    end

    if y <= 6 and y >= 2 and x >= 5 and x <= 8
      then params:set('transposition ' ..(x - 4), 4 - y)
    end

    if y <= 5 and y >= 2 and x >= 9 and x <= 12
      then params:set('carving ' ..(x - 8), 5 - y)
    end

    if y <= 6 and y >= 2 and x >= 13 and x <= 16
      then params:set('probability ' ..(x - 12), (6 - y) * 25)
    end
    end

    if y == 1 then
      for i = 1,5 do
        if i ~= 3 then
            for j = 1,4 do
              change_start_point(x,y,z,i,j)
            end
        end
      end
    end


    if y == 7 and x == 1 and z == 1 then
      params:set('offset mode', params:get('offset mode') % 2 + 1)
    end

    if y >= 7 and x <= 14 and x >= 9 and z == 1 then
      params:set('transpose', inverted_transpose[x][y])
    end

    if y == 6 and x <= 12 and x >= 9 then
      momentary_jumps[x] = z
    end

    if y == 7 and x <= 7 and x >= 5 then
      momentary_jumps[x] = z
    end

    if y == 8 and x <=8 then
      params:set("global clock div", x)
    end

  end

  if navigation_bar.sequence_or_live == 2 then

    if y == 8 and x == 14 and z == 1 then
      if params:get("pset_seq_enabled") >= 2 then
        params:set("pset_seq_enabled", 1)
      else
        params:set("pset_seq_enabled", 2)
      end
      end

    if y == 8 and x == 10 then
      write_preset = z
    end

    if x >= 13 and y <= 6 and z == 1 then
      if write_preset == 1 then
        params:write((y - 1) * 4 + x - 12, ((y - 1) * 4 + x - 12))
      else
        if colorwheel_lattice.enabled then
          change_preset = (y - 1) * 4 + x - 12
          else params:set('load_pset', (y - 1) * 4 + x - 12)
          create_the_collection()
        end
        print(params:get('load_pset'))
      end
    end

    if y == 7 then
      params:set('pset_seq_beats', x)
    end

    if y == 8 and x <= 4 then
      params:set('pset_seq_beats_per_bar', x)
    end

    if x <= 12 then
    if y == 2 then
      params:set("third", x - 1)
      create_the_collection()
    end

    if y == 3 then
      params:set("sixth", x -1)
      create_the_collection()
    end

    if y == 4 then
      params:set("second", x - 1)
      create_the_collection()
    end

    if y == 5 then
      params:set("fifth", x - 1)
      create_the_collection()
    end

    if y == 6 then
      params:set("root", x - 1)
      create_the_collection()
    end
    end

  end


    grid_dirty = true
end


function set_up_the_nav_bar()
  g:all(0)
  if navigation_bar.sequence_or_live == 0 then
  for i = 1,16,1 do
    g:led(i, 8, navigation_bar.backlights[i])
  end
    if momentary_loop then
      g:led(12, 8, 10)
    end
    if momentary_time then
      g:led(13, 8, 10)
    end
    if momentary_prob then
      g:led(14, 8, 10)
    end
      g:led(navigation_bar.displayed_track, 8, 10)
      if navigation_bar.displayed_trait <= 5 then
      g:led(navigation_bar.displayed_trait + 5, 8, 10)
      elseif navigation_bar.displayed_trait > 5 then
      g:led(navigation_bar.displayed_trait % 5 + 5, 8, 15)
      end
    end
  g:led(16, 8, 5)
end

function sequence_or_live_toggle()
  navigation_bar.sequence_or_live = (navigation_bar.sequence_or_live + 1) % 2
  print(navigation_bar.sequence_or_live)
end

function set_up_the_live_page(x,y,z)
  for i = 1,4 do
    g:led(i, 7 - params:get('offset ' ..i), 8)
    g:led(i + 4, 4 - params:get('transposition ' ..i), 12)
    g:led(i + 8, 5 - params:get('carving ' ..i), 8)
    g:led(i + 12, 6 - math.floor(params:get('probability ' ..i) / 25), 12)
  end

    g:led(1, 7, params:get('offset mode') * 4)

  for x = 9,14 do
    for y = 7,8 do
      g:led(x,y,2)
    end
  end

  g:led(global_transpose.x[params:get('transpose')], global_transpose.y[params:get('transpose')], 12)
  g:led(9, 6, 3)
  g:led(12, 6, 3)
  g:led(10, 6, 3)
  g:led(11, 6, 3)

  for x = 5,7 do
    g:led (x, 7, 7)
  end

  for x = 5,7 do
    if momentary_jumps[x] == 1 then
      g:led(x, 7, 12)
    end
  end

  for x = 1,8 do
    g:led(x, 8, 3)
  end

  g:led(params:get("global clock div"), 8, 12)

  for x = params:get('gate sequence start 1'), params:get('gate sequence end 1') do
    g:led(x, 1, 8)
  end

end

function set_up_the_gate_page()
if not momentary_prob and not momentary_time then -- if no mod keys are pressed
    for y = 1,4,1 do
      for x = 1,16,1 do
        if x >= params:get('gate sequence start ' ..y) and x <= params:get('gate sequence end ' ..y) then
          g:led(x,y,4)
        end
        if params:get('gate ' ..y.. ' ' ..x) == 1 then
          if x >= params:get('gate sequence start ' ..y) and x <= params:get('gate sequence end ' ..y) then
            g:led(x,y,10)
          else
            g:led(x,y,3)
          end
        end
      end
    if params:get('current gate step ' ..y) == params:get('gate sequence start ' ..y) then
      g:led(params:get('gate sequence end ' ..y), y, 15)
    else
    g:led(params:get('current gate step ' ..y) - 1, y, 15)
    end
  end
end
end

function set_up_the_meta_sequencer_page()
  g:all(0)
  g:led(16, 8, 5)
  g:led(10,8,6 + 9 * write_preset)
  if params:get("pset_seq_enabled") >= 2 then
    g:led(14, 8, 15)
  else
    g:led(14, 8, 6)
  end
  for i = 1, 16 do
    g:led(i, 7, 4)
  end
  g:led(params:get('pset_seq_beats'), 7, 15)
  for i = 1,4 do
    g:led(i, 8, 4)
  end
  g:led(params:get('pset_seq_beats_per_bar'), 8, 15)
  for i = params:get('pset_exclusion_first'), params:get('pset_exclusion_last') do
    g:led((i - 1) % 4 + 13, math.floor((i - 1) / 4 + 1), 6)
  end
  if params:get('load_pset') <= 24 then
    g:led((params:get('load_pset') - 1) % 4 + 13, math.floor((params:get('load_pset') - 1) / 4 + 1), 15)
  end
  g:led(params:get("root") + 1, 6, 4)
  g:led(params:get("fifth") + 1, 5, 4)
  g:led(params:get("second") + 1, 4, 4)
  g:led(params:get("sixth") + 1, 3, 4)
  g:led(params:get("third") + 1, 2, 4)
  for y = 2,6 do
    g:led(1, y, 4)
  end
  for x = 2, 12 do
    if x <= params:get("root") then
      g:led(x, 6, 2)
    end
    if x <= params:get("fifth") then
      g:led(x, 5, 2)
    end
    if x <= params:get("second") then
      g:led(x, 4, 2)
    end
    if x <= params:get("sixth") then
      g:led(x, 3, 2)
    end
    if x <= params:get("third") then
      g:led(x, 2, 2)
    end

  end

end

function set_up_the_interval_page(track)
    build_the_interval_display_table(track)
  if not momentary_prob and not momentary_time then -- if no mod keys are pressed
    for x = 1,16,1 do
      g:led(x, 6 - display_interval[track][x], 2)
    end
    for x = params:get('interval sequence start ' ..track), params:get('interval sequence end ' ..track),1 do
      g:led(x, 6-display_interval[track][x], 15)
    end
    for x = params:get('interval sequence start ' ..track), params:get('interval sequence end ' ..track) do
      g:led(x, 6, 4)
    end
        if params:get('current interval step ' ..track) == params:get('interval sequence start ' ..track) then
      g:led(params:get('interval sequence end ' ..track), 6, 15)
    else
    g:led(params:get('current interval step ' ..track) - 1, 6, 15)
    end
    g:led(params:get('interval div ' ..track), 7, 4)
        end

end


function build_the_interval_display_table(track)
    interval_display_table = {}
    interval_display_table[track] = {}
    interval_display_table_unsorted = {}
    interval_display_table_unsorted[track] = {}
    local inner_index = {}
    local outer_index = 1 + params:get("transpose")
    local carving = params:get("carving " ..track) * 7
    for i = 1,5 do
      inner_index[i] = (carving + i)
      interval_display_table[track][i]  = params:get("offset") + (params:get('key') + (collection_0[outer_index][inner_index[i]] + 24) + ( 7 * params:get("transposition " ..track))) % 12
      interval_display_table_unsorted[track][i] = interval_display_table[track][i]
    end
    table.sort(interval_display_table[track])
    local inner_index_var = 0
    interval_all_spelled_out = {}
    display_interval = {}
    display_interval[track] = {}
    for x = 1,16 do
      inner_index_var = carving + params:get('interval ' ..track.. ' ' ..x)
      interval_all_spelled_out[x] = params:get("offset") + (params:get('key') + (collection_0[outer_index][inner_index_var] + 24) + ( 7 * params:get("transposition " ..track))) % 12
      display_interval[track][x] = get_key_for_value(interval_display_table[track], interval_all_spelled_out[x])
    end
end

function set_up_the_octave_page(track)
  if not momentary_prob and not momentary_time then -- if no mod keys are pressed
    for x = 1,6 do
      g:led(x, 1, 6)
    end
    g:led(params:get('track octave ' ..track), 1, 12)
    for x = 1,16 do
      g:led(x, 6 - params:get('octave ' ..track.. ' ' ..x), 2)
    end
    for x = params:get('octave sequence start ' ..track), params:get('octave sequence end ' ..track),1 do
      g:led(x, 6-params:get('octave ' ..track.. ' ' ..x), 15)
    end

    for x = params:get('octave sequence start ' ..track), params:get('octave sequence end ' ..track) do
      g:led(x, 6, 4)
    end
        if params:get('current octave step ' ..track) == params:get('octave sequence start ' ..track) then
      g:led(params:get('octave sequence end ' ..track), 6, 15)
    else
    g:led(params:get('current octave step ' ..track) - 1, 6, 15)
        end    g:led(params:get('octave div ' ..track), 7, 4)
      end

end

function set_up_the_velocity_page(track)
if not momentary_prob and not momentary_time then -- if no mod keys are pressed
    local k = {}
    for x = 1,16,1 do
      k[x] = params:get('velocity ' ..track.. ' ' ..x)
      g:led(x, 6 - k[x], 2)
    end
    for x = params:get('velocity sequence start ' ..track), params:get('velocity sequence end ' ..track),1 do
      g:led(x, 6-k[x], 15)
    end
    for x = params:get('velocity sequence start ' ..track), params:get('velocity sequence end ' ..track) do
      g:led(x, 6, 4)
    end
        if params:get('current velocity step ' ..track) == params:get('velocity sequence start ' ..track) then
      g:led(params:get('velocity sequence end ' ..track), 6, 15)
    else
    g:led(params:get('current velocity step ' ..track) - 1, 6, 15)
        end    g:led(params:get('velocity div ' ..track), 7, 4)
      end

end

function set_up_the_length_page(track)
  if not momentary_prob and not momentary_time then -- if no mod keys are pressed
   local k = {}
    for x = 1,16,1 do
      k[x] = params:get('length ' ..track.. ' ' ..x)
      g:led(x, 6 - k[x], 2)
    end
    for x = params:get('length sequence start ' ..track), params:get('length sequence end ' ..track),1 do
      g:led(x, 6-k[x], 15)
    end
    for x = params:get('length sequence start ' ..track), params:get('length sequence end ' ..track) do
      g:led(x, 6, 4)
    end
        if params:get('current length step ' ..track) == params:get('length sequence start ' ..track) then
      g:led(params:get('length sequence end ' ..track), 6, 15)
    else
    g:led(params:get('current length step ' ..track) - 1, 6, 15)
        end    g:led(params:get('length div ' ..track), 7, 4)
      end

end

function set_up_the_alt_note_page(track)
    if not momentary_prob and not momentary_time then -- if no mod keys are pressed
      for x = 1,16,1 do
        g:led(x, 5 - params:get('alt note ' ..track.. ' ' ..x), 15)
      end
    for x = params:get('alt note sequence start ' ..track), params:get('alt note sequence end ' ..track) do
      g:led(x, 6, 4)
    end
      if params:get('current alt note step ' ..track) == params:get('alt note sequence start ' ..track) then
        g:led(params:get('alt note sequence end ' ..track), 6, 12)
      else
        g:led(params:get('current alt note step ' ..track) - 1, 6, 12)
      end
    g:led(params:get('alt note div ' ..track), 7, 4)
    end
end


function set_up_the_prob_page(trait, track)
  for x = 1,16 do
    g:led(x, math.floor(5 - (params:get(trait.. ' probability ' ..track.. ' ' ..x) / 25)) , 15)
  end
end

function set_up_the_gate_clock_page()
  if not momentary_prob then 
    for y = 1,4 do
      g:led(params:get('gate div ' ..y), y, 8)
    end
      for x = 1,4 do
        g:led(x,6,6)
      end
      for x = 5,8 do
        g:led(x,6, 2)
      end
      for x = 9,12 do
        g:led(x,6,6)
      end
      for x = 13,16 do
        g:led(x,6, 2)
      end  
    for output_track = 1,4 do
      g:led((output_track - 1) * 4 + params:get("output slot " ..output_track), 6, 12)
    end
  end
end


function gate_toggle(x,y,z)
  if z == 1 then
    if params:get('gate ' ..y.. ' ' ..x) == 1 then
      params:set('gate ' ..y.. ' ' ..x, 0)
    else
      params:set('gate ' ..y.. ' ' ..x, 1)
    end
  end
  for i = 1, 16 do
    print(i, params:get('gate 1 ' ..i))
  end
end

function change_interval(x,y,z,track)
  if z == 1 then
    params:set(('interval ' ..track.. ' ' ..x), get_key_for_value(interval_display_table_unsorted[track], interval_display_table[track][6 - y]))
    params:set(('gate ' ..track.. ' ' ..x), 1)
  end
end

function change_octave(x,y,z,track)
  if z == 1 then
    params:set(('octave ' ..track.. ' ' ..x), 6 - y)
  end
end

function change_track_octave(x,z,track)
  if z == 1 then
    params:set(('track octave ' ..track), x)
  end
end

function change_velocity(x,y,z,track)
    if z == 1 then
    params:set(('velocity ' ..track.. ' ' ..x), 6 - y)
  end
end

function change_length(x,y,z,track)
  if z == 1 then
    params:set(('length ' ..track.. ' ' ..x), 6-y)
  end
end

function change_alt_note(x,y,z,track)
  if z == 1 then
    params:set(('alt note ' ..track.. ' ' ..x), 5 - y)
  end
end

function change_gate_clock_div(x, y)
  if y <= 4 then
    params:set('gate div ' ..y, x)
    tracks[y].gate_pattern:set_division(params:get('gate div ' ..y) / 32)
  end
end


function change_start_point(x,y,z,trait,track)
   if z == 1 then
     range[trait][track].held = range[trait][track].held + 1
     local difference = range[trait][track][2] - range[trait][track][1]
     local original = {range[trait][track][1], range[trait][track][2]}
     if range[trait][track].held == 1 then
       range[trait][track][1] = x
       range[trait][track][2] = x
     elseif range[trait][track].held == 2 then
       range[trait][track][2] = x
       table.sort(range[trait][track])
       params:set((trait_dummies[trait].. ' sequence start ' ..track), range[trait][track][1])
     params:set((trait_dummies[trait].. ' sequence end ' ..track), range[trait][track][2])
     end
  end
    if z == 0 then
  range[trait][track].held = range[trait][track].held - 1
end

end

function change_div(x,y,z,trait,track)
  params:set((trait_dummies[trait].. ' div ' ..track), x)
end

function change_global_div(x,y,z)
  params:set("global clock div", x)
end

function change_the_step_probability(x,y,z,trait,track)
  if y <= 5 then
    params:set((trait.. ' probability ' ..track.. ' ' ..x), (5 - y) * 25)
  end
end

function activate_modifier(x,y,z)
  if z == 1 then
    g:led(x,y,15)
  end
  if z == 0 then
    g:led(x,y,8)
  end
end

function get_key_for_value( t, value )
  for k,v in pairs(t) do
    if v==value then return k end
  end
  return nil
end
