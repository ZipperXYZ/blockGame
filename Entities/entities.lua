require "class/superClass"
require "class/utility/vector2"
require "class/utility/eventEmitter"
require "Entities/sprite"

Entity = SuperClass:extend()
Entity.className = "Entity"

--init()
function Entity:init(name, type, sprite, position, health, size, level, ia, flags)
    self.name = name or "none"
    self.type = type or "enemy"
    self.health = health or 1
    self.size = size or 0.85
    self.level = level or 0
    self.ia = ia or "none"
    self.inventory = {}
    self.flags = flags or {}

    self.spriteName = sprite or "none"
    --self.texture = texture or "tiles.png"

    --self.texture = "Textures/" .. self.texture

    --self.deathEvent = EventEmitter:new()
    self.state = "alive"
    --self.deathEvent:on(self:death())

    self.animation = self.flags["animation"] or false
    self.position = position or Vector2:new(0, 0)
    self.velocity = self.flags["velocity"] or Vector2:new(0, 0)
    self.gravity = self.flags["gravity"] or 0.5
    self.movevementSpeed = self.flags["movevementSpeed"] or 1

    self.cameraFocus = self.flags.cameraFocus or (self.ia == "player" or self.ia == "human")

    --if self.spriteName ~= "none" and not textures["sprites"][self.spriteName] then
    --    textures["sprites"][spriteName] = Sprite(self.name, self.animation, self.texture, self.spriteName,
    --        { ["newQuad"] = { 9, 0, 1, 1, 8 } })
    --end
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

function Entity:getSize(newLevel)
    return self.size
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
end

function Entity:movementUpdate(dt)
    
end

function Entity:entityUpdate(dt)

end

function Entity:playerUpdate(dt)

end

function Entity:draw()
    if self.cameraFocus then 
        camx = self.position:getX() 
        camy = self.position:getY()
        spectator = false
    end
    local x
    local y
    x, y=positiontoscreen(self.position:getX(),self.position:getY())
    love.graphics.setColor(0,0,0,1)
    love.graphics.circle("fill",x,y,self.size*camv)
    love.graphics.setColor(1,1,1,1)
    love.graphics.circle("fill",x,y,self.size*camv*0.8)
end