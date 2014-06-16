--
-- lume
--
-- Copyright (c) 2014, rxi
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--

local lume = { _version = "1.4.0" }

local pairs, ipairs = pairs, ipairs
local type, assert, unpack = type, assert, unpack or table.unpack
local tostring, tonumber = tostring, tonumber
local math_floor = math.floor
local math_ceil = math.ceil
local math_random = math.random
local math_cos = math.cos
local math_atan2 = math.atan2
local math_sqrt = math.sqrt
local math_abs = math.abs
local math_pi = math.pi

local patternescape = function(str)
  return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
end

local absindex = function(len, i)
  return i < 0 and (len + i + 1) or i
end

local iscallable = function(x)
  if type(x) == "function" then return true end
  local mt = getmetatable(x)
  return mt and mt.__call ~= nil
end



function lume.clamp(x, min, max)
  return x < min and min or (x > max and max or x)
end


function lume.round(x, increment)
  if increment then return lume.round(x / increment) * increment end
  return x > 0 and math_floor(x + .5) or math_ceil(x - .5)
end


function lume.sign(x)
  return x < 0 and -1 or 1
end


function lume.lerp(a, b, amount)
  return a + (b - a) * lume.clamp(amount, 0, 1)
end


function lume.smooth(a, b, amount)
  local t = lume.clamp(amount, 0, 1)
  local m = t * t * (3 - 2 * t)
  return a + (b - a) * m
end


function lume.pingpong(x)
  return 1 - math_abs(1 - x % 2)
end


function lume.distance(x1, y1, x2, y2, squared)
  local dx = x1 - x2
  local dy = y1 - y2
  local s = dx * dx + dy * dy
  return squared and s or math_sqrt(s)
end


function lume.angle(x1, y1, x2, y2)
  return math_atan2(y2 - y1, x2 - x1)
end


function lume.random(a, b)
  if not a then a, b = 0, 1 end
  if not b then b = 0 end
  return a + math_random() * (b - a)
end


function lume.randomchoice(t)
  return t[math_random(#t)]
end


function lume.weightedchoice(t)
  local sum = 0
  for k, v in pairs(t) do
    assert(v >= 0, "weight value less than zero")
    sum = sum + v
  end
  assert(sum ~= 0, "all weights are zero")
  local rnd = lume.random(sum)
  for k, v in pairs(t) do
    if rnd < v then return k end
    rnd = rnd - v
  end
end


function lume.shuffle(t)
  for i = 1, #t do
    local r = math_random(#t)
    t[i], t[r] = t[r], t[i]
  end
  return t
end


function lume.array(...)
  local t = {}
  for x in ... do t[#t + 1] = x end
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
  local acc = first or t[1]
  assert(acc, "reduce of an empty array with no first value")
  for i = first and 1 or 2, #t do acc = fn(acc, t[i]) end
  return acc
end


function lume.set(t, retainkeys)
  local rtn = {}
  for k, v in pairs(lume.invert(t)) do
    rtn[retainkeys and v or (#rtn + 1)] = k
  end
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


function lume.match(t, fn)
  for k, v in pairs(t) do
    if fn(v) then return v, k end
  end
  return nil
end


function lume.count(t, fn)
  local count = 0
  if fn then
    for k, v in pairs(t) do
      if fn(v) then count = count + 1 end
    end
  else
    for k in pairs(t) do count = count + 1 end
  end
  return count
end


function lume.slice(t, i, j)
  i = i and absindex(#t, i) or 1
  j = j and absindex(#t, j) or #t
  local rtn = {}
  for x = i < 1 and 1 or i, j > #t and #t or j do
    rtn[#rtn + 1] = t[x]
  end
  return rtn
end


function lume.invert(t)
  local rtn = {}
  for k, v in pairs(t) do rtn[v] = k end
  return rtn
end


function lume.clone(t)
  local rtn = {}
  for k, v in pairs(t) do rtn[k] = v end
  return rtn
end


function lume.fn(fn, ...)
  assert(iscallable(fn), "expected a function as the first argument")
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


local memoize_fnkey = {}
local memoize_nil = {}

function lume.memoize(fn)
  local cache = {}
  return function(...)
    local c = cache
    for i = 1, select("#", ...) do
      local a = select(i, ...) or memoize_nil
      c[a] = c[a] or {}
      c = c[a]
    end
    c[memoize_fnkey] = c[memoize_fnkey] or {fn(...)}
    return unpack(c[memoize_fnkey])
  end
end


function lume.combine(...)
  local funcs = {}
  for i = 1, select("#", ...) do
    local fn = select(i, ...)
    if fn ~= nil then
      assert(iscallable(fn), "expected a function or nil")
      funcs[#funcs + 1] = fn
    end
  end
  return function(...)
    for _, f in ipairs(funcs) do f(...) end
  end
end


function lume.time(fn, ...)
  local start = os.clock()
  local rtn = {fn(...)}
  return (os.clock() - start), unpack(rtn)
end


local lambda_cache = {}

function lume.lambda(str)
  if not lambda_cache[str] then
    local args, body = str:match([[^([%w,_ ]-)%->(.-)$]])
    assert(args and body, "bad string lambda")
    local s = "return function(" .. args .. ")\nreturn " .. body .. "\nend"
    lambda_cache[str] = lume.dostring(s)
  end
  return lambda_cache[str]
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
  local err = function(t,k) error("unsupported serialize type: " .. k) end
  setmetatable(f, { __index = err })
  return f[type(x)](x)
end


function lume.deserialize(str)
  return lume.dostring("return " .. str)
end


function lume.split(str, sep)
  if not sep then
    return lume.array(str:gmatch("([%S]+)"))
  else
    assert(sep ~= "", "empty separator")
    local psep = patternescape(sep)
    return lume.array((str..sep):gmatch("(.-)("..psep..")"))
  end
end


function lume.trim(str, chars)
  if not chars then return str:match("^[%s]*(.-)[%s]*$") end
  chars = patternescape(chars)
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
  local t = { "[" .. info.short_src .. ":" .. info.currentline .. "]" }
  for i = 1, select("#", ...) do
    local x = select(i, ...)
    x = (type(x) == "number") and lume.round(x, .01) or (x or "nil")
    t[#t + 1] = tostring(x)
  end
  print(table.concat(t, " "))
end


function lume.dostring(str)
  return assert((loadstring or load)(str))()
end


function lume.uuid()
  local fn = function(x)
    local r = math_random(16) - 1
    r = (x == "x") and (r + 1) or (r % 4) + 9
    return ("0123456789abcdef"):sub(r, r)
  end
  return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", fn))
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
  local a = math_floor((color / 16777216) % 256)
  local r = math_floor((color /    65536) % 256)
  local g = math_floor((color /      256) % 256)
  local b = math_floor((color) % 256)
  return r, g, b, a
end


local chain_mt = {}
chain_mt.__index = lume.map(lume.filter(lume, iscallable, true),
  function(fn)
    return function(self, ...)
      self._value = fn(self._value, ...)
      return self
    end
  end)
chain_mt.__index.result = function(x) return x._value end

function lume.chain(value)
  return setmetatable({ _value = value }, chain_mt)
end


return lume
