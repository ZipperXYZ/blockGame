require "class/superClass"

Sprite = SuperClass:extend()
Sprite.className = "Tile"

--init()
function Sprite:init(name, type, textureName, quadName)
    self.name = name or "none"
    self.type = type or "fixed"
    self.textureName = textureName or "entities.png"
    self.quadName = quadName or "none"
end
