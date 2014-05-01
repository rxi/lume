local tester = require "tester"

package.path = "../?.lua;" .. package.path

local lume = require "lume"

local tests = {}
local testeq = tester.test.equal

-- lume.clamp
tests["lume.clamp"] = function()
  testeq( lume.clamp(8, 5, 10),       8     )
  testeq( lume.clamp(12, 5, 10),      10    )
  testeq( lume.clamp(-1, 5, 10),      5     )
  testeq( lume.clamp(-1, -10, 10),    -1    )
  testeq( lume.clamp(-100, -10, 10),  -10   )
  testeq( lume.clamp(13, 8, 8),       8     )
  testeq( lume.clamp(3, 8, 8),        8     )
end

-- lume.round
tests["lume.round"] = function()
  testeq( lume.round(.5),           1       )   
  testeq( lume.round(-.5),          -1      )
  testeq( lume.round(2.4),          2       )
  testeq( lume.round(123, 10),      120     )
  testeq( lume.round(129, 64),      128     )
  testeq( lume.round(-123.45, .1),  -123.5  )
  testeq( lume.round(0),            0       )
end

-- lume.sign
tests["lume.sign"] = function()
  testeq( lume.sign(-10),  -1 )
  testeq( lume.sign(10),   1  )
  testeq( lume.sign(0),    1  )
end

-- lume.lerp
tests["lume.lerp"] = function()
  testeq( lume.lerp(100, 200, .5),    150  )
  testeq( lume.lerp(100, 200, .25),   125  )
  testeq( lume.lerp(100, 200, 2),     200  )
  testeq( lume.lerp(100, 200, -2),    100  )
end

-- lume.smooth
tests["lume.smooth"] = function()
  testeq( lume.smooth(100, 200, .5),  150  )
  testeq( lume.smooth(100, 200, 0),   100  )
  testeq( lume.smooth(100, 200, 1),   200  )
  testeq( lume.smooth(100, 200, 2),   200  )
  testeq( lume.smooth(100, 200, -2),  100  )
end

-- lume.pingpong
tests["lume.pingpong"] = function()
  testeq( lume.pingpong(0),     0   )
  testeq( lume.pingpong(1.5),   .5  )
  testeq( lume.pingpong(-.2),   .2  )
  testeq( lume.pingpong(-1.6),  .4  )
  testeq( lume.pingpong(1.8),   .2  )
end

-- lume.distance
tests["lume.distance"] = function()
  testeq( lume.distance(15, 20, 15, 20),        0             )
  testeq( lume.distance(13, 44, 156, 232),      236.205419074 )
  testeq( lume.distance(-23, 66, -232, 123),    216.633330769 )
  local x = lume.distance(13, 15, -2, 81)
  testeq( lume.distance(13, 15, -2, 81, true),  x * x         )
end

-- lume.angle
tests["lume.angle"] = function()
  testeq( lume.angle(10, 10, 10, 10), math.rad(0)   )
  testeq( lume.angle(10, 10, 20, 10), math.rad(0)   )
  testeq( lume.angle(10, 10, 5,  10), math.rad(180) )
  testeq( lume.angle(10, 10, 20, 20), math.rad(45)  )
  testeq( lume.angle(10, 10, 10, 30), math.rad(90)  )
end

-- lume.random
tests["lume.random"] = function()
  testeq( type(lume.random()),      "number" )
  testeq( type(lume.random(1)),     "number" )
  testeq( type(lume.random(1, 2)),  "number" )
end

-- lume.randomchoice
tests["lume.randomchoice"] = function()
  local t = {}
  for i = 0, 1000 do
    t[lume.randomchoice({"a", "b", "c", "d"})] = true
  end
  testeq( t.a and t.b and t.c and t.d,  true )
  testeq( lume.randomchoice({true}),    true )
end

-- lume.weightedchoice
tests["lume.weightedchoice"] = function()
  testeq( lume.weightedchoice( {a = 1} ),         "a" )
  testeq( lume.weightedchoice( {a = 0, b = 1} ),  "b" )
  tester.test.error( lume.weightedchoice, {}                  )
  tester.test.error( lume.weightedchoice, { a = 0, b = 0 }    )
  tester.test.error( lume.weightedchoice, { a = 1, b = -1 }   )
end

-- lume.shuffle
tests["lume.shuffle"] = function()
  local t = {1, 2, 3, 4, 5}
  lume.shuffle(t)
  table.sort(t)
  testeq( t,                {1, 2, 3, 4, 5} )
  testeq( lume.shuffle({}), {}              )
