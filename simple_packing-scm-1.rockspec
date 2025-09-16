package = "simple_packing"
version = "scm-1"
source = {
   url = "git+https://github.com/YOUR_USERNAME/Simple-Packing.git"
}
description = {
   summary = "Simple Packing mod for Project Zomboid",
   detailed = "A mod that provides simple packing functionality for Project Zomboid B41",
   homepage = "https://github.com/YOUR_USERNAME/Simple-Packing",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1",
   "luaunit >= 3.4"
}
build = {
   type = "builtin",
   modules = {}
}