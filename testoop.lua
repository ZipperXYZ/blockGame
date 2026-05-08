class = {}


class.__index = class


function class.new(tilename,tiletype,texture,quad,flags) 
    local newClass = {}

    newClass.tileName = tilename 
    newClass.tileType = tileType or "empty"
    newClass.texture = texture or "none"
    newClass.quad = quad or "none"
    newClass.flags = flags or {}
    newClass.border = newClass.flags.border


    local xPos = newClass.flags["newQuad"][1]
    local yPos = newClass.flags["newQuad"][2]
    local xSize = newClass.flags["newQuad"][3]
    local ySize =  newClass.flags["newQuad"][4]
    local multiSize = newClass.flags["newQuad"][5]

    local borderXPos = newClass.border["newQuad"][1]
    local borderYPos = newClass.border["newQuad"][2]
    local borderXSize = newClass.border["newQuad"][3]
    local borderYSize =  newClass.border["newQuad"][4]
    local borderMultiSize = newClass.border["newQuad"][5]

    textures["quads"][newClass.quad] = love.graphics.newQuad(
        xPos * multiSize,
        yPos * multiSize,
        xSize * multiSize,
        ySize * multiSize)

    textures["quads"][newClass.border["quad"]] = love.graphics.newQuad(
        borderXPos * borderMultiSize,
        borderYPos * borderMultiSize,
        borderXSize * borderMultiSize,
        borderYSize * borderMultiSize)

    
    setmetatable(newClass,class)

    return newClass
end

//
function class:gettileinfo(tile,info)
    tiles[tile][info]
end
