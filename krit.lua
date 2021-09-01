g = grid.connect()
winning_row = 8
current_track = 1
current_page = 6
pagextrack = {{1,2,3,4},
              {1,2,3,4},
              {1,2,3,4},
              {1,2,3,4},
              {1,2,3,4},
              {1,2,3,4},
              {1,2,3,4}}
            

function init()
  grid_dirty = true
  switch = {}
  switch_page = {}
  range = {}
  future_range = {}
  for i = 1,16 do
    switch[i] = {y = 7}
  end
  for i = 1,8 do
    range[i] = {x1 = 1, x2 = 1, held = 0}
    future_range[i] = {x1 = 1, x2 = 1, held = 0}
  end
    clock.run(grid_redraw_clock)
end

function grid_redraw_clock()
  while true do
      if grid_dirty then
          grid_redraw()
          grid_dirty = false
      end
      clock.sleep(1/30)
  end
end

function grid_redraw()
  g:all(0)
  for i = 1, 16 do
    g:led(i,switch[i].y, 2)
  end
  for i = range[winning_row].x1, range[winning_row].x2 do
    g:led(i,switch[i].y, 9)
  end
  for i = 1,4 do
    g:led(i,8,4)
  end
  for i = 6,9 do
    g:led(i,8,4)
  end
  g:led(current_track, 8, 9)
  g:led(current_page, 8, 9)
    g:refresh()
end

function g.key(x,y,z)
  if z == 1 and y == 8 and 5 < x then
    current_page = x
  end
  if z == 1 and y == 8 and x < 5  then
    current_track = x
  end
  if z == 1 and y < 8 then
    range[y].held = range[y].held + 1
    local difference = range[y].x2 - range[y].x1
    local original = {x1 = range[y].x1, x2 = range[y].x2}
    
       if range[y].held == 1 then
          future_range[y].x1 = x
          move_dot(x,y,z)
      
    
       elseif range[y].held == 2 then
          range[y].x1 = future_range[y].x1
          range[y].x2 = x
          winning_row = y
       end

  elseif z == 0 and y < 8 then
     range[y].held = range[y].held - 1
     
  
  end
      grid_dirty = true
end

function move_dot(x,y,z)
    switch[x].y = y
end
