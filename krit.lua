include 'lib/nest/core'
include 'lib/nest/norns'
include 'lib/nest/grid'


g = grid.connect()

seqorlive = nest_ {
    meta = _grid.number {
      x = {15, 16},
      y = 8,
      level = {4, 15}
},

seq = nest_ {
    enabled = function(self)
        return (seqorlive.meta.value == 1)
    end,
    
    loop_mod = _grid.momentary {
        x = 11,
        y = 8,
        level = {4, 15 } },
      
    time_mod = _grid.momentary {
        x = 12,
        y = 8,
        level = {4, 15} },
      
    prob_mod = _grid.momentary {
        x = 13,
        y = 8,
        level = {4, 15} },
    
    tab = _grid.number {
        x = {6, 9},
        y = 8,
        level = {4, 15} },
  
    track = _grid.number {
        x = {1, 4},
        y = 8,
        level = {4, 15}
        },
      
    gate_tab = nest_ {
        
        enabled = function(self)
            return (seqorlive.seq.tab.value == 1 and
                    seqorlive.seq.time_mod.value == 0)
        end,
        
        gate_page = nest_ {
            
            gatefield = _grid.toggle {
                x = {1, 16},
                y = {1, 4},
                level = {0, 15},
                fingers = { 0, 0},
                
                enabled = function(self)
                    return (seqorlive.seq.loop_mod.value == 0 and 
                            seqorlive.seq.time_mod.value == 0 and 
                            seqorlive.seq.prob_mod.value == 0)
                    end,
    },
  
        gate_prob_1 = nest_(16):each(function(i,v)
    
          
                return _grid.number {
                    x = i,
                    y = {1, 5},
                    level = {0, 6},
                
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
                
                enabled = function(self)
                    return (seqorlive.seq.loop_mod.value == 0 and 
                            seqorlive.seq.time_mod.value == 0 and 
                            seqorlive.seq.track.value == 4 and
                            seqorlive.seq.prob_mod.value == 1)
                    end,
                }end),  
              
        gate_ranges = nest_(4):each(function(i, v)
    
            return _grid.range {
                x = {1, 16},
                y = i,
                level = {0, 4},
                z = 1,
                
                enabled = function(self)
                    return (seqorlive.seq.loop_mod.value == 1 and 
                            seqorlive.seq.time_mod.value == 0 and 
                            seqorlive.seq.prob_mod.value == 0)
                    end}end)
          
        }},
                  
         gate_clocks = nest_(4):each(function(i,v)
           
            return _grid.number {
                x = {1, 16},
                y = i,
                level = {0,4},
              
            enabled = function(self)
                return (seqorlive.seq.tab.value == 1 and
                        seqorlive.seq.loop_mod.value == 0 and 
                        seqorlive.seq.time_mod.value == 1 and 
                        seqorlive.seq.prob_mod.value == 0)
                end}    
                end)},
  
--interval stuff starts here  
    interval_tab_1 = nest_ {
        
        enabled = function(self)
            return (seqorlive.meta.value == 1 and
                    seqorlive.seq.tab.value == 2 and 
                    seqorlive.seq.track.value == 1)
            end,
    
            interval_dots_1 = nest_(16):each(function(i,v)
    
          
                return _grid.number {
                    x = i,
                    y = {1, 5},
                    level = {0, 4},
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 0)
                        end
                }end),
            
            interval_prob_1 = nest_(16):each(function(i,v)
    
          
                return _grid.number {
                    x = i,
                    y = {1, 5},
                    level = {0, 6},
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 1)
                        end
                }end),
              
            interval_clock_1 = _grid.number {
                x = {1, 16},
                y = 7,
                level = {0, 4}
            },

            interval_loop_1 = _grid.range {
                x = {1, 16},
                y = 6,
                level = {0, 4}
            }
          
        
  
        },
      
    interval_tab_2 = nest_ {
        
        enabled = function(self)
            return (seqorlive.meta.value == 1 and
                    seqorlive.seq.tab.value == 2 and 
                    seqorlive.seq.track.value == 2)
            end,
    
            interval_dots_2 = nest_(16):each(function(i,v)
          
                 return _grid.number {
                    x = i,
                    y = {1, 5},
                    level = {0, 4},
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 0)
                        end
                }end),
            
            interval_prob_2 = nest_(16):each(function(i,v)
    
          
                return _grid.number {
                    x = i,
                    y = {1, 5},
                    level = {0, 6},
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 1)
                        end
                }end),
              
            interval_clock_2 = _grid.number {
                x = {1, 16},
                y = 7,
                level = {0, 4}
            },

            interval_loop_2 = _grid.range {
                x = {1, 16},
                y = 6,
                level = {0, 4}
            }},
          
        
  
    interval_tab_3 = nest_ {
        
        enabled = function(self)
            return (seqorlive.meta.value == 1 and
                    seqorlive.seq.tab.value == 2 and 
                    seqorlive.seq.track.value == 3)
            end,
    
            interval_dots_3 = nest_(16):each(function(i,v)
          
                return _grid.number {
                    x = i,
                    y = {1, 5},
                    level = {0, 4},
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 0)
                        end
                }end),
            
            interval_prob_3 = nest_(16):each(function(i,v)
    
          
                return _grid.number {
                    x = i,
                    y = {1, 5},
                    level = {0, 6},
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 1)
                        end
                }end),
          
            interval_clock_3 = _grid.number {
                x = {1, 16},
                y = 7,
                level = {0, 4}
            },

            interval_loop_3 = _grid.range {
                x = {1, 16},
                y = 6,
                level = {0, 4}
            }
    },
  
      interval_tab_4 = nest_ {
        
        enabled = function(self)
            return (seqorlive.meta.value == 1 and
                    seqorlive.seq.tab.value == 2 and 
                    seqorlive.seq.track.value == 4)
            end,
    
            interval_dots_4 = nest_(16):each(function(i,v)
          
                return _grid.number {
                    x = i,
                    y = {1, 5},
                    level = {0, 4},
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 0)
                        end
                }end),
            
            interval_prob_4 = nest_(16):each(function(i,v)
    
          
                return _grid.number {
                    x = i,
                    y = {1, 5},
                    level = {0, 6},
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 1)
                        end
                }end),
          
            interval_clock_4 = _grid.number {
                x = {1, 16},
                y = 7,
                level = {0, 4}
            },

            interval_loop_4 = _grid.range {
                x = {1, 16},
                y = 6,
                level = {0, 4}
            }
    },
  
