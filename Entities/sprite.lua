require "class/superClass"

Sprite = SuperClass:extend()
Sprite.className = "Sprite"

--init()
function Sprite:init(name, type, textureName, quadName, flags)
    self.name = name or "none"
    self.type = type or false
    self.textureName = textureName or "entities.png"
    self.quadName = quadName or "none"
    self.flags = flags or {}

    self.textureName = ("Textures/" .. self.textureName)

    if not sprites["quads"][self.quadName] and self.quadName ~= "none" then
        sprites["quads"][self.quadName] = love.graphics.newQuad(
            self.flags["newQuad"][1] * self.flags["newQuad"][5]
            , self.flags["newQuad"][2] * self.flags["newQuad"][5]
            , self.flags["newQuad"][3] * self.flags["newQuad"][5]
            , self.flags["newQuad"][4] * self.flags["newQuad"][5]
            , sprites["textures"][self.textureName])
    end
end
