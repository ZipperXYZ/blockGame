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
    self.size = size or 0.5
    self.level = level or 0
    self.ia = ia or "none"
    self.id = math.random()
    self.inventory = {}
    self.flags = flags or {}

    self.spriteSize = self.flags["spriteSize"] or 1
    self.spriteOffsetY = self.flags["spriteOffsetY"] or (1 - self.size*2 -1/8)

    if sprite ~= nil and sprite ~= "none" then
        if textures["sprites"][sprite] ~= nil then
            self.sprite = textures["sprites"][sprite]
        else
            self.sprite = "none"
        end
    else
        self.sprite = "none"
    end
    self.animation = "idle"
    self.animationTime = 0
    self.animationSpeed = 1
    self.animationDirection = "right"
    self.spriteName = sprite or "none"
    --self.texture = texture or "tiles.png"

    --self.texture = "Textures/" .. self.texture

    --self.deathEvent = EventEmitter:new()
    self.state = "alive"
    --self.deathEvent:on(self:death())

    --self.animation = self.flags["animation"] or false
    self.movementSlide = self.flags["movementSlide"] or 0.25
    self.hasWorldCollisions = self.flags["hasWorldCollisions"] or true
    self.position = position or Vector2:new(0, 0)
    --movement
    self.velocity = self.flags["velocity"] or Vector2:new(0, 0)
    self.gravity = self.flags["gravity"] or 0.5
    self.movevementSpeed = self.flags["movevementSpeed"] or 1
    self.jumpStrength = self.flags["jumpStrength"] or 1.2

    self.cameraFocus = self.flags.cameraFocus or (self.ia == "player" or self.ia == "human")

    self.attackDamage = self.flags.attackDamage or 5
    self.miningRadius = self.flags.miningRadius or 1

    self.controls = {}
    self.controls.left = false
    self.controls.right = false
    self.controls.jump = false
    self.controls.mine = false

    self.mineList = {}

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
    if self.ai == "player" or true then
        self.controls.left = love.keyboard.isDown("a")
        self.controls.right = love.keyboard.isDown("d")
        self.controls.jump = love.keyboard.isDown("w")
         self.controls.mine = love.mouse.isDown(1)
    end
    
    if self.controls.right then
        self.velocity.x = self.velocity.x +
            (self.movevementSpeed * 10 * dt / self.movementSlide)
    end
    if self.controls.left then
        self.velocity.x = self.velocity.x -
            (self.movevementSpeed * 10 * dt / self.movementSlide)
    end

    if self.controls.jump and self:canJump() then
        if self.velocity.y < 0 then self.velocity.y = 0 end
        self.velocity.y = self.velocity.y + (self.jumpStrength * 10)
        if self.velocity.y > (self.jumpStrength * 10) then self.velocity.y = (self.jumpStrength * 10) end
    end

    self.velocity.y = self.velocity.y - dt * self.gravity * 50

    self.velocity.x = k(self.velocity.x, 0, dt / self.movementSlide)
    if self.velocity.y < -(1 / dt / 2) then self.velocity.y = -(1 / dt / 2) end
    --self.velocity.y = k(self.velocity.y,0,dt/self.movementSlide)
end

function Entity:canJump()
    return self:isGrounded() --self.velocity.y<0.05
end

function Entity:isGrounded()
    local yCheck = self.position.y - self.size - 0.05
    local xCheck
    for ix = 0, math.ceil(self.size * 2) + 2 do
        xCheck = self.position.x - self.size + ((self.size * 2) / (math.ceil(self.size * 2) + 2) * ix)
        if world:getColision(xCheck, yCheck) then
            return true
        end
    end
    return false
end

