local tester = require "util.tester"

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

-- lume.vector
tests["lume.vector"] = function()
  local function cmp(a, b) return math.abs(a - b) < 10e-6 end
  local x, y
  x, y = lume.vector(0, 10)
  testeq( cmp(x, 10) and cmp(y, 0), true )
  x, y = lume.vector(math.pi, 100)
  testeq( cmp(x, -100) and cmp(y, 0), true )
  x, y = lume.vector(math.pi * 0.25, 100)
  testeq( cmp(x, 70.71067811865476) and cmp(y, 70.71067811865476), true )
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

-- lume.push
tests["lume.push"] = function()
  local t = { 1, 2 }
  lume.push(t, 3, 4)
  testeq(t, { 1, 2, 3, 4 })
  lume.push(t, 5, nil, 6, nil, 7)
  testeq(t, { 1, 2, 3, 4, 5, 6, 7 })
  lume.push(t)
  testeq(t, { 1, 2, 3, 4, 5, 6, 7 })
  local x, y = lume.push(t, 123, 456)
  testeq(x, 123)
  testeq(y, 456)
end

-- lume.remove
tests["lume.remove"] = function()
  local t = { 1, 2, 3, 4, 5 }
  lume.remove(t, 3)
  testeq(t, { 1, 2, 4, 5  })
  lume.remove(t, 1)
  testeq(t, { 2, 4, 5 })
  lume.remove(t, 5)
  testeq(t, { 2, 4 })
  local x = lume.remove(t, 123)
  testeq(x, 123)
end

-- lume.clear
tests["lume.clear"] = function()
  local t = { 1, 2, 3 }
  lume.clear(t)
  testeq(t, {})
  local m = { a = 1, b = 2, c = 3 }
  lume.clear(m)
  testeq(m, {})
  testeq( lume.clear(t) == t, true )
end

-- lume.extend
tests["lume.extend"] = function()
  local t = { a = 10, b = 20, c = 30 }
  testeq( lume.extend(t) == t, true )
  lume.extend(t, { d = 40 }, { e = 50 })
  testeq( t, { a = 10, b = 20, c = 30, d = 40, e = 50 } )
  lume.extend(t, { a = "cat", b = "dog" }, { b = "owl", c = "fox" })
  testeq( t, { a = "cat", b = "owl", c = "fox", d = 40, e = 50 } )
end

-- lume.shuffle
tests["lume.shuffle"] = function()
  local t = {1, 2, 3, 4, 5}
  t = lume.shuffle(t)
  table.sort(t)
  testeq( t,                {1, 2, 3, 4, 5} )
  testeq( lume.shuffle({}), {}              )
end

-- lume.sort
tests["lume.sort"] = function()
  local t = { 1, 5, 2, 4, 3 }
  local fn = function(a, b) return a > b end
  testeq( t == lume.sort(t), false             )
  testeq( lume.sort(t),      { 1, 2, 3, 4, 5 } )
  testeq( lume.sort(t, fn),  { 5, 4, 3, 2, 1 } )
  testeq( t,                 { 1, 5, 2, 4, 3 } )
  local t = { { id = 2 }, { id = 3 }, { id = 1 } }
  testeq( lume.sort(t, "id"), { { id = 1 }, { id = 2 }, { id = 3 } })
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
  local t = {{ id = 10 }, { id = 20 }, { id = 30 }}
  testeq( lume.map(t, "id"), { 10, 20, 30 })
end

-- lume.all
tests["lume.all"] = function()
  testeq( lume.all({true, true, false, true}),                        false )
  testeq( lume.all({true, true, true, true}),                         true  )
  testeq( lume.all({2, 3, 4, 5}, function(x) return x % 2 == 0 end),  false )
  testeq( lume.all({2, 4, 6, 8}, function(x) return x % 2 == 0 end),  true  )
  testeq( lume.all({{ x = 1 }, {}, { x = 3 }}, "x"),                  false )
  testeq( lume.all({{ x = 1 }, { x = 2 }, { x = 3 }}, "x"),           true  )
  testeq( lume.all({{ x = 1 }, { x = 2 }, { x = 3 }}, { x = 2 }),     false )
  testeq( lume.all({{ x = 2 }, { x = 2 }, { x = 2 }}, { x = 2 }),     true  )
end

-- lume.any
tests["lume.any"] = function()
  testeq( lume.any({true, true, false, true}),                        true  )
  testeq( lume.any({false, false, false}),                            false )
  testeq( lume.any({2, 3, 4, 5}, function(x) return x % 2 == 0 end),  true  )
  testeq( lume.any({1, 3, 5, 7}, function(x) return x % 2 == 0 end),  false )
  local t = {{ id = 10 }, { id = 20 }, { id = 30 }}
  testeq( lume.any(t, { id = 10 }), true  )
  testeq( lume.any(t, { id = 40 }), false )
