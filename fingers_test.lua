include 'lib/core'
include 'lib/norns'
include 'lib/grid'

n = nest_ {
    range = _grid.range {
        x = { 1, 16 }, z = -1, lvl = 4
    },
    tog = _grid.toggle {
        x = { 1, 16 }, 
        edge = 'falling', --note that edge must be set to falling for fingers to work (AKA, action on key release), i forgot to mention this part before!
        fingers = 1,
    }
} :connect { g = grid.connect() }

n:init()