function Entity:collisionUpdate(dt)
    --update Y

    self.position.y = self.position.y + (self.velocity.y * dt)

    if self.hasWorldCollisions then
        local x
        local y
        for ix = 0, math.ceil(self.size * 2) + 2 do
            x = self.position.x - self.size + ((self.size * 2) / (math.ceil(self.size * 2) + 2) * ix)
            y = self.position.y + self.size
            if self:CollisionDirectionCheck(self.position.y, x, y, "y") then break end
            y = self.position.y - self.size
            if self:CollisionDirectionCheck(self.position.y, x, y, "y") then break end
        end
    end

    --if self.hasWorldCollisions then
    --    for iCollision=1,24 do
    --        local x
    --        local y
    --        x,y = moveposition180(self.position.x,self.position.y,360/24*iCollision,self.size)
    --        if self:CollisionDirectionCheck(self.position.y,x,y,"y") then break end
    --    end
    --end
    --update X
    self.position.x = self.position.x + (self.velocity.x * dt)

    if self.hasWorldCollisions then
        local x
        local y
        for iy = 0, math.ceil(self.size * 2) + 2 do
            y = self.position.y - self.size + ((self.size * 2) / (math.ceil(self.size * 2) + 2) * iy)
            x = self.position.x + self.size
            if self:CollisionDirectionCheck(self.position.x, y, x, "x") then break end
            x = self.position.x - self.size
            if self:CollisionDirectionCheck(self.position.x, y, x, "x") then break end
        end
    end


    --if self.hasWorldCollisions then
    --     for iCollision=1,24 do
    --         local x
    --         local y
    --         x,y = moveposition180(self.position.x,self.position.y,360/24*iCollision,self.size)
    --         if self:CollisionDirectionCheck(self.position.x,y,x,"x") then break end
    --     end
    --end

    --s'assurer que le joueur n'est toujours pas coincé dans un block
    if self.hasWorldCollisions then
        if world:getColision(self.position.x, self.position.y) then
            self.position.y = self.position.y + 1
        end
    end
end

function Entity:camUpdate()
    if (camEntityFollow == self.id) then
        realcamx = round(self.position:getX()*8)/8
        realcamy = round((self.position:getY()+ self.spriteOffsetY)*8)/8
        camx = realcamx
        camy = realcamy
        spectator = false
    end
    if self.cameraFocus then
        if (camEntityFollow == 0) then
            camEntityFollow = self.id
        end
    end
end

function Entity:DrawUI()
    --
end

function Entity:CollisionDirectionCheck(center, otherAxisPosition, check, axis)
    --local differenceAxis = math.abs(self.position.y-otherAxisPosition)
    --if axis == "y" then differenceAxis = math.abs(self.position.x-otherAxisPosition) end
    local differenceAxis = self.size
    if axis == "x" then
        local collide = world:getColision(check, otherAxisPosition)
        if collide then
            if check > center then
                self.position.x = round(center) + (0.5 - differenceAxis - 0.005)
                if self.velocity.x > 0 then self.velocity.x = 0 end
            else
                self.position.x = round(center) - (0.5 - differenceAxis - 0.005)
                if self.velocity.x < 0 then self.velocity.x = 0 end
            end
            return true
        end
    end
    if axis == "y" then
        local collide = world:getColision(otherAxisPosition, check)
        if collide then
            if check > center then
                self.position.y = round(center) + (0.5 - differenceAxis - 0.005)
                if self.velocity.y > 0 then self.velocity.y = 0 end
            else
                self.position.y = round(center) - (0.5 - differenceAxis - 0.005)
                if self.velocity.y < 0 then self.velocity.y = 0 end
            end
            return true
        end
    end
    return false
end

function Entity:collisionWithEntities(dt)
    for i2 = 1, #entities do
        other = entities[i2]
        if self.id ~= other.id then
            if dist(self.position.x, self.position.y, other.position.x, other.position.y) < self.size + other.size then
                local distance = (1 - (1 / (self.size + other.size) * dist(self.position.x, self.position.y, other.position.x, other.position.y))) ^
                    0.5
                entities[i2].position.x, entities[i2].position.y =
                    movetowards(other.position.x, other.position.y, self.position.x, self.position.y,
                        -distance * entities[i2].size * dt * 10)
                self.position.x, self.position.y =
                    movetowards(self.position.x, self.position.y, other.position.x, other.position.y,
                        -distance * self.size * dt * 10)
            end
        end
    end
end

function Entity:targetedBlock(x, y)

    local posX = x or mxworldpos
    local posY = y or myworldpos
    local targetTile = world:getTile(posX, posY, "tiles")
    if targetTile == tiles["none"] then
        return nil
    end

    local tileInfo = {}
    tileInfo["tile"] = targetTile
    tileInfo["x"] = posX
    tileInfo["y"] = posY
    tileInfo["health"] = targetTile.health

    if (world:getChangedTile(posX, posY)) then
        targetTile = world:getChangedTile(posX, posY)
    else
        targetTile = world:addChangedTile(tileInfo)
    end
    return targetTile
end



function Entity:mineBlock(tileInfo, index, dt)
    local result = "Table: {\n"
    for k, v in pairs(tileInfo) do
        if type(v) == "table" then
            result = result .. "  " .. k .. " = [table]\n" 
        else
            result = result .. "  " .. k .. " = " .. tostring(v) .. "\n"
        end
    end
    if tileInfo.health - self.attackDamage * dt > 0 then
        tileInfo.health =
            tileInfo.health - self.attackDamage * dt
        print(result)
    else
        world:destroyTile(tileInfo.x, tileInfo.y, "tiles")
        table.remove(self.mineList, index)
    end
