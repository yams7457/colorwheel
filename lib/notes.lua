Voice = require("lib/voice")

VOICES = {"midi", "w/syn", "just friends", "crow 1,2", "crow 3,4", "ansible", "disting"}

MIDI_VOICE = 1
WSYN_VOICE = 2
JF_VOICE = 3
CROW_12_VOICE = 4
CROW_34_VOICE = 5
ANSIBLE_VOICE = 6
DISTING_VOICE = 7

notes = {}

function curve_formatter(param)
  local c = param:get()
  local description = "square"
  if c == -5 then description = "pulse"
  elseif c < 0 then description = "trapezoid"
  elseif c == 0 then description = "saw/triangle"
  elseif c < 5 then description = "rounded"
  else description = "sinusoid"
  end
  return string.format("%.1f %s", c, description)
end

function ifoutput(opt, f)
  return function(param)
    local doit = false
    for i = 1,4,1 do
      if params:get("output "..i) == opt then
        doit = true
      end
    end
    if doit then f(param) end
  end
end

WSYN_SUSTAIN_MONO = 1
WSYN_SUSTAIN_STEAL = 2
WSYN_PLUCK = 3

JF_SUSTAIN_MONO = 1
JF_SUSTAIN_STEAL = 2

ASL_SHAPES = {'linear','sine','logarithmic','exponential','now'}

function notes.init()
  local V5_default0 = controlspec.def{
    min=-5.0,
    max=5.0,
    warp='lin',
    step=0.00,
    default=0.0,
    quantum=0.01,
    wrap=false,
    units='V'
  }

  local V5_default1 = controlspec.def{
    min=-5.0,
    max=5.0,
    warp='lin',
    step=0.00,
    default=1.0,
    quantum=0.01,
    wrap=false,
    units='V'
  }  

  local V5_default5 = controlspec.def{
    min=-5.0,
    max=5.0,
    warp='lin',
    step=0.00,
    default=5.0,
    quantum=0.01,
    wrap=false,
    units='V'
  }
  
  local V5_default_neg5 = controlspec.def{
    min=-5.0,
    max=5.0,
    warp='lin',
    step=0.00,
    default= -5.0,
    quantum=0.01,
    wrap=false,
    units='V'
  }
  
  local N16 = controlspec.def{
    min=1,
    max=16,
    warp='lin',
    step=1,
    default=1,
    quantum=0.01,
    wrap=false,
    units=''
  }
  
  local v5 = controlspec.new(-5.0, 5.0, 'lin', 0, 0.0, "", 0.1, false)

  params:add_group("w/syn",9)
  
  params:add_option("w/style", "style", {"voice/track", "dynamic poly", "pluck"}, 1)
  params:set_action("w/style", ifoutput(WSYN_VOICE, function (param)
    if param == WSYN_PLUCK then
      crow.ii.wsyn.ar_mode(1)
    else
      crow.ii.wsyn.ar_mode(0)
    end 
    crow.ii.wsyn.voices(4)
  end))
  
  params:add_control("w/curve", "curve", V5_default5)
  params:set_action("w/curve", ifoutput(WSYN_VOICE, function(param)
    crow.ii.wsyn.curve(param)
  end))
  
  params:add_control("w/ramp", "ramp", V5_default0)
  params:set_action("w/ramp", ifoutput(WSYN_VOICE, function(param)
    crow.ii.wsyn.ramp(param)
  end))
  
  params:add_control("w/fm_index", "fm index", V5_default1)
  params:set_action("w/fm_index", ifoutput(WSYN_VOICE, function(param)
    crow.ii.wsyn.fm_index(param)
  end))
  
  params:add_control("w/fm_env", "fm envelope", V5_default1)
  params:set_action("w/fm_env", ifoutput(WSYN_VOICE, function(param)
    crow.ii.wsyn.fm_env(param)
  end))
  
  params:add_control("w/fm_num", "ratio numerator", N16)
  params:set_action("w/fm_num", ifoutput(WSYN_VOICE, function(param)
    crow.ii.wsyn.fm_ratio(param, params:get("w/fm_denom"))
  end))
  
  params:add_control("w/fm_denom", "ratio denominator", N16)
  params:set_action("w/fm_denom", ifoutput(WSYN_VOICE, function(param)
    crow.ii.wsyn.fm_ratio(params:get("w/fm_num"), param)
  end))
  
  params:add_control("w/lpg_time", "lpg time", V5_default0)
  params:set_action("w/lpg_time", ifoutput(WSYN_VOICE, function(param)
    crow.ii.wsyn.lpg_time(param)
  end))
  
  params:add_control("w/lpg_symmetry", "lpg symmetry", V5_default_neg5)
  params:set_action("w/lpg_symmetry", ifoutput(WSYN_VOICE, function(param)
    crow.ii.wsyn.lpg_symmetry(param)
  end))
  
  params:add_group("just friends", 1)
  params:add_option("jf/style", "style", {"voice/track", "dynamic poly"}, 1)
  
  params:add_group("crow output", 9)
  params:add_control("crow/attack_time", "attack", controlspec.new(0.0001, 3, 'exp', 0, 0.1, "s"))
  params:add_option("crow/attack_shape", "attack shape", ASL_SHAPES, 3)
  params:add_control("crow/decay_time", "decay", controlspec.new(0.0001, 10, 'exp', 0, 1.0, "s"))
  params:add_option("crow/decay_shape", "decay shape", ASL_SHAPES, 4)
  params:add_control("crow/sustain", "sustain", controlspec.new(0.0, 1.0, 'lin', 0, 0.75, ""))
  params:add_control("crow/release_time", "release", controlspec.new(0.0001, 10, 'exp', 0, 0.5, "s"))
  params:add_option("crow/release_shape", "release shape", ASL_SHAPES, 4)
  params:add_control("crow/portomento", "portomento", controlspec.new(0.0, 1, 'lin', 0, 0.0, "s"))
  params:add_binary("crow/legato", "legato", "toggle", 1)
  
  params:add_group("ansible", 1)
  params:add_number("ansible/offset_halfsteps", "offset halfsteps", 0, 48, 12)
  params:set_action("ansible/offset_halfsteps", ifoutput(ANSIBLE_VOICE, function(param)
    for i=1,4,1 do
      crow.ii.ansible.cv_offset(i, param/12)
    end
  end))

