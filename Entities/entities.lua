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
    self.controls.openInventory = false

    self.mineList = {}

    self.inventoryOpened = false
    self.inventoryCursor = {["amount"]=0,["name"]="none",["attributes"]={}}
    if (self.type == "player") then
        self.inventory = { --(inventoryName,color,screenPos,sizeX,sizeY,sizeZ,maxStack,tileSize,itemSize,flags)
            Inventory("inventory",{0.5,0.6,0.7,1},Vector2(0.5,0.05),7,5,1,100,(0.065),(0.065/8),{})
            ,Inventory("armor",{0.5,0.6,0.7,1},Vector2(0.95,0.05),3,4,1,1,(0.065),(0.065/8),{["isEquipmentInventory"]=true,["anchorX"]="right",["anchorY"]="top"})
            ,Inventory("chest test",{0.7,0.5,0.5,1},Vector2(0.5,0.95),8,3,1,100,(0.065),(0.065/8),{["anchorX"]="middle",["anchorY"]="bottom"})
        }
    else
        self.inventory = {
            Inventory("inventory",{0.5,0.6,0.7,1},Vector2(0.5,0.05),3,2,1,100,(0.065),(0.065/8),{})
            ,Inventory("armor",{0.5,0.6,0.7,1},Vector2(0.95,0.05),3,4,1,1,(0.065),(0.065/8),{["isEquipmentInventory"]=true,["anchorX"]="right",["anchorY"]="top"})
        }
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
    if #self.inventory >0 then
        for ii = 1, #self.inventory do
           self.inventory[ii]:throwEveryItem(self.position.x,self.position.y)
        end
    end
    self.state = "death"
end

function Entity:movementUpdate(dt)
    --if love.keyboard.isDown("w") then self.velocity.y=self.velocity.y+(8*dt) end
    --if love.keyboard.isDown("s") then self.velocity.y=self.velocity.y-(8*dt) end
    if self.ai == "player" or true then


        self.controls.left = love.keyboard.isDown("a")
        self.controls.right = love.keyboard.isDown("d")
        self.controls.jump = love.keyboard.isDown("w")
        if self.inventoryOpened then 
            self.controls.invClick = buttonFramePress["click"]
            self.controls.invRightClick = buttonFramePress["rclick"]
            self.controls.invShiftClick = buttonFramePress["shiftclick"]
            self.controls.invShiftRightClick = buttonFramePress["shiftrclick"]
            self.controls.invClickHold = love.mouse.isDown(1) and (not love.keyboard.isDown("lshift")) and (not buttonFramePress["click"])
            self.controls.invShiftClickHold = love.mouse.isDown(1) and (love.keyboard.isDown("lshift")) and (not buttonFramePress["shiftclick"])
            self.controls.invRightClickHold = love.mouse.isDown(2) and (not love.keyboard.isDown("lshift")) and (not buttonFramePress["rclick"])
            self.controls.invShiftRightClickHold = love.mouse.isDown(2) and (love.keyboard.isDown("lshift")) and (not buttonFramePress["shiftrclick"])
            self.controls.mine = false
        else
            self.controls.invClick = false
            self.controls.invClickHold = false
            self.controls.invRightClick = false
            self.controls.invRightClickHold = false
            self.controls.invShiftClick = false
            self.controls.invShiftClickHold = false
            self.controls.invShiftRightClick = false
            self.controls.invShiftRightClickHold = false
            self.controls.mine = love.mouse.isDown(1)
        end
        self.controls.openInventory = buttonFramePress["tab"]
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
    if self.controls.openInventory then
        self.inventoryOpened = not self.inventoryOpened
    end

    if self.inventoryOpened then
        if #self.inventory > 0 then
            for i = 1, #self.inventory do
                self.inventory[i]:draw("complete")
            end
        end
        if self.inventoryCursor.name ~= "none" then
            self:drawCursorItem()
        end
    else
        if #self.inventory > 0 then
            self.inventory[1]:draw("firstLine")
        end
    end