end

-- lume.reduce
tests["lume.reduce"] = function()
  local concat = function(a, b) return a .. b end
  local add = function(a, b) return a + b end
  local any = function(a, b) return a or b end
  testeq( lume.reduce({"cat", "dog"}, concat, ""),    "catdog"    )
  testeq( lume.reduce({"cat", "dog"}, concat, "pig"), "pigcatdog" )
  testeq( lume.reduce({"me", "ow"}, concat),          "meow"      )
  testeq( lume.reduce({1, 2, 3, 4}, add),             10          )
  testeq( lume.reduce({1, 2, 3, 4}, add, 5),          15          )
  testeq( lume.reduce({1}, add),                      1           )
  testeq( lume.reduce({}, concat, "potato"),          "potato"    )
  testeq( lume.reduce({a=1, b=2}, add, 5),            8           )
  testeq( lume.reduce({a=1, b=2}, add),               3           )
  testeq( lume.reduce({false, false, false}, any),    false       )
  testeq( lume.reduce({false, true, false}, any),     true        )
  tester.test.error(lume.reduce, {}, add)
end

-- lume.unique
tests["lume.unique"] = function()
  testeq( lume.unique({}), {} )
  local t = lume.unique({1, 2, 3, 2, 5, 6, 6})
  table.sort(t)
  testeq( t, {1, 2, 3, 5, 6} )
  local t = lume.unique({"a", "b", "c", "b", "d"})
  table.sort(t)
  testeq( t, {"a", "b", "c", "d"} )
end

-- lume.filter
tests["lume.filter"] = function()
  local t = lume.filter({1, 2, 3, 4, 5}, function(x) return x % 2 == 0 end  )
  testeq( t, {2, 4} )
  local t = lume.filter({a=1, b=2, c=3}, function(x) return x == 2 end, true)
  testeq( t, {b=2} )
  local t = lume.filter({{ x=1, y=1 }, { x=2, y=2 }, { x=1, y=3 }}, { x = 1 })
  testeq( t, {{ x=1, y=1 }, {x=1, y=3}} )
end

-- lume.reject
tests["lume.reject"] = function()
  local t = lume.reject({1, 2, 3, 4, 5}, function(x) return x % 2 == 0 end  )
  testeq( t, {1, 3, 5} )
  local t = lume.reject({a=1, b=2, c=3}, function(x) return x == 2 end, true)
  testeq( t, {a=1, c=3} )
  local t = lume.reject({{ x=1, y=1 }, { x=2, y=2 }, { x=1, y=3 }}, { x = 1 })
  testeq( t, {{ x=2, y=2 }} )
end

-- lume.merge
tests["lume.merge"] = function()
  testeq( lume.merge(),                       {}              )
  testeq( lume.merge({x=1, y=2}),             {x=1, y=2}      )
  testeq( lume.merge({a=1, b=2}, {b=3, c=4}), {a=1, b=3, c=4} )
end

-- lume.concat
tests["lume.concat"] = function()
  testeq( lume.concat(nil),                            {}                    )
  testeq( lume.concat({1, 2, 3}),                      {1, 2, 3}             )
  testeq( lume.concat({1, 2, 3}, {4, 5, 6}),           {1, 2, 3, 4, 5, 6}    )
  testeq( lume.concat({1, 2, 3}, {4, 5, 6}, nil, {7}), {1, 2, 3, 4, 5, 6, 7} )
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
  local t3 = { {x=1, y=2}, {x=3, y=4}, {x=5, y=6} }
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
  local v, k = lume.match(t3, { x = 3, y = 4 })
  testeq( k, 2    )
end