--here be octaves
    octave_tab_1 = nest_ {
        
        enabled = function(self)
            return (seqorlive.meta.value == 1 and
                    seqorlive.seq.tab.value == 3 and 
                    seqorlive.seq.track.value == 1)
            end,
    
            octave_dots_1 = nest_(16):each(function(i,v)
          
                return _grid.number {
                    x = i,
                    y = {2, 5},
                    level = {0, 4},
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 0)
                        end
                }end),
            
            octave_prob_1 = nest_(16):each(function(i,v)
    
          
                return _grid.number {
                    x = i,
                    y = {1, 5},
                    level = {0, 6},
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 1)
                        end
                }end),
          
            octave_clock_1 = _grid.number {
                x = {1, 16},
                y = 7,
                level = {0, 4}
            },

            octave_loop_1 = _grid.range {
                x = {1, 16},
                y = 6,
                level = {0, 4}
            },
            
            octave_offset_1 = _grid.number {
                x = {1, 5},
                y = 1,
                level = {2, 4},
                enabled = function(self)
                    return (seqorlive.seq.prob_mod.value == 0)
                    end
            }
          
        
  
        },
      
    octave_tab_2 = nest_ {
        
        enabled = function(self)
            return (seqorlive.meta.value == 1 and
                    seqorlive.seq.tab.value == 3 and 
                    seqorlive.seq.track.value == 2)
            end,
    
            octave_dots_2 = nest_(16):each(function(i,v)
          
                return _grid.number {
                    x = i,
                    y = {2, 5},
                    level = {0, 4},
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 0)
                        end
                }end),
            
            octave_prob_2 = nest_(16):each(function(i,v)
    
          
                return _grid.number {
                    x = i,
                    y = {1, 5},
                    level = {0, 6},
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 1)
                        end
                }end),
          
            octave_clock_2 = _grid.number {
                x = {1, 16},
                y = 7,
                level = {0, 4}
            },

            octave_loop_2 = _grid.range {
                x = {1, 16},
                y = 6,
                level = {0, 4}
            },
            
            octave_offset_2 = _grid.number {
                x = {1, 5},
                y = 1,
                level = {2, 4},
                enabled = function(self)
                    return (seqorlive.seq.prob_mod.value == 0)
                    end
            }
      
      
    },
          
        
  
    octave_tab_3 = nest_ {
        
        enabled = function(self)
            return (seqorlive.meta.value == 1 and
                    seqorlive.seq.tab.value == 3 and 
                    seqorlive.seq.track.value == 3)
            end,
    
            octave_dots_3 = nest_(16):each(function(i,v)
          
                return _grid.number {
                    x = i,
                    y = {2, 5},
                    level = {0, 4},
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 0)
                        end
                }end),
            
            octave_prob_3 = nest_(16):each(function(i,v)
    
          
                return _grid.number {
                    x = i,
                    y = {1, 5},
                    level = {0, 6},
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 1)
                        end
                }end),
          
            octave_clock_3 = _grid.number {
                x = {1, 16},
                y = 7,
                level = {0, 4}
            },

            octave_loop_3 = _grid.range {
                x = {1, 16},
                y = 6,
                level = {0, 4}
            },
            
            octave_offset_3 = _grid.number {
                x = {1, 5},
                y = 1,
                level = {2, 4},
                enabled = function(self)
                    return (seqorlive.seq.prob_mod.value == 0)
                    end
            }
    },
  
      octave_tab_4 = nest_ {
        
        enabled = function(self)
            return (seqorlive.meta.value == 1 and
                    seqorlive.seq.tab.value == 3 and 
                    seqorlive.seq.track.value == 4)
            end,
    
            octave_dots_4 = nest_(16):each(function(i,v)
          
                return _grid.number {
                    x = i,
                    y = {2, 5},
                    level = {0, 4},
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 0)
                        end
                }end),
            
            octave_prob_4 = nest_(16):each(function(i,v)
    
          
                return _grid.number {
                    x = i,
                    y = {1, 5},
                    level = {0, 6},
                    enabled = function(self)
                        return (seqorlive.seq.prob_mod.value == 1)
                        end
                }end),
          
            octave_clock_4 = _grid.number {
                x = {1, 16},
                y = 7,
                level = {0, 4}
            },

            octave_loop_4 = _grid.range {
                x = {1, 16},
                y = 6,
                level = {0, 4}
            },
            
            octave_offset_4 = _grid.number {
                x = {1, 5},
                y = 1,
                level = {2, 4},
                enabled = function(self)
                    return (seqorlive.seq.prob_mod.value == 0)
                    end
            }
    },