end

function Entity:drawCursorItem()
    local x1,y1,s1 = self.inventory[1]:getTilePosAndSize(1,1)
    x1 = mx - s1/2
    y1 = my - s1/2
    if self.inventoryCursor.name ~= "none" then
        if items[self.inventoryCursor.name] ~= nil then
            items[self.inventoryCursor.name]:draw("medium",x1+s1/2,y1+s1/2,s1,self.inventoryCursor.attributes)
            if self.inventoryCursor.amount > 0 then
                love.graphics.setColor(1,1,1,1)
                love.graphics.printf("x"..self.inventoryCursor.amount,x1,y1 + s1 - 15,s1/1.2,"right",0,1.2,1.2)
            end
        end
    end
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
    self:inventoryUpdate(dt)
    if self.controls.mine then
        if self.mineRadius == 1 then
            self:mineTarget(dt)
        else
            self:mineTarget(dt,self.miningRadius)
        end
    end
end

function Entity:inventoryUpdate(dt)
    --self.controls.invClick
    --self.controls.invRightClick
    --self.controls.invShiftClick
    --self.controls.invShiftRightClick

    --self.inventoryCursor = {["amount"]=0,["name"]="none",["attributes"]={}}

    local tileInteraction = {}
    tileInteraction.insideInventory = false
    tileInteraction.x = 0
    tileInteraction.y = 0
    tileInteraction.page = 0
    tileInteraction.inventory = 0
    
    for inv = 1,#self.inventory do
        invX,invY,sizeX,sizeY = self.inventory[inv]:getPosAndSize()
       if mx >  invX and mx < invX + sizeX and my > invY and my < invY + sizeY then
            tileInteraction.insideInventory = true
       end
       for ix = 1, #self.inventory[inv]["items"][self.inventory[inv]["currentPage"]] do
            for iy = 1, #self.inventory[inv]["items"][self.inventory[inv]["currentPage"]][ix] do
                tileX,tileY,size = self.inventory[inv]:getTilePosAndSize(ix,iy)
                if mx > tileX and mx < tileX + size and my > tileY and my < tileY + size then
                    tileInteraction.x = ix
                    tileInteraction.y = iy
                    tileInteraction.page = self.inventory[inv]["currentPage"]
                    tileInteraction.inventory = inv
                end
            end
       end
    end

    if self.inventoryCursor.amount <= 0 then
        self.inventoryCursor.amount = 0
        self.inventoryCursor.name = "none"
        self.inventoryCursor.attributes = {}
    end

    if tileInteraction.insideInventory then
        if tileInteraction.inventory > 0 then
            if self.controls.invClick then
                self:inventorySwitchHand(tileInteraction.inventory,tileInteraction.page,tileInteraction.x,tileInteraction.y)
            end

            if self.controls.invRightClick and self.inventoryCursor.name == "none" then
                self:inventoryTakeHalfHand(tileInteraction.inventory,tileInteraction.page,tileInteraction.x,tileInteraction.y)
            end

            if self.controls.invRightClick and self.inventoryCursor.name ~= "none" then
                self:inventoryLeaveOneItem(tileInteraction.inventory,tileInteraction.page,tileInteraction.x,tileInteraction.y)
            end

            if (self.controls.invRightClickHold) and self.inventoryCursor.name ~= "none" 
            and self.inventory[tileInteraction.inventory]["items"][tileInteraction.page][tileInteraction.x][tileInteraction.y]["name"] == "none" 
            then
                self:inventoryLeaveOneItem(tileInteraction.inventory,tileInteraction.page,tileInteraction.x,tileInteraction.y)
            end

            if (self.controls.invShiftClick or self.controls.invShiftClickHold) then
                self:inventoryShiftItemToNewInventory(tileInteraction.inventory,tileInteraction.page,tileInteraction.x,tileInteraction.y)
            end
            
        end
    else
        if self.controls.invClick and self.inventoryCursor.name ~= "none" then
            self:throwItemOffInventory("all")
        end
        if self.controls.invRightClick and self.inventoryCursor.name ~= "none" then
            self:throwItemOffInventory("single")
        end
    end
