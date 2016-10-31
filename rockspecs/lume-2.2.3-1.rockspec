package = "lume"
version = "2.2.3-1"
source = {
   url = "git://github.com/rxi/lume",
   tag = "v2.2.3"
}
description = {
   summary = "A collection of functions for Lua, geared towards game development.",
   detailed = "A collection of functions for Lua, geared towards game development.",
   homepage = "http://github.com/rxi/lume",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1, < 5.4"
}
build = {
   type = "builtin",
   modules = {
      lume = "lume.lua"
   }
}
