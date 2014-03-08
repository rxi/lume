

local tester = { 
  test = {}, 
  linecache = {},
  globals = {},
  passcount = 0,
  failcount = 0
}


local function isequal(a, b)
  if type(a) ~= type(b) then return nil end
  local t = {}
  function t.table(a, b)
    for k, v in pairs(a) do if not isequal(b[k], v) then return nil end end
    for k, v in pairs(b) do if not isequal(a[k], v) then return nil end end
    return true
  end
  function t.number(a, b) return math.abs(a - b) < 10e-9 end
  return t[type(a)] and t[type(a)](a, b) or (a == b)
end


local function stringify(x)
  if type(x) == "number" then return string.format("%.2f", x) end
  return string.format("%q", tostring(x))
end


local function getline(file, line)
  if not tester.linecache[file] then
    local t = {}
    for line in io.lines(file) do
      t[#t + 1] = line
    end
    tester.linecache[file] = t
  end
  return tester.linecache[file][line]  
end


local function truncate(str, max)
  max = max or 72
  if #str > max then
    return str:sub(1, max - 3) .. "..."
  end
  return str
end


local function has(t, value)
  for k, v in pairs(t) do
    if v == value then return true end
  end
  return false
end


local function makelogstr(passed, file, line)
  local t = {}
  t[#t + 1] = passed and "[\27[32mPASS\27[0m]" or "[\27[31mFAIL\27[0m]"
  t[#t + 1] = file .. ":" .. line .. ":"
  t[#t + 1] = getline(file, line) :gsub(" %s+", " ") :gsub("^ *", "")
  return truncate(table.concat(t, " "))
end


local function dopass(file, line)
  print(makelogstr(true, file, line))
  tester.passcount = tester.passcount + 1
end


local function dofail(file, line)
  print(makelogstr(false, file, line))
  tester.failcount = tester.failcount + 1
end


local function printfailmsg(str)
    print(string.rep(" ", 7) .. str)
end




function tester.init()
  for k, v in pairs(_G) do
    tester.globals[k] = v
  end
  return tester
end


function tester.test.global(expectedglobals)
  expectedglobals = expectedglobals or {}
  local info = debug.getinfo(2)
  local unexpected = {}
  for k in pairs(_G) do
    if not tester.globals[k] and not has(expectedglobals, k) then
      table.insert(unexpected, "Unexpected global '" .. k .. "'")
    end
  end
  if #unexpected == 0 then
    dopass(info.short_src, info.currentline)
  else
    dofail(info.short_src, info.currentline)
    for _, v in pairs(unexpected) do printfailmsg(v) end
  end
end


function tester.test.equal(result, expected)
  local passed = isequal(result, expected)
  local info = debug.getinfo(2)
  if passed then
    dopass(info.short_src, info.currentline)
  else
    dofail(info.short_src, info.currentline)
    if type(expected) == "table" and type(result) == "table" then
      printfailmsg("Tables do not match")
    else
      printfailmsg(string.format("Expected %s got %s",
                                 stringify(expected), stringify(result) ))
    end
  end
end


function tester.test.error(fn, ...)
  local passed = not pcall(fn, ...)
  local info = debug.getinfo(2)
  if passed then
    dopass(info.short_src, info.currentline)
  else
    dofail(info.short_src, info.currentline)
    printfailmsg("Expected an error to be raised")
  end
end


function tester.dotests(t)
  local keys = {}
  for k in pairs(t) do table.insert(keys, k) end
  table.sort(keys)
  for _, k in pairs(keys) do
    print("\27[33m-- " .. k .. "\27[0m")
    t[k]()
  end
end


function tester.printresults()
  local str = table.concat{
    "-- ", 
    string.format("Results:   %d Total", tester.passcount + tester.failcount),
    "   ", string.format("%d Passed", tester.passcount),
    "   ", string.format("%d Failed", tester.failcount), 
    " --", }
  local b = string.rep("-", #str)
  print(table.concat{b, "\n", str, "\n", b})
end


return tester.init()