end

function Entity:mineTarget(dt)
    local tileInfo = self:targetedBlock()

    if tileInfo == nil then
        return false
    end

    for ix = 1, #self.mineList do
        local target = self.mineList[ix]

        if target.x == tileInfo.x
            and target.y == tileInfo.y then
            self:mineBlock(tileInfo, ix, dt)
            return true
        end
    end

    table.insert(self.mineList, tileInfo)
    self:mineBlock(tileInfo, 1, dt)


    return true
end

--[[function Entity:mineTarget(dt, radius)
    local worldPosX = round(mxworldpos)
    local worldPosY = round(myworldpos)

    for y = worldPosY - radius, worldPosY + radius do
        for x = worldPosX - radius, worldPosX + radius do
            local tileInfo = self:targetedBlock(x, y)

            if tileInfo ~= nil then
                for ix = 1, #self.mineList do
                    local target = self.mineList[ix]

                    if target.x == tileInfo.x
                        and target.y == tileInfo.y then
                        self:mineBlock(tileInfo, ix, dt)
                        return true
                    end
                end

                table.insert(self.mineList, tileInfo)
                self:mineBlock(tileInfo, 1, dt)
            end
        end
    end
    return true
end--]]
function Entity:entityUpdate(dt)

end

function Entity:playerUpdate(dt)
    if self.controls.mine then
        if self.mineRadius == 1 then
            self:mineTarget(dt)
        else
            self:mineTarget(dt,self.miningRadius)
        end
    end
end

function Entity:animationUpdate(dt)
    self.animationTime = self.animationTime + dt * self.animationSpeed
    if self.controls.left then self.animationDirection = "left" end
    if self.controls.right then self.animationDirection = "right" end

    local newAnimation = "idle"

    if self.controls.left or self.controls.right or math.abs(self.velocity.x)>0.1 then newAnimation = "walk" end
    if not self:isGrounded() then newAnimation = "jump" end
    if self.controls.mine then newAnimation = "use" end

    if newAnimation ~= self.animation then self:setAnimation(newAnimation) end

    if self.animation == "idle" then self.animationSpeed = 1 end
    if self.animation == "walk" then self.animationSpeed = math.abs(self.velocity.x) end
    if self.animation == "jump" then self.animationSpeed = 1 end
    if self.animation == "use" then self.animationSpeed = 1 end
end

function Entity:setAnimation(newAnimation)
    local canChange = true
    if self.animation ~= "none" then
        if self.sprite.spriteData[newAnimation] == nil then canChange = false end
        if self.sprite.spriteData[self.animation] ~= nil then
            if self.sprite.spriteData[self.animation]["type"] == "repeat&needsToEnd" then
                if self.animationTime < #self.sprite.spriteData[self.animation]["quads"] * self.sprite.spriteData[self.animation]["timePerFrame"] then
                    canChange = false
                end
            end
        end
    end
    if canChange then
        self.animationTime = 0 
        self.animation = newAnimation
    end
end

function Entity:draw()
    local x
    local y
    x, y = positiontoscreen(round(self.position:getX()*8)/8, round((self.position:getY()+ self.spriteOffsetY)*8)/8-self.spriteOffsetY)
    local spriteX, spriteY = positiontoscreen(round(self.position:getX()*8)/8, round((self.position:getY()+ self.spriteOffsetY)*8)/8)
    spriteY = spriteY  
    --love.graphics.setColor(0, 0, 0, 1)
    --love.graphics.circle("fill", x, y, self.size * camv)
    --love.graphics.setColor(1, 1, 1, 1)
    --love.graphics.circle("fill", x, y, self.size * camv * 0.8)

    love.graphics.setColor(1, 1, 1, 0.2)
    love.graphics.circle("fill", x, y, self.size * camv * 1)

    --print("sprite name : "..self.spriteName)
    --print("animation : "..self.animation)

    if self.spriteName ~= "none" and self.animation ~= "none" and textures["sprites"][self.spriteName] ~= nil then
        --print("draw1")
        self.sprite:draw(self.animation,self.animationTime,self.animationDirection,spriteX,spriteY,camv/8*self.spriteSize,camv/8*self.spriteSize,{1,1,1,1})
    end

    --love.graphics.print(self.ia, x, y + 100)
end
