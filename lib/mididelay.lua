delay_time = 2
delay_preserve = .9

--here are a bunch of tables to hold values

delay_counters = {}
delay_counters.note = {}
delay_counters.vel = {}
delay_counters.length = {}
delay_counters.channel = {}
delay_counters.track = {}
delay_counters.position = {}

function add_note_to_delay(note, vel, length, channel, track) -- this populates the tables with values, and is called from the "play_midi_note" function
  table.insert(delay_counters.note, note)
  table.insert(delay_counters.vel, vel)
  table.insert(delay_counters.length, length)
  table.insert(delay_counters.channel, channel)
  table.insert(delay_counters.track, track)
  table.insert(delay_counters.position, colorwheel_lattice.transport)
end

function delay_tick()
  if delay_counters.note[1] then -- if there are any items in the table...
    for i = 1, tablelength(delay_counters.note) do --loop from the first item in the table to the last...
      if (colorwheel_lattice.transport + delay_counters.position[i]) % (192 * delay_time) == 0 then -- periodically...
    play_midi_note(delay_counters.note[i], math.floor(delay_counters.vel[i] * delay_preserve), delay_counters.length[i], delay_counters.channel[i], delay_counters.track[i]) --play a midi note (this should also add it back to the end of the table)
        table.remove(delay_counters.note, 1) -- remove the note's values from the table[s]
        table.remove(delay_counters.vel, 1)
        table.remove(delay_counters.length, 1)
        table.remove(delay_counters.channel, 1)
        table.remove(delay_counters.track, 1)
      end
    end
  end
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end