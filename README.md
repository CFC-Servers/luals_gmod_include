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
  - `"Lua.runtime.special": { "include": "require", "IncludeCS": "require" },`

If another extension has already set `include` to `dofile` in `Lua.runtime.special`, change it to `require`. LuaLS only calls this plugin for `require`.

LuaLS warns when one file is `require`d under two different names. Different `include` paths to the same file are normal in GMod, so you will probably want to turn that warning off:
  - `"Lua.diagnostics.disable": [ "different-requires" ],`

## How paths are resolved
`include` paths are looked up in the same order GMod uses:
1. Relative to the file calling `include` _(`../` and `./` work)_
2. Relative to the `lua/` or `gamemodes/` folder that the calling file lives in
3. Relative to any other `lua/` or `gamemodes/` folder in your workspace

This means it doesn't matter whether you open a single addon, your whole `addons/` folder, or all of `garrysmod/` as your workspace.


## Technical details
`include`, everyone loves it!... Except LuaLS :(

We can tell LuaLS to remap `include` -> `require`, but that still doesn't quite fix the problem. LuaLS expects `require` to be loading files/modules in the normal Lua way, and has no idea what to do if you include a `.lua` in your path _(which, of course, `include` needs)_.

This plugin updates the logic of LuaLS' `require` functionality to handle `.lua` paths and fake a `require` call in a way that LuaLs understands, while preserving the "relative>absolute" seeking behavior of `include`.

Since LuaLS handles `require` well already, we only need to do a little tinkering with the path and the rest "just works".