end

-- lume.array
tests["lume.array"] = function()
  local t = lume.array(pairs({a=0, b=0, c=0}))
  table.sort(t)
  testeq( t,                              {"a", "b", "c"} )
  testeq( lume.array(ipairs({0, 0, 0})),  {1, 2, 3}       )
end

-- lume.each
tests["lume.each"] = function()
  local acc = 1
  lume.each({1, 2, 3}, function(x) acc = acc + x end)
  testeq( acc, 7  )

  local acc = 1
  local f = function(o, x) acc = acc + x end
  local f2 = function() end
  local t = {a = {f = f}, b = {f = f}, c = {f = f2}}
  lume.each(t, "f", 10)
  testeq( acc, 21 )
end

-- lume.map
tests["lume.map"] = function()
  testeq( lume.map({1, 2, 3}, function(x) return x * 2 end), {2, 4, 6} )
  testeq( lume.map({a=2,b=3}, function(x) return x * 2 end), {a=4,b=6} )
end

-- lume.all
tests["lume.all"] = function()
  testeq( lume.all({true, true, false, true}),                        false )
  testeq( lume.all({true, true, true, true}),                         true  )
  testeq( lume.all({2, 3, 4, 5}, function(x) return x % 2 == 0 end),  false )
  testeq( lume.all({2, 4, 6, 8}, function(x) return x % 2 == 0 end),  true  )
end

-- lume.any
tests["lume.any"] = function()
  testeq( lume.any({true, true, false, true}),                        true  )
  testeq( lume.any({false, false, false}),                            false )
  testeq( lume.any({2, 3, 4, 5}, function(x) return x % 2 == 0 end),  true  )
  testeq( lume.any({1, 3, 5, 7}, function(x) return x % 2 == 0 end),  false )
end

-- lume.reduce
tests["lume.reduce"] = function()
  local concat = function(a, b) return a .. b end
  local add = function(a, b) return a + b end
  testeq( lume.reduce({"cat", "dog"}, concat, ""),    "catdog"    )
  testeq( lume.reduce({"cat", "dog"}, concat, "pig"), "pigcatdog" )
  testeq( lume.reduce({"me", "ow"}, concat),          "meow"      )
  testeq( lume.reduce({1, 2, 3, 4}, add),             10          )
  testeq( lume.reduce({1, 2, 3, 4}, add, 5),          15          )
  testeq( lume.reduce({1}, add),                      1           )
  testeq( lume.reduce({}, concat, "potato"),          "potato"    )
end

-- lume.set
tests["lume.set"] = function()
  testeq( lume.set({}), {} )
  local t = lume.set({1, 2, 3, 2, 5, 6, 6})
  table.sort(t)
  testeq( t, {1, 2, 3, 5, 6} )
  local t = lume.set({"a", "b", "c", "b", "d"})
  table.sort(t)
  testeq( t, {"a", "b", "c", "d"} )
end

-- lume.filter
tests["lume.filter"] = function()
  local t = lume.filter({1, 2, 3, 4, 5}, function(x) return x % 2 == 0 end  ) 
  testeq( t, {2, 4} )
  local t = lume.filter({a=1, b=2, c=3}, function(x) return x == 2 end, true) 
  testeq( t, {b=2} )
end

-- lume.merge
tests["lume.merge"] = function()
  testeq( lume.merge({1, 2, 3}, {8, 9, 0}),         {1, 2, 3, 8, 9, 0}  )
  testeq( lume.merge({a=1, b=2}, {b=3, c=4}, true), {a=1, b=3, c=4}     )
end

-- lume.find
tests["lume.find"] = function()
  testeq( lume.find({"a", "b", "c"}, "b"),  2   )
  testeq( lume.find({"a", "b", "c"}, "c"),  3   )
  testeq( lume.find({a=1, b=5, c=7}, 5),    "b" )
end

-- lume.match
tests["lume.match"] = function()
  local t = { "a", "b", "c", "d" }
  local t2 = { a = 1, b = 2, c = 3, d = 4 }
  local v, k = lume.match(t, function(x) return x > "c" end)
  testeq( v, "d"  )
  testeq( k, 4    )
  local v, k = lume.match(t, function(x) return x < "b" end)
  testeq( v, "a"  )
  testeq( k, 1    )
  local v, k = lume.match(t2, function(x) return x < 2 end)
  testeq( v, 1    )
  testeq( k, "a"  )
  local v, k = lume.match(t2, function(x) return x > 5 end)
  testeq( v, nil  )
  testeq( k, nil  )