-- lume.count
tests["lume.count"] = function()
  local t = { a = 1, b = 2, c = 5, [13] = 22, z = 8 }
  testeq( lume.count(t), 5 )
  testeq( lume.count(t, function(x) return x % 2 == 0 end ), 3 )
  local a = { 5, 6, 7, 8, 9 }
  testeq( lume.count(a), #a )
  local t = { { n = 20 }, { n = 30 }, { n = 40 }, { n = 20 } }
  testeq( lume.count(t, { n = 20 }),  2 )
  testeq( lume.count(t, { n = 30 }),  1 )
  testeq( lume.count(t, { n = 50 }),  0 )
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

-- lume.first
tests["lume.first"] = function()
  local t = { "a", "b", "c", "d", "e" }
  testeq( lume.first(t),    "a"           )
  testeq( lume.first(t, 1), { "a" }       )
  testeq( lume.first(t, 2), { "a", "b" }  )
end

-- lume.last
tests["lume.last"] = function()
  local t = { "a", "b", "c", "d", "e" }
  testeq( lume.last(t),     "e"           )
  testeq( lume.last(t, 1),  { "e" }       )
  testeq( lume.last(t, 2),  { "d", "e" }  )
end

-- lume.invert
tests["lume.invert"] = function()
  testeq( lume.invert({}),                        {}                  )
  testeq( lume.invert{a = "x", b = "y"},          {x = "a", y = "b"}  )
  testeq( lume.invert{a = 1, b = 2},              {"a", "b"}          )
  testeq( lume.invert(lume.invert{a = 1, b = 2}), {a = 1, b = 2}      )
end

-- lume.pick
tests["lume.pick"] = function()
  local t = { cat = 10, dog = 20, fox = 30, owl = 40 }
  testeq( lume.pick(t, "cat", "dog"), { cat = 10, dog = 20 } )
  testeq( lume.pick(t, "fox", "owl"), { fox = 30, owl = 40 } )
  testeq( lume.pick(t, "owl"), { owl = 40 } )
  testeq( lume.pick(t), {} )
end

-- lume.keys
tests["lume.keys"] = function()
  testeq( lume.keys({}), {} )
  local t = lume.keys({ aaa = 1, bbb = 2, ccc = 3 })
  table.sort(t)
  testeq( t, {"aaa", "bbb", "ccc"} )
  local t = lume.keys({ "x", "x", "x" })
  testeq( t, {1, 2, 3} )
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
  local x = false
  fn = lume.combine(function() x = true end)
  fn()
  testeq( x, true )
  testeq( type(lume.combine(nil)), "function" )
  testeq( type(lume.combine()),    "function" )
end

-- lume.call
tests["lume.call"] = function()
  local add = function(a, b) return a + b end
  testeq( lume.call(),              nil )
  testeq( lume.call(nil, 1, 2, 3),  nil )
  testeq( lume.call(add, 1, 2),     3   )
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
  testeq( lume.deserialize(lume.serialize(math.huge)), math.huge )
  testeq( lume.deserialize(lume.serialize(-math.huge)), -math.huge )
  local x = lume.deserialize(lume.serialize(0 / 0)) -- nan
  testeq( x ~= x, true )
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

-- lume.wordwrap
tests["lume.wordwrap"] = function()
  local str = "A small string with some words and then some more   words"
  local b = "A small string with \nsome words and then \nsome more   words"
  local fn = function(str) return #str >= 20 end
  testeq( lume.wordwrap(str),     str )
  testeq( lume.wordwrap(str, 20), b   )
  testeq( lume.wordwrap(str, fn), b   )
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
    file, line, msg = x:match("(.-):(.-): (.*)")
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

-- lume.ripairs
tests["lume.ripairs"] = function()
  local t = { "a", "b", false, "c" }
  local r = {}
  for i, v in lume.ripairs(t) do
    table.insert(r, { i, v })
  end
  testeq( r, { { 4, "c" }, { 3, false }, { 2, "b" }, { 1, "a" } })
  tester.test.error(lume.ripairs, nil)
end

-- lume.color
tests["lume.color"] = function()
  testeq({ lume.color("#ff0000") },                   { 1, 0, 0, 1 }  )
  testeq({ lume.color("#00ff00") },                   { 0, 1, 0, 1 }  )
  testeq({ lume.color("#0000ff") },                   { 0, 0, 1, 1 }  )
  testeq({ lume.color("rgb( 255, 255, 255 )") },      { 1, 1, 1, 1 }  )
  testeq({ lume.color("rgb (0, 0, 0)") },             { 0, 0, 0, 1 }  )
  testeq({ lume.color("rgba(255, 255, 255, .5)") },   { 1, 1, 1, .5 } )
  testeq({ lume.color("#ffffff", 2) },                { 2, 2, 2, 2 }  )
  testeq({ lume.color("rgba(255, 255, 255, 1)", 3) }, { 3, 3, 3, 3 }  )
  tester.test.error(lume.color, "#ff00f")
  tester.test.error(lume.color, "#xyzxyz")
  tester.test.error(lume.color, "rgba(hello)")
  tester.test.error(lume.color, "rgba()")
  tester.test.error(lume.color, "rgba(1, 1, 1, 1")
end

-- lume.chain
tests["lume.chain"] = function()
  local t = lume.chain({1, 2}):map(function(x) return x * 2 end):result()
  testeq( t, { 2, 4 } )
  testeq( lume.chain(10):result(), 10 )
  local t = lume({1, 2}):map(function(x) return x * 2 end):result()
  testeq( t, { 2, 4 } )
end


tester.dotests(tests)
tester.test.global()
tester.printresults()