end

function Entity:throwItemOffInventory(type)
    local velocity = Vector2(0,12)
    local position = Vector2(self.position.x,self.position.y)

    if self.animationDirection == "right" then velocity.x = 25 end
    if self.animationDirection == "left" then velocity.x = -25 end

    if type == "all" then
        world:spawnGroundItem(self.inventoryCursor.name, position, velocity, self.inventoryCursor.amount, self.inventoryCursor.attributes, {["pickupTimer"] = 3})

        self.inventoryCursor.amount = 0
        self.inventoryCursor.name = "none"
        self.inventoryCursor.attributes = {}
    end

    if type == "single" then
        world:spawnGroundItem(self.inventoryCursor.name, position, velocity, 1, self.inventoryCursor.attributes, {["pickupTimer"] = 3})

        self.inventoryCursor.amount = self.inventoryCursor.amount - 1
        if self.inventoryCursor.amount <= 0 then
            self.inventoryCursor.name = "none"
            self.inventoryCursor.attributes = {}
        end
    end
    
end

function Entity:inventorySwitchHand(inventoryIndex,page,x,y)
    if self.inventoryCursor.name == self.inventory[inventoryIndex]["items"][page][x][y]["name"]
    --and self.inventoryCursor.attributes == self.inventory[inventoryIndex]["items"][page][x][y]["attributes"]
    then
        self.inventory[inventoryIndex]["items"][page][x][y]["amount"] = self.inventory[inventoryIndex]["items"][page][x][y]["amount"] + self.inventoryCursor.amount

        self.inventoryCursor.amount = 0
        self.inventoryCursor.name = "none"
        self.inventoryCursor.attributes = {}
    else
        local buffer = {}
        buffer.amount = self.inventoryCursor.amount
        buffer.name = self.inventoryCursor.name
        buffer.attributes = self.inventoryCursor.attributes

        self.inventoryCursor.amount = self.inventory[inventoryIndex]["items"][page][x][y]["amount"]
        self.inventoryCursor.name = self.inventory[inventoryIndex]["items"][page][x][y]["name"]
        self.inventoryCursor.attributes = self.inventory[inventoryIndex]["items"][page][x][y]["attributes"]

        self.inventory[inventoryIndex]["items"][page][x][y]["amount"] = buffer.amount
        self.inventory[inventoryIndex]["items"][page][x][y]["name"] = buffer.name
        self.inventory[inventoryIndex]["items"][page][x][y]["attributes"] = buffer.attributes

    end
end

function Entity:inventoryTakeHalfHand(inventoryIndex,page,x,y)

    self.inventoryCursor.amount = math.ceil(self.inventory[inventoryIndex]["items"][page][x][y]["amount"]/2)
    self.inventoryCursor.name = self.inventory[inventoryIndex]["items"][page][x][y]["name"]
    self.inventoryCursor.attributes = self.inventory[inventoryIndex]["items"][page][x][y]["attributes"]

    self.inventory[inventoryIndex]["items"][page][x][y]["amount"] = self.inventory[inventoryIndex]["items"][page][x][y]["amount"] - math.ceil(self.inventory[inventoryIndex]["items"][page][x][y]["amount"]/2)
end

