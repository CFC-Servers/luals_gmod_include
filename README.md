# luals_gmod_include
Proper GMod `include` support for LuaLS 🙌

_(`include` will properly recognize the type of the object returned from `include` 🎉)_

- 👉 [Installation](https://github.com/CFC-Servers/luals_gmod_include?tab=readme-ov-file#installation)
- 👉 [Technical Details](https://github.com/CFC-Servers/luals_gmod_include?tab=readme-ov-file#technical-details)


## Showcase
Let's say you have a project like this:
```lua
-- lua/myAddon/module.lua

--- @class MyModule
local MyModule = {
    example = "Hello!"
}

--- Runs some work inside the module
function MyModule:RunWork()
    print( "Running that work real good" )
end

return MyModule
```
    
```lua
-- lua/myAddon/sv_init.lua

--- @class MyAddon
MyAddon = {}

local Module = include( "module.lua" )
MyAddon.Module = Module

Module:RunWork()
```

`MyModule` is properly typed, but because `include` can't figure out what's being returned, you won't get autocomplete or type checking when you go to use it:

![image](https://github.com/user-attachments/assets/f828d4b1-5570-4371-8895-361f70af378f)


You could annotate it yourself with `--- @type`, of course:

![image](https://github.com/user-attachments/assets/c80ed13e-f34b-40d4-8410-193014b7fc29)

...but that means if you ever update the type name or change what that file returns, your `sv_init.lua` will think that it's _supposed_ to be of the type you specifically set.
For example, LuaLS is happily unaware that this code will error:

![image](https://github.com/user-attachments/assets/bd33a2c0-3a17-4dd5-8e8b-b38ab8ecbe1d)


But, with proper `include` support, LuaLS is smart enough to catch that situation 😌:

![image](https://github.com/user-attachments/assets/f1161a7d-e02a-4314-973f-5007924d8395)


## Installation
- Clone this repository somewhere
- Update your LuaLS config:
  - `"Lua.runtime.plugin": [ "/absolute/path/to/luals_gmod_include/plugin.lua" ],`
 

## Technical details
`include`, everyone loves it!... Except LuaLS :(

We can tell LuaLS to remap `include` -> `require`, but that still doesn't quite fix the problem. LuaLS expects `require` to be loading a module, and has no idea what to do if you include a `.lua` in your path _(which, of course, `include` needs)_.

This plugin updates the logic of LuaLS' `require` functionality to handle `.lua` paths and fake a `require` call in a way that LuaLs understands, while preserving the "relative>absolute" seeking behavior of `include`.

Since LuaLS handles `require` well already, we only need to do a little tinkering with the path and the rest "just works".
