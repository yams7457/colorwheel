tab = require 'tabutil'

-------------------------------------------CONNECT------------------------

nest_.connect = function(self, objects, fps)
    local devs = {}

    local fps = fps or 30

    for k,v in pairs(objects) do
        if k == 'g' or k == 'a' then
            local kk = k
            local vv = v

            local rd = function()
                vv:all(0)
                self:draw(kk) 
                vv:refresh()
            end
            
            devs[kk] = _dev:new {
                object = vv,
                -- redraw = function() 
                --     rd()
                -- end,
                refresh = function()
                    vv:refresh()
                end,
                handler = function(...)
                    self:process(kk, {...}, {})
                end
            }

            if k == 'a' then
                devs.akey = _dev:new {
                    handler = function(...)
                        self:process('akey', {...}, {})
                    end
                }

                v.key = devs.akey.handler
                v.delta = devs.a.handler

                arc_redraw = rd --global
                devs[kk].redraw = function() arc_redraw() end
            else
                v.key = devs.g.handler

                grid_redraw = rd --global
                devs[kk].redraw = function() grid_redraw() end
            end

        elseif k == 'm' or k == 'h' then
            local kk = k
            local vv = v

            devs[kk] = _dev:new {
                object = vv,
                handler = function(data)
                    self:process(kk, data, {})
                end
            }

            v.event = devs[kk].handler
        elseif k == 'enc' or k == 'key' then
            local kk = k
            local vv = v

            devs[kk] = _dev:new {
                handler = function(...)
                    self:process(kk, {...}, {})
                end
            }

            _G[kk] = devs[kk].handler
        elseif k == 'screen' then
            local kk = k

            devs[kk] = _dev:new {
                object = screen,
                refresh = function()
                    screen.update()
                end,
                --[[
                redraw = function()
                    screen.clear()
                    self:draw('screen')
                    screen.update()
                end
                --]]
               redraw = function() redraw() end
            }

            --redraw = devs[kk].redraw
            redraw = function()
                screen.clear()
                self:draw('screen')
                screen.update()
            end
        else 
            print('nest_.connect: invalid device key. valid options are g, a, m, h, screen, enc, key')
        end
    end

    local function linkdevs(obj) 
        if type(obj) == 'table' and obj.is_nest then
            rawset(obj._, 'devs', devs)
            
            --might not be needed with _output.redraw args
            for k,v in pairs(objects) do 
                rawset(obj._, k, v)
            end
            
            for k,v in pairs(obj) do 
                linkdevs(v)
            end
        end
    end

    linkdevs(self)
    
    local oi = self.init
    self.init = function(s)
        oi(s)

        s.drawloop = clock.run(function() 
            while true do 
                clock.sleep(1/fps)
                
                for k,v in pairs(devs) do 
                    --if k == 'screen' and (not _menu.mode) then v.redraw() --norns menu secret system dependency
                    if v.redraw and v.dirty then 
                        v.dirty = false
                        v.redraw()
                    end
                end
            end   
        end)
    end
    
    return self
end

nest_.disconnect = function(self)
    if self.drawloop then clock.cancel(self.drawloop) end
end
-----------------------------------SCREEN------------------------------------------------

_screen_group = _group:new()
_screen_group.devk = 'screen'

_screen_group.affordance = _affordance:new {
    aa = 0,
    output = _output:new()
}
_screen = _screen_group.affordance

------------------------------------ENC---------------------------------------------------

_enc = _group:new()
_enc.devk = 'enc'

_enc.affordance = _affordance:new { 
    n = 2,
    sens = 1,
    input = _input:new()
}

_enc.affordance.input.filter = function(self, args) -- args = { n, d }
    local n, d = args[1], args[2] * self.p_.sens
    if type(n) == "table" then 
        if tab.contains(self.p_.n, args[1]) then return n, d end
    elseif args[1] == self.p_.n then return n, d
    else return nil
    end
end

_enc.muxaffordance = _enc.affordance:new()