function Entity:inventoryShiftItemToNewInventory(inventoryIndex,page,x,y)

    if self.inventory[inventoryIndex]["items"][page][x][y]["name"] ~= "none" then

        local targetInventory = #self.inventory
        if inventoryIndex == targetInventory then
            targetInventory = 1
        end

        local targetInventoryPage = self.inventory[targetInventory]["currentPage"]
        for ix = 1, #self.inventory[targetInventory]["items"][targetInventoryPage] do 
            for iy = 1, #self.inventory[targetInventory]["items"][targetInventoryPage][ix] do 
                if self.inventory[inventoryIndex]["items"][page][x][y]["amount"] > 0 then
                    if self.inventory[targetInventory]["items"][targetInventoryPage][ix][iy]["name"] == "none" then
                        self.inventory[targetInventory]["items"][targetInventoryPage][ix][iy]["name"] = self.inventory[inventoryIndex]["items"][page][x][y]["name"]
                        self.inventory[targetInventory]["items"][targetInventoryPage][ix][iy]["attributes"] = self.inventory[inventoryIndex]["items"][page][x][y]["attributes"]
                        self.inventory[targetInventory]["items"][targetInventoryPage][ix][iy]["amount"] = self.inventory[inventoryIndex]["items"][page][x][y]["amount"]
                        self.inventory[inventoryIndex]["items"][page][x][y]["amount"] = self.inventory[inventoryIndex]["items"][page][x][y]["amount"] - self.inventory[inventoryIndex]["items"][page][x][y]["amount"]
                    end
                    if self.inventory[targetInventory]["items"][targetInventoryPage][ix][iy]["name"] == self.inventory[inventoryIndex]["items"][page][x][y]["name"] then
                        self.inventory[targetInventory]["items"][targetInventoryPage][ix][iy]["amount"] = 
                            self.inventory[targetInventory]["items"][targetInventoryPage][ix][iy]["amount"]
                            + self.inventory[inventoryIndex]["items"][page][x][y]["amount"]
                        self.inventory[inventoryIndex]["items"][page][x][y]["amount"] = self.inventory[inventoryIndex]["items"][page][x][y]["amount"] - self.inventory[inventoryIndex]["items"][page][x][y]["amount"]
                    end
                end
            end
        end
        if self.inventory[inventoryIndex]["items"][page][x][y]["amount"] <= 0 then
            self.inventory[inventoryIndex]["items"][page][x][y]["name"] = "none"
            self.inventory[inventoryIndex]["items"][page][x][y]["attributes"] = {}
            self.inventory[inventoryIndex]["items"][page][x][y]["amount"] = 0
        end
    end
end

function Entity:inventoryLeaveOneItem(inventoryIndex,page,x,y)

    if self.inventory[inventoryIndex]["items"][page][x][y]["name"] == self.inventoryCursor.name
    or self.inventory[inventoryIndex]["items"][page][x][y]["name"] == "none" 
    then

    self.inventoryCursor.amount = self.inventoryCursor.amount - 1 
    self.inventory[inventoryIndex]["items"][page][x][y]["amount"] = self.inventory[inventoryIndex]["items"][page][x][y]["amount"] + 1
    self.inventory[inventoryIndex]["items"][page][x][y]["name"] = self.inventoryCursor.name
    self.inventory[inventoryIndex]["items"][page][x][y]["attributes"] = self.inventoryCursor.attributes

    end
end

function Entity:animationUpdate(dt)
    self.animationTime = self.animationTime + dt * self.animationSpeed
    if self.controls.left then self.animationDirection = "left" end
    if self.controls.right then self.animationDirection = "right" end

    local newAnimation = "idle"

    if self.controls.left or self.controls.right or math.abs(self.velocity.x)>0.04 then newAnimation = "walk" end
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

function Entity:groundItemsUpdate(dt)
    if #world.groundItems > 0 then
        for g = #world.groundItems, 1, -1 do
            if self.inventory[1]:checkIfEmptySpacesAvailable() then
                if world.groundItems[g]:moveEntityUpdate(dt,self.position, self.size + 5) then
                    self.inventory[1]:addItem(world.groundItems[g]["name"],world.groundItems[g]["amount"],world.groundItems[g]["attributes"])
                    table.remove(world.groundItems, g)
                end
            end
        end
    end
end
