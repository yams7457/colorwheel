-- RGB in this emmer effer
--
-- k2 to randomize
-- k3 to spin that shit
--
-- or stop it spinning
-- 
-- for if you get the spins

include 'lib/core'
include 'lib/norns'
include 'lib/grid'
include 'lib/algebra'
lattice = require("lib/lattice")

g = grid.connect()

--gridwork

velocity_values = { 0, 32, 64, 96, 127 }
length_values = {1/4, 1/2, 1, 2, 4}



function key(n,z)
  if n == 3 and z == 1 then
    my_lattice:toggle()
  else if n == 2 and z == 1 then
    randomize()
    print('randomizing!')
  end
  end
  seqorlive.seq:update()
end

function down_a_fifth()
   params:set('transpose', (params:get('transpose') + 5) % 12)
end
          
function up_a_fifth()
    params:set('transpose', (params:get('transpose') + 7) % 12)
end

function return_to_root()
    params:set('transpose', 0)
end

function return_to_c()
    params:set('key', 0)
end

function restart_sequences()
  for i = 1,4,1 do
    params:set("current gate step " ..i, 0)
    params:set("current interval step " ..i, 2)
    params:set("current octave step " ..i, 2)
    params:set("current velocity step " ..i, 2)
    params:set("current length step " ..i, 2)
  end 
  print('back to the one!')
  seqorlive.seq:update()
  end

function randomize()
for i = 1,4,1
  do
params:set("gate div " ..i, math.random (1, 6))
params:set("interval div " ..i, math.random (1, 6))
params:set("octave div " ..i, math.random (1, 6))
params:set("gate sequence start " ..i, math.random(1, 8))
params:set("interval sequence start " ..i, math.random(1, 8))
params:set("octave sequence start " ..i, math.random (1, 8))
params:set("velocity sequence start " ..i, math.random(1,8))
params:set("gate sequence end " ..i, math.random(params:get("gate sequence start " ..i) + 3, 16))
params:set("interval sequence end " ..i, math.random(params:get("interval sequence start " ..i) + 3, 16))
params:set("octave sequence end " ..i, math.random (params:get("octave sequence start " ..i) + 3, 16))
params:set("velocity sequence end " ..i, math.random (params:get("velocity sequence start " ..i) + 3, 16))
params:set("length sequence end " ..i, math.random (params:get("length sequence start " ..i) + 3, 16))
params:set("offset " ..i, (params:get("offset " ..i) + math.random(-1,1) - 1) % 5 + 1)
params:set("transposition " ..i, ((params:get("transposition " ..i) + (math.random(-1, 1)) + 2) % 5 - 2))

for j = 1,16,1 do

params:set("gate " ..i .." "..j, math.random(0, 1))
params:set("interval " ..i .." "..j, math.random (1, 5))
params:set("velocity " ..i .." "..j, velocity_values[math.random (2, 5)])
end
end
end

function clock_sync()
  for i = 1,4,1
  do params:set("gate div " ..i, 1)
     params:set("interval div " ..i, 1)
     params:set("octave div " ..i, 1)
  end
  print('clocks aligned!')
  end

