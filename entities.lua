require "class/superClass"

Entity = SuperClass:extend()
Entity.className = "Tile"

--init()
function Entity:init(name, type, sprite, health, level, ia, flags)
    self.name = name or "none"
    self.type = type or "enemy"
    self.health = health or 1
    self.level = level or 0
    self.ia = ia or "none"
    self.flags = flags or {}
    self.sprite = sprite or sprite()
    self.posX = 0
    self.poxY = 0
    self.velocityX = 0
    self.velocityY = 0
end

function Entity:setType(newType)
    self.type = newType
end

function Entity:setHealth(newHealth)
    self.health = newHealth
end

function Entity:setPosY(posY)
    self.poxY = posY
end

function Entity:setPosX(posX)
    self.posX = posX
end

function Entity:setPos(posX, posY)
    self:setPosX(posX)
    self:setPosY(posY)
end

function Entity:setVelocityX(velocity)
    self.velocityX = velocity
end

function Entity:setVelocityY(velocity)
    self.velocityY = velocity
end

function Entity:setLevel(newLevel)
    self.level = newLevel
end

function Entity:spawnentity(name, x, y)

end

function Entity:entityupdate(dt)

end

function Entity:playerupdate(dt)

end
