--
-- lume
--
-- Copyright (c) 2014, rxi
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--

local lume = { _version = "1.1.1" }


function lume.clamp(x, min, max)
  return x < min and min or (x > max and max or x)
end


function lume.round(x, increment)
  if increment then return lume.round(x / increment) * increment end
  return x > 0 and math.floor(x + .5) or math.ceil(x - .5)
end


function lume.sign(x)
  return x < 0 and -1 or 1
end


function lume.lerp(a, b, amount)
  return a + (b - a) * lume.clamp(amount, 0, 1)
end


function lume.smooth(a, b, amount)
  local m = (1 - math.cos(lume.clamp(amount, 0, 1) * math.pi)) / 2
  return a + (b - a) * m
end


function lume.pingpong(x)
  return 1 - math.abs(1 - x % 2)
end


function lume.distance(x1, y1, x2, y2, squared)
  local dx = x1 - x2
  local dy = y1 - y2
  local s = dx * dx + dy * dy
  return squared and s or math.sqrt(s)
end


function lume.angle(x1, y1, x2, y2)
  return math.atan2(y2 - y1, x2 - x1)
end


function lume.random(a, b)
  if not a then a, b = 0, 1 end
  if not b then b = 0 end
  return a + math.random() * (b - a)
end


function lume.randomchoice(t)
  return t[math.random(#t)]
end


function lume.shuffle(t)
  for i = 1, #t do
    local r = math.random(#t)
    t[i], t[r] = t[r], t[i]
  end
  return t
end


function lume.array(...)
  local t = {}
  for x in unpack({...}) do t[#t + 1] = x end
  return t
end


function lume.each(t, fn, ...)
  if type(fn) == "string" then
    for _, v in pairs(t) do v[fn](v, ...) end
  else
    for _, v in pairs(t) do fn(v, ...) end
  end
  return t
end


function lume.map(t, fn)
  local rtn = {} 
  for k, v in pairs(t) do rtn[k] = fn(v) end
  return rtn
end


function lume.all(t, fn)
  fn = fn or function(x) return x end
  for k, v in pairs(t) do
    if not fn(v) then return false end
  end
  return true
end


function lume.any(t, fn)
  fn = fn or function(x) return x end
  for k, v in pairs(t) do
    if fn(v) then return true end
  end
  return false
end


function lume.reduce(t, fn, first)
  for i = 1, #t do first = fn(first, t[i]) end
  return first
end


function lume.set(t, retainkeys)
  local tmp = {}
  for k, v in pairs(t) do tmp[v] = k end
  local rtn = {}
  for k, v in pairs(tmp) do rtn[retainkeys and v or (#rtn + 1)] = k end
  return rtn
end


function lume.filter(t, fn, retainkeys)
  local rtn = {}
  for k, v in pairs(t) do
    if fn(v) then rtn[retainkeys and k or (#rtn + 1)] = v end
  end
  return rtn
end


function lume.merge(t, t2, retainkeys)
  for k, v in pairs(t2) do
    t[retainkeys and k or (#t + 1)] = v
  end
  return t
end


function lume.find(t, value)
  for k, v in pairs(t) do
    if v == value then return k end
  end
  return nil
end


function lume.slice(t, i, j)
  i = i or 1
  j = j and (j < 0 and (#t + j + 1) or j) or #t
  local rtn = {}
  for i = math.max(i, 1), math.min(j, #t) do
    rtn[#rtn + 1] = t[i]
  end
  return rtn
end


function lume.clone(t)
  local rtn = {}
  for k, v in pairs(t) do rtn[k] = v end
  return rtn
end


function lume.fn(fn, ...)
  local args = {...}
  return function(...)
    local a = lume.merge(lume.clone(args), {...})
    return fn(unpack(a)) 
  end
end


function lume.once(fn, ...)
  local fn = lume.fn(fn, ...)
  local done = false
  return function(...)
    if done then return end
    done = true
    return fn(...)
  end
end


function lume.time(fn, ...)
  local start = os.clock()
  local rtn = {fn(...)}
  return (os.clock() - start), unpack(rtn)
end


function lume.serialize(x)
  local f = { string = function(v) return string.format("%q", v) end,
              number = tostring, boolean = tostring }
  f.table = function(t)
    local rtn = {}
    for k, v in pairs(t) do
      rtn[#rtn + 1] = "[" .. f[type(k)](k) .. "]=" .. f[type(v)](v) .. ","
    end
    return "{" .. table.concat(rtn) .. "}"
  end
  return f[type(x)](x)
end


function lume.deserialize(str)
  return lume.dostring("return " .. str)
end


function lume.split(str, sep)
  return lume.array(str:gmatch("([^" .. (sep or "%s") .. "]+)"))
end


function lume.trim(str, chars)
  chars = chars or "%s"
  return str:match("^[" .. chars .. "]*(.-)[" .. chars .. "]*$")
end


function lume.format(str, vars)
  if not vars then return str end
  local f = function(x) 
    return tostring(vars[x] or vars[tonumber(x)] or "{" .. x .. "}") 
  end
  return (str:gsub("{(.-)}", f))
end


function lume.trace(...)
  local info = debug.getinfo(2, "Sl")
  local head = "[" .. info.short_src .. ":" .. info.currentline .. "] "
  print(head .. table.concat(lume.map({...}, tostring), " "))
end


function lume.dostring(str)
  return assert((loadstring or load)(str))()
end


function lume.hotswap(modname)
  local oldglobal = lume.clone(_G)
  local updated = {}
  local function update(old, new)
    if updated[old] then return end 
    updated[old] = true
    local oldmt, newmt = getmetatable(old), getmetatable(new)
    if oldmt and newmt then update(oldmt, newmt) end
    for k, v in pairs(new) do
      if type(v) == "table" then update(old[k], v) else old[k] = v end
    end
  end
  local err = nil
  local function onerror(e)
    for k, v in pairs(_G) do _G[k] = oldglobal[k] end
    err = lume.trim(e)
  end
  local ok, oldmod = pcall(require, modname)
  oldmod = ok and oldmod or nil
  xpcall(function()
    package.loaded[modname] = nil
    local newmod = require(modname)
    if type(oldmod) == "table" then update(oldmod, newmod) end
    for k, v in pairs(oldglobal) do
      if v ~= _G[k] and type(v) == "table" then 
        update(v, _G[k])
        _G[k] = v
      end
    end
  end, onerror)
  package.loaded[modname] = oldmod
  if err then return nil, err end
  return oldmod
end


function lume.rgba(color)
  local floor = math.floor
  local a = floor((color / 2 ^ 24) % 256)
  local r = floor((color / 2 ^ 16) % 256)
  local g = floor((color / 2 ^ 08) % 256)
  local b = floor((color) % 256)
  return r, g, b, a
end


return lume