seqorlive = nest_ {
    meta = _grid.toggle {
      x = 16,
      y = 8,
      level = {4, 15}
},

seq = nest_ {
    enabled = function(self)
        return (seqorlive.meta.value == 0)
    end,

    loop_mod = _grid.momentary {
        x = 12,
        y = 8,
        level = {4, 15 } },

    time_mod = _grid.momentary {
        x = 13,
        y = 8,
        level = {4, 15} },

    prob_mod = _grid.momentary {
        x = 14,
        y = 8,
        level = {4, 15} },

    tab = _grid.number {
        x = {6, 10},
        y = 8,
        level = {4, 15} },

    track = _grid.number {
        x = {1, 4},
        y = 8,
        level = {4, 15},
        enabled = function(self)
            return (seqorlive.seq.loop_mod.value == 0)
        end
        },

                track_mute = nest_(4):each(function(i,v)

                return _grid.toggle {
                  x = i,
                  y = 8,
                  level = function(self)
                        if params:get('track active ' ..i) == 1 then return 7

                        else return 2
                       end
                    end,

                  controlspec = params:lookup_param('track active ' ..i).controlspec,
                  value = function() return params:get('track active ' ..i) end,
                  action = function(s,v,x) params:set('track active ' ..i, v)
                    end,

                  enabled = function(self)
                      return (seqorlive.seq.loop_mod.value == 1)
                  end,}end),


    gate_tab = nest_ {

        enabled = function(self)
            return (seqorlive.seq.tab.value == 1 and
                    seqorlive.seq.time_mod.value == 0)
        end,

        gate_page = nest_ {

            gaterange_1 = _grid.range {
                x = {1, 16},
                y = 1,
                z = -1,
                level = 4,

                value = function()
                    return { params:get('gate sequence start 1'), params:get('gate sequence end 1') }
                    end,

                action = function(s, v)
                    params:set('gate sequence start 1', v[1])
                    params:set('gate sequence end 1', v[2])
                    end,

                enabled = function(self)
                    return (seqorlive.seq.loop_mod.value == 1 and
                            seqorlive.seq.time_mod.value == 0 and
                            seqorlive.seq.prob_mod.value == 0)
                end},

            gaterange_2 = _grid.range {
                x = {1, 16},
                y = 2,
                z = -1,
                level = 4,

                value = function()
                    return { params:get('gate sequence start 2'), params:get('gate sequence end 2') }
                    end,

                action = function(s, v)
                    params:set('gate sequence start 2', v[1])
                    params:set('gate sequence end 2', v[2])
                    end,

                enabled = function(self)
                    return (seqorlive.seq.loop_mod.value == 1 and
                            seqorlive.seq.time_mod.value == 0 and
                            seqorlive.seq.prob_mod.value == 0)
                    end},

            gaterange_3 = _grid.range {
                x = {1, 16},
                y = 3,
                z = -1,
                level = 4,

                value = function()
                    return { params:get('gate sequence start 3'), params:get('gate sequence end 3') }
                    end,

                action = function(s, v)
                    params:set('gate sequence start 3', v[1])
                    params:set('gate sequence end 3', v[2])
                    end,

                enabled = function(self)
                    return (seqorlive.seq.loop_mod.value == 1 and
                            seqorlive.seq.time_mod.value == 0 and
                            seqorlive.seq.prob_mod.value == 0)
                end},

            gaterange_4 = _grid.range {
                x = {1, 16},
                y = 4,
                z = -1,
                level = 4,

                value = function()
                    return { params:get('gate sequence start 4'), params:get('gate sequence end 4') }
                    end,

                action = function(s, v)
                    params:set('gate sequence start 4', v[1])
                    params:set('gate sequence end 4', v[2])
                    end,

                enabled = function(self)
                    return (seqorlive.seq.loop_mod.value == 1 and
                            seqorlive.seq.time_mod.value == 0 and
                            seqorlive.seq.prob_mod.value == 0)
                end},

gatefield_5 = nest_(16):each(function(i,v)

    return _grid.toggle {
      x = i,
      y = 1,
      level = function(self)
            if i == params:get('current gate step 1') then return 15

            elseif params:get('gate 1 ' ..i) == 1 then
              if i >= params:get('gate sequence start 1') then
                if i <= params:get('gate sequence end 1') then
                return 10
                end
                else return 2
                   end

            else return 0 end
            
            if params:get('gate 1 ' ..i) == 1 then
              if i > params:get('gate sequence end 1') then
                return 2
                end
            end
        end,
      controlspec = params:lookup_param('gate 1 ' ..i).controlspec,
      value = function() return params:get('gate 1 ' ..i) end,
      action = function(s,v) params:set('gate 1 ' ..i, v) end,

      enabled = function(self)
        return (seqorlive.seq.loop_mod.value == 0 and
                seqorlive.seq.time_mod.value == 0 and
                seqorlive.seq.prob_mod.value == 0)
      end,}end),

range_display_5 = nest_(16):each(function(i,v)

    return _grid.toggle {
        x = i,
        y = 1,
        value = 1,
        input = false,
    level = function(self)
        if i == params:get('current gate step 1') then return 15
        elseif params:get('gate 1 ' ..i) == 1 then return 0
        elseif i >= params:get('gate sequence start 1') then
          if i <= params:get('gate sequence end 1') then
          return 4
          else return 0
        end end end,
        enabled = function(self)
        return (seqorlive.seq.loop_mod.value == 0 and
                seqorlive.seq.time_mod.value == 0 and
                seqorlive.seq.prob_mod.value == 0)
      end,}end),

gatefield_6 = nest_(16):each(function(i,v)

    return _grid.toggle {
      x = i,
      y = 2,
      level = function(self)
            if i == params:get('current gate step 2') then return 15

            elseif params:get('gate 2 ' ..i) == 1 then
              if i >= params:get('gate sequence start 2') then
                if i <= params:get('gate sequence end 2') then
                return 10
                end
                else return 2
                   end

            else return 0 end
            
            if params:get('gate 2 ' ..i) == 1 then
              if i > params:get('gate sequence end 2') then
                return 2
                end
            end
        end,
      controlspec = params:lookup_param('gate 2 ' ..i).controlspec,
      value = function() return params:get('gate 2 ' ..i) end,
      action = function(s,v) params:set('gate 2 ' ..i, v) end,

      enabled = function(self)
        return (seqorlive.seq.loop_mod.value == 0 and
                seqorlive.seq.time_mod.value == 0 and
                seqorlive.seq.prob_mod.value == 0)
      end,}end),

range_display_6 = nest_(16):each(function(i,v)

    return _grid.toggle {
        x = i,
        y = 2,
        value = 1,
        input = false,
    level = function(self)
        if i == params:get('current gate step 2') then return 15
        elseif params:get('gate 2 ' ..i) == 1 then return 0
        elseif i >= params:get('gate sequence start 2') then
          if i <= params:get('gate sequence end 2') then
          return 4
          else return 0
        end end end,
        enabled = function(self)
        return (seqorlive.seq.loop_mod.value == 0 and
                seqorlive.seq.time_mod.value == 0 and
                seqorlive.seq.prob_mod.value == 0)
      end,}end),

gatefield_7 = nest_(16):each(function(i,v)

    return _grid.toggle {
      x = i,
      y = 3,
      level = function(self)
            if i == params:get('current gate step 3') then return 15

            elseif params:get('gate 3 ' ..i) == 1 then
              if i >= params:get('gate sequence start 3') then
                if i <= params:get('gate sequence end 3') then
                return 10
                end
                else return 2
                   end

            else return 0 end
            
            if params:get('gate 3 ' ..i) == 1 then
              if i > params:get('gate sequence end 3') then
                return 2
                end
            end
        end,
      controlspec = params:lookup_param('gate 3 ' ..i).controlspec,
      value = function() return params:get('gate 3 ' ..i) end,
      action = function(s,v) params:set('gate 3 ' ..i, v) end,

      enabled = function(self)
        return (seqorlive.seq.loop_mod.value == 0 and
                seqorlive.seq.time_mod.value == 0 and
                seqorlive.seq.prob_mod.value == 0)
      end,}end),

range_display_7 = nest_(16):each(function(i,v)

    return _grid.toggle {
        x = i,
        y = 3,
        value = 1,
        input = false,
    level = function(self)
        if i == params:get('current gate step 3') then return 15
        elseif params:get('gate 3 ' ..i) == 1 then return 0
        elseif i >= params:get('gate sequence start 3') then
          if i <= params:get('gate sequence end 3') then
          return 4
          else return 0
        end end end,
        enabled = function(self)
        return (seqorlive.seq.loop_mod.value == 0 and
                seqorlive.seq.time_mod.value == 0 and
                seqorlive.seq.prob_mod.value == 0)
      end,}end),

            gatefield_8 = nest_(16):each(function(i,v)

                return _grid.toggle {
                  x = i,
                  y = 4,
      level = function(self)
            if i == params:get('current gate step 4') then return 15

            elseif params:get('gate 4 ' ..i) == 1 then
              if i >= params:get('gate sequence start 4') then
                if i <= params:get('gate sequence end 4') then
                return 10
                end
                else return 2
                   end

            else return 0 end
            
            if params:get('gate 4 ' ..i) == 1 then
              if i > params:get('gate sequence end 4') then
                return 2
                end
            end
        end,
                  controlspec = params:lookup_param('gate 4 ' ..i).controlspec,
                  value = function() return params:get('gate 4 ' ..i) end,
                  action = function(s,v) params:set('gate 4 ' ..i, v) end,

                  enabled = function(self)
                    return (seqorlive.seq.loop_mod.value == 0 and
                            seqorlive.seq.time_mod.value == 0 and
                            seqorlive.seq.prob_mod.value == 0)
                  end,}end),

            range_display_8 = nest_(16):each(function(i,v)

                return _grid.toggle {
                    x = i,
                    y = 4,
                    value = 1,
                    input = false,
                level = function(self)
                    if i == params:get('current gate step 4') then return 15
                    elseif params:get('gate 4 ' ..i) == 1 then return 0
                    elseif i >= params:get('gate sequence start 4') then
                      if i <= params:get('gate sequence end 4') then
                      return 4
                      else return 0
                    end end end,
                    enabled = function(self)
                    return (seqorlive.seq.loop_mod.value == 0 and
                            seqorlive.seq.time_mod.value == 0 and
                            seqorlive.seq.prob_mod.value == 0)
                  end,}end),


    },

        gate_prob_1 = nest_(16):each(function(i,v)


                return _grid.number {
                    x = i,
                    y = {1, 5},
                    level = {0, 6},
                    controlspec = params:lookup_param('gate probability 1 ' ..i).controlspec,
                    value = function() return params:get('gate probability 1 ' ..i) / 25 + 1 end,
                    action = function(s, v) params:set('gate probability 1 ' ..i, (v - 1) * 25) end,
                enabled = function(self)
                    return (seqorlive.seq.loop_mod.value == 0 and
                            seqorlive.seq.time_mod.value == 0 and
                            seqorlive.seq.track.value == 1 and
                            seqorlive.seq.prob_mod.value == 1)
                    end,
                }end),

        gate_prob_2 = nest_(16):each(function(i,v)

                return _grid.number {
                    x = i,
                    y = {1, 5},
                    level = {0, 6},
                    controlspec = params:lookup_param('gate probability 2 ' ..i).controlspec,
                    value = function() return params:get('gate probability 2 ' ..i) / 25 + 1 end,
                    action = function(s, v) params:set('gate probability 2 ' ..i, (v - 1) * 25) end,

                enabled = function(self)
                    return (seqorlive.seq.loop_mod.value == 0 and
                            seqorlive.seq.time_mod.value == 0 and
                            seqorlive.seq.track.value == 2 and
                            seqorlive.seq.prob_mod.value == 1)
                    end,
                }end),

        gate_prob_3 = nest_(16):each(function(i,v)

                return _grid.number {
                    x = i,
                    y = {1, 5},
                    level = {0, 6},
                    controlspec = params:lookup_param('gate probability 3 ' ..i).controlspec,
                    value = function() return params:get('gate probability 3 ' ..i) / 25 + 1 end,
                    action = function(s, v) params:set('gate probability 3 ' ..i, (v - 1) * 25) end,
                enabled = function(self)
                    return (seqorlive.seq.loop_mod.value == 0 and
                            seqorlive.seq.time_mod.value == 0 and
                            seqorlive.seq.track.value == 3 and
                            seqorlive.seq.prob_mod.value == 1)
                    end,
                }end),

        gate_prob_4 = nest_(16):each(function(i,v)

                return _grid.number {
                    x = i,
                    y = {1, 5},
                    level = {0, 6},
                    controlspec = params:lookup_param('gate probability 4 ' ..i).controlspec,
                    value = function() return params:get('gate probability 4 ' ..i) / 25 + 1 end,
                    action = function(s, v) params:set('gate probability 4 ' ..i, (v - 1) * 25) end,
                enabled = function(self)
                    return (seqorlive.seq.loop_mod.value == 0 and
                            seqorlive.seq.time_mod.value == 0 and
                            seqorlive.seq.track.value == 4 and
                            seqorlive.seq.prob_mod.value == 1)
                    end,
                }end),


        }},

         gate_clocks = nest_(4):each(function(i,v)

            return _grid.number {
                x = {1, 16},
                y = i,
                level = {0,4},

                controlspec = params:lookup_param('gate div ' ..i).controlspec,
                value = function() return params:get('gate div ' ..i) end,
                action = function(s, v) params:set('gate div ' ..i, v) end,

            enabled = function(self)
                return (seqorlive.seq.tab.value == 1 and
                        seqorlive.seq.loop_mod.value == 0 and
                        seqorlive.seq.time_mod.value == 1 and
                        seqorlive.seq.prob_mod.value == 0)
                end}
                end),

--interval stuff starts here
    interval_tab_1 = nest_ {

        enabled = function(self)
            return (seqorlive.meta.value == 0 and
                    seqorlive.seq.tab.value == 2 and
                    seqorlive.seq.track.value == 1)
            end,

            interval_dots_1 = nest_(16):each(function(i,v)


                return _grid.number {
                    x = i,
                    y = {1, 5},
                    level = function(self)
                        if i == params:get('current interval step 1') then return 15
                        else return 4 end
                    end,
                    controlspec = params:lookup_param('interval 1 ' ..i).controlspec,
                    value = function() return params:get('interval 1 ' ..i) end,
                    action = function(s, v) params:set('interval 1 ' ..i, v) end,
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 0)
                        end
                }end),

            interval_prob_1 = nest_(16):each(function(i,v)


                return _grid.number {
                    x = i,
                    y = {1, 5},
                    level = {0, 6},
                    controlspec = params:lookup_param('interval probability 1 ' ..i).controlspec,
                    value = function() return params:get('interval probability 1 ' ..i) / 25 + 1 end,
                    action = function(s, v) params:set('interval probability 1 ' ..i, (v - 1) * 25) end,
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 1)
                        end
                }end),

            interval_clock_1 = _grid.number {
                x = {1, 16},
                y = 7,
                level = {0, 4},
                controlspec = params:lookup_param('interval div 1').controlspec,
                value = function() return params:get('interval div 1') end,
                action = function(s, v) params:set('interval div 1', v) end
            },

            interval_loop_1 = _grid.range {
                x = {1, 16},
                y = 6,
                level = {0, 4},

                value = function()
                    return { params:get('interval sequence start 1'), params:get('interval sequence end 1') }
                    end,

                action = function(s, v)
                    params:set('interval sequence start 1', v[1])
                    params:set('interval sequence end 1', v[2])
                    end,
            }



        },

    interval_tab_2 = nest_ {

        enabled = function(self)
            return (seqorlive.meta.value == 0 and
                    seqorlive.seq.tab.value == 2 and
                    seqorlive.seq.track.value == 2)
            end,

            interval_dots_2 = nest_(16):each(function(i,v)

                 return _grid.number {
                    x = i,
                    y = {1, 5},
                    level = function(self)
                        if i == params:get('current interval step 2') then return 15
                        else return 4 end
                    end,
                    controlspec = params:lookup_param('interval 2 ' ..i).controlspec,
                    value = function() return params:get('interval 2 ' ..i) end,
                    action = function(s, v) params:set('interval 2 ' ..i, v) end,
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 0)
                        end
                }end),

            interval_prob_2 = nest_(16):each(function(i,v)


                return _grid.number {
                    x = i,
                    y = {1, 5},
                    level = {0, 6},
                    controlspec = params:lookup_param('interval probability 2 ' ..i).controlspec,
                    value = function() return params:get('interval probability 2 ' ..i) / 25 + 1 end,
                    action = function(s, v) params:set('interval probability 2 ' ..i, (v - 1) * 25) end,
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 1)
                        end
                }end),

            interval_clock_2 = _grid.number {
                x = {1, 16},
                y = 7,
                level = {0, 4},
                controlspec = params:lookup_param('interval div 2').controlspec,
                value = function() return params:get('interval div 2') end,
                action = function(s, v) params:set('interval div 2', v) end
            },

            interval_loop_2 = _grid.range {
                x = {1, 16},
                y = 6,
                level = {0, 4},

                value = function()
                    return { params:get('interval sequence start 2'), params:get('interval sequence end 2') }
                    end,

                action = function(s, v)
                    params:set('interval sequence start 2', v[1])
                    params:set('interval sequence end 2', v[2])
                    end,
            }},



    interval_tab_3 = nest_ {

        enabled = function(self)
            return (seqorlive.meta.value == 0 and
                    seqorlive.seq.tab.value == 2 and
                    seqorlive.seq.track.value == 3)
            end,

            interval_dots_3 = nest_(16):each(function(i,v)

                return _grid.number {
                    x = i,
                    y = {1, 5},
                    level = function(self)
                        if i == params:get('current interval step 3') then return 15
                        else return 4 end
                    end,
                    controlspec = params:lookup_param('interval 3 ' ..i).controlspec,
                    value = function() return params:get('interval 3 ' ..i) end,
                    action = function(s, v) params:set('interval 3 ' ..i, v) end,
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 0)
                        end
                }end),

            interval_prob_3 = nest_(16):each(function(i,v)


                return _grid.number {
                    x = i,
                    y = {1, 5},
                    level = {0, 6},
                    controlspec = params:lookup_param('interval probability 3 ' ..i).controlspec,
                    value = function() return params:get('interval probability 3 ' ..i) / 25 + 1 end,
                    action = function(s, v) params:set('interval probability 3 ' ..i, (v - 1) * 25) end,
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 1)
                        end
                }end),

            interval_clock_3 = _grid.number {
                x = {1, 16},
                y = 7,
                level = {0, 4},
                controlspec = params:lookup_param('interval div 3').controlspec,
                value = function() return params:get('interval div 3') end,
                action = function(s, v) params:set('interval div 3', v) end
            },

            interval_loop_3 = _grid.range {
                x = {1, 16},
                y = 6,
                level = {0, 4},

                value = function()
                    return { params:get('interval sequence start 3'), params:get('interval sequence end 3') }
                    end,

                action = function(s, v)
                    params:set('interval sequence start 3', v[1])
                    params:set('interval sequence end 3', v[2])
                    end,
            }
    },

      interval_tab_4 = nest_ {

        enabled = function(self)
            return (seqorlive.meta.value == 0 and
                    seqorlive.seq.tab.value == 2 and
                    seqorlive.seq.track.value == 4)
            end,

            interval_dots_4 = nest_(16):each(function(i,v)

                return _grid.number {
                    x = i,
                    y = {1, 5},
                    level = function(self)
                        if i == params:get('current interval step 4') then return 15
                        else return 4 end
                    end,
                    controlspec = params:lookup_param('interval 4 ' ..i).controlspec,
                    value = function() return params:get('interval 4 ' ..i) end,
                    action = function(s, v) params:set('interval 4 ' ..i, v) end,
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 0)
                        end
                }end),

            interval_prob_4 = nest_(16):each(function(i,v)


                return _grid.number {
                    x = i,
                    y = {1, 5},
                    level = {0, 6},
                    controlspec = params:lookup_param('interval probability 4 ' ..i).controlspec,
                    value = function() return params:get('interval probability 4 ' ..i) / 25 + 1 end,
                    action = function(s, v) params:set('interval probability 4 ' ..i, (v - 1) * 25) end,
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 1)
                        end
                }end),

            interval_clock_4 = _grid.number {
                x = {1, 16},
                y = 7,
                level = {0, 4},
                controlspec = params:lookup_param('interval div 4').controlspec,
                value = function() return params:get('interval div 4') end,
                action = function(s, v) params:set('interval div 4', v) end
            },

            interval_loop_4 = _grid.range {
                x = {1, 16},
                y = 6,
                level = {0, 4},

                value = function()
                    return { params:get('interval sequence start 4'), params:get('interval sequence end 4') }
                    end,

                action = function(s, v)
                    params:set('interval sequence start 4', v[1])
                    params:set('interval sequence end 4', v[2])
                    end,
            }
    },

