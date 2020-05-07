--- A collection of functions for Lua, geared towards game development.
-- @module lume
-- @author rxi
-- @copyright 2020
-- @license MIT

-- Copyright (c) 2020 rxi
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do
-- so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

local lume = { _version = "2.3.0" }

local pairs, ipairs = pairs, ipairs
local type, assert, unpack = type, assert, unpack or table.unpack
local tostring, tonumber = tostring, tonumber
local math_floor = math.floor
local math_ceil = math.ceil
local math_atan2 = math.atan2 or math.atan
local math_sqrt = math.sqrt
local math_abs = math.abs

local noop = function()
end

local identity = function(x)
  return x
end

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

local getiter = function(x)
  if lume.isarray(x) then
    return ipairs
  elseif type(x) == "table" then
    return pairs
  end
  error("expected table", 3)
end

local iteratee = function(x)
  if x == nil then return identity end
  if iscallable(x) then return x end
  if type(x) == "table" then
    return function(z)
      for k, v in pairs(x) do
        if z[k] ~= v then return false end
      end
      return true
    end
  end
  return function(z) return z[x] end
end


--- Math
-- @section math

--- Returns the number `x` clamped between the numbers `min` and `max`.
-- @function clamp
-- @tparam number x
-- @tparam number min
-- @tparam number max
-- @treturn number
function lume.clamp(x, min, max)
  return x < min and min or (x > max and max or x)
end


--- Rounds `x` to the nearest integer;
-- rounds away from zero if we're midway between two integers.
-- If `increment` is set then the number is rounded to the nearest increment.
-- @function round
-- @tparam number x
-- @tparam[opt] number increment
-- @treturn int
-- @treturn number if increment is set
-- @usage lume.round(2.3) -- Returns 2
-- @usage lume.round(123.4567, .1) -- Returns 123.5
function lume.round(x, increment)
  if increment then return lume.round(x / increment) * increment end
  return x >= 0 and math_floor(x + .5) or math_ceil(x - .5)
end


--- Returns `1` if `x` is 0 or above, returns `-1` when `x` is negative.
-- @function sign
-- @tparam number x
-- @return 1 if `x` >= 0
-- @return 0 if `x` < 0
function lume.sign(x)
  return x < 0 and -1 or 1
end


--- Returns the linearly interpolated number between `a` and `b`, `amount` should
-- be in the range of 0 - 1; if `amount` is outside of this range it is clamped.
-- @function lerp
-- @tparam number a
-- @tparam number b
-- @tparam number amount
-- @treturn number
-- @usage lume.lerp(100, 200, .5) -- Returns 150
function lume.lerp(a, b, amount)
  return a + (b - a) * lume.clamp(amount, 0, 1)
end


--- Similar to `lume.lerp()` but uses cubic interpolation instead of linear interpolation.
-- @function smooth
-- @tparam number a
-- @tparam number b
-- @tparam number amount
-- @treturn number
-- @see lerp
function lume.smooth(a, b, amount)
  local t = lume.clamp(amount, 0, 1)
  local m = t * t * (3 - 2 * t)
  return a + (b - a) * m
end


--- Ping-pongs the number `x` between 0 and 1.
-- @function pingpong
-- @tparam number x
-- @treturn number
function lume.pingpong(x)
  return 1 - math_abs(1 - x % 2)
end


--- Returns the distance between the two points. If `squared` is true then the
-- squared distance is returned -- this is faster to calculate and can still be used when comparing distances.
-- @function distance
-- @tparam number x1
-- @tparam number y1
-- @tparam number x2
-- @tparam number y2
-- @tparam[opt] bool squared
-- @treturn number distance between (`x1`,`y1`) and (`x2`,`y2`)
-- @treturn number squared distance between (`x1`,`y1`) and (`x2`,`y2`), if `squared` is true
function lume.distance(x1, y1, x2, y2, squared)
  local dx = x1 - x2
  local dy = y1 - y2
  local s = dx * dx + dy * dy
  return squared and s or math_sqrt(s)
end


--- Returns the angle between the two points.
-- @function angle
-- @tparam number x1
-- @tparam number y1
-- @tparam number x2
-- @tparam number y2
-- @treturn number
function lume.angle(x1, y1, x2, y2)
  return math_atan2(y2 - y1, x2 - x1)
end


