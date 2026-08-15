require "class/superClass"
Projectile = SuperClass:extend()
Projectile.className = "Projectile"


function Projectile:init(name,position,velocity,sprite,owner,itemInfo,flags,addToWorld)
    self.name = name
    self.position = position or Vector2(0,0)
    self.velocity = velocity or Vector2(0,0)

    self.owner = owner or nil
    self.itemInfo = itemInfo or {}
    if self.itemInfo.name == nil then self.itemInfo.name = "none" end
    if self.itemInfo.item == nil then self.itemInfo.item = nil end
    if self.itemInfo.attributes == nil then self.itemInfo.attributes = nil end
    self.flags = flags or {}

    self.movementSlide = self.flags.movementSlide or 0.9
    self.bounceFactor = self.flags.bounceFactor or 0.3
    self.breakOnBounce = self.flags.breakOnBounce or false
    self.size = self.flags.size or 0.15
    self.damageSize =  self.size * 2.5
    if self.flags.damageSize ~= nil then self.damageSize = self.flags.damageSize end
    self.gravity = self.flags.gravity or 0.5

    self.explodeRadius = self.flags.explodeRadius or 0
    self.explodeDamage = self.flags.explodeDamage or 0
    self.explodeTileDamage = self.flags.explodeTileDamage or 0
    self.explodeTime = 0
    self.explodeTimer = self.flags.explodeTimer or 0
    self.explosive = false
    if (self.explodeTimer>0 or self.explodeRadius>0) then
        self.explosive = true
    end

    self.damage = self.flags.damage or 0
    self.knockback = self.flags.knockback or 0

    self.targetList = {}
    self.timeAlive = 0
    self.stuck = false
    self.disappearTime = 0
    self.timeMax = self.flags.timeMax or 10
    

    self.hasWorldCollisions = self.flags.hasWorldCollisions or true


    self.particleTime = 0
    self.particleTimer = self.flags.particleTimer or 0.1
    self.spawnParticles =
    function (self)
        world:spawnParticles(1,"wind",self.position:copy(),0,{0.8,0.8,0.8,0.8}, {0.05,0.05,0.05,0.05}, 1, 0,"fire", nil, nil, nil, {})
    end
    
    if self.flags.spawnParticles ~= nil then
        self.spawnParticles = self.flags.spawnParticles
    end


    --time | orientation
    self.animationType = self.flags.animationType or "time"

    self.currentAnimation = "none"

    self.textureType = "singular"
    if type(sprite) == "table" then
        if type(sprite[1]) == "table" then
            self.textureType = "complex"
            self.spriteName = {}
            self.sprite = {}
            self.spriteColor = {}
            self.spriteColorisation = {}
            for i = 1, #sprite do
                self.spriteName[i] = sprite[i].sprite or "none"
                self.sprite[i]={}
                self.sprite[i].sprite = textures["sprites"][sprite[i].sprite] or "none"
                self.sprite[i].color = sprite[i].color or {1,1,1,1}
                self.sprite[i].colorisation = sprite[i].colorisation or {0,0,0,0}
            end
        else
            self.textureType = "multiple"
            self.spriteName = {}
            self.colorisation = self.flags.colorisation or {0,0,0,0}
            self.color = self.flags.color or {1,1,1,1}
            self.sprite = {}
            for i = 1, #sprite do
                self.spriteName[i] = sprite[i] or "none"
                self.sprite[i] = textures["sprites"][sprite[i]] or "none"
            end
        end
    else
        self.colorisation = self.flags.colorisation or {0,0,0,0}
        self.color = self.flags.color or {1,1,1,1}
        self.sprite = textures["sprites"][sprite] or "none"
        self.spriteName = sprite or "none"
    end

    addToWorld = addToWorld or true
    if addToWorld then
        table.insert(world.projectiles,self)
    end
end

function Projectile:update(dt)
    local die = false

    self.particleTime = self.particleTime + dt
    if self.particleTime > self.particleTimer and (not self.stuck) then
        self.particleTime = 0
        if self.spawnParticles ~= nil then
            self:spawnParticles()
        end
    end

    self.timeAlive = self.timeAlive + dt
    if self.timeAlive > self.timeMax and (not self.explosive) then
        die = true
    end

    if self.damage > 0 and (not self.explosive) then
        self:damageUpdate(dt)
    end

    if self.stuck and (not self.explosive) then
        self.disappearTime = self.disappearTime + dt
        if self.disappearTime > 1 then
            die = true
        end
    end

    if self.explosive then
        die = self:exploseUpdate(dt)
    end

    self:collisionsUpdate(dt)

    return die