--here be octaves
    octave_tab_1 = nest_ {

        enabled = function(self)
            return (seqorlive.meta.value == 0 and
                    seqorlive.seq.tab.value == 3 and
                    seqorlive.seq.track.value == 1)
            end,

            octave_dots_1 = nest_(16):each(function(i,v)

                return _grid.number {
                    x = i,
                    y = {2, 5},
                    level = function(self)
                        if i == params:get('current octave step 1') then return 15
                        else return 4 end
                    end,
                    controlspec = params:lookup_param('octave 1 ' ..i).controlspec,
                    value = function() return params:get('octave 1 ' ..i) end,
                    action = function(s, v) params:set('octave 1 ' ..i, v) end,
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 0)
                        end
                }end),

            octave_prob_1 = nest_(16):each(function(i,v)


                return _grid.number {
                    x = i,
                    y = {1, 5},
                    level = {0, 6},
                    controlspec = params:lookup_param('octave probability 1 ' ..i).controlspec,
                    value = function() return params:get('octave probability 1 ' ..i) / 25 + 1 end,
                    action = function(s, v) params:set('octave probability 1 ' ..i, (v - 1) * 25) end,
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 1)
                        end
                }end),

            octave_clock_1 = _grid.number {
                x = {1, 16},
                y = 7,
                level = {0, 4},
                controlspec = params:lookup_param('octave div 1').controlspec,
                value = function() return params:get('octave div 1') end,
                action = function(s, v) params:set('octave div 1', v) end
            },

            octave_loop_1 = _grid.range {
                x = {1, 16},
                y = 6,
                level = {0, 4},

                value = function()
                    return { params:get('octave sequence start 1'), params:get('octave sequence end 1') }
                    end,

                action = function(s, v)
                    params:set('octave sequence start 1', v[1])
                    params:set('octave sequence end 1', v[2])
                    end,


            },

            octave_offset_1 = _grid.number {
                x = {1, 6},
                y = 1,
                level = {2, 4},
                controlspec = params:lookup_param('track octave 1').controlspec,
                value = function() return params:get('track octave 1') end,
                action = function(s, v) params:set('track octave 1', v) end,
                enabled = function(self)
                    return (seqorlive.seq.prob_mod.value == 0)
                    end
            }



        },

    octave_tab_2 = nest_ {

        enabled = function(self)
            return (seqorlive.meta.value == 0 and
                    seqorlive.seq.tab.value == 3 and
                    seqorlive.seq.track.value == 2)
            end,

            octave_dots_2 = nest_(16):each(function(i,v)

                return _grid.number {
                    x = i,
                    y = {2, 5},
                    level = function(self)
                        if i == params:get('current octave step 2') then return 15
                        else return 4 end
                    end,
                    controlspec = params:lookup_param('octave 2 ' ..i).controlspec,
                    value = function() return params:get('octave 2 ' ..i) end,
                    action = function(s, v) params:set('octave 2 ' ..i, v) end,
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 0)
                        end
                }end),

            octave_prob_2 = nest_(16):each(function(i,v)


                return _grid.number {
                    x = i,
                    y = {1, 5},
                    level = {0, 6},
                    controlspec = params:lookup_param('octave probability 2 ' ..i).controlspec,
                    value = function() return params:get('octave probability 2 ' ..i) / 25 + 1 end,
                    action = function(s, v) params:set('octave probability 2 ' ..i, (v - 1) * 25) end,
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 1)
                        end
                }end),

            octave_clock_2 = _grid.number {
                x = {1, 16},
                y = 7,
                level = {0, 4},
                controlspec = params:lookup_param('octave div 2').controlspec,
                value = function() return params:get('octave div 2') end,
                action = function(s, v) params:set('octave div 2', v) end
            },

            octave_loop_2 = _grid.range {
                x = {1, 16},
                y = 6,
                level = {0, 4},

                value = function()
                    return { params:get('octave sequence start 2'), params:get('octave sequence end 2') }
                    end,

                action = function(s, v)
                    params:set('octave sequence start 2', v[1])
                    params:set('octave sequence end 2', v[2])
                    end,
            },

            octave_offset_2 = _grid.number {
                x = {1, 6},
                y = 1,
                level = {2, 4},
                controlspec = params:lookup_param('track octave 2').controlspec,
                value = function() return params:get('track octave 2') end,
                action = function(s, v) params:set('track octave 2', v) end,
                enabled = function(self)
                    return (seqorlive.seq.prob_mod.value == 0)
                    end
            }


    },



    octave_tab_3 = nest_ {

        enabled = function(self)
            return (seqorlive.meta.value == 0 and
                    seqorlive.seq.tab.value == 3 and
                    seqorlive.seq.track.value == 3)
            end,

            octave_dots_3 = nest_(16):each(function(i,v)

                return _grid.number {
                    x = i,
                    y = {2, 5},
                    level = function(self)
                        if i == params:get('current octave step 3') then return 15
                        else return 4 end
                    end,
                    controlspec = params:lookup_param('octave 3 ' ..i).controlspec,
                    value = function() return params:get('octave 3 ' ..i) end,
                    action = function(s, v) params:set('octave 3 ' ..i, v) end,
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 0)
                        end
                }end),

            octave_prob_3 = nest_(16):each(function(i,v)


                return _grid.number {
                    x = i,
                    y = {1, 5},
                    level = {0, 6},
                    controlspec = params:lookup_param('octave probability 3 ' ..i).controlspec,
                    value = function() return params:get('octave probability 3 ' ..i) / 25 + 1 end,
                    action = function(s, v) params:set('octave probability 3 ' ..i, (v - 1) * 25) end,
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 1)
                        end
                }end),

            octave_clock_3 = _grid.number {
                x = {1, 16},
                y = 7,
                level = {0, 4},
                controlspec = params:lookup_param('octave div 3').controlspec,
                value = function() return params:get('octave div 3') end,
                action = function(s, v) params:set('octave div 3', v) end
            },

            octave_loop_3 = _grid.range {
                x = {1, 16},
                y = 6,
                level = {0, 4},

                value = function()
                    return { params:get('octave sequence start 3'), params:get('octave sequence end 3') }
                    end,

                action = function(s, v)
                    params:set('octave sequence start 3', v[1])
                    params:set('octave sequence end 3', v[2])
                    end,
            },

            octave_offset_3 = _grid.number {
                x = {1, 6},
                y = 1,
                level = {2, 4},
                controlspec = params:lookup_param('track octave 3').controlspec,
                value = function() return params:get('track octave 3') end,
                action = function(s, v) params:set('track octave 3', v) end,
                enabled = function(self)
                    return (seqorlive.seq.prob_mod.value == 0)
                    end
            }
    },

      octave_tab_4 = nest_ {

        enabled = function(self)
            return (seqorlive.meta.value == 0 and
                    seqorlive.seq.tab.value == 3 and
                    seqorlive.seq.track.value == 4)
            end,

            octave_dots_4 = nest_(16):each(function(i,v)

                return _grid.number {
                    x = i,
                    y = {2, 5},
                    level = function(self)
                        if i == params:get('current octave step 4') then return 15
                        else return 4 end
                    end,
                    controlspec = params:lookup_param('octave 4 ' ..i).controlspec,
                    value = function() return params:get('octave 4 ' ..i) end,
                    action = function(s, v) params:set('octave 4 ' ..i, v) end,
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 0)
                        end
                }end),

            octave_prob_4 = nest_(16):each(function(i,v)


                return _grid.number {
                    x = i,
                    y = {1, 5},
                    level = {0, 6},
                    controlspec = params:lookup_param('octave probability 4 ' ..i).controlspec,
                    value = function() return params:get('octave probability 4 ' ..i) / 25 + 1 end,
                    action = function(s, v) params:set('octave probability 4 ' ..i, (v - 1) * 25) end,                    
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 1)
                        end
                }end),

            octave_clock_4 = _grid.number {
                x = {1, 16},
                y = 7,
                level = {0, 4},
                controlspec = params:lookup_param('octave div 4').controlspec,
                value = function() return params:get('octave div 4') end,
                action = function(s, v) params:set('octave div 4', v) end
            },

            octave_loop_4 = _grid.range {
                x = {1, 16},
                y = 6,
                level = {0, 4},

                value = function()
                    return { params:get('octave sequence start 4'), params:get('octave sequence end 4') }
                    end,

                action = function(s, v)
                    params:set('octave sequence start 4', v[1])
                    params:set('octave sequence end 4', v[2])
                    end,
            },

            octave_offset_4 = _grid.number {
                x = {1, 6},
                y = 1,
                level = {2, 4},
                controlspec = params:lookup_param('track octave 4').controlspec,
                value = function() return params:get('track octave 4') end,
                action = function(s, v) params:set('track octave 4', v) end,
                enabled = function(self)
                    return (seqorlive.seq.prob_mod.value == 0)
                    end
            }
    },
  
  
  velocity_tab_1 = nest_ {

    enabled = function(self)
        return (seqorlive.meta.value == 0 and
                seqorlive.seq.tab.value == 4 and
                seqorlive.seq.track.value == 1)
        end,

        velocity_dots_1 = nest_(16):each(function(i,v)


            return _grid.number {
                x = i,
                y = {1, 5},
                level = function(self)
                    if i == params:get('current velocity step 1') then return 15
                    else return 4 end
                end,
                controlspec = params:lookup_param('velocity 1 ' ..i).controlspec,
                value = function() return math.floor( params:get('velocity 1 ' ..i) / 32 + 1.5) end,
                action = function(s, v) params:set('velocity 1 ' ..i, velocity_values[v]) end,
                enabled = function(self)
                    return (seqorlive.seq.prob_mod.value == 0)
                    end
            }end),

        velocity_prob_1 = nest_(16):each(function(i,v)


            return _grid.number {
                x = i,
                y = {1, 5},
                level = {0, 6},
                controlspec = params:lookup_param('velocity probability 1 ' ..i).controlspec,
                value = function() return params:get('velocity probability 1 ' ..i) / 25 + 1 end,
                action = function(s, v) params:set('velocity probability 1 ' ..i, (v - 1) * 25) end,
                enabled = function(self)
                    return (seqorlive.seq.prob_mod.value == 1)
                    end
            }end),

        velocity_clock_1 = _grid.number {
            x = {1, 16},
            y = 7,
            level = {0, 4},
            controlspec = params:lookup_param('velocity div 1').controlspec,
            value = function() return params:get('velocity div 1') end,
            action = function(s, v) params:set('velocity div 1', v) end
        },

        velocity_loop_1 = _grid.range {
            x = {1, 16},
            y = 6,
            level = {0, 4},

            value = function()
                return { params:get('velocity sequence start 1'), params:get('velocity sequence end 1') }
                end,

            action = function(s, v)
                params:set('velocity sequence start 1', v[1])
                params:set('velocity sequence end 1', v[2])
                end,
        }



    },

