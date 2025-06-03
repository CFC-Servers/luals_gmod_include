local fs = require( "bee.filesystem" )

local existsCache = {}

--- Remove first 7 characters (file:///)
--- @param uri string
--- @return boolean
local function uriExists( uri )
    local cached = existsCache[uri]
    if cached ~= nil then
        return cached
    end

    local path = uri:sub( 8 )
    local exists = fs.exists( path )

    existsCache[uri] = exists
    return exists
end

function ResolveRequire( uri, name )
    if string.sub( name, -4 ) ~= ".lua" then return nil end

    -- https://github.com/LuaLS/LuaLS.github.io/issues/48
    local _callingName, callingURI = debug.getlocal( 5, 2 ) do
        assert( _callingName == "suri", "Something broke! Did LuaLS update?" )
    end

    -- Get everything up to and including the last forward slash.
    local callingDirURI = callingURI:match( "^(.*)/[^/]*$" )

    -- Relative to the calling file
    local relative = callingDirURI .. "/" .. name
    if uriExists( relative ) then
        return { relative }
    end

    -- Relative to the top level lua/ dir
    local absolute = uri .. "/lua/" .. name
    return { absolute }
end

