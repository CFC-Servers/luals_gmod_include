# luals_gmod_include
Proper GMod `include` support for LuaLS 🙌

With this plugin, `include` will properly recognize the type of the object returned from `include` 🎉

**Enjoy the perks you've been missing out on!:**
- Proper `include` typing without needing to manually annotate
- Linting violations and warnings if you misuse an `include`'d module
- `include` autocomplete

![image](https://github.com/user-attachments/assets/85e7192b-a2d0-4aba-8cda-7c3fd905fcf7)


## Installation
- Clone this repository somewhere
- Update your LuaLS config:
  - `"Lua.runtime.plugin": [ "/absolute/path/to/luals_gmod_include/plugin.lua" ],`
 

## Technical details
`include`, everyone loves it!... Except LuaLS :(

We can tell LuaLS to remap `include` -> `require`, but that still doesn't quite fix the problem. LuaLS expects `require` to be loading files/modules in the normal Lua way, and has no idea what to do if you include a `.lua` in your path _(which, of course, `include` needs)_.

This plugin updates the logic of LuaLS' `require` functionality to handle `.lua` paths and fake a `require` call in a way that LuaLs understands, while preserving the "relative>absolute" seeking behavior of `include`.

Since LuaLS handles `require` well already, we only need to do a little tinkering with the path and the rest "just works".