end

-- lume.count
tests["lume.count"] = function()
  local t = { a = 1, b = 2, c = 5, [13] = 22, z = 8 }
  testeq( lume.count(t), 5 )
  testeq( lume.count(t, function(x) return x % 2 == 0 end ), 3 )
  local a = { 5, 6, 7, 8, 9 }
  testeq( lume.count(a), #a )
end

-- lume.slice
tests["lume.slice"] = function()
  testeq( lume.slice({"a", "b", "c", "d", "e"}, 2, 4),    {"b", "c", "d"} )
  testeq( lume.slice({"a", "b", "c", "d", "e"}, 2, -2),   {"b", "c", "d"} )
  testeq( lume.slice({"a", "b", "c", "d", "e"}, 3, -1),   {"c", "d", "e"} )
  testeq( lume.slice({"a", "b", "c", "d", "e"}, 3),       {"c", "d", "e"} )
  testeq( lume.slice({"a", "b", "c", "d", "e"}, 4),       {"d", "e"}      )
  testeq( lume.slice({"a", "b", "c", "d", "e"}, 1, 1),    {"a"}           )
  testeq( lume.slice({"a", "b", "c", "d", "e"}, 2, 1),    {}              )
  testeq( lume.slice({"a", "b", "c", "d", "e"}, -3, -2),  {"c", "d"}      )
  testeq( lume.slice({"a", "b", "c", "d", "e"}, -3, 1),   {}              )
  testeq( lume.slice({"a", "b", "c", "d", "e"}, 0, 1),    {"a"}           )
  testeq( lume.slice({"a", "b", "c", "d", "e"}, 0, 0),    {}              )
  testeq( lume.slice({"a", "b", "c", "d", "e"}, -3),      {"c", "d", "e"} )
  testeq( lume.slice({"a", "b", "c", "d", "e"}, -3, 900), {"c", "d", "e"} )
end

-- lume.invert
tests["lume_invert"] = function()
  testeq( lume.invert({}),                        {}                  )
  testeq( lume.invert{a = "x", b = "y"},          {x = "a", y = "b"}  )
  testeq( lume.invert{a = 1, b = 2},              {"a", "b"}          )
  testeq( lume.invert(lume.invert{a = 1, b = 2}), {a = 1, b = 2}      )
end

-- lume.clone
tests["lume.clone"] = function()
  local t = {6, 7, 4, 5}
  testeq( lume.clone(t) ~= t,       true         )
  testeq( lume.clone(t),            {6, 7, 4, 5} )
  testeq( lume.clone({x=2, y="a"}), {x=2, y="a"} )
end

-- lume.fn
tests["lume.fn"] = function()
  local f = lume.fn(function(a, b) return a + b end, 10)
  testeq( f(5),  15 )
  tester.test.error( lume.fn, 123 )
end

-- lume.once
tests["lume.once"] = function()
  local f = lume.once(function(a, b) return a + b end, 10)
  testeq( f(5),  15   )
  testeq( f(5),  nil  )
  tester.test.error( lume.once, 123 )
end

-- lume.memoize
tests["lume.memoize"] = function()
  local f = lume.memoize(
    function(a, b, c)
      return tostring(a) .. tostring(b) .. tostring(c)
    end)
  testeq( f("hello", nil, 15),  "hellonil15"  )
  testeq( f("hello", nil, 15),  "hellonil15"  )
  testeq( f(),                  "nilnilnil"   )
  testeq( f(),                  "nilnilnil"   )
  local f2 = lume.memoize(function() end)
  testeq( f2(), nil )
end

-- lume.combine
tests["lume.combine"] = function()
  local acc = 0
  local a = function(x, y) acc = acc + x + y end
  local b = function(x, y) acc = acc + x * y end
  local fn = lume.combine(a, b)
  fn(10, 20)
  testeq( acc, 230 )
  acc = 0
  fn = lume.combine(nil, a, nil, b, nil)
  fn(10, 20)
  testeq( acc, 230 )
end

-- lume.time
tests["lume.time"] = function()
  local t, a, b, c = lume.time(function(x) return 50, 60, x end, 70)
  testeq( type(t),    "number"      )
  testeq( {a, b, c},  {50, 60, 70}  )
end

-- lume.lambda
tests["lume.lambda"] = function()
  testeq( lume.lambda "x->x*x"(10),                 100         )
  testeq( lume.lambda "x->x*x"(20),                 400         )
  testeq( lume.lambda "x,y -> 2*x+y"(10,5),         25          )
  testeq( lume.lambda "a, b -> a / b"(1, 2),        .5          )
  testeq( lume.lambda "a -> 'hi->' .. a"("doggy"),  "hi->doggy" )
  testeq( lume.lambda "A1,_->A1.._"("te","st"),     "test"      )
  testeq( lume.lambda "->"(1,2,3),                  nil         )
  tester.test.error( lume.lambda, "abc"         )
  tester.test.error( lume.lambda, ""            )
  tester.test.error( lume.lambda, "a,b->a->b"   )
  tester.test.error( lume.lambda, "(a),b->a+b"  )
end

-- lume.serialize / lume.deserialize
tests["lume.serialize, lume.deserialize"] = function()
  local t = { 1, 2, 3, 4, true, false, "cat", "dog", {1, 2, 3} }
  local s = lume.serialize(t)
  testeq( lume.deserialize(s), t )
end

-- lume.split
tests["lume.split"] = function()
  testeq( lume.split("cat   dog  pig"),     {"cat", "dog", "pig"}     )
  testeq( lume.split("cat,dog,pig", ","),   {"cat", "dog", "pig"}     )
  testeq( lume.split("cat,dog;pig", ";"),   {"cat,dog", "pig"}        )
  testeq( lume.split("cat,dog,,pig", ","),  {"cat", "dog", "", "pig"} )
  testeq( lume.split(";;;cat;", ";"),       {"", "", "", "cat", ""}   )
  testeq( lume.split("cat.dog", "."),       {"cat", "dog"}            )
  testeq( lume.split("cat%dog", "%"),       {"cat", "dog"}            )
  testeq( lume.split("1<>2<>3", "<>"),      {"1", "2", "3"}           )
  tester.test.error( lume.split, "abc", "" )
end

-- lume.trim
tests["lume.trim"] = function()
  testeq( lume.trim("   hello world   "),       "hello world"   )
  testeq( lume.trim("-=-hello-world===", "-="), "hello-world"   )
  testeq( lume.trim("***hello world*-*", "*"),  "hello world*-" )
  testeq( lume.trim("...hello world.", "."),    "hello world"   )
  testeq( lume.trim("^.hello world]^", "^.]"),  "hello world"   )
end

-- lume.format
tests["lume.format"] = function()
  local str = lume.format("a {a} in a {b}", {a = "mouse", b = "house"})
  testeq( str, "a mouse in a house" )
  testeq( lume.format("number {num}", {num = 13}),    "number 13"         )
  testeq( lume.format("{missing} {keys}", {}),        "{missing} {keys}"  )
  testeq( lume.format("A {missing} table"),           "A {missing} table" )
  testeq( lume.format("{1} idx {2}", {"an", "test"}), "an idx test"       )
  testeq( lume.format("bad idx {-1}", {"x"}),         "bad idx {-1}"      )
  testeq( lume.format("empty {}", {"idx"}),           "empty {}"          )
end

-- lume.trace
tests["lume.trace"] = function()
  local oldprint = print
  local file, line, msg
  print = function(x)
    file, line, msg = x:match("%[(.-):(.-)%] (.*)")
  end
  lume.trace("Hi world", 123.456, 1, nil)
  print = oldprint
  testeq( file:match(".lua$"),    ".lua"                  )
  testeq( tonumber(line) ~= nil,  true                    ) 
  testeq( msg,                    "Hi world 123.46 1 nil" )
end

-- lume.dostring
tests["lume.dostring"] = function()
  testeq( lume.dostring([[return "hello!"]]), "hello!"  )
  testeq( lume.dostring([[return 12345]]),    12345     )   
end

-- lume.uuid
tests["lume.uuid"] = function()
  testeq( type(lume.uuid()), "string" )
  testeq( #lume.uuid(),      36       )
end

-- lume.hotswap
tests["lume.hotswap"] = function()
  local ok, err = lume.hotswap("bad_module_name")
  testeq( ok,         nil       )
  testeq( type(err),  "string"  )
end

-- lume.rgba
tests["lume.rgba"] = function()
  local r, g, b, a = lume.rgba(0x12345678)
  testeq( a, 0x12 )
  testeq( r, 0x34 )
  testeq( g, 0x56 )
  testeq( b, 0x78 )
end

-- lume.chain
tests["lume.chain"] = function()
  local t = lume.chain({1, 2}):map(function(x) return x * 2 end):result() 
  testeq( t, { 2, 4 } )
  testeq( lume.chain(10):result(), 10 )
end


tester.dotests(tests)
tester.test.global()
tester.printresults()