velocity_tab_2 = nest_ {

    enabled = function(self)
        return (seqorlive.meta.value == 0 and
                seqorlive.seq.tab.value == 4 and
                seqorlive.seq.track.value == 2)
        end,

        velocity_dots_2 = nest_(16):each(function(i,v)

             return _grid.number {
                x = i,
                y = {1, 5},
                level = function(self)
                    if i == params:get('current velocity step 2') then return 15
                    else return 4 end
                end,
controlspec = params:lookup_param('velocity 2 ' ..i).controlspec,
value = function() return math.floor( params:get('velocity 2 ' ..i) / 32 + 1.5) end,
action = function(s, v) params:set('velocity 2 ' ..i, velocity_values[v]) end,
enabled = function(self)
    return (seqorlive.seq.prob_mod.value == 0)
    end
}end),

        velocity_prob_2 = nest_(16):each(function(i,v)


            return _grid.number {
                x = i,
                y = {1, 5},
                level = {0, 6},
                controlspec = params:lookup_param('velocity probability 2 ' ..i).controlspec,
                value = function() return params:get('velocity probability 2 ' ..i) / 25 + 1 end,
                action = function(s, v) params:set('velocity probability 2 ' ..i, (v - 1) * 25) end,
                enabled = function(self)
                    return (seqorlive.seq.prob_mod.value == 1)
                    end
            }end),

        velocity_clock_2 = _grid.number {
            x = {1, 16},
            y = 7,
            level = {0, 4},
            controlspec = params:lookup_param('velocity div 2').controlspec,
            value = function() return params:get('velocity div 2') end,
            action = function(s, v) params:set('velocity div 2', v) end
        },

        velocity_loop_2 = _grid.range {
            x = {1, 16},
            y = 6,
            level = {0, 4},

            value = function()
                return { params:get('velocity sequence start 2'), params:get('velocity sequence end 2') }
                end,

            action = function(s, v)
                params:set('velocity sequence start 2', v[1])
                params:set('velocity sequence end 2', v[2])
                end,
        }},