--- Given an `angle` and `magnitude`, returns a vector.
-- @function vector
-- @tparam number angle
-- @tparam number magnitude
-- @treturn number
-- @usage local x, y = lume.vector(0, 10) -- Returns 10, 0
function lume.vector(angle, magnitude)
  return math.cos(angle) * magnitude, math.sin(angle) * magnitude
end


--- Random
-- @section random

--- Returns a random number between `a` and `b`. If only `a` is supplied a number between `0` and `a` is returned.
 -- If no arguments are supplied a random number between `0` and `1` is returned.
-- @function random
-- @tparam[opt] number a
-- @tparam[opt] number b
-- @treturn number Random number between 0 and 1
-- @treturn number Random number between 0 and `b`
-- @treturn number Random number between `a` and `b`
function lume.random(a, b)
  if not a then a, b = 0, 1 end
  if not b then b = 0 end
  return a + math.random() * (b - a)
end


--- Returns a random value from array `t`. If the array is empty an error is raised.
-- @function randomchoice
-- @tparam table t
-- @return random value from `t`
-- @raise If t is empty
-- @usage lume.randomchoice({true, false}) -- Returns either true or false
function lume.randomchoice(t)
  return t[math.random(#t)]
end


--- Takes the argument table `t` where the keys are the possible choices and the value is the choice's weight.
-- A weight should be 0 or above, the larger the number the higher the probability of that choice being picked.
-- If the table is empty, a weight is below zero or all the weights are 0 then an error is raised.
-- Returns either "cat" or "dog" with "cat" being twice as likely to be chosen.
-- @function weightedchoice
-- @tparam table t
-- @return random value from `t`
-- @raise If t is empty
-- @usage lume.weightedchoice({ ["cat"] = 10, ["dog"] = 5, ["frog"] = 0 })
function lume.weightedchoice(t)
  local sum = 0
  for _, v in pairs(t) do
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


--- Tables
-- @section tables


--- Returns `true` if `x` is an array.
-- The value `x` is assumed to be an array if it is a table which contains a value at the index `1`.
--
-- This function is used internally and can be overridden if you wish to use a different method to detect arrays.
-- @function isarray
-- @param x
-- @treturn bool
function lume.isarray(x)
  return type(x) == "table" and x[1] ~= nil
end


--- Pushes all the given values to the end of the table `t` and returns the pushed values. Nil values are ignored.
-- @function push
-- @tparam table t
-- @param ... arguments
-- @treturn table
-- @usage local t = { 1, 2, 3 }
--lume.push(t, 4, 5) -- `t` becomes { 1, 2, 3, 4, 5 }
function lume.push(t, ...)
  local n = select("#", ...)
  for i = 1, n do
    t[#t + 1] = select(i, ...)
  end
  return ...
end


--- Removes the first instance of the value `x` if it exists in the table `t`.
-- @function remove
-- @tparam table t
-- @param x value
-- @treturn table updated table
-- @usage local t = { 1, 2, 3 }
--lume.remove(t, 2) -- `t` becomes { 1, 3 }
function lume.remove(t, x)
  local iter = getiter(t)
  for i, v in iter(t) do
    if v == x then
      if lume.isarray(t) then
        table.remove(t, i)
        break
      else
        t[i] = nil
        break
      end
    end
  end
  return x
end


--- Nils all the values in the table `t`, this renders the table empty.
-- @function clear
-- @tparam table t
-- @return t
-- @usage local t = { 1, 2, 3 }
--lume.clear(t) -- `t` becomes {}
function lume.clear(t)
  local iter = getiter(t)
  for k in iter(t) do
    t[k] = nil
  end
  return t
end


--- Copies all the fields from the source tables to the table `t` and returns `t`.
-- If a key exists in multiple tables the right-most table's value is used.
-- @function extend
-- @tparam table t
-- @param ... arguments
-- @treturn table Updated table
-- @usage local t = { a = 1, b = 2 }
--lume.extend(t, { b = 4, c = 6 }) -- `t` becomes { a = 1, b = 4, c = 6 }
function lume.extend(t, ...)
  for i = 1, select("#", ...) do
    local x = select(i, ...)
    if x then
      for k, v in pairs(x) do
        t[k] = v
      end
    end
  end
  return t
end


--- Returns a shuffled copy of the array `t`.
-- @function shuffle
-- @tparam table t
-- @treturn table
function lume.shuffle(t)
  local rtn = {}
  for i = 1, #t do
    local r = math.random(i)
    if r ~= i then
      rtn[i] = rtn[r]
    end
    rtn[r] = t[i]
  end
  return rtn
end


--- Returns a copy of the array `t` with all its items sorted.
-- If `comp` is a function it will be used to compare the items when sorting.
-- If `comp` is a string it will be used as the key to sort the items by.
-- @function sort
-- @tparam table t
-- @tparam[opt] func|string comp
-- @treturn table t
-- @usage lume.sort({ 1, 4, 3, 2, 5 }) -- Returns { 1, 2, 3, 4, 5 }
-- @usage lume.sort({ {z=2}, {z=3}, {z=1} }, "z") -- Returns { {z=1}, {z=2}, {z=3} }
-- @usage lume.sort({ 1, 3, 2 }, function(a, b) return a > b end) -- Returns { 3, 2, 1 }
function lume.sort(t, comp)
  local rtn = lume.clone(t)
  if comp then
    if type(comp) == "string" then
      table.sort(rtn, function(a, b) return a[comp] < b[comp] end)
    else
      table.sort(rtn, comp)
    end
  else
    table.sort(rtn)
  end
  return rtn
end


--- Iterates the supplied iterator and returns an array filled with the values.
-- @function array
-- @tparam function ...
-- @treturn table
-- @usage lume.array(string.gmatch("Hello world", "%a+")) -- Returns {"Hello", "world"}
function lume.array(...)
  local t = {}
  for x in ... do t[#t + 1] = x end
  return t
end


--- Iterates the table `t` and calls the function `fn` on each value followed by the supplied additional arguments
-- If `fn` is a string the method of that name is called for each value. The function returns `t` unmodified.
-- @function each
-- @tparam table t
-- @tparam func|string fn
-- @param ... arguments
-- @treturn table t
-- @usage lume.each({1, 2, 3}, print) -- Prints "1", "2", "3" on separate lines
-- @usage lume.each({a, b, c}, "move", 10, 20) -- Does x:move(10, 20) on each value
function lume.each(t, fn, ...)
  local iter = getiter(t)
  if type(fn) == "string" then
    for _, v in iter(t) do v[fn](v, ...) end
  else
    for _, v in iter(t) do fn(v, ...) end
  end
  return t
end


--- Applies the function `fn` to each value in table `t` and returns a new table with the resulting values.
-- @function map
-- @tparam table t
-- @tparam function fn
-- @treturn table
-- @usage lume.map({1, 2, 3}, function(x) return x * 2 end) -- Returns {2, 4, 6}
function lume.map(t, fn)
  fn = iteratee(fn)
  local iter = getiter(t)
  local rtn = {}
  for k, v in iter(t) do rtn[k] = fn(v) end
  return rtn
end


--- Returns true if all the values in `t` table are true. If a `fn` function is supplied it is called on each value,
-- true is returned if all of the calls to `fn` return true.
-- @function all
-- @tparam table t
-- @tparam[opt] function fn
-- @treturn bool
-- @usage lume.all({1, 2, 1}, function(x) return x == 1 end) -- Returns false
function lume.all(t, fn)
  fn = iteratee(fn)
  local iter = getiter(t)
  for _, v in iter(t) do
    if not fn(v) then return false end
  end
  return true
end

--- Returns true if any of the values in `t` table are true. If a `fn` function is supplied it is called on each value,
-- true is returned if any of the calls to `fn` return true.
-- @function any
-- @tparam table t
-- @tparam[opt] function fn
-- @treturn bool
-- @usage lume.any({1, 2, 1}, function(x) return x == 1 end) -- Returns true
function lume.any(t, fn)
  fn = iteratee(fn)
  local iter = getiter(t)
  for _, v in iter(t) do
    if fn(v) then return true end
  end
  return false
end


--- Applies `fn` on two arguments cumulative to the items of the array `t`, from left to right, so as to reduce the
-- array to a single value. If a `first` value is specified the accumulator is initialised to this, otherwise
-- the first value in the array is used. If the array is empty and no `first` value is specified an error is raised.
-- @function reduce
-- @tparam table t
-- @tparam function fn
-- @param[opt] first
-- @treturn table
-- @usage lume.reduce({1, 2, 3}, function(a, b) return a + b end) -- Returns 6
function lume.reduce(t, fn, first)
  local started = first ~= nil
  local acc = first
  local iter = getiter(t)
  for _, v in iter(t) do
    if started then
      acc = fn(acc, v)
    else
      acc = v
      started = true
    end
  end
  assert(started, "reduce of an empty table with no first value")
  return acc
end


--- Returns a copy of the `t` array with all the duplicate values removed.
-- @function unique
-- @tparam table t
-- @treturn table
-- @usage lume.unique({2, 1, 2, "cat", "cat"}) -- Returns {1, 2, "cat"}
function lume.unique(t)
  local rtn = {}
  for k in pairs(lume.invert(t)) do
    rtn[#rtn + 1] = k
  end
  return rtn
end


--- Calls `fn` on each value of `t` table. Returns a new table with only the values where `fn` returned true.
-- If `retainkeys` is true the table is not treated as an array and retains its original keys.
-- @function filter
-- @tparam table t
-- @tparam function fn
-- @tparam[opt] bool retainkeys
-- @treturn table
-- @see reject
-- @usage lume.filter({1, 2, 3, 4}, function(x) return x % 2 == 0 end) -- Returns {2, 4}
function lume.filter(t, fn, retainkeys)
  fn = iteratee(fn)
  local iter = getiter(t)
  local rtn = {}
  if retainkeys then
    for k, v in iter(t) do
      if fn(v) then rtn[k] = v end
    end
  else
    for _, v in iter(t) do
      if fn(v) then rtn[#rtn + 1] = v end
    end
  end
  return rtn
end


--- The opposite of `lume.filter()`: Calls `fn` on each value of `t` table; returns a new table with only
-- the values where `fn` returned false.
-- If `retainkeys` is true the table is not treated as an array and retains its original keys.
-- @see filter
-- @function reject
-- @tparam table t
-- @tparam function fn
-- @tparam[opt] bool retainkeys
-- @treturn table
-- @usage lume.reject({1, 2, 3, 4}, function(x) return x % 2 == 0 end) -- Returns {1, 3}
function lume.reject(t, fn, retainkeys)
  fn = iteratee(fn)
  local iter = getiter(t)
  local rtn = {}
  if retainkeys then
    for k, v in iter(t) do
      if not fn(v) then rtn[k] = v end
    end
  else
    for _, v in iter(t) do
      if not fn(v) then rtn[#rtn + 1] = v end
    end
  end
  return rtn
end


--- Returns a new table with all the given tables merged together.
-- If a key exists in multiple tables the right-most table's value is used.
-- @function merge
-- @param ... arguments
-- @treturn table
-- @usage lume.merge({a=1, b=2, c=3}, {c=8, d=9}) -- Returns {a=1, b=2, c=8, d=9}
function lume.merge(...)
  local rtn = {}
  for i = 1, select("#", ...) do
    local t = select(i, ...)
    local iter = getiter(t)
    for k, v in iter(t) do
      rtn[k] = v
    end
  end
  return rtn
end


--- Returns a new array consisting of all the given arrays concatenated into one.
-- @function concat
-- @param ... arguments
-- @treturn table
-- @usage lume.concat({1, 2}, {3, 4}, {5, 6}) -- Returns {1, 2, 3, 4, 5, 6}
function lume.concat(...)
  local rtn = {}
  for i = 1, select("#", ...) do
    local t = select(i, ...)
    if t ~= nil then
      local iter = getiter(t)
      for _, v in iter(t) do
        rtn[#rtn + 1] = v
      end
    end
  end
  return rtn
end


--- Returns the index/key of `value` in `t`. Returns `nil` if that value does not exist in the table.
-- @function find
-- @tparam table t
-- @param value
-- @return index/key
-- @treturn[opt] nil
-- @usage lume.find({"a", "b", "c"}, "b") -- Returns 2
function lume.find(t, value)
  local iter = getiter(t)
  for k, v in iter(t) do
    if v == value then return k end
  end
  return nil
end


--- Returns the value and key of the value in table `t` which returns true when `fn` is called on it.
-- Returns `nil` if no such value exists.
-- @function match
-- @tparam table t
-- @tparam function fn
-- @return index/key
-- @treturn[opt] nil
-- @usage lume.match({1, 5, 8, 7}, function(x) return x % 2 == 0 end) -- Returns 8, 3
function lume.match(t, fn)
  fn = iteratee(fn)
  local iter = getiter(t)
  for k, v in iter(t) do
    if fn(v) then return v, k end
  end
  return nil
end


--- Counts the number of values in the table `t`. If a `fn` function is supplied it is called on each value,
-- the number of times it returns true is counted.
-- @function count
-- @tparam table t
-- @tparam[opt] function fn
-- @treturn number
-- @usage lume.count({a = 2, b = 3, c = 4, d = 5}) -- Returns 4
-- @usage lume.count({1, 2, 4, 6}, function(x) return x % 2 == 0 end) -- Returns 3
function lume.count(t, fn)
  local count = 0
  local iter = getiter(t)
  if fn then
    fn = iteratee(fn)
    for _, v in iter(t) do
      if fn(v) then count = count + 1 end
    end
  else
    if lume.isarray(t) then
      return #t
    end
    for _ in iter(t) do count = count + 1 end
  end
  return count
end


--- Mimics the behaviour of Lua's `string.sub`, but operates on an array rather than a string.
-- Creates and returns a new array of the given slice.
-- @function slice
-- @tparam table t
-- @tparam[opt] number i
-- @tparam[opt] number j
-- @treturn table
-- @see string.sub
-- @usage lume.slice({"a", "b", "c", "d", "e"}, 2, 4) -- Returns {"b", "c", "d"}
function lume.slice(t, i, j)
  i = i and absindex(#t, i) or 1
  j = j and absindex(#t, j) or #t
  local rtn = {}
  for x = i < 1 and 1 or i, j > #t and #t or j do
    rtn[#rtn + 1] = t[x]
  end
  return rtn
end


--- Returns the first element of an array or nil if the array is empty.
-- If `n` is specified an array of the first `n` elements is returned.
-- @function first
-- @tparam table t
-- @tparam[opt] number n
-- @return element
-- @treturn table if n
-- @treturn nil if empty
-- @usage lume.first({"a", "b", "c"}) -- Returns "a"
function lume.first(t, n)
  if not n then return t[1] end
  return lume.slice(t, 1, n)
end


--- Returns the last element of an array or nil if the array is empty.
-- If `n` is specified an array of the last `n` elements is returned.
-- @function last
-- @tparam table t
-- @tparam[opt] number n
-- @return element
-- @treturn table if n
-- @treturn nil if empty
-- @usage lume.last({"a", "b", "c"}) -- Returns "c"
function lume.last(t, n)
  if not n then return t[#t] end
  return lume.slice(t, -n, -1)
end


--- Returns a copy of the table where the keys have become the values and the values the keys.
-- @function invert
-- @tparam table t
-- @treturn table copy of `t`
-- @usage lume.invert({a = "x", b = "y"}) -- returns {x = "a", y = "b"}
function lume.invert(t)
  local rtn = {}
  for k, v in pairs(t) do rtn[v] = k end
  return rtn
end


--- Returns a copy of the table filtered to only contain values for the given keys.
-- @function pick
-- @tparam table t
-- @param ... arguments
-- @treturn table
-- @usage lume.pick({ a = 1, b = 2, c = 3 }, "a", "c") -- Returns { a = 1, c = 3 }
function lume.pick(t, ...)
  local rtn = {}
  for i = 1, select("#", ...) do
    local k = select(i, ...)
    rtn[k] = t[k]
  end
  return rtn
end


--- Returns an array containing each key of the table.
-- @function keys
-- @tparam table t
-- @treturn table
function lume.keys(t)
  local rtn = {}
  local iter = getiter(t)
  for k in iter(t) do rtn[#rtn + 1] = k end
  return rtn
end


--- Returns a shallow copy of the table `t`.
-- @function clone
-- @tparam table t
-- @treturn table shallow copy
function lume.clone(t)
  local rtn = {}
  for k, v in pairs(t) do rtn[k] = v end
  return rtn
end


--- Higher-order functions
-- @section function

--- Creates a wrapper function around function `fn`, automatically inserting the arguments into `fn` which will
-- persist every time the wrapper is called. Any arguments which are passed to the returned function will be
-- inserted after the already existing arguments passed to `fn`.
-- @function fn
-- @tparam function fn
-- @param ... arguments
-- @treturn func
-- @usage local f = lume.fn(print, "Hello")
--f("world") -- Prints "Hello world"
function lume.fn(fn, ...)
  assert(iscallable(fn), "expected a function as the first argument")
  local args = { ... }
  return function(...)
    local a = lume.concat(args, { ... })
    return fn(unpack(a))
  end
end


--- Returns a wrapper function to `fn` which takes the supplied arguments. The wrapper function will call `fn` on
-- the first call and do nothing on any subsequent calls.
-- @function once
-- @tparam function fn
-- @param ... arguments
-- @treturn func
-- @usage local f = lume.once(print, "Hello")
--f() -- Prints "Hello"
--f() -- Does nothing
function lume.once(fn, ...)
  local f = lume.fn(fn, ...)
  local done = false
  return function(...)
    if done then return end
    done = true
    return f(...)
  end
end


local memoize_fnkey = {}
local memoize_nil = {}

--- Returns a wrapper function to `fn` where the results for any given set of arguments are cached.
-- `lume.memoize()` is useful when used on functions with slow-running computations.
-- @function memoize
-- @tparam function fn
-- @treturn func
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


--- Creates a wrapper function which calls each supplied argument in the order they were passed to `lume.combine()`;
-- nil arguments are ignored. The wrapper function passes its own arguments to each of its wrapped functions
-- when it is called.
-- @function combine
-- @param ... arguments
-- @treturn function wrapper function
-- @usage local f = lume.combine(function(a, b) print(a + b) end,
--                        function(a, b) print(a * b) end)
-- f(3, 4) -- Prints "7" then "12" on a new line
function lume.combine(...)
  local n = select('#', ...)
  if n == 0 then return noop end
  if n == 1 then
    local fn = select(1, ...)
    if not fn then return noop end
    assert(iscallable(fn), "expected a function or nil")
    return fn
  end
  local funcs = {}
  for i = 1, n do
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


--- Calls the given function with the provided arguments and returns its values. If `fn` is `nil` then
-- no action is performed and the function returns `nil`.
-- @function call
-- @tparam function fn
-- @param ... arguments
-- @return ...
-- @return nil if fn is nil
-- @usage lume.call(print, "Hello world") -- Prints "Hello world"
function lume.call(fn, ...)
  if fn then
    return fn(...)
  end
end


local lambda_cache = {}

--- Takes a string lambda and returns a function. `str` should be a list of comma-separated parameters,
-- followed by `->`, followed by the expression which will be evaluated and returned.
-- @function lambda
-- @tparam string str list of comma-separate parameters
-- @treturn func
-- @usage local f = lume.lambda "x,y -> 2*x+y"
--f(10, 5) -- Returns 25
function lume.lambda(str)
  if not lambda_cache[str] then
    local args, body = str:match([[^([%w,_ ]-)%->(.-)$]])
    assert(args and body, "bad string lambda")
    local s = "return function(" .. args .. ")\nreturn " .. body .. "\nend"
    lambda_cache[str] = lume.dostring(s)
  end
  return lambda_cache[str]
end


local serialize

local serialize_map = {
  [ "boolean" ] = tostring,
  [ "nil"     ] = tostring,
  [ "string"  ] = function(v) return string.format("%q", v) end,
  [ "number"  ] = function(v)
    if      v ~=  v     then return  "0/0"      --  nan
    elseif  v ==  1 / 0 then return  "1/0"      --  inf
    elseif  v == -1 / 0 then return "-1/0" end  -- -inf
    return tostring(v)
  end,
  [ "table"   ] = function(t, stk)
    stk = stk or {}
    if stk[t] then error("circular reference") end
    local rtn = {}
    stk[t] = true
    for k, v in pairs(t) do
      rtn[#rtn + 1] = "[" .. serialize(k, stk) .. "]=" .. serialize(v, stk)
    end
    stk[t] = nil
    return "{" .. table.concat(rtn, ",") .. "}"
  end
}

setmetatable(serialize_map, {
  __index = function(_, k) error("unsupported serialize type: " .. k) end
})

serialize = function(x, stk)
  return serialize_map[type(x)](x, stk)
end

--- String
-- @section string

--- Serializes the argument `x` into a string which can be loaded again using `lume.deserialize()`. Only booleans,
-- numbers, tables and strings can be serialized. Circular references will result in an error;
-- all nested tables are serialized as unique tables.
-- @function serialize
-- @tparam bool|number|table|string x
-- @treturn string serialized string
-- @see deserialize
-- @usage lume.serialize({a = "test", b = {1, 2, 3}, false})
-- -- Returns "{[1]=false,["a"]="test",["b"]={[1]=1,[2]=2,[3]=3,},}"
function lume.serialize(x)
  return serialize(x)
end


--- Deserializes a string created by `lume.serialize()` and returns the resulting value. This function should not
-- be run on an untrusted string.
-- @function deserialize
-- @tparam string str
-- @return ... resulting value
-- @see serialize
-- @usage lume.deserialize("{1, 2, 3}") -- Returns {1, 2, 3}
function lume.deserialize(str)
  return lume.dostring("return " .. str)
end


--- Returns an array of the words in the string `str`. If `sep` is provided it is used as the delimiter,
-- consecutive delimiters are not grouped together and will delimit empty strings.
-- @function split
-- @tparam string str
-- @tparam[opt] string sep
-- @treturn table words
-- @usage lume.split("One two three") -- Returns {"One", "two", "three"}
-- @usage lume.split("a,b,,c", ",") -- Returns {"a", "b", "", "c"}
function lume.split(str, sep)
  if not sep then
    return lume.array(str:gmatch("([%S]+)"))
  else
    assert(sep ~= "", "empty separator")
    local psep = patternescape(sep)
    return lume.array((str..sep):gmatch("(.-)("..psep..")"))
  end
end


--- Trims the whitespace from the start and end of the string `str` and returns the new string. If a `chars` value is
-- set the characters in `chars` are trimmed instead of whitespace.
-- @function trim
-- @tparam string str
-- @tparam[opt] string chars
-- @treturn string trimmed string
-- @usage lume.trim("  Hello  ") -- Returns "Hello"
function lume.trim(str, chars)
  if not chars then return str:match("^[%s]*(.-)[%s]*$") end
  chars = patternescape(chars)
  return str:match("^[" .. chars .. "]*(.-)[" .. chars .. "]*$")
end


--- Returns `str` wrapped to `limit` number of characters per line, by default `limit` is `72`. `limit` can also be a
-- function which when passed a string, returns `true` if it is too long for a single line.
-- @function wordwrap
-- @tparam string str
-- @tparam[opt=72] number|function limit
-- @treturn string wrapped string
-- @usage lume.wordwrap("Hello world. This is a short string", 14)
-- -- Returns "Hello world\nThis is a\nshort string"
function lume.wordwrap(str, limit)
  limit = limit or 72
  local check
  if type(limit) == "number" then
    check = function(s) return #s >= limit end
  else
    check = limit
  end
  local rtn = {}
  local line = ""
  for word, spaces in str:gmatch("(%S+)(%s*)") do
    local s = line .. word
    if check(s) then
      table.insert(rtn, line .. "\n")
      line = word
    else
      line = s
    end
    for c in spaces:gmatch(".") do
      if c == "\n" then
        table.insert(rtn, line .. "\n")
        line = ""
      else
        line = line .. c
      end
    end
  end
  table.insert(rtn, line)
  return table.concat(rtn)
end


--- Returns a formatted string. The values of keys in the table `vars` can be inserted into the string by using
-- the form `"{key}"` in `str`; numerical keys can also be used.
-- @function format
-- @tparam string str
-- @tparam[opt] table vars
-- @treturn string
-- @usage lume.format("{b} hi {a}", {a = "mark", b = "Oh"}) -- Returns "Oh hi mark"
-- @usage lume.format("Hello {1}!", {"world"}) -- Returns "Hello world!"
function lume.format(str, vars)
  if not vars then return str end
  local f = function(x)
    return tostring(vars[x] or vars[tonumber(x)] or "{" .. x .. "}")
  end
  return (str:gsub("{(.-)}", f))
end


--- Miscellaneous
-- @section misc

--- Inserts the arguments into function `fn` and calls it. Returns the time in seconds the function `fn` took
-- to execute followed by `fn`'s returned values.
-- @function time
-- @tparam function fn
-- @param ... arguments
-- @treturn number
-- @usage lume.time(function(x) return x end, "hello") -- Returns 0, "hello"
function lume.time(fn, ...)
  local start = os.clock()
  local rtn = {fn(...)}
  return (os.clock() - start), unpack(rtn)
end



--- Prints the current filename and line number followed by each argument separated by a space.
-- @function trace
-- @param ... arguments
-- @treturn string current filename, line number, and arguments
-- @usage -- Assuming the file is called "example.lua" and the next line is 12:
--lume.trace("hello", 1234) -- Prints "example.lua:12: hello 1234"
function lume.trace(...)
  local info = debug.getinfo(2, "Sl")
  local t = { info.short_src .. ":" .. info.currentline .. ":" }
  for i = 1, select("#", ...) do
    local x = select(i, ...)
    if type(x) == "number" then
      x = string.format("%g", lume.round(x, .01))
    end
    t[#t + 1] = tostring(x)
  end
  print(table.concat(t, " "))
end


--- Executes the lua code inside `str`.
-- @function dostring
-- @tparam string str
-- @usage lume.dostring("print('Hello!')") -- Prints "Hello!"
function lume.dostring(str)
  return assert((loadstring or load)(str))()
end


--- Generates a random UUID string; version 4 as specified in [RFC 4122](http://www.ietf.org/rfc/rfc4122.txt).
-- @function uuid
-- @treturn string uuid
function lume.uuid()
  local fn = function(x)
    local r = math.random(16) - 1
    r = (x == "x") and (r + 1) or (r % 4) + 9
    return ("0123456789abcdef"):sub(r, r)
  end
  return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", fn))
end


--- Reloads an already loaded module in place, allowing you to immediately see the effects of code changes without
-- having to restart the program. `modname` should be the same string used when loading the module with require().
-- In the case of an error the global environment is restored and `nil` plus an error message is returned.
-- @function hotswap
-- @tparam module modname
-- @treturn module
-- @treturn nil,string If an error occurs
-- @usage lume.hotswap("lume") -- Reloads the lume module
-- @usage assert(lume.hotswap("inexistant_module")) -- Raises an error
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
    for k in pairs(_G) do _G[k] = oldglobal[k] end
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


local ripairs_iter = function(t, i)
  i = i - 1
  local v = t[i]
  if v ~= nil then
    return i, v
  end
end

--- Performs the same function as `ipairs()` but iterates in reverse; this allows the removal of items from the table
-- during iteration without any items being skipped.
-- @function ripairs
-- @tparam function t
-- @treturn function
-- @usage -- Prints "3->c", "2->b" and "1->a" on separate lines
-- for i, v in lume.ripairs({ "a", "b", "c" }) do
--   print(i .. "->" .. v)
-- end
function lume.ripairs(t)
  return ripairs_iter, t, (#t + 1)
end


--- Takes color string `str` and returns 4 values, one for each color channel (`r`, `g`, `b` and `a`). By default the
-- returned values are between 0 and 1; the values are multiplied by the number `mul` if it is provided.
-- @function color
-- @tparam string str
-- @tparam[opt] number mul
-- @treturn number,number,number,number r, g, b, a
-- @usage lume.color("#ff0000")               -- Returns 1, 0, 0, 1
-- @usage lume.color("rgba(255, 0, 255, .5)") -- Returns 1, 0, 1, .5
-- @usage lume.color("#00ffff", 256)          -- Returns 0, 256, 256, 256
-- @usage lume.color("rgb(255, 0, 0)", 256)   -- Returns 256, 0, 0, 256
function lume.color(str, mul)
  mul = mul or 1
  local r, g, b, a
  r, g, b = str:match("#(%x%x)(%x%x)(%x%x)")
  if r then
    r = tonumber(r, 16) / 0xff
    g = tonumber(g, 16) / 0xff
    b = tonumber(b, 16) / 0xff
    a = 1
  elseif str:match("rgba?%s*%([%d%s%.,]+%)") then
    local f = str:gmatch("[%d.]+")
    r = (f() or 0) / 0xff
    g = (f() or 0) / 0xff
    b = (f() or 0) / 0xff
    a = f() or 1
  else
    error(("bad color string '%s'"):format(str))
  end
  return r * mul, g * mul, b * mul, a * mul
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

--- Returns a wrapped object which allows chaining of lume functions. The function result() should be called
-- at the end of the chain to return the resulting value.
-- The table returned by the `lume` module, when called, acts in the same manner as calling chain().
-- @usage lume.chain({1, 2, 3, 4})
--   :filter(function(x) return x % 2 == 0 end)
--   :map(function(x) return -x end)
--   :result() -- Returns { -2, -4 }
-- @usage lume({1, 2, 3}):each(print) -- Prints 1, 2 then 3 on separate lines
-- @function chain
-- @tparam table value
-- @treturn table
function lume.chain(value)
  return setmetatable({ _value = value }, chain_mt)
end

setmetatable(lume,  {
  __call = function(_, ...)
    return lume.chain(...)
  end
})


return lume
