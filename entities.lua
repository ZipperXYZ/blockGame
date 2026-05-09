require "class/superClass"
require "class/utility/vector2"
require "class/utility/eventEmitter"

Entity = SuperClass:extend()
Entity.className = "Entity"

--init()
function Entity:init(name, type, sprite, health, level, ia, flags)
    self.name = name or "none"
    self.type = type or "enemy"
    self.health = health or 1
    self.level = level or 0
    self.ia = ia or "none"
    self.flags = flags or {}
    self.sprite = sprite or sprite()
    self.position = vector2:new(0,0)
    self.velocity = vector2:new(0,0)
    self.deathEvent = eventEmitter:new()

end

function Entity:setType(newType)
    self.type = newType
end

function Entity:setHealth(newHealth)
    self.health = newHealth
end

function Entity:setPosY(posY)
    self.position:setY(y)
end

function Entity:setPosX(posX)
    self.position:setY(y)
end

function Entity:setPos(posX, posY)
    self.position = vector2:new(posX,posY)
end

function Entity:setVelocityX(velocityX)
    self.velocity:setX(velocityX)
end

function Entity:setVelocityY(velocityY)
    self.velocity:setY(velocityY)
end

function Entity:setLevel(newLevel)
    self.level = newLevel
end

function Entity:spawnEntity(name, x, y)
    self.position = vector2:new(x,y)
end

function Entity:damage(damage)
    if (self.health - damage < 0) then
        self.health = 0
        self:deathEvent:emit()
    else
        self.health -= damage 
    end
end

function Entity:entityUpdate(dt)

end

function Entity:playerUpdate(dt)

end