velocity_tab_3 = nest_ {

    enabled = function(self)
        return (seqorlive.meta.value == 0 and
                seqorlive.seq.tab.value == 4 and
                seqorlive.seq.track.value == 3)
        end,

        velocity_dots_3 = nest_(16):each(function(i,v)

            return _grid.number {
                x = i,
                y = {1, 5},
                level = function(self)
                    if i == params:get('current velocity step 3') then return 15
                    else return 4 end
                end,
controlspec = params:lookup_param('velocity 3 ' ..i).controlspec,
value = function() return math.floor( params:get('velocity 3 ' ..i) / 32 + 1.5) end,
action = function(s, v) params:set('velocity 3 ' ..i, velocity_values[v]) end,
enabled = function(self)
    return (seqorlive.seq.prob_mod.value == 0)
    end
}end),

        velocity_prob_3 = nest_(16):each(function(i,v)


            return _grid.number {
                x = i,
                y = {1, 5},
                level = {0, 6},
                controlspec = params:lookup_param('velocity probability 3 ' ..i).controlspec,
                value = function() return params:get('velocity probability 3 ' ..i) / 25 + 1 end,
                action = function(s, v) params:set('velocity probability 3 ' ..i, (v - 1) * 25) end,
                enabled = function(self)
                    return (seqorlive.seq.prob_mod.value == 1)
                    end
            }end),

        velocity_clock_3 = _grid.number {
            x = {1, 16},
            y = 7,
            level = {0, 4},
            controlspec = params:lookup_param('velocity div 3').controlspec,
            value = function() return params:get('velocity div 3') end,
            action = function(s, v) params:set('velocity div 3', v) end
        },

        velocity_loop_3 = _grid.range {
            x = {1, 16},
            y = 6,
            level = {0, 4},

            value = function()
                return { params:get('velocity sequence start 3'), params:get('velocity sequence end 3') }
                end,

            action = function(s, v)
                params:set('velocity sequence start 3', v[1])
                params:set('velocity sequence end 3', v[2])
                end,
        }
},

  velocity_tab_4 = nest_ {

    enabled = function(self)
        return (seqorlive.meta.value == 0 and
                seqorlive.seq.tab.value == 4 and
                seqorlive.seq.track.value == 4)
        end,

        velocity_dots_4 = nest_(16):each(function(i,v)

            return _grid.number {
                x = i,
                y = {1, 5},
                level = function(self)
                    if i == params:get('current velocity step 1') then return 15
                    else return 4 end
                end,
controlspec = params:lookup_param('velocity 4 ' ..i).controlspec,
value = function() return math.floor( params:get('velocity 4 ' ..i) / 32 + 1.5) end,
action = function(s, v) params:set('velocity 4 ' ..i, velocity_values[v]) end,
enabled = function(self)
    return (seqorlive.seq.prob_mod.value == 0)
    end
}end),

        velocity_prob_4 = nest_(16):each(function(i,v)


            return _grid.number {
                x = i,
                y = {1, 5},
                level = {0, 6},
                controlspec = params:lookup_param('velocity probability 4 ' ..i).controlspec,
                value = function() return params:get('velocity probability 4 ' ..i) / 25 + 1 end,
                action = function(s, v) params:set('velocity probability 4 ' ..i, (v - 1) * 25) end,
                enabled = function(self)
                    return (seqorlive.seq.prob_mod.value == 1)
                    end
            }end),

        velocity_clock_4 = _grid.number {
            x = {1, 16},
            y = 7,
            level = {0, 4},
            controlspec = params:lookup_param('velocity div 4').controlspec,
            value = function() return params:get('velocity div 4') end,
            action = function(s, v) params:set('velocity div 4', v) end
        },

        velocity_loop_4 = _grid.range {
            x = {1, 16},
            y = 6,
            level = {0, 4},

            value = function()
                return { params:get('velocity sequence start 4'), params:get('velocity sequence end 4') }
                end,

            action = function(s, v)
                params:set('velocity sequence start 4', v[1])
                params:set('velocity sequence end 4', v[2])
                end,
        }
},

