require "class/superClass"
GroundItem = SuperClass:extend()
GroundItem.className = "GroundItem"

function GroundItem:init(itemName, position, velocity, amount, attributes, flags) 
    
    self.name = itemName or "none"
    self.time = 0
    self.size = 0.45
    self.gravity = 0.6
    self.position = position or Vector2(0,0)
    self.velocity = velocity or Vector2(0,0)
    self.amount = amount or 1 
    self.attributes = attributes or {}
    self.flags = flags or {}
    self.hasGravity = self.flags.hasGravity or true
    self.canDisappear = self.flags.canDisappear or true
    self.disableGravityTime = 0
    self.pickupTimer = self.flags.pickupTimer or 0
    
    if items[self.name] ~= nil then
        local item = items[self.name]
        self.size = item.groundSize
    end
end

function GroundItem:moveEntityUpdate(dt,entityPosition, distanceTreshold)
    local touchingPlayer = false
    
    if self.pickupTimer <= 0 then
        
        if dist(self.position.x, self.position.y, entityPosition.x, entityPosition.y) < distanceTreshold then
            if dist(self.position.x, self.position.y, entityPosition.x, entityPosition.y) < distanceTreshold/2 then
                self.disableGravityTime = 0.75
            end
            self.position:moveTowards(entityPosition, dt * 10 * (1- (self.position:dist(entityPosition)/distanceTreshold)) )
        end

        if dist(self.position.x, self.position.y, entityPosition.x, entityPosition.y) < 0.3 then
            touchingPlayer = true
        end

    end
    
    return touchingPlayer
end

function GroundItem:update(dt)
    local OverTimer = false
    self.time = self.time + dt

    if self.pickupTimer > 0 then self.pickupTimer = self.pickupTimer - dt end
    if self.disableGravityTime > 0 then self.disableGravityTime = self.disableGravityTime - dt end

    if self.time > 300 and self.canDisappear then
        OverTimer = true
    end


    self.velocity.x = k(self.velocity.x, 0, dt / 0.2)

    if self.hasGravity and self.disableGravityTime <= 0 then
        self.velocity.y = self.velocity.y - dt * self.gravity * 50
        if self.velocity.y < -(1 / dt / 2) then self.velocity.y = -(1 / dt / 2) end
    else
        self.velocity.y = k(self.velocity.y, 0, dt / 0.2)
        self.velocity.y = 0
    end


    self:colisionsUpdate(dt)

    return OverTimer
end

function GroundItem:CollisionDirectionCheck(center, otherAxisPosition, check, axis)
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

function GroundItem:colisionsUpdate(dt)
    --update Y
    self.position.y = self.position.y + (self.velocity.y * dt)

    if self.hasGravity and self.disableGravityTime <= 0 then
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

    --update X
    self.position.x = self.position.x + (self.velocity.x * dt)

    if self.hasGravity and self.disableGravityTime <= 0 then
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
end

function GroundItem:draw()
    love.graphics.setColor(1,1,1,0.2)
    local x,y
    x, y = positiontoscreen(round(self.position.x*8)/8, round(self.position.y*8)/8)
    --slove.graphics.circle("fill", x, y, 0.25 * camv * 1)
    local size = camv 
    --love.graphics.setColor(1,1,1,1)
    --love.graphics.print(round(self.pickupTimer*100),x,y+10)
        
    if self.name ~= "none" then
        
        local drawFormat = "small"
        if items[self.name] ~= nil then
            items[self.name]:draw(drawFormat,x,y,size,self.attributes)
            if self.amount > 0 then
                love.graphics.setColor(1,1,1,1)
                love.graphics.printf("x"..self.amount,x-size/2,y+size/2 - 15,size/1.2,"right",0,1.2,1.2)
            end
        end
    end
end
