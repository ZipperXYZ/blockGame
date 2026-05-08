Tile = {}

Tile.__index = Tile

function Tile.new(tilename,tiletype,textureName,quadName,flags)
    local newTile = {}

    if tilename then
    newTile.name = tilename
    else
        return
    end
    newTile.type = tiletype
    newTile.textureName = textureName
    newTile.quadName = quadName
    newTile.flags = flags

    setmetatable(newTile,Tile)
    return newTile
end