end

m = midi.connect()



function play_midi_note(note, vel, length, channel, track)
  m:note_on(note, vel, channel)
  clock.run(midi_note_off, note, vel, length, channel, track)
end

wsyn_player = {
  channel_map={0, 0, 0, 0},
  allocator=Voice.new(4, Voice.LRU),
}

function wsyn_player:play_note(note, vel, length, channel, track)
  local v8 = (note - 60)/12
  local v_vel = (vel/127) * 5
  if params:get("w/style") == WSYN_SUSTAIN_MONO then
    crow.ii.wsyn.play_voice(track, v8, v_vel)
    local index = self.channel_map[track] + 1
    self.channel_map[track] = index
    clock.run(function() 
      clock.sleep(clock.get_beat_sec() * length)
      if self.channel_map[track] == index then
        crow.ii.wsyn.velocity(track, 0)
      end
    end)
  elseif params:get("w/style") == WSYN_SUSTAIN_STEAL then
    local slot = self.allocator:get()
    local index = self.channel_map[slot.id] + 1
    self.channel_map[slot.id] = index
    crow.ii.wsyn.play_voice(slot.id, v8, v_vel)
    slot.on_release = function(slot)
      if self.channel_map[slot.id] == index then
        crow.ii.wsyn.velocity(slot.id, 0)
      end
    end
    clock.run(function() 
      clock.sleep(clock.get_beat_sec() * length)
      self.allocator:release(slot)
    end)
  else
    crow.ii.wsyn.play_note(v8, v_vel)
  end
end

jf_player = {
  channel_map={0, 0, 0, 0, 0, 0},
  allocator=Voice.new(6, Voice.LRU),
}

