require "class/superClass"
require "class/utility/vector2"
require "class/utility/eventEmitter"
require "Entities/sprite"

Entity = SuperClass:extend()
Entity.className = "Entity"

--init()
function Entity:init(name, type, spriteName, texture, health, level, ia, flags)
    self.name = name or "none"
    self.type = type or "enemy"
    self.health = health or 1
    self.level = level or 0
    self.ia = ia or "none"
    self.flags = flags or {}

    self.spriteName = spriteName or "none"
    self.texture = texture or "tiles.png"

    self.texture = "Textures/" .. self.texture

    --self.deathEvent = EventEmitter:new()
    self.state = "alive"
    --self.deathEvent:on(self:death())

    self.animation = self.flags["animation"] or false
    self.position = self.flags["position"] or Vector2:new(0, 0)
    self.velocity = self.flags["velocity"] or Vector2:new(0, 0)

    if self.spriteName ~= "none" and not textures["sprites"][self.spriteName] then
        textures["sprites"][spriteName] = Sprite(self.name, self.animation, self.texture, self.spriteName,
            { ["newQuad"] = { 9, 0, 1, 1, 8 } })
    end
end

function Entity:setType(newType)
    self.type = newType
end

function Entity:getTexture()
    return textures["textures"][self.texture]
end

function Entity:getSprite()
    return entities[self.spriteName]:getQuad()
end

function Entity:getPosition()
    return self.position
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
    self.position = Vector2:new(posX, posY)
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
    self.position = Vector2:new(x, y)
end

function Entity:damage(damage)
    if (self.health - damage < 0) then
        self.health = 0
        self.deathEvent:emit()
    else
        self.health = -damage
    end
end

function Entity:death()
    self.state = "death"
    print("I died")
end

function Entity:entityUpdate(dt)

end

function Entity:playerUpdate(dt)

end
