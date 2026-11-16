local fs = require( "bee.filesystem" )
local furi = require( "file-uri" )
local files = require( "files" )

local luaRootNames = { "lua", "gamemodes" }

local skipIncludeNames = {
    __newindex = function( cache, name, result )
        if string.sub( name, -4 ) == ".lua" then return end
        rawset( cache, name, result )
    end
}

--- @param name string
--- @return string
local function encodeIncludeName( name )
    local forwardSlashed = name:gsub( "\\", "/" )
    local encoded = furi.encode( forwardSlashed ):gsub( "^file:/*", "" )

    return encoded
end

--- @param uri string
--- @return string
local function collapseDotSegments( uri )
    uri = uri:gsub( "/%.%f[/]", "" )

    local collapsed
    repeat
        uri, collapsed = uri:gsub( "/[^/]+/%.%./", "/", 1 )
    until collapsed == 0

    return uri
end

--- @param baseURI string
--- @param encodedName string
--- @return string?
local function existingURI( baseURI, encodedName )
    local uri = collapseDotSegments( baseURI .. "/" .. encodedName )
    if not fs.exists( furi.decode( uri ) ) then return nil end

    return files.getRealUri( uri )
end

--- @param scopeURI string?
--- @param encodedName string
--- @return string[]
local function findUnderAnyLuaRoot( scopeURI, encodedName )
    local matches = {}

    for knownURI in files.eachFile( scopeURI ) do
        for _, rootName in ipairs( luaRootNames ) do
            local suffix = "/" .. rootName .. "/" .. encodedName

            if knownURI:sub( -#suffix ) == suffix then
                matches[#matches + 1] = knownURI
            end
        end
    end

    return matches
end

function ResolveRequire( scopeURI, name )
    if string.sub( name, -4 ) ~= ".lua" then return nil end

    -- https://github.com/LuaLS/LuaLS.github.io/issues/48
    local managerName, manager = debug.getlocal( 5, 1 )
    local callingName, callingURI = debug.getlocal( 5, 2 )
    assert( managerName == "self" and callingName == "suri", "Something broke! Did LuaLS update?" )

    -- LuaLS caches results by name alone, but a relative include resolves differently per calling file
    setmetatable( manager.requireCache, skipIncludeNames )

    local encodedName = encodeIncludeName( name )

    local callingDirURI = callingURI:match( "^(.*)/[^/]*$" )
    local relative = existingURI( callingDirURI, encodedName )
    if relative then return { relative } end

    for _, rootName in ipairs( luaRootNames ) do
        local ownRootURI = callingURI:match( "^(.*/" .. rootName .. ")/" )
        local underOwnRoot = ownRootURI and existingURI( ownRootURI, encodedName )

        if underOwnRoot then return { underOwnRoot } end
    end

    return findUnderAnyLuaRoot( scopeURI, encodedName )
end