end

function Projectile:exploseUpdate(dt)
    local die = false
    self.explodeTime = self.explodeTime + dt
    if self.explodeTime > self.explodeTimer then

        self:explose(self.explodeRadius, self.explodeDamage, self.explodeTileDamage)

        die = true
    end
    return die
end

function Projectile:explose(radius,damage,tileDamage)
    --print("explose radius : "..radius.." damage: "..damage.." tileDamage: "..tileDamage)
    if radius == nil then radius = 1 end
    if damage == nil then damage = 0 end
    if tileDamage == nil then tileDamage = 0 end
    local center = self.position:copy()
    center.x = round(center.x)
    center.y = round(center.y)
    for ix = -math.ceil(radius), math.ceil(radius) do
        for iy = -math.ceil(radius), math.ceil(radius) do
            local pos =  Vector2(center.x + ix,center.y + iy)
            if pos:dist(center) <= radius then
                if tileDamage > 0 then
                    local tile = world:getRawTile(pos.x, pos.y, "tiles")
                    if tile ~= nil and tile ~= "none" then
                        world:damageBlock(pos.x, pos.y, tileDamage, "tiles", true, nil)
                    end
                end
                if self.explodeDamage > 0 then
                    if #entities > 0 then
                        for i = 1, #entities do
                            local entity = entities[i]
                            if entity.position:dist(pos) < radius + entity.size then
                                if self.owner ~= nil then
                                    if self.owner:canAttack(entity) then
                                        if not checkifinlist(entity.id,self.targetList) then
                                            table.insert(self.targetList,entity.id)

                                            if self.itemInfo.item ~= nil then
                                                self.itemInfo.item:attackTarget(entity,self.itemInfo.attributes,self.owner,nil,self.explodeDamage,self.knockback,self.position:copy())
                                            end

                                        end
                                    else
                                        --knockback
                                        if not checkifinlist(entity.id,self.targetList) then
                                            table.insert(self.targetList,entity.id)
                                            if self.knockback > 0 then
                                                entity:dash(self.knockback*5*entity.knockbackMultiplier,0.3,pointat180(self.position.x,self.position.y,entity.position.x,entity.position.y),1)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    world:updateLights(round(self.position.x),round(self.position.y))
end

function Projectile:damageUpdate(dt)
    if #entities > 0 then
        for i = 1, #entities do
            local entity = entities[i]
            if self.position:dist(entity.position) < self.damageSize + entity.size then
                if self.owner ~= nil then
                    if self.owner:canAttack(entity) then
                        if not checkifinlist(entity.id,self.targetList) then
                            table.insert(self.targetList,entity.id)

                            if self.itemInfo.item ~= nil then
                                self.itemInfo.item:attackTarget(entity,self.itemInfo.attributes,self.owner,nil,self.damage,self.knockback,self.position:copy())
                            end

                        end
                    end
                end
            end
        end
    end
end