length_tab_1 = nest_ {

  enabled = function(self)
      return (seqorlive.meta.value == 0 and
              seqorlive.seq.tab.value == 5 and
              seqorlive.seq.track.value == 1)
      end,

      length_dots_1 = nest_(16):each(function(i,v)


          return _grid.number {
              x = i,
              y = {1, 5},
              level = function(self)
                  if i == params:get('current length step 1') then return 15
                  else return 4 end
              end,
              controlspec = params:lookup_param('length 1 ' ..i).controlspec,
              value = function() return params:get('length 1 ' ..i)
                end,
              action = function(s, v) params:set('length 1 ' ..i, v) end,
              enabled = function(self)
                  return (seqorlive.seq.prob_mod.value == 0)
                  end
          }end),

      length_prob_1 = nest_(16):each(function(i,v)


          return _grid.number {
              x = i,
              y = {1, 5},
              level = {0, 6},
              controlspec = params:lookup_param('length probability 1 ' ..i).controlspec,
              value = function() return params:get('length probability 1 ' ..i) / 25 + 1 end,
              action = function(s, v) params:set('length probability 1 ' ..i, (v - 1) * 25) end,
              enabled = function(self)
                  return (seqorlive.seq.prob_mod.value == 1)
                  end
          }end),

      length_clock_1 = _grid.number {
          x = {1, 16},
          y = 7,
          level = {0, 4},
          controlspec = params:lookup_param('length div 1').controlspec,
          value = function() return params:get('length div 1') end,
          action = function(s, v) params:set('length div 1', v) end
      },

      length_loop_1 = _grid.range {
          x = {1, 16},
          y = 6,
          level = {0, 4},

          value = function()
              return { params:get('length sequence start 1'), params:get('length sequence end 1') }
              end,

          action = function(s, v)
              params:set('length sequence start 1', v[1])
              params:set('length sequence end 1', v[2])
              end,
      }



  },

length_tab_2 = nest_ {

  enabled = function(self)
      return (seqorlive.meta.value == 0 and
              seqorlive.seq.tab.value == 5 and
              seqorlive.seq.track.value == 2)
      end,

      length_dots_2 = nest_(16):each(function(i,v)

           return _grid.number {
              x = i,
              y = {1, 5},
              level = function(self)
                  if i == params:get('current length step 2') then return 15
                  else return 4 end
              end,
controlspec = params:lookup_param('length 2 ' ..i).controlspec,
              value = function() return params:get('length 2 ' ..i)
                end,
              action = function(s, v) params:set('length 2 ' ..i, v) end,
enabled = function(self)
  return (seqorlive.seq.prob_mod.value == 0)
  end
}end),

      length_prob_2 = nest_(16):each(function(i,v)


          return _grid.number {
              x = i,
              y = {1, 5},
              level = {0, 6},
              controlspec = params:lookup_param('length probability 2 ' ..i).controlspec,
              value = function() return params:get('length probability 2 ' ..i) / 25 + 1 end,
              action = function(s, v) params:set('length probability 2 ' ..i, (v - 1) * 25) end,
              enabled = function(self)
                  return (seqorlive.seq.prob_mod.value == 1)
                  end
          }end),

      length_clock_2 = _grid.number {
          x = {1, 16},
          y = 7,
          level = {0, 4},
          controlspec = params:lookup_param('length div 2').controlspec,
          value = function() return params:get('length div 2') end,
          action = function(s, v) params:set('length div 2', v) end
      },

      length_loop_2 = _grid.range {
          x = {1, 16},
          y = 6,
          level = {0, 4},

          value = function()
              return { params:get('length sequence start 2'), params:get('length sequence end 2') }
              end,

          action = function(s, v)
              params:set('length sequence start 2', v[1])
              params:set('length sequence end 2', v[2])
              end,
      }},



length_tab_3 = nest_ {

  enabled = function(self)
      return (seqorlive.meta.value == 0 and
              seqorlive.seq.tab.value == 5 and
              seqorlive.seq.track.value == 3)
      end,

      length_dots_3 = nest_(16):each(function(i,v)

          return _grid.number {
              x = i,
              y = {1, 5},
              level = function(self)
                  if i == params:get('current length step 3') then return 15
                  else return 4 end
              end,
controlspec = params:lookup_param('length 3 ' ..i).controlspec,
              value = function() return params:get('length 3 ' ..i)
                end,
              action = function(s, v) params:set('length 3 ' ..i, v) end,
enabled = function(self)
  return (seqorlive.seq.prob_mod.value == 0)
  end
}end),

      length_prob_3 = nest_(16):each(function(i,v)


          return _grid.number {
              x = i,
              y = {1, 5},
              level = {0, 6},
              controlspec = params:lookup_param('length probability 3 ' ..i).controlspec,
              value = function() return params:get('length probability 3 ' ..i) / 25 + 1 end,
              action = function(s, v) params:set('length probability 3 ' ..i, (v - 1) * 25) end,
              enabled = function(self)
                  return (seqorlive.seq.prob_mod.value == 1)
                  end
          }end),

      length_clock_3 = _grid.number {
          x = {1, 16},
          y = 7,
          level = {0, 4},
          controlspec = params:lookup_param('length div 3').controlspec,
          value = function() return params:get('length div 3') end,
          action = function(s, v) params:set('length div 3', v) end
      },

      length_loop_3 = _grid.range {
          x = {1, 16},
          y = 6,
          level = {0, 4},

          value = function()
              return { params:get('length sequence start 3'), params:get('length sequence end 3') }
              end,

          action = function(s, v)
              params:set('length sequence start 3', v[1])
              params:set('length sequence end 3', v[2])
              end,
      }
},