_enc.muxaffordance.input.filter = function(self, args) -- args = { n, d }
    local sens = self.p_.sens or 1
    local n, d = args[1], args[2] * sens
    if type(self.p_.n) == "table" then 
        if tab.contains(self.p_.n, args[1]) then return { "line", n, d } end
    elseif args[1] == self.p_.n then return { "point", n, d }
    else return nil
    end
end

_enc.muxaffordance.input.muxhandler = _obj_:new {
    point = function(s, z) end,
    line = function(s, v, z) end
}

_enc.muxaffordance.input.handler = function(s, k, ...)
    return s.muxhandler[k](s, ...)
end

local function minit(n)
    if type(n) == 'table' then
        local ret = {}
        for i = 1, #n do ret[i] = 0 end
        return ret
    else return 0 end
end

_enc.delta = _enc.muxaffordance:new()

_enc.delta.input.muxhandler = _obj_:new {
    point = function(s, n, d) 
        return d
    end,
    line = function(s, n, d) 
        local i = tab.key(s.p_.n, n)
        return d, i
    end
}

local function delta_number(self, value, d)
    local range = { self.p_.min, self.p_.max }

    local v = value + (d * self.inc)

    if self.p_.wrap then
        while v > range[2] do
            v = v - (range[2] - range[1]) - 1
        end
        while v < range[1] do
            v = v + (range[2] - range[1]) + 1
        end
    end

    local c = util.clamp(v, range[1], range[2])
    if value ~= c then
        return c
    end
end

_enc.number = _enc.muxaffordance:new {
    min = 1, max = 1,
    inc = 0.01,
    wrap = false
}