--this is all placeholders
    length_tab = nest_ {
        enabled = function(self)
            return (seqorlive.seq.tab.value == 4)
            end,
        gate_page_1 = nest_ {
            enabled = function(self)
                return (seqorlive.seq.track.value == 1)
            end,
            gate_test = _grid.number {
                x = 4,
                y = 1,
                level = {4, 15}
        }
    },
          gate_page_2 = nest_ {
            enabled = function(self)
                return (seqorlive.seq.track.value == 2)
            end,
            gate_test = _grid.number {
                x = 4,
                y = 2,
                level = {4, 15}
        }
        },
          gate_page_3 = nest_ {
            enabled = function(self)
                return (seqorlive.seq.track.value == 3)
            end,
            gate_test = _grid.number {
                x = 4,
                y = 3,
                level = {4, 15}
           }
        },
          gate_page_4 = nest_ {
            enabled = function(self)
                return (seqorlive.seq.track.value == 4)
            end,
            gate_test = _grid.number {
                x = 4,
                y = 4,
                level = {4, 15}       
                
        } }
    } }
  
  
    
  
-- if 1 then
    --gate
        --mod
            --track 1
            --track 2
            --track 3
            --track 4
        --alt
            --track 1
            --track 2
            --track 3
            --track 4
    --interval
        --track 1
            --mod
            --alt
        --track 2
            --mod
            --alt
        --track 3
            --mod
            --alt
        --track 4
            --mod
            --alt
     --octave
        --track 1
            --mod
            --alt
        --track 2
            --mod
            --alt
        --track 3
            --mod
            --alt
        --track 4
            --mod
            --alt  
    --length
        --track 1
            --mod
            --alt
        --track 2
            --mod
            --alt
        --track 3
            --mod
            --alt
        --track 4
            --mod
            --alt 
            
--if 2 then
    --live shit???
seqorlive:connect { g = grid.connect() }
function init() seqorlive:init() end