length_tab_4 = nest_ {

  enabled = function(self)
      return (seqorlive.meta.value == 0 and
              seqorlive.seq.tab.value == 5 and
              seqorlive.seq.track.value == 4)
      end,

      length_dots_4 = nest_(16):each(function(i,v)

          return _grid.number {
              x = i,
              y = {1, 5},
              level = function(self)
                  if i == params:get('current length step 1') then return 15
                  else return 4 end
              end,
controlspec = params:lookup_param('length 4 ' ..i).controlspec,
              value = function() return params:get('length 4 ' ..i)
                end,
              action = function(s, v) params:set('length 4 ' ..i, v) end,
enabled = function(self)
  return (seqorlive.seq.prob_mod.value == 0)
  end
}end),

      length_prob_4 = nest_(16):each(function(i,v)


          return _grid.number {
              x = i,
              y = {1, 5},
              level = {0, 6},
              controlspec = params:lookup_param('length probability 4 ' ..i).controlspec,
              value = function() return params:get('length probability 4 ' ..i) / 25 + 1 end,
              action = function(s, v) params:set('length probability 4 ' ..i, (v - 1) * 25) end,
              enabled = function(self)
                  return (seqorlive.seq.prob_mod.value == 1)
                  end
          }end),

      length_clock_4 = _grid.number {
          x = {1, 16},
          y = 7,
          level = {0, 4},
          controlspec = params:lookup_param('length div 4').controlspec,
          value = function() return params:get('length div 4') end,
          action = function(s, v) params:set('length div 4', v) end
      },

      length_loop_4 = _grid.range {
          x = {1, 16},
          y = 6,
          level = {0, 4},

          value = function()
              return { params:get('length sequence start 4'), params:get('length sequence end 4') }
              end,

          action = function(s, v)
              params:set('length sequence start 4', v[1])
              params:set('length sequence end 4', v[2])
              end,
      }
},
  
  
    
    live_down = _grid.momentary{
      x = 10,
      y = 6,
      level = {5, 15},
      value = 0,
      action = function () if seqorlive.live_down.value == 1 then down_a_fifth() end end,
      enabled = function(self)
                return (seqorlive.meta.value == 1)
                end
      
    },
  
    live_double_down = _grid.momentary{
      x = 9,
      y = 6,
      level = {10, 15},
      value = 0,
      action = function () if seqorlive.live_double_down.value == 1 then down_a_fifth() down_a_fifth() end end,
      enabled = function(self)
                return (seqorlive.meta.value == 1)
                end
      
    },
  
    --return_to_root = _grid.momentary{
      --x = 3,
--      y = 8,
--      level = 15,
--      value = 0,
--      action = function () if seqorlive.return_to_root.value == 1 then return_to_root() end end,
--      enabled = function(self)
--              return (seqorlive.meta.value == 2)
--              end
--    },
    
    clock_sync = _grid.momentary{
      x = 3,
      y = 7,
      level = {5, 15},
      value = 0,
      action = function () if seqorlive.clock_sync.value == 1 then clock_sync() end end,
      enabled = function(self)
                return (seqorlive.meta.value == 1)
                end
      
    },
  
    restart_sequences = _grid.momentary{
      x = 4,
      y = 7,
      level = {5, 15},
      value = 0,
      action = function () if seqorlive.restart_sequences.value == 1 then restart_sequences() end end,
      enabled = function(self)
                return (seqorlive.meta.value == 1)
                end
      
    },
    
    live_up = _grid.momentary{
      x = 11,
      y = 6,
      level = {5, 15},
      value = 0,
      action = function () if seqorlive.live_up.value == 1 then up_a_fifth() end end,
      enabled = function(self)
                return (seqorlive.meta.value == 1)
                end
      
    },
  
    live_double_up = _grid.momentary{
      x = 12,
      y = 6,
      level = {10, 15},
      value = 0,
      action = function () if seqorlive.live_double_up.value == 1 then up_a_fifth() up_a_fifth() end end,
      enabled = function(self)
                return (seqorlive.meta.value == 1)
                end
      
    },
    
    live_key_1 = _grid.number {
          x = {9, 14},
          y = 7,
          level = {3, 15},
          controlspec = params:lookup_param('key').controlspec,
          action = function(s,v) 
            params:set('key', ((v - 1) * 7 % 12))
            seqorlive.live_key_2.value = 0 end,
          enabled = function(self)
                return (seqorlive.meta.value == 1)
                end
    },
    live_key_2 = _grid.number {
          x = {9, 14},
          y = 8,
          level = {3, 15},
          value = 0,
          controlspec = params:lookup_param('key').controlspec,
          action = function(s,v) 
            params:set('key', (v * 5 % 12))
            seqorlive.live_key_1.value = 0 end,
          enabled = function(self)
                return (seqorlive.meta.value == 1)
                end
    },
    
    live_offset = nest_(4):each(function(i,v)


        return _grid.number {
            x = i,
            y = {2, 6},
            level = 5,
            controlspec = params:lookup_param('offset ' ..i).controlspec,
            value = function() return params:get('offset ' ..i) end,
            action = function(s, v) params:set('offset ' ..i, v) end,
            enabled = function(self)
                return (seqorlive.meta.value == 1)
                end
        }end),
      
    live_transposition = nest_(4):each(function(i,v)


        return _grid.number {
            x = i + 4,
            y = {2, 6},
            level = 15,
            controlspec = params:lookup_param('transposition ' ..i).controlspec,
            value = function() return params:get('transposition ' ..i) + 3 end,
            action = function(s, v) params:set('transposition ' ..i, v - 3) end,
            enabled = function(self)
                return (seqorlive.meta.value == 1)
                end
        }end),
      
    live_carving = nest_(4):each(function(i,v)


        return _grid.number {
            x = i + 8,
            y = {2, 5},
            level = 5,
            controlspec = params:lookup_param('carving ' ..i).controlspec,
            value = function() return params:get('carving ' ..i) + 1 end,
            action = function(s, v) params:set('carving ' ..i, v - 1) end,
            enabled = function(self)
                return (seqorlive.meta.value == 1)
                end
        }end),    
    
      live_probability = nest_(4):each(function(i,v)


        return _grid.number {
            x = i + 12,
            y = {2, 6},
            level = 15,
            controlspec = params:lookup_param('probability ' ..i).controlspec,
            value = function() return math.floor(params:get('probability ' ..i) / 25 + 1)  end,
            action = function(s, v) params:set('probability ' ..i, (v - 1) * 25) end,
            enabled = function(self)
                return (seqorlive.meta.value == 1)
                end
        }end), 
        
        metarange = _grid.range {
                x = {1, 16},
                y = 7,
                level = 4,

                controlspec = params:lookup_param('meta loop start').controlspec,

                value = function()
                  return {params:get('meta loop start'), params:get('meta loop end')}
                end,
                enabled = function(self)
                  return (seqorlive.seq.tab.value == 1 and
                          seqorlive.meta.value == 0)
                  end,
                action = function(s, v)
                  params:set('meta loop start', v[1])
                  params:set('meta loop end', v[2])
                  meta_counter = meta_counter + 1
                  if meta_counter % 2 == 1 then
                  meta_start_1 = v[1]
                  meta_end_1 = v[2]

                  else
                  meta_start_2 = v[1]
                  meta_end_2 = v[2]
                  end
                  for i = 1,4,1 do
                  params:set('gate sequence start ' ..i, params:get('meta loop start'))

                  params:set('interval sequence start ' ..i, params:get('meta loop start'))

                  params:set('octave sequence start ' ..i, params:get('meta loop start'))
                  
                  params:set('velocity sequence start ' ..i, params:get('meta loop start'))
                  
                  params:set('length sequence start ' ..i, params:get('meta loop start'))
                  
                  params:set('gate sequence end ' ..i, params:get('meta loop end'))
                  
                  params:set('interval sequence end ' ..i, params:get('meta loop end'))

                  params:set('octave sequence end ' ..i, params:get('meta loop end'))
                  
                  params:set('velocity sequence end ' ..i, params:get('meta loop end'))
                  
                  params:set('length sequence end ' ..i, params:get('meta loop end'))
                  end
                end,
            },
      live_metarange = _grid.range {
                x = {1, 16},
                y = 1,
                level = 4,

                controlspec = params:lookup_param('meta loop start').controlspec,

                value = function()
                  return {params:get('meta loop start'), params:get('meta loop end')}
                end,

                action = function(s, v)
                  params:set('meta loop start', v[1])
                  params:set('meta loop end', v[2])
                  meta_counter = meta_counter + 1
                  if meta_counter % 2 == 1 then
                  meta_start_1 = v[1]
                  meta_end_1 = v[2]

                  else
                  meta_start_2 = v[1]
                  meta_end_2 = v[2]
                  end
                  if meta_start_1 ~= meta_start_2 or meta_end_1 ~= meta_end_2 then
                  for i = 1,4,1 do
                  params:set('gate sequence start ' ..i, params:get('meta loop start'))

                  params:set('interval sequence start ' ..i, params:get('meta loop start'))

                  params:set('octave sequence start ' ..i, params:get('meta loop start'))
                  
                  params:set('velocity sequence start ' ..i, params:get('meta loop start'))
                  
                  params:set('length sequence start ' ..i, params:get('meta loop start'))
                  
                  params:set('gate sequence end ' ..i, params:get('meta loop end'))
                  
                  params:set('interval sequence end ' ..i, params:get('meta loop end'))

                  params:set('octave sequence end ' ..i, params:get('meta loop end'))
                  
                  params:set('velocity sequence end ' ..i, params:get('meta loop end'))
                  
                  params:set('length sequence end ' ..i, params:get('meta loop end'))
                  end
                  end
              
                end,
                enabled = function(self)
                return (seqorlive.meta.value == 1)
                end

    
 }}

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