_enc.number.copy = function(self, o)
    o = _enc.muxaffordance.copy(self, o)

    local v = minit(o.p_.n)
    if type(o.v) ~= 'function' then
        if type(v) == 'table' and (type(o.v) ~= 'table' or (type(o.v) == 'table' and #o.v ~= #v)) then o.v = v end
    end

    return o
end

_enc.number.input.muxhandler = _obj_:new {
    point = function(s, n, d) 
        return delta_number(s, s.p_.v, d), d * s.inc
    end,
    line = function(s, n, d) 
        local i = tab.key(s.p_.n, n)
        local v = delta_number(s, s.p_.v[i], d * s.inc)
        if v then
            local del = minit(s.p_.n)
            del[i] = d
            s.p_.v[i] = v
            return s.p_.v, del
        end
    end
}

local function delta_control(self, v, d)
    local value = self.controlspec:unmap(v) + (d * self.controlspec.quantum)

    if self.controlspec.wrap then
        while value > 1 do
            value = value - 1
        end
        while value < 0 do
            value = value + 1
        end
    end
    
    local c = self.controlspec:map(util.clamp(value, 0, 1))
    if v ~= c then
        return c
    end
end

_enc.control = _enc.muxaffordance:new {
    controlspec = nil,
    min = 0, max = 1,
    step = 0.01,
    units = '',
    quantum = 0.01,
    warp = 'lin',
    wrap = false
}

_enc.control.copy = function(self, o)
    local cs = o.controlspec

    o = _enc.muxaffordance.copy(self, o)

    o.controlspec = cs or controlspec.new(o.p_.min, o.p_.max, o.p_.warp, o.p_.step, o.v, o.p_.units, o.p_.quantum, o.p_.wrap)

    local v = minit(o.p_.n)
    if type(o.v) ~= 'function' then
        if type(v) == 'table' and (type(o.v) ~= 'table' or (type(o.v) == 'table' and #o.v ~= #v)) then o.v = v end
    end
    return o
end

_enc.control.input.muxhandler = _obj_:new {
    point = function(s, n, d) 
        local last = s.p_.v
        return delta_control(s, s.p_.v, d), s.p_.v - last 
    end,
    line = function(s, n, d) 
        local i = tab.key(s.p_.n, n)
        local v = delta_control(s, s.p_.v[i], d)
        if v then
            local last = s.p_.v[i]
            local del = minit(s.p_.n)
            s.p_.v[i] = v
            del[i] = v - last
            return s.p_.v, del
        end
    end
}

local tab = require 'tabutil'

local function delta_option_point(self, value, d, wrap_scoot)
    local i = value or 0
    local v = i + d
    local size = #self.p_.options + 1 - self.p_.sens

    if self.wrap then
        while v > size do
            v = v - size + (wrap_scoot and 1 or 0)
        end
        while v < 1 do
            v = v + size + 1
        end
    end

    local c = util.clamp(v, 1, size)
    if i ~= c then
        return c
    end
end

local function delta_option_line(self, value, dx, dy, wrap_scoot)
    local i = value.x
    local j = value.y
    local sizey = #self.p_.options + 1 - self.p_.sens

    vx = i + (dx or 0)
    vy = j + (dy or 0)

    if self.wrap then
        while vy > sizey do
            vy = vy - sizey + (wrap_scoot and 1 or 0)
        end
        while vy < 1 do
            vy = vy + sizey + 1
        end
    end

    local cy = util.clamp(vy, 1, sizey)
    local sizex = #self.p_.options[cy] + 1 - self.p_.sens

    if self.wrap then
        while vx > sizex do
            vx = vx - sizex
        end
        while vx < 1 do
            vx = vx + sizex + 1
        end
    end

    local cx = util.clamp(vx, 1, sizex)

    if i ~= cx or j ~= cy then
        value.x = cx
        value.y = cy
        return value
    end
end

_enc.option = _enc.muxaffordance:new {
    value = 1,
    --options = {},
    wrap = false
}

_enc.option.copy = function(self, o) 
    o = _enc.muxaffordance.copy(self, o)

    if type(o.p_.n) == 'table' then
        if type(o.v) ~= 'function' then
            if type(o.v) ~= 'table' then
                o.v = { x = 1, y = 1 }
            end
        end
    end

    return o
end

_enc.option.input.muxhandler = _obj_:new {
    point = function(s, n, d) 
        local v = delta_option_point(s, s.p_.v, d, true)
        return v, s.p_.options[v], d
    end,
    line = function(s, n, d) 
        local i = tab.key(s.p_.n, n)
        local dd = { 0, 0 }
        dd[i] = d
        local v = delta_option_line(s, s.p_.v, dd[2], dd[1], true)
        if v then
            local del = minit(s.p_.n)
            del[i] = d
            return v, s.p_.options[v.y][v.x], del
        end
    end
}

-----------------------------------KEY------------------------------------------------------

local edge = { rising = 1, falling = 0, both = 2 }

_key = _group:new()
_key.devk = 'key'

_key.affordance = _affordance:new { 
    n = 2,
    edge = 'rising',
    input = _input:new()
}

_key.affordance.input.filter = _enc.affordance.input.filter

_key.muxaffordance = _key.affordance:new()

_key.muxaffordance.input.filter = _enc.muxaffordance.input.filter

_key.muxaffordance.input.muxhandler = _obj_:new {
    point = function(s, z) end,
    line = function(s, v, z) end
}

_key.muxaffordance.input.handler = _enc.muxaffordance.input.handler

_key.number = _key.muxaffordance:new {
    inc = 1,
    wrap = false,
    min = 0, max = 10,
    edge = 'rising',
    tdown = 0
}

_key.number.input.muxhandler = _obj_:new {
    point = function(s, n, z) 
        if z == edge[s.p_.edge] then
            s.wrap = true
            return delta_number(s, s.p_.v, s.inc), util.time() - s.tdown, s.inc
        else s.tdown = util.time()
        end
    end,
    line = function(s, n, z) 
        if z == edge[s.p_.edge] then
            local i = tab.key(s.p_.n, n)
            local d = i == 2 and s.inc or -s.inc
            return delta_number(s, s.p_.v, d), util.time() - s.tdown, d
        else s.tdown = util.time()
        end
    end
}

_key.option = _enc.muxaffordance:new {
    value = 1,
    --options = {},
    wrap = false,
    inc = 1,
    edge = 'rising',
    tdown = 0
}

_key.option.copy = function(self, o) 
    o = _enc.muxaffordance.copy(self, o)

    return o
end

_key.option.input.muxhandler = _obj_:new {
    point = function(s, n, z) 
        if z == edge[s.p_.edge] then 
            s.wrap = true
            local v = delta_option_point(s, s.p_.v, s.inc)
            return v, s.p_.options[v], util.time() - s.tdown, s.inc
        else s.tdown = util.time()
        end
    end,
    line = function(s, n, z) 
        if z == edge[s.p_.edge] then 
            local i = tab.key(s.p_.n, n)
            local d = i == 2 and s.inc or -s.inc
            local v = delta_option_point(s, s.p_.v, d)
            return v, s.p_.options[v], util.time() - s.tdown, d
        else s.tdown = util.time()
        end
    end
}

_key.binary = _key.muxaffordance:new {
    fingers = nil
}

_key.binary.copy = function(self, o) 
    o = _key.muxaffordance.copy(self, o)

    rawset(o, 'list', {})

    local axis = o.p_.n
    local v = minit(axis)
    o.held = minit(axis)
    o.tdown = minit(axis)
    o.tlast = minit(axis)
    o.theld = minit(axis)
    o.vinit = minit(axis)
    o.blank = {}

    o.arg_defaults =  {
        minit(axis),
        minit(axis),
        nil,
        nil,
        o.list
    }

    if type(o.v) ~= 'function' then
        if type(v) == 'table' and (type(o.v) ~= 'table' or (type(o.v) == 'table' and #o.v ~= #v)) then o.v = v end
    end
    
    return o
end

_key.binary.input.muxhandler = _obj_:new {
    point = function(s, n, z, min, max, wrap)
        if z > 0 then 
            s.tlast = s.tdown
            s.tdown = util.time()
        else s.theld = util.time() - s.tdown end
        return z, s.theld
    end,
    line = function(s, n, z, min, max, wrap)
        local i = tab.key(s.p_.n, n)
        local add
        local rem

        if z > 0 then
            add = i
            s.tlast[i] = s.tdown[i]
            s.tdown[i] = util.time()
            table.insert(s.list, i)
            if wrap and #s.list > wrap then rem = table.remove(s.list, 1) end
        else
            local k = tab.key(s.list, i)
            if k then
                rem = table.remove(s.list, k)
            end
            s.theld[i] = util.time() - s.tdown[i]
        end
        
        if add then s.held[add] = 1 end
        if rem then s.held[rem] = 0 end

        return (#s.list >= min and (max == nil or #s.list <= max)) and s.held or nil, s.theld, nil, add, rem, s.list
    end
}

_key.momentary = _key.binary:new()

local function count(s) 
    local min = 0
    local max = nil

    if type(s.p_.count) == "table" then 
        max = s.p_.count[#s.p_.count]
        min = #s.p_.count > 1 and s.p_.count[1] or 0
    else max = s.p_.count end

    return min, max
end

local function fingers(s)
    local min = 0
    local max = nil

    if type(s.p_.fingers) == "table" then 
        max = s.p_.fingers[#s.p_.fingers]
        min = #s.p_.fingers > 1 and s.p_.fingers[1] or 0
    else max = s.p_.fingers end

    return min, max
end

_key.momentary.input.muxhandler = _obj_:new {
    point = function(s, n, z)
        return _key.binary.input.muxhandler.point(s, n, z)
    end,
    line = function(s, n, z)
        local max
        local min, wrap = count(s)
        if s.fingers then
            min, max = fingers(s)
        end        

        local v,t,last,add,rem,list = _key.binary.input.muxhandler.line(s, n, z, min, max, wrap)
        if v then
            return v,t,last,add,rem,list
        else
            return s.vinit, s.vinit, nil, nil, nil, s.blank
        end
    end
}

_key.toggle = _key.binary:new { edge = 'rising', lvl = { 0, 15 } } -- it is wierd that lvl is being used w/o an output :/

_key.toggle.copy = function(self, o) 
    o = _key.binary.copy(self, o)

    rawset(o, 'toglist', {})

    local axis = o.p_.n

    --o.tog = minit(axis)
    o.ttog = minit(axis)

    o.arg_defaults = {
        minit(axis),
        minit(axis),
        nil,
        nil,
        o.toglist
    }

    return o
end

local function toggle(s, v)
    return (v + 1) % (((type(s.p_.lvl) == 'table') and #s.p_.lvl > 1) and (#s.p_.lvl) or 2)
end

_key.toggle.input.muxhandler = _obj_:new {
    point = function(s, n, z)
        local held = _key.binary.input.muxhandler.point(s, n, z)

        if edge[s.p_.edge] == held then
            return toggle(s, s.p_.v), s.theld, util.time() - s.tlast 
        end
    end,
    line = function(s, n, z)
        local held, theld, _, hadd, hrem, hlist = _key.binary.input.muxhandler.line(s, n, z, 0, nil)
        local min, max = count(s)
        local i
        local add
        local rem
       
        if edge[s.p_.edge] == 1 and hadd then i = hadd end
        if edge[s.p_.edge] == 0 and hrem then i = hrem end
 
        if i then   
            if #s.toglist >= min then
                local v = toggle(s, s.p_.v[i])
                
                if v > 0 then
                    add = i
                    
                    if v == 1 then table.insert(s.toglist, i) end
                    if max and #s.toglist > max then rem = table.remove(s.toglist, 1) end
                else 
                    local k = tab.key(s.toglist, i)
                    if k then
                        rem = table.remove(s.toglist, k)
                    end
                end
            
                s.ttog[i] = util.time() - s.tlast[i]

                if add then s.p_.v[add] = v end
                if rem then s.p_.v[rem] = 0 end

            elseif #hlist >= min then
                for j,w in ipairs(hlist) do
                    s.toglist[j] = w
                    s.p_.v[w] = 1
                end
            end
            
            if #s.toglist < min then
                for j,w in ipairs(s.p_.v) do s.p_.v[j] = 0 end
                s.toglist = {}
            end

            return s.p_.v, theld, s.ttog, add, rem, s.toglist
        end
    end
}

_key.trigger = _key.binary:new { edge = 'rising', blinktime = 0.1, persistent = false }

_key.trigger.copy = function(self, o) 
    o = _key.binary.copy(self, o)

    rawset(o, 'triglist', {})

    local axis = o.p_.n
    o.tdelta = minit(axis)

    o.arg_defaults = {
        minit(axis),
        minit(axis),
        nil,
        nil,
        o.triglist
    }
    
    return o
end

_key.trigger.input.muxhandler = _obj_:new {
    point = function(s, n, z)
        local held = _key.binary.input.muxhandler.point(s, n, z)
        
        if edge[s.p_.edge] == held then
            return 1, s.theld, util.time() - s.tlast
        end
    end,
    line = function(s, n, z)
        local e = edge[s.p_.edge]
        local max
        local min, wrap = count(s)
        if s.fingers then
            min, max = fingers(s)
        end        
        local held, theld, _, hadd, hrem, hlist = _key.binary.input.muxhandler.line(s, n, z, 0, nil)
        local ret = false
        local lret, add

        if e == 1 and #hlist > min and (max == nil or #hlist <= max) and hadd then
            s.p_.v[hadd] = 1
            s.tdelta[hadd] = util.time() - s.tlast[hadd]

            ret = true
            add = hadd
            lret = hlist
        elseif e == 1 and #hlist == min and hadd then
            for i,w in ipairs(hlist) do 
                s.p_.v[w] = 1

                s.tdelta[w] = util.time() - s.tlast[w]
            end

            ret = true
            lret = hlist
            add = hlist[#hlist]
        elseif e == 0 and #hlist >= min - 1 and (max == nil or #hlist <= max - 1)and hrem and not hadd then
            s.triglist = {}

            for i,w in ipairs(hlist) do 
                if s.p_.v[w] <= 0 then
                    s.p_.v[w] = 1
                    s.tdelta[w] = util.time() - s.tlast[w]
                    table.insert(s.triglist, w)
                end
            end
            
            if s.p_.v[hrem] <= 0 then
                ret = true
                lret = s.triglist
                s.p_.v[hrem] = 1 
                add = hrem
                s.tdelta[hrem] = util.time() - s.tlast[hrem]
                table.insert(s.triglist, hrem)
            end
        end
            
        if ret then return s.p_.v, s.theld, s.tdelta, add, nil, lret end
    end
}

-------------------------------------BINDERS----------------------------------------------

local pt = { separator = 0, number = 1, option = 2, control = 3, file = 4, taper = 5, trigger = 6, group = 7, text = 8, binary = 9 }
local tp = tab.invert(pt)
local err = function(t) print(t .. '.param: cannot bind to param of type '..tp[p.t]) end
local gp = function(id) 
    local p = params:lookup_param(id)
    if p then return p
    else print('_affordance.param: no param with id "'..id..'"') end
end
local lnk = function(s, id, t, o)
    if type(s.v) == 'table' then
        print(t .. '.param: value cannot be a table')
    else
        --o.label = (s.label ~= nil) and s.label or gp(id).name or id
        o.value = function() return params:get(id) end
        o.action = function(s, v) params:set(id, v) end
        o.formatter = o.formatter or gp(id).formatter and 
            function(s,v) return gp(id).formatter({value = v}) end
        s:merge(o)
    end
end

_enc.control.param = function(s, id)
    local p,t = gp(id), '_enc.control'

    if p.t == pt.control then
        lnk(s, id, t, {
            controlspec = p.controlspec,
        })
    else err(t) end; return s
end
_enc.number.param = function(s, id)
    local p,t = gp(id), '_enc.number'

    if p.t == pt.number then
        lnk(s, id, t, {
            min = p.min, max = p.max, wrap = p.wrap, inc = 1
        })
    elseif p.t == pt.control then
        lnk(s, id, t, {
            min = p.controlspec.min, max = p.controlspec.max, wrap = p.controlspec.wrap,
        })
    else err(t) end; return s
end
_enc.option.param = function(s, id)
    local p,t = gp(id), '_enc.option'

    if p.t == pt.option then
        lnk(s, id, t, {
            options = p.options,  
        })
    else err(t) end; return s
end
_key.number.param = function(s, id)
    local p,t = gp(id), '_key.number'

    if p.t == pt.number then
        lnk(s, id, t, {
            min = p.min, max = p.max, wrap = p.wrap,
        })
    else err(t) end; return s
end
_key.option.param = function(s, id)
    local p,t = gp(id), '_key.option'

    if p.t == pt.option then
        lnk(s, id, t, {
            options = p.options,  
        })
    else err(t) end; return s
end
_key.toggle.param = function(s, id)
    local p,t = gp(id), '_key.toggle'

    if p.t == pt.binary then
        lnk(s, id, t, {})
    elseif p.t == pt.option then
        if type(s.v) == 'table' then
            print(t .. '.param: value cannot be a table')
        else
            s.value = function() return params:get(id) - 1 end
            s.action = function(s, v) params:set(id, v + 1) end
        end
    else err(t) end; return s
end
_key.momentary.param = function(s, id)
    local p = gp(id)

    if p.t == pt.binary then
        lnk(s, id, '_key.momentary', {})
    else err(t) end; return s
end
_key.trigger.param = function(s, id)
    local p,t = gp(id), '_key.trigger'

    if p.t == pt.binary then
        if type(s.v) == 'table' then
            print(t .. '.param: value cannot be a table')
        else
            --o.label = (s.label ~= nil) and s.label or gp(id).name or id
            s.action = function(s, v) params:delta(id) end
        end
    else err(t) end; return s
end