function Projectile:collisionsUpdate(dt)

    if not self.stuck then

        if self.gravity > 0 then
            self.velocity:move(-90,dt * self.gravity * 50)
        end


        self.velocity.x = k(self.velocity.x, 0, dt / self.movementSlide)
        self.velocity.y = k(self.velocity.y, 0, dt / self.movementSlide)
        --if self.velocity.y < -(1 / dt / 2) then self.velocity.y = -(1 / dt / 2) end
        --if self.velocity.y < -(1 / (1/20) / 2) then self.velocity.y = -(1 / (1/20) / 2) end


        local oldY = self.position.y
        self.position.y = self.position.y + (self.velocity.y * dt * self.movementSlide)

        if self.hasWorldCollisions then
            local touchedWall = false
            local x
            local y
            for ix = 0, math.ceil(self.size * 2) + 2 do
                x = self.position.x - self.size + ((self.size * 2) / (math.ceil(self.size * 2) + 2) * ix)
                y = self.position.y + self.size
                if self:CollisionDirectionCheck(self.position.y, x, y, "y") then touchedWall = true
                    if self.velocity.y > 0 then self.velocity.y = -self.velocity.y * self.bounceFactor end
                    self.velocity.x = self.velocity.x * (self.bounceFactor^0.5)
                break end
                y = self.position.y - self.size
                if self:CollisionDirectionCheck(self.position.y, x, y, "y") then touchedWall = true
                    if self.velocity.y < 0 then self.velocity.y = -self.velocity.y * self.bounceFactor end
                    self.velocity.x = self.velocity.x * (self.bounceFactor^0.5)
                break end
            end
            if touchedWall then
                if self.breakOnBounce or self.velocity:length() <1 then
                    self.stuck = true
                else
                    self.position.y = oldY
                end
            end
        end

        --update X
        local oldX = self.position.x
        self.position.x = self.position.x + (self.velocity.x * dt * self.movementSlide)

        if self.hasWorldCollisions then
            local touchedWall = false
            local x
            local y
            for iy = 0, math.ceil(self.size * 2) + 2 do
                y = self.position.y - self.size + ((self.size * 2) / (math.ceil(self.size * 2) + 2) * iy)
                x = self.position.x + self.size
                if self:CollisionDirectionCheck(self.position.x, y, x, "x") then touchedWall = true
                    if self.velocity.x > 0 then self.velocity.x = -self.velocity.x * self.bounceFactor end
                    self.velocity.y = self.velocity.y * (self.bounceFactor^0.5)
                break end
                x = self.position.x - self.size
                if self:CollisionDirectionCheck(self.position.x, y, x, "x") then touchedWall = true
                    if self.velocity.x < 0 then self.velocity.x = -self.velocity.x * self.bounceFactor end
                    self.velocity.y = self.velocity.y * (self.bounceFactor^0.5)
                break end
            end
            if touchedWall then
                if self.breakOnBounce or self.velocity:length() <1 then
                    self.stuck = true
                else
                    self.position.x = oldX
                end
            end
        end

    end
    
end

function Projectile:CollisionDirectionCheck(center, otherAxisPosition, check, axis)
    --local differenceAxis = math.abs(self.position.y-otherAxisPosition)
    --if axis == "y" then differenceAxis = math.abs(self.position.x-otherAxisPosition) end
    local differenceAxis = self.size
    if axis == "x" then
        local collide = world:getColision(check, otherAxisPosition)
        if collide then
            if check > center then
                self.position.x = round(center) + (0.5 - differenceAxis - 0.005)
            else
                self.position.x = round(center) - (0.5 - differenceAxis - 0.005)
            end
            return true
        end
    end
    if axis == "y" then
        local collide = world:getColision(otherAxisPosition, check)
        if collide then
            if check > center then
                self.position.y = round(center) + (0.5 - differenceAxis - 0.005)
            else
                self.position.y = round(center) - (0.5 - differenceAxis - 0.005)
            end
            return true
        end
    end
    return false
end

function Projectile:getDirection()
    local d = self.velocity:getDirection()
    if d > -90 and d < 90 then
        return "right"
    end
    return "left"
end

function Projectile:draw()

    local animationTime = 0
    if self.animationType == "time" then
        animationTime = self.timeAlive
    end
    if self.animationType == "orientation" then
        local d = self.velocity:getDirection()
        if d > 90 then
            d = 180 - d
        elseif d < -90 then
            d = -180 - d
        end
        animationTime = d + 90
    end

    local posX, posY, drawSize = world:getTileScreenPosition(round(self.position.x,8),round(self.position.y,8))

    if self.textureType == "singular" then
        local color = CopyAll(self.color)
        if self.disappearTime > 0 then
            color[4] = color[4] * (1 - (self.disappearTime / 1))
        end
        self.sprite:draw(self.currentAnimation,animationTime,self:getDirection(),posX,posY,drawSize,drawSize,color,self.colorisation)
    end
    if self.textureType == "multiple" then
        for i = 1, #self.sprite do
            local color = CopyAll(self.color)
            if self.disappearTime > 0 then
                color[4] = color[4] * (1 - (self.disappearTime / 1))
            end
            self.sprite[i]:draw(self.currentAnimation,animationTime,self:getDirection(),posX,posY,drawSize,drawSize,color,self.colorisation)
        end
    end
    if self.textureType == "complex" then
        for i = 1, #self.sprite do
            local color = CopyAll(self.sprite[i].color)
            if self.disappearTime > 0 then
                color[4] = color[4] * (1 - (self.disappearTime / 1))
            end
            self.sprite[i].sprite:draw(self.currentAnimation,animationTime,self:getDirection(),posX,posY,drawSize,drawSize,color,self.sprite[i].colorisation)
        end
    end
end