function jf_player:play_note(note, vel, length, channel, track)
  local v8 = (note - 60)/12
  local v_vel = (vel/127) * 5
  if params:get("jf/style") == JF_SUSTAIN_MONO then
    crow.ii.jf.play_voice(track, v8, v_vel)
    local index = self.channel_map[track] + 1
    self.channel_map[track] = index
    clock.run(function() 
      clock.sleep(clock.get_beat_sec() * length)
      if self.channel_map[track] == index then
        crow.ii.jf.trigger(track, 0)
      end
    end)
  elseif params:get("jf/style") == JF_SUSTAIN_STEAL then
    local slot = self.allocator:get()
    local index = self.channel_map[slot.id] + 1
    self.channel_map[slot.id] = index
    crow.ii.jf.play_voice(slot.id, v8, v_vel)
    slot.on_release = function(slot)
      if self.channel_map[slot.id] == index then
        crow.ii.jf.trigger(slot.id, 0)
      end
    end
    clock.run(function() 
      clock.sleep(clock.get_beat_sec() * length)
      self.allocator:release(slot)
    end)
  else
    crow.ii.jf.play_note(v8, v_vel)
  end
end

crow_player = {
  channel_map={0, 0},
}

function crow_player:play_note(note, vel, length, channel, track)
  local v8 = (note - 60)/12
  local v_vel = (vel/127) * 10
  local pitch_o = 0;
  local envelope_o = 0;
  local voice = 0;
  local attack = params:get("crow/attack_time")
  local attack_shape = ASL_SHAPES[params:get("crow/attack_shape")]
  local decay = params:get("crow/decay_time")
  local decay_shape = ASL_SHAPES[params:get("crow/decay_shape")]
  local sustain = params:get("crow/sustain")
  local release = params:get("crow/release_time")
  local release_shape = ASL_SHAPES[params:get("crow/release_shape")]
  local portomento = params:get("crow/portomento")
  local legato = params:get("crow/legato")

  if params:get("output "..track) == CROW_12_VOICE then
    voice = 1
    pitch_o = 1
    envelope_o = 2
  else
    voice = 2
    pitch_o = 3
    envelope_o = 4
  end
  local was = self.channel_map[voice]
  local now = was + 1
  self.channel_map[voice] = now
  if was then
    crow.output[pitch_o].action = string.format("{ to(%f,%f,sine) }", v8, portomento)
    crow.output[pitch_o]()
  else
    crow.output[pitch_o].volts = v8
  end
  if (was > 0) and (legato > 0) then
    crow.output[envelope_o].action = string.format("{ to(%f,%f,%s) }", v_vel*sustain, decay, decay_shape)
  else
    crow.output[envelope_o].action = string.format("{ to(%f,%f,%s), to(%f,%f,%s) }", v_vel, attack, attack_shape, v_vel*sustain, decay, decay_shape)
  end
  crow.output[envelope_o]()
  clock.run(function() 
    clock.sleep(clock.get_beat_sec() * length)
    if self.channel_map[voice] == now then
      self.channel_map[voice] = 0
      crow.output[envelope_o].action = string.format("{ to(%f,%f,%s) }", 0, release, release_shape)
      crow.output[envelope_o]()
    end
  end)
end

ansible_player = {}

function ansible_player:play_note(note, vel, length, channel, track)
  local v8 = (note - 60)/12
  crow.ii.ansible.cv(track, v8)
  crow.ii.ansible.trigger_time(track, clock.get_beat_sec() * length)
  crow.ii.ansible.trigger_pulse(track)
  
end

disting_player = {
}

function disting_player:play_note(note, vel, length, channel, track)
  local v_vel = (vel/127) * 10
  local v8 = (note - 36)/12
  crow.ii.disting.note_pitch(note, v8)
  crow.ii.disting.note_velocity(note, v_vel)
  clock.run(function() 
    clock.sleep(clock.get_beat_sec() * length)
    crow.ii.disting.note_off(note)    
  end)
end

notes.play = {
  play_midi_note,
  function (...) wsyn_player:play_note(...) end,
  function (...) jf_player:play_note(...) end,
  function (...) crow_player:play_note(...) end,
  function (...) crow_player:play_note(...) end,
  function (...) ansible_player:play_note(...) end,
  function (...) disting_player:play_note(...) end,
}

function midi_note_off(note, vel, length, channel)
  clock.sleep(clock.get_beat_sec() * length)
  m:note_off(note, vel, channel)
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
