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
    self.id = math.random()
    self.inventory = {}
    self.flags = flags or {}

    self.spriteName = sprite or "none"
    --self.texture = texture or "tiles.png"

    --self.texture = "Textures/" .. self.texture

    --self.deathEvent = EventEmitter:new()
    self.state = "alive"
    --self.deathEvent:on(self:death())

    self.animation = self.flags["animation"] or false
    self.movementSlide = self.flags["movementSlide"] or 0.25
    self.hasWorldCollisions = self.flags["hasWorldCollisions"] or true
    self.position = position or Vector2:new(0, 0)
    --movement
    self.velocity = self.flags["velocity"] or Vector2:new(0, 0)
    self.gravity = self.flags["gravity"] or 0.5
    self.movevementSpeed = self.flags["movevementSpeed"] or 1
    self.jumpStrength = self.flags["jumpStrength"] or 1.2

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
    --if love.keyboard.isDown("w") then self.velocity.y=self.velocity.y+(8*dt) end
    --if love.keyboard.isDown("s") then self.velocity.y=self.velocity.y-(8*dt) end
    if love.keyboard.isDown("d") then self.velocity.x=self.velocity.x+(self.movevementSpeed*10*dt/self.movementSlide) end
    if love.keyboard.isDown("a") then self.velocity.x=self.velocity.x-(self.movevementSpeed*10*dt/self.movementSlide) end

    if love.keyboard.isDown("w") and self:canJump() then 
        if self.velocity.y < 0 then self.velocity.y = 0 end
        self.velocity.y = self.velocity.y + (self.jumpStrength*10)
        if self.velocity.y > (self.jumpStrength*10) then self.velocity.y = (self.jumpStrength*10) end
    end

    self.velocity.y=self.velocity.y-dt*self.gravity*50

    self.velocity.x = k(self.velocity.x,0,dt/self.movementSlide)
    if self.velocity.y<-(1/dt/2) then self.velocity.y=-(1/dt/2) end
    --self.velocity.y = k(self.velocity.y,0,dt/self.movementSlide)
end

function  Entity:canJump()
    return self:isGrounded()--self.velocity.y<0.05
end

function Entity:isGrounded()
    local yCheck = self.position.y - self.size -0.05
    if world:getColision(self.position.x,yCheck) then
        return true
    else
        return false
    end
end

function Entity:collisionUpdate(dt)
    --update Y

    self.position.y=self.position.y+(self.velocity.y*dt)
    

    if self.hasWorldCollisions then
        for iCollision=1,24 do
            local x
            local y
            x,y = moveposition180(self.position.x,self.position.y,360/24*iCollision,self.size)
            if self:CollisionDirectionCheck(self.position.y,x,y,"y") then break end
        end
    end
    --update X
    self.position.x=self.position.x+(self.velocity.x*dt)
    

    if self.hasWorldCollisions then
        for iCollision=1,24 do
            local x
            local y
            x,y = moveposition180(self.position.x,self.position.y,360/24*iCollision,self.size)
            if self:CollisionDirectionCheck(self.position.x,y,x,"x") then break end
        end
    end

    
    if self.cameraFocus then 
        realcamx = self.position.x
        realcamy = self.position.y
        camx=realcamx
        camy=realcamy
        spectator = false
    end
end

function Entity:CollisionDirectionCheck(center,otherAxisPosition,check,axis)
    --local differenceAxis = math.abs(self.position.y-otherAxisPosition)
    --if axis == "y" then differenceAxis = math.abs(self.position.x-otherAxisPosition) end
    local differenceAxis = self.size
    if axis == "x" then
        local collide = world:getColision(check,otherAxisPosition)
        if collide then
            if check>center then
                self.position.x = round(center)+(0.5-differenceAxis-0.005)
                if self.velocity.x > 0 then self.velocity.x = 0 end
                else
                self.position.x = round(center)-(0.5-differenceAxis-0.005)
                if self.velocity.x < 0 then self.velocity.x = 0 end
            end
            return true
        end
    end
    if axis == "y" then
        local collide = world:getColision(otherAxisPosition,check)
        if collide then
            if check>center then
                self.position.y = round(center)+(0.5-differenceAxis-0.005)
                if self.velocity.y > 0 then self.velocity.y = 0 end
                else
                self.position.y = round(center)-(0.5-differenceAxis-0.005)
                if self.velocity.y < 0 then self.velocity.y = 0 end
            end
            return true
        end
    end
    return false
end

function  Entity:collisionWithEntities(dt)
    for i2=1,#entities do
        other = entities[i2]
        if self.id ~= other.id then
            if dist(self.position.x,self.position.y,other.position.x,other.position.y)<self.size+other.size then
               local distance = (1-(1/(self.size+other.size)*dist(self.position.x,self.position.y,other.position.x,other.position.y)))^0.5
                entities[i2].position.x,entities[i2].position.y = 
                    movetowards(other.position.x,other.position.y,self.position.x,self.position.y,-distance*entities[i2].size*dt*10)
                self.position.x,self.position.y = 
                    movetowards(self.position.x,self.position.y,other.position.x,other.position.y,-distance*self.size*dt*10)
            end
        end
    end
end

function Entity:entityUpdate(dt)
    
end

function Entity:playerUpdate(dt)

end

function Entity:draw()
    local x
    local y
    x, y=positiontoscreen(self.position:getX(),self.position:getY())
    love.graphics.setColor(0,0,0,1)
    love.graphics.circle("fill",x,y,self.size*camv)
    love.graphics.setColor(1,1,1,1)
    love.graphics.circle("fill",x,y,self.size*camv*0.8)

    love.graphics.print(self.ia,x,y+100)
end