seqorlive:connect { g = grid.connect() }
function init()
    screen.clear()
    algebra.init()
    my_lattice = lattice:new()
    ppqn = 16
  gate_transport_1 = my_lattice:new_pattern{
      action = function(t) tick(1)
      gate_transport_1.division = params:get('gate div 1') / 16
      end,
      division = params:get('gate div 1') / 16
  }

  gate_transport_2 = my_lattice:new_pattern{
      action = function(t) tick(2)
        gate_transport_2.division = params:get('gate div 2') / 16
        end,
      division = params:get('gate div 2') / 16
  }

    gate_transport_3 = my_lattice:new_pattern{
      action = function(t) tick(3)
        gate_transport_3.division = params:get('gate div 3') / 16
        end,
      division = params:get('gate div 3') / 16
  }

    gate_transport_4 = my_lattice:new_pattern{
      action = function(t) tick (4)
        gate_transport_4.division = params:get('gate div 4') / 16
        end,
      division = params:get('gate div 4') / 16
  }

interval_transport_1 = my_lattice:new_pattern{
    action = function(t) interval_tick(1)
      interval_transport_1.division = params:get('interval div 1') / 16
      end,
    division = params:get('interval div 1') / 16
}

interval_transport_2 = my_lattice:new_pattern{
    action = function(t) interval_tick(2)
    interval_transport_2.division = params:get('interval div 2') / 16
      end,
    division = params:get('interval div 2') / 16
}

  interval_transport_3 = my_lattice:new_pattern{
    action = function(t) interval_tick(3)
      interval_transport_3.division = params:get('interval div 3') / 16
      end,
    division = params:get('interval div 3') / 16
}

  interval_transport_4 = my_lattice:new_pattern{
    action = function(t) interval_tick(4)
      interval_transport_4.division = params:get('interval div 4') / 16
      end,
    division = params:get('interval div 4') / 16
}

octave_transport_1 = my_lattice:new_pattern{
    action = function(t) octave_tick(1)
      octave_transport_1.division = params:get('octave div 1') / 16
      end,
    division = params:get('octave div 1') / 16
}

octave_transport_2 = my_lattice:new_pattern{
    action = function(t) octave_tick(2)
      octave_transport_2.division = params:get('octave div 2') / 16
      end,
    division = params:get('octave div 2') / 16
}

  octave_transport_3 = my_lattice:new_pattern{
    action = function(t) octave_tick(3)
      octave_transport_3.division = params:get('octave div 3') / 16
      end,
    division = params:get('octave div 3') / 16
}

  octave_transport_4 = my_lattice:new_pattern{
    action = function(t) octave_tick (4)
      octave_transport_4.division = params:get('octave div 4') / 16
      end,
    division = params:get('octave div 4') / 16
}

velocity_transport_1 = my_lattice:new_pattern{
    action = function(t) velocity_tick(1)
      velocity_transport_1.division = params:get('velocity div 1') / 16
      end,
    division = params:get('velocity div 1') / 16
}

velocity_transport_2 = my_lattice:new_pattern{
    action = function(t) velocity_tick(2)
      velocity_transport_2.division = params:get('velocity div 2') / 16
      end,
    division = params:get('velocity div 2') / 16
}

  velocity_transport_3 = my_lattice:new_pattern{
    action = function(t) velocity_tick(3)
      velocity_transport_3.division = params:get('velocity div 3') / 16
      end,
    division = params:get('velocity div 3') / 16
}

  velocity_transport_4 = my_lattice:new_pattern{
    action = function(t) velocity_tick (4)
      velocity_transport_4.division = params:get('velocity div 4') / 16
      end,
    division = params:get('velocity div 4') / 16
}

length_transport_1 = my_lattice:new_pattern{
    action = function(t) length_tick(1)
      length_transport_1.division = params:get('length div 1') / 16
      end,
    division = params:get('length div 1') / 16
}

length_transport_2 = my_lattice:new_pattern{
    action = function(t) length_tick(2)
      length_transport_2.division = params:get('length div 2') / 16
      end,
    division = params:get('length div 2') / 16
}

length_transport_3 = my_lattice:new_pattern{
    action = function(t) length_tick(3)
      length_transport_3.division = params:get('length div 3') / 16
      end,
    division = params:get('length div 3') / 16
}

  length_transport_4 = my_lattice:new_pattern{
    action = function(t) length_tick (4)
      length_transport_4.division = params:get('length div 4') / 16
      end,
    division = params:get('length div 4') / 16
}
    refresh = my_lattice:new_pattern{
      action = function(t) seqorlive.seq:update()
        end,
      division = 1 / 32
    }
  
  meta_counter = 0
  my_lattice:start()
  my_lattice:toggle()
  restart_sequences()
  seqorlive:init() 
  seqorlive.seq:update()
  end
