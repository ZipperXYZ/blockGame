require "class/superClass"

Sprite = SuperClass:extend()
Sprite.className = "Sprite"

--init()
function Sprite:init(name, spriteData, textureName, flags)
    self.name = name or "none"
    self.textureName = textureName or "tiles.png"
    --self.quadName = quadName or "none"
    self.flags = flags or {}

    if not textures["textures"][self.textureName] and self.textureName ~= "none" then
        textures["textures"][self.textureName] = love.graphics.newImage(self.textureName)
    end

    if (not textures["sprites"][self.quadName]) and self.quadName ~= "none" then
        textures["sprites"][self.quadName] = love.graphics.newQuad(
            self.flags["newQuad"][1] * self.flags["newQuad"][5]
            , self.flags["newQuad"][2] * self.flags["newQuad"][5]
            , self.flags["newQuad"][3] * self.flags["newQuad"][5]
            , self.flags["newQuad"][4] * self.flags["newQuad"][5]
            , textures["textures"][self.textureName])
    end
end

function Sprite:getQuad()
    return textures["sprites"][self.quadName]
end

function Sprite:getTexture()
    return textures["textures"][self.textureName]
end
