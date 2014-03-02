# lume

A collection of functions for Lua, geared towards game development.


## Installation

The [lume.lua](lume.lua?raw=1) file should be dropped into an existing project and
required by it:

```lua
lume = require "lume"
```


## Function reference

### lume.clamp(x, min, max)
Returns the value `x` clamped between the values `min` and `max`

### lume.round(x)
Rounds `x` to the nearest integer. Rounds away from zero if we're midway
between two integers.

### lume.sign(x)
Returns `1` if `x` is 0 or above, returns `-1` when `x` is negative.

### lume.lerp(a, b, amount)
Returns the linearly interpolated value between `a` and `b`, `amount` should be
range of 0 - 1; if `amount` is outside of this range it is clamped.

### lume.smooth(a, b, amount)
Similar to `lume.lerp()` but uses cosine interpolation instead of linear
interpolation.

### lume.pingpong(x)
Ping-pongs the value `x` between 0 and 1.

### lume.distance(x1, y1, x2, y2)
Returns the distance between the two points.

### lume.angle(x1, y2, x2, y2)
Returns the angle between the two points.

### lume.random([a [, b]])
Returns a random number between `a` and `b`. If only `a` is supplied a number
between `0` and `a` is returned. If no arguments are supplied a random number
between `0` and `1` is returned.

### lume.randomchoice(t)
Returns a random value from array `t`.

### lume.shuffle(t)
Shuffles the values of array `t` in place, returns the array.

### lume.array(...)
Iterates the supplied iterator and returns an array filled with the values.
```lua
lume.array(pairs({a = 1, b = 2})) -- Returns {"a", "b"}
```

### lume.map(t, fn)
Applies the function `fn` to each value in table `t` and returns a new table
with the resulting values.
```lua
lume.map({1, 2, 3}, function(x) return x * 2 end) -- Returns {2, 4, 6}
```

### lume.all(t [, fn])
Returns true if all the values in `t` table are true. If a `fn` function is
supplied it is called on each value, true is returned if all of the calls to
`fn` return true.
```lua
lume.all({1, 2, 1}, function(x) return x == 1 end) -- Returns false
```

### lume.any(t [, fn])
Returns true if any of the values in `t` table are true. If a `fn` function is
supplied it is called on each value, true is returned if any of the calls to
`fn` return true.
```lua
lume.any({1, 2, 1}, function(x) return x == 1 end) -- Returns true
```

### lume.reduce(t, fn, first)
Applies `fn` on two arguments cumulative to the items of the array `t`, from
left to right, so as to reduce the array to a single value. The accumulator is
intialised to the `first` value.
```lua
lume.reduce({1, 2, 3}, function(a, b) return a + b end, 0) -- Returns 6
```

### lume.set(t [, retainkeys])
Returns a copy of the `t` table with all the duplicate values removed. If
`retainkeys` is true the table is not treated as an array and retains its
original keys.
```lua
lume.set({2, 1, 2, "cat", "cat"}) -- Returns {1, 2, cat}
```

### lume.filter(t, fn [, retainkeys])
Calls `fn` on each value of `t` table. Returns a new table with only the values
where `fn` returned true. If `retainkeys` is true the table is not treated as
an array and retains its original keys.
```lua
lume.filter({1, 2, 3, 4}, function(x) return x % 2 == 0 end) -- Returns {2, 4}
```

### lume.merge(t, t2 [, retainkeys])
Merges all the values from the table `t2` into `t` in place. If `retainkeys` is
true the table is not treated as an array and retains its original keys; if `t`
and `t2` have a conflicting key, the value from `t2` is used.
```lua
lume.merge({2, 3}, {4, 5}) -- Returns {2, 3, 4, 5}
```

### lume.find(t, value)
Returns the index/key of `value` in `t`. Returns `nil` if that value does not
exist in the table.
```lua
lume.find({"a", "b", "c"}, "b") -- Returns 2
```


### lume.slice(t [, i [, j]])
Mimics the behaviour of Lua's `string.sub`, but operates on an array rather
than a string. Creates and returns a new array of the given slice.
```lua
lume.slice({"a", "b", "c", "d", "e"}, 2, 4) -- Returns {"b", "c", "d"}
```

### lume.clone(t)
Returns a shallow copy of the table `t`.

### lume.fn(fn, ...)
Creates a wrapper function around function `fn`, automatically inserting the
arguments into `fn` which will persist every time the wrapper is called.
```lua
local f = lume.fn(print, "Hello")
f() -- Prints "Hello"
```

### lume.once(fn, ...)
Returns a wrapper function to `fn` which takes the supplied arguments. The
wrapper function will call `fn` on the first call and do nothing on any
subsequent calls.
```lua
local f = lume.once(print, "Hello")
f() -- Prints "Hello"
f() -- Does nothing
```

### lume.time(fn, ...)
Inserts the arguments into function `fn` and calls it. Returns the time in
seconds the function `fn` took to execute followed by `fn`'s returned values.
```lua
lume.time(function(x) return x end, "hello") -- Returns 0, "hello"
```

### lume.serialize(x)
Serializes the argument `x` into a string which can be loaded again using
`lume.deserialize()`. Only booleans, numbers, tables and strings can be
serialized. Circular references are not handled; all nested tables are
serialized as unique tables.
```lua
lume.serialize({a = "test", b = {1, 2, 3}, false})
-- Returns "{[1]=false,["a"]="test",["b"]={[1]=1,[2]=2,[3]=3,},}"
```

### lume.deserialize(str)
Deserializes a string created by `lume.serialize()` and returns the resulting
value. This function should not be run on an untrusted string.
```lua
lume.deserialize("{1, 2, 3}") -- Returns {1, 2, 3}
```

### lume.split(str [, sep])
Splits the string `str` into words and returns a table of the sub strings. If
`sep` is provided the string will be split at any of the characters in `sep`
instead of on whitespace.
```lua
lume.split("One two three") -- Returns {"One", "two", "three"}
```

### lume.trim(str [, chars])
Trims the whitespace from the start and end of the string `str` and returns the
new string. If a `chars` value is set the characters in `chars` are trimmed
instead of whitespace.
```lua
lume.trim("  Hello  ") -- Returns "Hello"
```

### lume.format(str, vars)
Returns a formatted string. The values of keys in the table `vars` can be
inserted into the string by using the form `"{key}"` in `str`.
```lua
lume.format("Hello {a}, I hope {a} is {b}.", {a = "world", b = "well"})
-- Returns "Hello world, I hope world is well."
```

### lume.dostring(str)
Executes the lua code inside `str`.
```lua
lume.dostring("print('Hello!')") -- Prints "Hello!"
```

### lume.hotswap(modname)
Reloads an already loaded module in place; `modname` should be the same string
used when loading the module with require(). This function can be used to
immediatly see the effects of code changes without having to restart the
program.
```lua
lume.hotswap("lume") -- Reloads the lume module
```

### lume.rgba(color)
Takes the 32bit integer `color` argument and returns 4 numbers, one for each
channel, with a range of 0 - 255. The returned values can be used as the
arguments to [LÖVE](http://love2d.org)'s setColor() function.
```lua
lume.rgba(0xFF304050) -- Returns 48, 64, 80, 255
```


## License

This library is free software; you can redistribute it and/or modify it under
the terms of the MIT license. See [LICENSE](LICENSE) for details.

