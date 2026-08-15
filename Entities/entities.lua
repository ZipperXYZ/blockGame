require "class/superClass"
require "class/utility/vector2"
require "class/utility/eventEmitter"
require "Entities/sprite"

Entity = SuperClass:extend()
Entity.className = "Entity"

--init()
function Entity:init(name, type, sprite, position, health, size, level, ia, flags)
    --name : player, slime, skeleton...
    --type : player, enemy, boss, specialBoss, other
    --ai : player, regular, other...
    --movevementType : humanlike, hoplike, flying, other
    self.name = name or "none"
    self.type = type or "enemy"
    self.flags = flags or {}
    self.team = self.flags.team or "neutral"
    if self.flags.team == nil then
        if self.type == "player" then
            self.team = "ally"
        else
            self.team = "enemy"
        end
    end

    self.fogValue = 0

    self.xpBar = Bar("xp",{1,1,1,1},{1,1,1,1},"multisection")
    self.xpAccumulated = 0
    self.xpGiveOnDeath = self.flags.xpGiveOnDeath or 0
    self.xpToLevelUp = self.flags.xpToLevelUp or 50
    self.xpToLevelUpPerLevel = self.flags.xpToLevelUpPerLevel or self.xpToLevelUp/5
    self.xpBar:addSection("xp",{0,1,1,1},self.xpToLevelUp,0,3,true,false,false)
    self.xpBar:setValue(0,"xp")
    

    self.baseHealth = health or self.flags.health or 1
    self.baseRegen = self.flags.regen or (health/100)
    self.healthPerLevel = self.flags.healthPerLevel or (self.baseHealth * 0.05)

    self.health = Bar("health",{1,0.5,0.5,1},{1,1,1,1},"multisection")
    if health == nil then health = self.baseHealth end
    self.health:addSection("hp",{0,1,0.5,1},health,self.baseRegen,3,false,false,false)
    --self.health:addSection("shield",{0,0.5,1,1},health*0.2,(health/30),8,false,false,false)
    --self.health:addSection("yshield",{1,1,0,1},health*0.3,(health/30),8,false,false,false)

     if size == nil then size = self.flags.size or 0.45 end
    self.size = size or 0.45
    self.baseSize = self.size
    self.level = level or 1
    self.ai = ia or "none"
    self.id = math.random()
    

    self.spriteSize = self.flags["spriteSize"] or 1
    self.spriteOffsetY = self.flags["spriteOffsetY"] or (1 - self.size * 2 - 1 / 8)

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
    self.movementAnimationSpeed = self.flags.movementAnimationSpeed or 1
    self.animationDirection = "right"
    self.spriteName = sprite or "none"

    self.itemHold = { ["name"] = "none", ["quantity"] = 0, ["attributes"] = {} }
    --self.texture = texture or "tiles.png"

    --self.texture = "Textures/" .. self.texture

    --self.deathEvent = EventEmitter:new()
    self.state = "alive"
    --self.deathEvent:on(self:death())

    self.movementType = self.flags.movementType or "humanlike"

    self.movementSlide = self.flags["movementSlide"] or 0.25
    self.dashes = {}
    self.hasWorldCollisions = self.flags["hasWorldCollisions"] or true
    self.position = position or Vector2:new(0, 0)
    --movement
    self.velocity = self.flags["velocity"] or Vector2:new(0, 0)
    self.gravity = self.flags.gravity or 0.5
    self.baseGravity = self.gravity
    self.movevementSpeed = self.flags.movevementSpeed or 1
    self.baseMovementSpeed = self.movevementSpeed
    self.jumpStrength = self.flags.jumpStrength or 1.2
    self.baseJumpStrength = self.jumpStrength

    self.highestPositionBeforeFall = nil
    self.groundedLastFrame = true
    self.flyCheat = false

    self.cameraFocus = self.flags.cameraFocus or (self.ai == "player" or self.ai == "human")
    self.disappearFarFromPlayer = self.flags.disappearFarFromPlayer or (self.type == "enemy")

    self.attackDamage = self.flags.attackDamage or 1
    self.baseAttackDamage = self.attackDamage
    self.attackDamagePerLevel = self.attackDamagePerLevel or 0
    self.miningRadius = self.flags.miningRadius or 1
    self.knockbackMultiplier = self.flags.knockbackMultiplier or 1
    self.baseKnockbackMultiplier = self.knockbackMultiplier
    self.cooldownReduction = 1


    self.colorisation = self.flags.colorisation or {0,0,0,0}
    self.bloodColor = self.flags.bloodColor or {0.4,0,0.1,1}
    self.bloodColorNoise = self.flags.bloodColorNoise or {0.3,0.05,0.075,1}


    self.directorId = self.flags.directorId or 0
    self.directorCost = self.flags.directorCost or 1
    self.startItems = self.flags.startItems or {}
    self.aiInfo = self.flags.aiInfo or {}


    self.controls = {}
    self:resetControls()

    self.platformDropHoldFrames = self.flags.platformDropHoldFrames or 2
    self.platformDropSpeedThreshold = self.flags.platformDropSpeedThreshold or 1.2
    self.platformDropThroughDuration = self.flags.platformDropThroughDuration or 0.12
    self.platformDropThroughTimer = 0
    self.platformDropTargetKey = nil
    self.platformDropHeldFrames = 0
    self.platformDropLastTick = -1

    self.mineList = {}
    self.lastDamageTakenTime = 0
    self.timeAlive = 0
    self.redTime = 1
    self.greenTime = 1
    self.lastDamageTakenEntityId = 0
    self.inventorySpaceHighlights = {}
    self.cursorColor = { 1, 1, 1, 1 }


    self.inventoryOpened = false
    self.inventoryCursor = { ["amount"] = 0, ["name"] = "none", ["attributes"] = {} }
    if (self.type == "player") then
        self.inventory = { --(inventoryName,color,screenPos,sizeX,sizeY,sizeZ,maxStack,tileSize,itemSize,flags)
            Inventory("inventory", { 0.5, 0.6, 0.7, 1 }, Vector2(0.5, 0.05), 7, 5, 1, 100, (0.065), (0.065 / 8), { ["isMainInventory"] = true },self)
            --Inventory("inventory", { 0.15, 0.15, 0.15, 1 }, Vector2(0.5, 0.05), 7, 6, 1, 100, (0.065), (0.065 / 8), { ["isMainInventory"] = true },self)
            , Inventory("armor", { 0.5, 0.6, 0.7, 1 }, Vector2(0.95, 0.05), 3, 4, 1, 1, (0.065), (0.065 / 8),
            { ["isEquipmentInventory"] = true, ["anchorX"] = "right", ["anchorY"] = "top" },self)
        , --Inventory("chest test", { 0.7, 0.5, 0.5, 1 }, Vector2(0.5, 0.95), 8, 3, 1, 100, (0.065), (0.065 / 8),
            --{ ["anchorX"] = "middle", ["anchorY"] = "bottom" },self)
        }
        --self.inventory[1]:setupMainInventory()
        if CheatMode then
            table.insert(self.inventory,
                Inventory("cheat inventory, press arrows to scroll", { 0.5, 0.5, 0.7, 1 }, Vector2(0.5, 0.5), 12, 3, 1,
                    100, (0.065), (0.065 / 8), { ["anchorY"] = "top", ["cheat"] = true }))
        end
    else
        self.inventory = {
            Inventory("inventory", { 0.5, 0.6, 0.7, 1 }, Vector2(0.5, 0.05), 7, 2, 1, 100, (0.065), (0.065 / 8),
                { ["isMainInventory"] = true },self)
            , Inventory("armor", { 0.5, 0.6, 0.7, 1 }, Vector2(0.95, 0.05), 3, 4, 1, 1, (0.065), (0.065 / 8),
            { ["isEquipmentInventory"] = true, ["anchorX"] = "right", ["anchorY"] = "top" },self)
        }
    end


    self.isPlayer = (false)
    if self.type == "player" then
        self.isPlayer = true
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

--function Entity:setHealth(newHealth)
    --self.health = newHealth
--end

function Entity:setPosY(posY)
    self.position:setY(posY)
end

function Entity:setPosX(posX)
    self.position:setX(posX)
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
    self.position = Vector2(x, y)
end

function Entity:applyEnchantSignal(signal,signalInfo,item,itemAttributes)
    local success

    if item ~= nil and itemAttributes ~= nil then
        if itemAttributes.enchants ~= nil then
            if #itemAttributes.enchants > 0 then
                for i = 1, #itemAttributes.enchants do
                    local enchant = itemAttributes.enchants[i]
                    if enchant ~= nil then
                        success, signalInfo = enchantReceiveSignal(signal,signalInfo,enchant.cause,enchant.condition,enchant.reaction,itemAttributes,item,self)
                    end
                end
            end
        end
    end

    for i = 1,#self.inventory do
        local inventory = self.inventory[i]
        if inventory ~= nil then
            for ix = 1,inventory.sizeX do
                for iy = 1,inventory.sizeY do
                    local item = inventory:getActualItem(ix,iy)
                    local attributes = inventory:getItemAttributes(ix,iy)
                    local slot = inventory:getSlotAttribute("button",ix,iy)..""
                    local icon = inventory:getSlotAttribute("icon",ix,iy)..""
                    if item.itemName ~= nil and item.itemName ~= "none" then
                        if item.applyEnchantFromAnyItem and (checkifinlist(slot,item.desiredInventorySpots) or checkifinlist(icon,item.desiredInventorySpots)) then
                            --print("Applying enchant signal from item: "..item.itemName)
                            if attributes.enchants ~= nil then
                                if #attributes.enchants > 0 then
                                    for i = 1, #attributes.enchants do
                                        local enchant = attributes.enchants[i]
                                        --print("    Applying enchant signal from enchant")
                                        if enchant ~= nil then
                                            success, signalInfo = enchantReceiveSignal(signal,signalInfo,enchant.cause,enchant.condition,enchant.reaction,attributes,item,self)
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
    
    return signalInfo
end

function Entity:canAttack(otherEntity)
    local canAttack = true
    if otherEntity == nil then
        return false
    end

    if otherEntity.team == self.team then
        canAttack = false
    end

    if otherEntity.team == "pacifist" or self.team == "pacifist" then
        canAttack = false
    end
    if otherEntity.team == "neutral" or self.team == "neutral" then
        canAttack = true
    end
    if self.team == "ghost player" then
        canAttack = false
    end


    if otherEntity.id == self.id then
        canAttack = false
    end
    if otherEntity.state == "death" then
        canAttack = false
    end

    return canAttack
end

function Entity:damage(damage,source,entitySource,info)
    local section = nil
    local death = false
    if info == nil then info = {} end
    if info.critical == nil then info.critical = false end

    --damage health first :
    if checkifinlist(source,{"fall"}) then
        section = "hp"
    end

    local signalInfo = {
        position = self.position:copy(),
        damageReceiver = self,
        damageValue = damage,
    }
    signalInfo = self:applyEnchantSignal("takingDamage",signalInfo)
    if signalInfo.damageValue ~= nil then
        damage = signalInfo.damageValue
    end


    local damageColor = {1,1,1,1}
    local outlineColor = nil
    if info.critical then outlineColor = {1,0,0,1} end
    if self.type == "player" then damageColor = {1,0,0,1} end
    if source == "fog" then damageColor = {0.1,0,0.35,1} end
    world:spawnTextParticle(round(damage),self.position:copy(), 1.5, 0.4,nil,damageColor,outlineColor)


    local overflow,downflow = self.health:decrease(damage,section)

    if self.health:isEmpty("hp") then
        death = true
    end


    self.lastDamageTakenTime = 0
    if entitySource ~= nil then
        self:aiTakeDamage(entitySource)
        self.lastDamageTakenEntityId = entitySource.id
    end

    return death
end

function Entity:gainHealth(value,hpType,source,entitySource)
    local section = hpType


    local overflow,downflow = self.health:increase(value,section)


    return overflow,downflow
end

function Entity:death()
    if #self.inventory > 0 then
        for ii = 1, #self.inventory do
            self.inventory[ii]:throwEveryItem(self.position.x, self.position.y)
        end
    end
    self:dropXp()
    self.state = "death"
end

function Entity:resetControls()
    self.controls = {}

    self.controls.invClick = false
    self.controls.invClickHold = false
    self.controls.invRightClick = false
    self.controls.invRightClickHold = false
    self.controls.invShiftClick = false
    self.controls.invShiftClickHold = false
    self.controls.invShiftRightClick = false
    self.controls.invShiftRightClickHold = false

    self.controls.mine = false

    self.controls.leftClick = false
    self.controls.rightClick = false
    self.controls.space = false
    self.controls.shift = false
    self.controls.r = false
    self.controls.x = false
    self.controls.c = false

    self.controls.interact = false
end

function Entity:getAim(axis)
    if self.ai == "player" then
        if axis == nil then
            return world:getMouseTile(false)
        else
            local returnValue = world:getMouseTile(false)
            return returnValue[axis]
        end
    else
        local position = self.position:copy()
        if axis == nil then
            return Vector2(self:getAim("x"), self:getAim("y"))
        end
        if axis == "x" then
            if self.aiInfo.aimTarget.x ~= nil then 
                position.x = self.aiInfo.aimTarget.x 
            end
            return position.x
        end
        if axis == "y" then
            if self.aiInfo.aimTarget.y ~= nil then 
                position.y = self.aiInfo.aimTarget.y 
            end
            return position.y
        end
    end
end

function Entity:controlsUpdate(dt)
    if self.ai == "player" or false then
        self.controls.left = love.keyboard.isDown("a")
        self.controls.right = love.keyboard.isDown("d")
        self.controls.jump = love.keyboard.isDown("w")
        self.controls.up = love.keyboard.isDown("w")
        self.controls.down = love.keyboard.isDown("s")
        if self.inventoryOpened then
            self.controls.invClick = buttonFramePress["click"]
            self.controls.invRightClick = buttonFramePress["rclick"]
            self.controls.invShiftClick = buttonFramePress["shiftclick"]
            self.controls.invShiftRightClick = buttonFramePress["shiftrclick"]
            self.controls.invClickHold = love.mouse.isDown(1) and (not love.keyboard.isDown("lshift")) and
            (not buttonFramePress["click"])
            self.controls.invShiftClickHold = love.mouse.isDown(1) and (love.keyboard.isDown("lshift")) and
            (not buttonFramePress["shiftclick"])
            self.controls.invRightClickHold = love.mouse.isDown(2) and (not love.keyboard.isDown("lshift")) and
            (not buttonFramePress["rclick"])
            self.controls.invShiftRightClickHold = love.mouse.isDown(2) and (love.keyboard.isDown("lshift")) and
            (not buttonFramePress["shiftrclick"])

            self.controls.mine = false

            self.controls.leftClick = false
            self.controls.rightClick = false
            self.controls.space = false
            self.controls.shift = false
            self.controls.r = false
            self.controls.x = false
            self.controls.c = false

            self.controls.interact = buttonFramePress["e"]
        else
            self.controls.invClick = false
            self.controls.invClickHold = false
            self.controls.invRightClick = false
            self.controls.invRightClickHold = false
            self.controls.invShiftClick = false
            self.controls.invShiftClickHold = false
            self.controls.invShiftRightClick = false
            self.controls.invShiftRightClickHold = false

            self.controls.mine = false -- love.mouse.isDown(1)

            self.controls.leftClick = love.mouse.isDown(1)
            self.controls.rightClick = love.mouse.isDown(2)
            self.controls.space = love.keyboard.isDown("space")
            self.controls.shift = love.keyboard.isDown("lshift")
            self.controls.r = love.keyboard.isDown("r")
            self.controls.x = love.keyboard.isDown("x")
            self.controls.c = love.keyboard.isDown("c")
            self.controls.v = love.keyboard.isDown("v")
            self.controls.b = love.keyboard.isDown("b")
            self.controls.n = love.keyboard.isDown("n")
            self.controls.m = love.keyboard.isDown("m")
            self.controls.h = love.keyboard.isDown("h")
            self.controls.j = love.keyboard.isDown("j")
            self.controls.k = love.keyboard.isDown("k")
            self.controls.l = love.keyboard.isDown("l")

            self.controls.interact = buttonFramePress["e"]
        end
        self.controls.openInventory = buttonFramePress["tab"]
    end
    if self.ai ~= "player" then
        self:aiUpdate(dt)
    end
end

function Entity:openInventory(newInventory)
    --print("Opening inventory: "..newInventory.name)
    if self.inventoryOpened then
        self:closeInventory()
        self.inventoryOpened = false
    else
        self:closeInventory()
        self.inventoryOpened = true
        table.insert(self.inventory,newInventory)
    end
end

function Entity:closeInventory()
    self.inventoryOpened = false
    for i = #self.inventory, 1, -1 do
        if self.inventory[i].isChest then
            table.remove(self.inventory, i)
        end
    end
end

function Entity:InventoryItemsUpdate(dt)
    if #self.inventory > 0 then
        for i = 1, #self.inventory do
            self.inventory[i]:resetDefaultPassData()
            local page = self.inventory[i].currentPage
            for ix = 1, self.inventory[i].sizeX do
                for iy = 1, self.inventory[i].sizeY do
                    self.inventory[i]:slotUpdate(dt, self, ix, iy, page)
                end
            end
        end
    end
end

function Entity:getInventoryData(data,type,default,baseValue)
    local value = 0
    if type == nil then type = "multiply" end
    if type == "multiply" then value = 1 end
    if type == "divide" then value = 1 end
    if baseValue ~= nil then value = baseValue end
    if default == nil then
        default = 0
        if type == "multiply" then default = 1 end
        if type == "divide" then default = 1 end
        if type == "highest" then default = -math.huge end
        if type == "lowest" then default = math.huge end
    end
    
    if #self.inventory > 0 then
        for i = 1, #self.inventory do
            local currentData = self.inventory[i]:getPassData(data,default)
            if type == "add" then
                value = value + currentData
            end
            if type == "multiply" then
                value = value * currentData
            end
            if type == "divide" then
                value = value / currentData
            end
            if type == "highest" then
                if currentData > value then value = currentData end
            end
            if type == "lowest" then
                if currentData < value then value = currentData end
            end
        end
    end

    return value
end

function Entity:updateFallDamage()
    
    if (not self.groundedLastFrame)  then
        if self.highestPositionBeforeFall ~= nil then

            local difference = self.highestPositionBeforeFall.y-self.position.y 
            local treshold = 8
            
            if difference > 0 then
                if self:isGrounded() then
                    self:jumpHopParticules( maximum(difference + 3,40))
                end
            end
            if difference > treshold then

                local maxHealth = self.health:getMax("hp")
                local damage = self:getFallDamage((difference) - treshold, maxHealth)

                self.health:setDamagePreview("fallDamage",damage,{0.8,0.3,0.3,1},0.1,"hp")
                
                if self:isGrounded() and damage >= 1 then
                    self:spawnBlood(1 * math.ceil(damage/ maxHealth*150),3 + damage * 5 / maxHealth)
                    self:damage(damage,"fall")
                    self.health:removeDamagePreview("fallDamage")
                end
            end
        end
    end
    if self.velocity.y >= -0.05 or self:getDashVelocity("y") >= 0.1 then
        self.highestPositionBeforeFall = self.position:copy()
    end
    self.groundedLastFrame = self:isGrounded()
    
end

function Entity:jumpHopParticules(amount,velo,direction,arc)
    if velo == nil then velo = 0.5 end
    if direction == nil then direction = -90 end
    if arc == nil then arc = 360 end
    world:spawnParticles(
                        amount,
                        "air",
                        self.position:copy(),
                        self.size,
                        {0.7,0.7,0.7,0.5}, 
                        {0.1,0.1,0.1,0.3}, 
                        0.5, 
                        0.5,
                        "fire", 
                        velo, 
                        direction, 
                        arc, 
                        {["weight"]=0.25})
end

function Entity:spawnBlood(amount,velo,direction,arc)
    if velo == nil then velo = 0.5 end
    if direction == nil then direction = -90 end
    if arc == nil then arc = 360 end
    world:spawnParticles(
                        amount,
                        "blood",
                        self.position:copy(),
                        self.size,
                        self.bloodColor, 
                        self.bloodColorNoise, 
                        5, 
                        5,
                        "dust", 
                        velo, 
                        direction, 
                        arc, 
                        {})
end

function Entity:getFallDamage(fallHeight, maxHealth)
    local kv = 0.2 --
    if fallHeight < 40 then
        kv = k(0,kv,fallHeight/40)
    end
    local damageFraction = math.log(1 + kv * fallHeight)
                           / (1 + math.log(1 + kv * fallHeight))

    return damageFraction * maxHealth
end

function Entity:entityDeathUpdate(dt)
    local dead = false
    if self.health:getValue("hp") <= 0.4 then
        dead = true
        self:death()
    end
    return dead
end

function Entity:getCooldownReductionMultiplier()
    local cooldownReduction = 1
    cooldownReduction = cooldownReduction * self:getInventoryData("cooldownReduction","multiply")
    return cooldownReduction
end

function Entity:getMaxHealth()
    local maxHealth = self.baseHealth
    maxHealth = maxHealth + (self.level-1) * self.healthPerLevel
    maxHealth = maxHealth + self:getInventoryData("maxHealthAdd","add")
    maxHealth = maxHealth * self:getInventoryData("maxHealth","multiply")
    return math.ceil(maxHealth)
end

function Entity:getRegen()
    local regen = self.baseRegen
    regen = regen + self:getInventoryData("regenAdd","add")
    regen = regen * self:getInventoryData("regen","multiply")
    return regen
end

function Entity:getDamage()
    local damage = self.baseAttackDamage
    damage = damage + (self.level-1) * self.attackDamagePerLevel
    damage = damage + self:getInventoryData("damageAdd","add")
    damage = damage * self:getInventoryData("damage","multiply")
    return damage
end

function Entity:getKnockback()
    local knockback = self.baseKnockbackMultiplier
    knockback = knockback + self:getInventoryData("knockbackAdd","add")
    knockback = knockback * self:getInventoryData("knockback","multiply")
    return knockback
end

function Entity:getMovementSpeed()
    local speed = self.baseMovementSpeed
    speed = speed + self:getInventoryData("movementSpeedAdd","add")
    speed = speed * self:getInventoryData("movementSpeed","multiply")
    return speed
end

function Entity:getJumpStrength()
    local jumpStrength = self.baseJumpStrength
    jumpStrength = jumpStrength + self:getInventoryData("jumpStrengthAdd","add")
    jumpStrength = jumpStrength * self:getInventoryData("jumpStrength","multiply")
    return jumpStrength
end

function Entity:getGravity()
    local gravity = self.baseGravity
    gravity = gravity + self:getInventoryData("gravityAdd","add")
    gravity = gravity * self:getInventoryData("gravity","multiply")
    if #self.dashes > 0 then
        for i = 1, #self.dashes do
            local dash = self.dashes[i]
            if dash.dashTime > 0 then
                gravity = gravity * dash.gravityMultiplier
            end
        end
    end
    return gravity
end



function Entity:movementUpdate(dt)
    --if love.keyboard.isDown("w") then self.velocity.y=self.velocity.y+(8*dt) end
    --if love.keyboard.isDown("s") then self.velocity.y=self.velocity.y-(8*dt) end

    if self.flyCheat then
        
    else
    
        if self.controls.right then
            self.velocity.x = self.velocity.x +
                (10 * dt / self.movementSlide)
        end
        if self.controls.left then
            self.velocity.x = self.velocity.x -
                (10 * dt / self.movementSlide)
        end

        --self:updateFallDamage()

        if self.controls.jump and self:canJump() then

            local signalInfo = {
                position = self.position:copy(),
                jumpStrength = self.jumpStrength,
                entity = self,
            }
            signalInfo = self:applyEnchantSignal("jump",signalInfo)

            if self.velocity.y < 0 then self.velocity.y = 0 end
            self.velocity.y = self.velocity.y + (self.jumpStrength * 10)
            if self.velocity.y > (self.jumpStrength * 10) then self.velocity.y = (self.jumpStrength * 10) end
        end

        --self.velocity.y = self.velocity.y - dt * self:getGravity() * 50
        self.velocity:move(-90,dt * self:getGravity() * 50)


        self.velocity.x = k(self.velocity.x, 0, dt / self.movementSlide)
        --if self.velocity.y < -(1 / dt / 2) then self.velocity.y = -(1 / dt / 2) end
        if self.velocity.y < -(1 / (1/90) / 2) then self.velocity.y = -(1 / (1/90) / 2) end
        --self.velocity.y = k(self.velocity.y,0,dt/self.movementSlide)

    end
end

function Entity:canJump()
    return self:isGrounded() --self.velocity.y<0.05
end

function Entity:getStairSurfaceYAt(x, y)
    local tileX = round(x)
    local tileY = round(y)
    local tile = world:getTile(tileX, tileY, "tiles")
    if tile == nil then return nil end

    local tileType = tile.type or "non-solid"
    if tileType ~= "rightStair" and tileType ~= "leftStair" then
        return nil
    end

    local xInBlock = x - (tileX - 0.5)
    if xInBlock < 0 then xInBlock = 0 end
    if xInBlock > 1 then xInBlock = 1 end

    local surfaceYInBlock
    if tileType == "leftStair" then
        surfaceYInBlock = 1 - xInBlock
    else
        surfaceYInBlock = xInBlock
    end

    return (tileY - 0.5) + surfaceYInBlock
end

function Entity:isStairCollisionAt(x, y)
    local surfaceY = self:getStairSurfaceYAt(x, y)
    if surfaceY == nil then return false end
    return y < (surfaceY - 0.0001)
end

function Entity:canDropThroughPlatform(tileX, tileY)
    if self.platformDropThroughTimer > 0 then
        return true
    end

    if self.controls == nil or (not self.controls.down) then
        self.platformDropTargetKey = nil
        self.platformDropHeldFrames = 0
        self.platformDropLastTick = -1
        return false
    end

    -- Only block drop-through when falling too fast; small settling velocity should still allow it.
    if self.velocity.y < -self.platformDropSpeedThreshold then
        self.platformDropHeldFrames = 0
        self.platformDropLastTick = -1
        return false
    end

    -- Use platform row key to avoid per-sample X jitter resetting the hold counter.
    local key = tostring(tileY)
    if self.platformDropTargetKey ~= key then
        self.platformDropTargetKey = key
        self.platformDropHeldFrames = 1
        self.platformDropLastTick = tick
        return false
    end

    if self.platformDropLastTick ~= tick then
        self.platformDropHeldFrames = self.platformDropHeldFrames + 1
        self.platformDropLastTick = tick
    end

    if self.platformDropHeldFrames >= self.platformDropHoldFrames then
        self.platformDropThroughTimer = self.platformDropThroughDuration
        return true
    end

    return false
end

function Entity:isPlatformCollisionAt(x, y, centerY)
    local tileX = round(x)
    local tileY = round(y)
    local tile = world:getTile(tileX, tileY, "tiles")
    if tile == nil or tile.type ~= "platform" then return false end
    if self.platformDropThroughTimer > 0 then return false end
    if centerY ~= nil and y >= centerY then return false end

    if self:canDropThroughPlatform(tileX, tileY) then return false end

    local tileTop = tileY + 0.5
    local feetY = self.position.y - self.size
    local previousFeetY = feetY
    if self.velocity ~= nil then
        previousFeetY = feetY - (self.velocity.y * delta)
    end

    if feetY <= tileTop + 0.02 and previousFeetY >= tileTop - 0.08 then
        return true
    end
    return false
end

function Entity:isGrounded()
    local yCheck = self.position.y - self.size - 0.05
    local xCheck
    for ix = 0, math.ceil(self.size * 2) + 2 do
        xCheck = self.position.x - self.size + ((self.size * 2) / (math.ceil(self.size * 2) + 2) * ix)
        if world:getColision(xCheck, yCheck)
            or self:isStairCollisionAt(xCheck, yCheck)
            or self:isPlatformCollisionAt(xCheck, yCheck, self.position.y)
        then
            return true
        end
    end
    return false
end

function Entity:resolveStairFooting()
    if not self.hasWorldCollisions then return end
    if self.flyCheat then return end
    if self.velocity.y > 0 then return end

    local samples = math.ceil(self.size * 2) + 2
    local footY = self.position.y - self.size
    local bestSurfaceY = nil

    for ix = 0, samples do
        local xCheck = self.position.x - self.size + ((self.size * 2) / samples * ix)
        for oy = -1, 1 do
            local surfaceY = self:getStairSurfaceYAt(xCheck, footY + oy * 0.25)
            if surfaceY ~= nil then
                if footY <= surfaceY + 0.15 and footY >= surfaceY - 0.35 then
                    if bestSurfaceY == nil or surfaceY > bestSurfaceY then
                        bestSurfaceY = surfaceY
                    end
                end
            end
        end
    end

    if bestSurfaceY ~= nil then
        local targetPosY = bestSurfaceY + self.size + 0.005
        if self.position.y < targetPosY then
            self.position.y = targetPosY
            if self.velocity.y < 0 then self.velocity.y = 0 end
        end
    end
end

function Entity:dash(velocity,dashTime,direction,gravityMultiplier,dashStopVelocityX,dashStopVelocityY,continueVelocity)
    if dashStopVelocityX == nil then dashStopVelocityX = false end
    if dashStopVelocityY == nil then dashStopVelocityY = false end
    if continueVelocity == nil then continueVelocity = true end
    if gravityMultiplier == nil then gravityMultiplier = 0.5 end
    table.insert(self.dashes, {velocity = velocity, dashTime = dashTime, direction = direction, gravityMultiplier = gravityMultiplier, dashStopVelocityX = dashStopVelocityX, dashStopVelocityY = dashStopVelocityY, continueVelocity = continueVelocity})
end

function Entity:dashUpdate(dt)
    if #self.dashes > 0 then
        for i = #self.dashes, 1, -1 do
            local dash = self.dashes[i]

            if dash.dashStopVelocityX then
                self.velocity.x = 0
            end
            if dash.dashStopVelocityY then
                self.velocity.y = 0
            end

            if dash.dashTime > 0 then
                dash.dashTime = dash.dashTime - dt
            else
                if dash.continueVelocity then
                    self.velocity:move(dash.direction, dash.velocity)
                end
                table.remove(self.dashes, i)
            end
        end
    end
end

function Entity:getDashVelocity(axis)
    local dashVelocity = Vector2(0,0)
    if #self.dashes > 0 then
        for i = 1, #self.dashes do
            local dash = self.dashes[i]
            if dash.dashTime > 0 then
                dashVelocity:move(dash.direction, dash.velocity)
            end
        end
    end
    if axis == nil then
        return dashVelocity
    end
    return dashVelocity[axis]
end

function Entity:collisionUpdate(dt)
    self:dashUpdate(dt)
    if self.platformDropThroughTimer > 0 then
        self.platformDropThroughTimer = self.platformDropThroughTimer - dt
        if self.platformDropThroughTimer < 0 then self.platformDropThroughTimer = 0 end
    end
    --self:dash(10,1,100)
    if self.flyCheat then
        if self.controls.up then
            self.position.y = self.position.y + 20 * dt
        end
        if self.controls.down then
            self.position.y = self.position.y - 20 * dt
        end
        if self.controls.right then
            self.position.x = self.position.x + 20 * dt
        end
        if self.controls.left then
            self.position.x = self.position.x - 20 * dt
        end
    else
        --update Y

        self.position.y = self.position.y + (self.velocity.y * dt) + (self:getDashVelocity("y") * dt)

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
        self.position.x = self.position.x + (self.velocity.x * dt * self:getMovementSpeed()) + (self:getDashVelocity("x") * dt)

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

        self:resolveStairFooting()


        --s'assurer que le joueur n'est toujours pas coincé dans un block
        if self.hasWorldCollisions then
            if world:getColision(self.position.x, self.position.y)
                or self:isStairCollisionAt(self.position.x, self.position.y)
                or self:isPlatformCollisionAt(self.position.x, self.position.y, self.position.y)
            then
                local stuckCheckLimit = 1
                if self.type == "player" then stuckCheckLimit = 3 end
                for distan = 1, stuckCheckLimit do
                    if (not world:getColision(self.position.x, self.position.y-distan))
                        and (not self:isStairCollisionAt(self.position.x, self.position.y-distan))
                        and (not self:isPlatformCollisionAt(self.position.x, self.position.y-distan, self.position.y))
                    then
                        self.position.y = self.position.y - distan
                        return
                    end
                    if (not world:getColision(self.position.x, self.position.y+distan))
                        and (not self:isStairCollisionAt(self.position.x, self.position.y+distan))
                        and (not self:isPlatformCollisionAt(self.position.x, self.position.y+distan, self.position.y))
                    then
                        self.position.y = self.position.y + distan
                        return
                    end
                    if (not world:getColision(self.position.x+distan, self.position.y))
                        and (not self:isStairCollisionAt(self.position.x+distan, self.position.y))
                        and (not self:isPlatformCollisionAt(self.position.x+distan, self.position.y, self.position.y))
                    then
                        self.position.x = self.position.x + distan
                        return
                    end
                    if (not world:getColision(self.position.x-distan, self.position.y))
                        and (not self:isStairCollisionAt(self.position.x-distan, self.position.y))
                        and (not self:isPlatformCollisionAt(self.position.x-distan, self.position.y, self.position.y))
                    then
                        self.position.x = self.position.x - distan
                        return
                    end
                end
            end
        end
    end
end

function Entity:camUpdate()
    if (camEntityFollow == self.id) then
        camv = math.sqrt(szy * szx) / 30

        camv = round(camv / 8) * 8

        if camv <= 8 then camv = 8 end
        if camv >= 128 then camv = 128 end

        realcamx = round(self.position.x * 8) / 8
        realcamy = round((self.position.y + self.spriteOffsetY) * 8) / 8
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

function Entity:interactUpdate(dt)
    if self.controls.interact then
        local success, interactable, interactablePosition = self:getInteractable(self.position, self:getAim(), 8)
        if success and interactable ~= nil and interactablePosition ~= nil then
            interactable:interact(interactablePosition.x, interactablePosition.y, self)
        end
    end
end

function Entity:getInteractable(entityPosition, aimPosition, interactionRange)
    local interactable = nil
    local interactablePosition = nil
    local success = false

    if entityPosition == nil then return false, nil, nil end
    if aimPosition == nil then aimPosition = entityPosition end

    local aimDirection = pointat180(entityPosition.x, entityPosition.y, aimPosition.x, aimPosition.y)
    local interactionRadius = 1

    local function checkTileAt(position)
        if position == nil then return false end
        local tile = world:getTile(round(position.x), round(position.y), "tiles")
        if tile ~= nil and tile ~= tiles["none"] and tile.interactable then
            interactable = tile
            interactablePosition = Vector2(round(position.x), round(position.y))
            return true
        end
        return false
    end

    if checkTileAt(aimPosition) and aimPosition:dist(entityPosition) <= interactionRange and world:canLineGoThrough(entityPosition, aimPosition) then
        return true, interactable, interactablePosition
    end

    for i = 0, interactionRange, 0.5 do
        local checkPosition = entityPosition:copy()
        checkPosition:move(aimDirection, i)
        checkPosition.x = round(checkPosition.x)
        checkPosition.y = round(checkPosition.y)

        if checkTileAt(checkPosition) and world:canLineGoThrough(entityPosition, checkPosition) then
            success = true
            break
        end

        for ix = -interactionRadius, interactionRadius do
            for iy = -interactionRadius, interactionRadius do
                local offsetPosition = checkPosition:copy()
                offsetPosition.x = round(offsetPosition.x + ix)
                offsetPosition.y = round(offsetPosition.y + iy)

                if checkTileAt(offsetPosition) and world:canLineGoThrough(entityPosition, checkPosition) then
                    success = true
                    break
                end
            end
            if success then break end
        end

        if success then break end
    end

    if success then
        return true, interactable, interactablePosition
    end

    --[[for ix = -interactionRange, interactionRange do
        for iy = -interactionRange, interactionRange do
            local offsetPosition = entityPosition:copy()
            offsetPosition.x = round(offsetPosition.x + ix)
            offsetPosition.y = round(offsetPosition.y + iy)

            if checkTileAt(offsetPosition) then
                return true, interactable, interactablePosition
            end
        end
    end]]

    return false, nil, nil
end

function Entity:drawInteractionPreview()
    local success, interactable, interactablePosition = self:getInteractable(self.position, self:getAim(), 8)
    if success and interactablePosition ~= nil then
        local x, y, size = world:getTileScreenPosition(round(interactablePosition.x), round(interactablePosition.y))
        local color = { 0.8, 0.8, 0, 0.8 }
        if textures["sprites"]["placementPreview"] ~= nil then
            textures["sprites"]["placementPreview"]:drawSI("right", x, y, size, size, color)
        end
        local textSize = size / 4
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("Press E to interact", x - size * 2, y + size * 1.5, (size * 15)/textSize, "left",0,textSize,textSize)
    end
end

function Entity:drawBlocPreview()
    for ix = 1, self.inventory[1].sizeX do
        for iy = 1, self.inventory[1].sizeY do
            local item = items[self.inventory[1]:getItemName(ix, iy)]

            if item ~= nil then
                if item.placeBlock ~= "none" and checkifinlist(self.inventory[1]:getSlotAttribute("button", ix, iy), item.desiredInventorySpots) then
                    local color = { self.cursorColor[1], self.cursorColor[2], self.cursorColor[3], 0.4 }
                    if self.inventory[1]:getSlotAttribute("cooldown", ix, iy) > 0.1 then color = { self.cursorColor[1],
                            self.cursorColor[2], self.cursorColor[3], 0.18 } end

                    local place = world:rayTrace({ item.blockPlaceLayer }, self.position:copy(),
                        Vector2(round(self:getAim("x")), round(self:getAim("y"))), item.rangeLimit, true)

                    if self.flyCheat then
                        place = Vector2(round(self:getAim("x")), round(self:getAim("y")))
                    end

                    local x, y, size = world:getTileScreenPosition(round(place.x), round(place.y))


                    textures["sprites"]["placementPreview"]:drawSI("right", x, y, size, size, color)
                end
            end
        end
    end
end

function Entity:drawAttackPreview()
    for ix = 1, self.inventory[1].sizeX do
        for iy = 1, self.inventory[1].sizeY do
            local item = items[self.inventory[1]:getItemName(ix, iy)]

            if item ~= nil then
                if item.damage > 0 and checkifinlist(self.inventory[1]:getSlotAttribute("button", ix, iy), item.desiredInventorySpots) and item.subCategory == "melee" then
                    local targets = item:getMeleeWeaponTargets(self, self.inventory[1]:getItemAttributes(ix, iy), self:getAim("x"), self:getAim("y"))

                    if #targets > 0 then
                        for targ = 1, #targets do
                            local x, y, size = world:getTileScreenPosition(round(targets[targ].position.x,8), round(targets[targ].position.y,8))

                            if self.inventory[1]:getSlotAttribute("cooldown", ix, iy) > 0.1 then
                                local color = { 0.8, 0.8, 0, 0.5 }
                                textures["sprites"]["destroyPreview"]:drawSI("right", x, y, size, size, color)
                            else
                                local color = { 0.8, 0.8, 0, 0.8 }
                                textures["sprites"]["destroyPreviewReady"]:drawSI("right", x, y, size, size, color)
                            end
                        end
                    end
                end
            end
        end
    end
end

function Entity:drawMinePreview()
    local aimX = self:getAim("x")
    local aimY = self:getAim("y")
    local inventory = self.inventory[1]

    for ix = 1, self.inventory[1].sizeX do
        for iy = 1, self.inventory[1].sizeY do
            local itemName = inventory:getItemName(ix, iy)
            local item = items[itemName]

            if item ~= nil then
                local button = inventory:getSlotAttribute("button", ix, iy)
                if item.mineDamage > 0 and checkifinlist(button, item.desiredInventorySpots) then
                    local attributes = inventory:getItemAttributes(ix, iy)
                    local targets = item:getPickaxeTargets(self, attributes, aimX, aimY)

                    if #targets > 0 then
                        for targ = 1, #targets do
                            local x, y, size = world:getTileScreenPosition(round(targets[targ].x), round(targets[targ].y))

                            if inventory:getSlotAttribute("cooldown", ix, iy) > 0.1 then
                                local color = { 0.8, 0.4, 0, 0.5 }
                                textures["sprites"]["destroyPreview"]:drawSI("right", x, y, size, size, color)
                            else
                                local color = { 0.8, 0.4, 0, 0.8 }
                                textures["sprites"]["destroyPreviewReady"]:drawSI("right", x, y, size, size, color)
                            end
                        end
                    end
                end
            end
        end
    end
end

function Entity:DrawUI()
    self:drawBlocPreview() debugtimelog("blocPreview","sub")
    self:drawMinePreview() debugtimelog("minePreview","sub")
    self:drawInteractionPreview() debugtimelog("interactionPreview","sub")
    self:drawAttackPreview() debugtimelog("attackPreview","sub")

    if self.controls.openInventory then
        if self.inventoryOpened then
            self:closeInventory()
        else
            self.inventoryOpened = true
        end
    end

    local itemToolTipOffset = 0
    local itemDraw = nil
    
    if self.inventoryOpened then
        if #self.inventory > 0 then
            for i = 1, #self.inventory do
                local hovered = self.inventory[i]:draw("complete", self, { ["hightlights"] = self.inventorySpaceHighlights }) debugtimelog("inventoryDraw","sub")
                if hovered ~= nil then
                    itemDraw = hovered
                end
            end
        end
    else
        if #self.inventory > 0 then
            itemDraw = self.inventory[1]:draw("firstLine", self) debugtimelog("hotBarDraw","sub")
        end
    end

    if self.xpBar ~= nil then
        if HealthBarPosition == "top" then
            self.xpBar:draw(szx*0.05,szy*0.05+szy*0.07,szx*0.25,szy*0.02,HealthBarStyle,"total",szy*0.02/10,5,nil,"Level: "..self.level..", xp: ")
        else
            self.xpBar:draw(szx*0.05,szy*0.89-szy*0.03,szx*0.25,szy*0.02,HealthBarStyle,"total",szy*0.02/10,5,nil,"Level: "..self.level..", xp: ")
        end
        --self.health:draw(szx*0.05,szy*0.89-szy*0.1,szx*0.25,szy*0.06,HealthBarStyle,"total",nil,5)
    end
    debugtimelog("xpBarDraw","sub")

    if self.health ~= nil then
        if HealthBarPosition == "top" then
            self.health:draw(szx*0.05,szy*0.05,szx*0.25,szy*0.06,HealthBarStyle,"sectionned",nil,5)
        else
            self.health:draw(szx*0.05,szy*0.89,szx*0.25,szy*0.06,HealthBarStyle,"sectionned",nil,5)
        end
        --self.health:draw(szx*0.05,szy*0.89-szy*0.1,szx*0.25,szy*0.06,HealthBarStyle,"total",nil,5)
    end
    debugtimelog("healthBarDraw","sub")

    if itemDraw ~= nil then
        if itemDraw.item ~= nil and itemDraw.item.itemName ~= "none" then
            itemToolTipOffset = itemDraw.item:drawToolTip(true,mx+100,my,math.ceil(szx*0.07),szx * 0.35,itemDraw.attributes,itemDraw.amount,self)
        end
    end
    debugtimelog("itemToolTipDraw","sub")

    if self.inventoryCursor.name ~= "none" then
        self:drawCursorItem(itemToolTipOffset)
        debugtimelog("drawCursorItem","sub")
    end
end

function Entity:drawCursorItem(itemToolTipOffset)
    local x1, y1, s1 = self.inventory[1]:getTilePosAndSize(1, 1)
    x1 = mx - s1 / 2
    y1 = my - s1 / 2
    if self.inventoryCursor.name ~= "none" then
        if items[self.inventoryCursor.name] ~= nil then
            items[self.inventoryCursor.name]:draw("medium", x1 + s1 / 2, y1 + s1 / 2, s1, self.inventoryCursor
            .attributes)
            if self.inventoryCursor.amount > 0 then
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.printf("x" .. self.inventoryCursor.amount, x1, y1 + s1 - 15, s1 / 1.2, "right", 0, 1.2, 1.2)
            end
            items[self.inventoryCursor.name]:drawToolTip(true,mx+100,my + itemToolTipOffset + 10,math.ceil(szx*0.07),szx * 0.3,self.inventoryCursor.attributes,self.inventoryCursor.amount,self)
        end
    end
end

function Entity:CollisionDirectionCheck(center, otherAxisPosition, check, axis)
    --local differenceAxis = math.abs(self.position.y-otherAxisPosition)
    --if axis == "y" then differenceAxis = math.abs(self.position.x-otherAxisPosition) end
    local differenceAxis = self.size
    if axis == "x" then
        -- Horizontal resolution should not treat stairs as full wall blocks.
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

        if (not collide) and check < center then
            local platformCollide = self:isPlatformCollisionAt(otherAxisPosition, check, center)
            if platformCollide then
                local tileTop = round(check) + 0.5
                local targetPosY = tileTop + differenceAxis + 0.005
                if self.position.y < targetPosY then
                    self.position.y = targetPosY
                end
                if self.velocity.y < 0 then self.velocity.y = 0 end
                return true
            end
        end

        -- Stair collision is floor-only and resolves to the slope surface, not a full-block boundary.
        if check < center then
            local surfaceY = self:getStairSurfaceYAt(otherAxisPosition, check)
            if surfaceY ~= nil and check < surfaceY then
                local targetPosY = surfaceY + differenceAxis + 0.005
                if self.position.y < targetPosY then
                    self.position.y = targetPosY
                end
                if self.velocity.y < 0 then self.velocity.y = 0 end
                return true
            end
        end
    end
    return false
end

function Entity:collisionWithEntities(dt)
    --
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
        --print(result)
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
    --[[if middleclicktick then
        self:gainHealth(20,nil)
    end
    if rightclicktick then
        self:damage(20,"dev")
    end]]
    if self.state ~= "death" then
        self.timeAlive = self.timeAlive + dt
        if self.timeAlive < 0.2 then
            self.health:setValue(self:getMaxHealth(),"hp")
        end
    end
    self.lastDamageTakenTime = self.lastDamageTakenTime + dt
    self.greenTime = self.greenTime + dt
    self.redTime = self.redTime + dt
    self.health:update(dt)
    self.xpBar:update(dt)
    self:levelUpdate(dt)
    self:statsUpdate(dt)
end

function Entity:levelUpdate(dt)
    --self.xpBar = Bar("xp",{0,0,0,1},{1,1,1,1},"multisection")
    --self.xpAccumulated = 0

    self.xpBar:setMax(self.xpToLevelUp + (self.level - 1) * self.xpToLevelUpPerLevel)
    if self.xpBar:isFull() then
        self:levelUp()
    end
end

function Entity:dropXp(proportion)
    if proportion == nil then proportion = 1 end
    local xpToDrop = (self.xpGiveOnDeath + self.xpAccumulated) * proportion
    world:spawnXPparticles(xpToDrop, self.position:copy())
end

function Entity:giveXp(amount,from)
    --time, size, height,color,outlineColor,animationColor, flags)
    world:spawnTextParticle((round(amount)).."",self.position:copy(),nil,nil,nil,{0,1,1,1},{1,1,1,1})

    self.xpAccumulated = self.xpAccumulated + amount
    self.xpBar:increase(amount)
    self.xpBar.flashTime = 0
end

function Entity:levelDown()
    self.level = self.level - 1
    --self.xpBar:setValue(self.xpBar:getValue() - self.xpBar:getMax())
    --self:giveHealth(self:getMaxHealth(),"hp")
end

function Entity:levelUp()

    world:spawnTextParticle("Level Up!",self.position:copy(),nil,nil,nil,{0,1,1,1},{1,1,1,1})

    self.level = self.level + 1
    self.xpBar:setValue(self.xpBar:getValue() - self.xpBar:getMax())
    self:gainHealth(self:getMaxHealth() - self.health:getValue("hp"),"hp")
end

function Entity:statsUpdate(dt)

    self.health:setMax(self:getMaxHealth(),"hp")
    self.health:setBaseRegen(self:getRegen(),"hp")
    self.movevementSpeed = self:getMovementSpeed()
    self.jumpStrength = self:getJumpStrength()
    self.attackDamage = self:getDamage()
    self.knockbackMultiplier = self:getKnockback()
    self.gravity = self:getGravity()
    self.cooldownReduction = self:getCooldownReductionMultiplier()

end

function Entity:playerUpdate(dt)
    self:inventoryUpdate(dt)
    if self.controls.mine then
        if self.mineRadius == 1 then
            self:mineTarget(dt)
        else
            self:mineTarget(dt, self.miningRadius)
        end
    end
end

function Entity:inventoryUpdate(dt)
    --self.controls.invClick
    --self.controls.invRightClick
    --self.controls.invShiftClick
    --self.controls.invShiftRightClick

    --self.inventoryCursor = {["amount"]=0,["name"]="none",["attributes"]={}}
    if love.keyboard.isDown("f8") and self.type == "player" then
        self.inventory[2]:cheatAccessoryShortcut()
    end

    self.inventorySpaceHighlights = {}

    local tileInteraction = {}
    tileInteraction.insideInventory = false
    tileInteraction.x = 0
    tileInteraction.y = 0
    tileInteraction.page = 0
    tileInteraction.inventory = 0

    for inv = 1, #self.inventory do
        invX, invY, sizeX, sizeY = self.inventory[inv]:getPosAndSize()
        if mx > invX and mx < invX + sizeX and my > invY and my < invY + sizeY then
            tileInteraction.insideInventory = true
        end
        for ix = 1, #self.inventory[inv]["items"][self.inventory[inv]["currentPage"]] do
            for iy = 1, #self.inventory[inv]["items"][self.inventory[inv]["currentPage"]][ix] do
                tileX, tileY, size = self.inventory[inv]:getTilePosAndSize(ix, iy)
                if mx > tileX and mx < tileX + size and my > tileY and my < tileY + size then
                    if not self.inventory[inv]:getSlotAttribute("disabled", ix, iy) then
                        tileInteraction.x = ix
                        tileInteraction.y = iy
                        tileInteraction.page = self.inventory[inv]["currentPage"]
                        tileInteraction.inventory = inv

                        local itemName, itemAmount, itemAttributes = self.inventory[tileInteraction.inventory]:getItem(
                        tileInteraction.x, tileInteraction.y, tileInteraction.page)

                        if items[itemName] ~= nil then
                            local item = items[itemName]

                            self.inventorySpaceHighlights = item.desiredInventorySpots
                        end
                    end
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
                self:inventorySwitchHand(tileInteraction.inventory, tileInteraction.page, tileInteraction.x,
                    tileInteraction.y)
            end

            if self.controls.invRightClick and self.inventoryCursor.name == "none" then
                self:inventoryTakeHalfHand(tileInteraction.inventory, tileInteraction.page, tileInteraction.x,
                    tileInteraction.y)
            end

            if self.controls.invRightClick and self.inventoryCursor.name ~= "none" then
                self:inventoryLeaveOneItem(tileInteraction.inventory, tileInteraction.page, tileInteraction.x,
                    tileInteraction.y)
            end

            if (self.controls.invRightClickHold) and self.inventoryCursor.name ~= "none"
                and self.inventory[tileInteraction.inventory]["items"][tileInteraction.page][tileInteraction.x][tileInteraction.y]["name"] == "none"
            then
                self:inventoryLeaveOneItem(tileInteraction.inventory, tileInteraction.page, tileInteraction.x,
                    tileInteraction.y)
            end

            if (self.controls.invShiftClick or self.controls.invShiftClickHold) then
                self:inventoryShiftItemToNewInventory(tileInteraction.inventory, tileInteraction.page, tileInteraction.x,
                    tileInteraction.y)
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
    local velocity = Vector2(0, 12)
    local position = Vector2(self.position.x, self.position.y)

    if self.animationDirection == "right" then velocity.x = 25 end
    if self.animationDirection == "left" then velocity.x = -25 end

    if type == "all" then
        world:spawnGroundItem(self.inventoryCursor.name, position, velocity, self.inventoryCursor.amount,
            self.inventoryCursor.attributes, { ["pickupTimer"] = 3 })

        self.inventoryCursor.amount = 0
        self.inventoryCursor.name = "none"
        self.inventoryCursor.attributes = {}
    end

    if type == "single" then
        world:spawnGroundItem(self.inventoryCursor.name, position, velocity, 1, self.inventoryCursor.attributes,
            { ["pickupTimer"] = 3 })

        self.inventoryCursor.amount = self.inventoryCursor.amount - 1
        if self.inventoryCursor.amount <= 0 then
            self.inventoryCursor.name = "none"
            self.inventoryCursor.attributes = {}
        end
    end
end

function Entity:inventorySwitchHand(inventoryIndex, page, x, y)
    local maxS = items[self.inventory[inventoryIndex]:getItemName(x, y, page)].maxStack

    if self.inventoryCursor.name == self.inventory[inventoryIndex]:getItemName(x, y, page)
    and self.inventoryCursor.attributes == self.inventory[inventoryIndex]:getItemAttributes(x, y, page)
    --and self.inventoryCursor.attributes == self.inventory[inventoryIndex]["items"][page][x][y]["attributes"]
    then
        local add = maximum(self.inventoryCursor.amount, maxS - self.inventory[inventoryIndex]:getItemAmount(x, y, page))

        self.inventory[inventoryIndex]:itemAmountAdd(add, x, y, page)

        self.inventoryCursor.amount = self.inventoryCursor.amount - add

        if self.inventoryCursor.amount <= 0 then
            self.inventoryCursor.name = "none"
            self.inventoryCursor.attributes = {}
        end
    else
        local buffer = {}
        buffer.amount = self.inventoryCursor.amount
        buffer.name = self.inventoryCursor.name
        buffer.attributes = self.inventoryCursor.attributes

        self.inventoryCursor.amount = self.inventory[inventoryIndex]:getItemAmount(x, y, page)
        self.inventoryCursor.name = self.inventory[inventoryIndex]:getItemName(x, y, page)
        self.inventoryCursor.attributes = self.inventory[inventoryIndex]:getItemAttributes(x, y, page)

        self.inventory[inventoryIndex]:setItemAmount(buffer.amount, x, y, page)
        self.inventory[inventoryIndex]:setItemName(buffer.name, x, y, page)
        self.inventory[inventoryIndex]:setItemAttributes(buffer.attributes, x, y, page)
    end
end

function Entity:inventoryTakeHalfHand(inventoryIndex, page, x, y)
    self.inventoryCursor.amount = math.ceil(self.inventory[inventoryIndex]:getItemAmount(x, y, page) / 2)
    self.inventoryCursor.name = self.inventory[inventoryIndex]:getItemName(x, y, page)
    self.inventoryCursor.attributes = self.inventory[inventoryIndex]:getItemAttributes(x, y, page)

    self.inventory[inventoryIndex]:itemAmountAdd(-math.ceil(self.inventory[inventoryIndex]:getItemAmount(x, y, page) / 2),
        x, y, page)
end

function Entity:inventoryShiftItemToNewInventory(inventoryIndex, page, x, y)
    if self.inventory[inventoryIndex]:getItemName(x, y, page) ~= "none" then
        local targetInventory = #self.inventory
        if inventoryIndex == targetInventory then
            targetInventory = 1
        end

        local targetInventoryPage = self.inventory[targetInventory]["currentPage"]
        for ix = 1, self.inventory[targetInventory].sizeX do
            for iy = 1, self.inventory[targetInventory].sizeY do
                if self.inventory[inventoryIndex]:getItemAmount(x, y, page) > 0 then
                    local itemName, itemAmount, itemAttributes = self.inventory[inventoryIndex]:getItem(x, y, page)
                    local targetItemName, targetItemAmount, targetItemAttributes = self.inventory[targetInventory]
                    :getItem(ix, iy, targetInventoryPage)
                    local maxS = items[itemName].maxStack

                    if targetItemName == "none" then
                        self.inventory[targetInventory]:setItemName(itemName, ix, iy, targetInventoryPage)
                        self.inventory[targetInventory]:setItemAttributes(itemAttributes, ix, iy, targetInventoryPage)
                        self.inventory[targetInventory]:setItemAmount(maximum(itemAmount, maxS), ix, iy,
                            targetInventoryPage)
                        self.inventory[inventoryIndex]:itemAmountAdd(-maximum(itemAmount, maxS), x, y, page)

                        self.inventory[targetInventory]:setSlotAttribute("useAnimation", 0.5, ix, iy, targetInventoryPage)
                        self.inventory[targetInventory]:setSlotAttribute("useAnimationMax", 0.5, ix, iy,
                            targetInventoryPage)
                    end
                    if targetItemName == itemName and targetItemAmount < maxS then
                        self.inventory[targetInventory]:itemAmountAdd(maximum(itemAmount, maxS), ix, iy,
                            targetInventoryPage)
                        self.inventory[inventoryIndex]:itemAmountAdd(-maximum(itemAmount, maxS), x, y, page)

                        self.inventory[targetInventory]:setSlotAttribute("useAnimation", 0.5, ix, iy, page)
                        self.inventory[targetInventory]:setSlotAttribute("useAnimationMax", 0.5, ix, iy, page)
                    end
                end
            end
        end
        if self.inventory[inventoryIndex]:getItemAmount(x, y, page) <= 0 then
            self.inventory[inventoryIndex]:resetItem(x, y, page)
        end
    end
end

function Entity:inventoryLeaveOneItem(inventoryIndex, page, x, y)
    if self.inventory[inventoryIndex]:getItemName(x, y, page) == self.inventoryCursor.name
        or self.inventory[inventoryIndex]:getItemName(x, y, page) == "none"
    then
        if self.inventory[inventoryIndex]:getItemAmount(x, y, page) < items[self.inventoryCursor.name].maxStack then
            self.inventoryCursor.amount = self.inventoryCursor.amount - 1
            self.inventory[inventoryIndex]:itemAmountAdd(1, x, y, page)
            self.inventory[inventoryIndex]:setItem(self.inventoryCursor.name, nil, self.inventoryCursor.attributes, x, y,
                page)
        end
    end
end

function Entity:animationUpdate(dt)
    self.animationTime = self.animationTime + dt * self.animationSpeed
    if self.controls.left then self.animationDirection = "left" end
    if self.controls.right then self.animationDirection = "right" end

    local newAnimation = "idle"

    if self.controls.left or self.controls.right or math.abs(self.velocity.x) > 0.04 then newAnimation = "walk" end
    if not self:isGrounded() then newAnimation = "jump" end
    if self.controls.mine then newAnimation = "use" end

    if newAnimation ~= self.animation then self:setAnimation(newAnimation) end

    if self.animation == "idle" then self.animationSpeed = 1 end
    if self.animation == "walk" then self.animationSpeed = math.abs(self.velocity.x * self.movevementSpeed) * self.movementAnimationSpeed end
    if self.animation == "jump" then self.animationSpeed = 1 end
    --if self.animation == "use" then self.animationSpeed = 1 end
end

function Entity:setAnimation(newAnimation, newSpeed)
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
        if newSpeed ~= nil then self.animationSpeed = newSpeed end
    end
end

function Entity:drawHoldItem(spriteX, spriteY, size)
    if self.itemHold.name ~= "none" then
        items[self.itemHold.name]:drawHolding(self, spriteX, spriteY, size, self.itemHold.attributes,
            self.itemHold.quantity)
    end
end

function Entity:drawHealthBars()
    --love.graphics.setColor(1,1,1,1)
    --love.graphics.print(self:getMovementSpeed(),300,0)
    --love.graphics.print(self:getInventoryData("movementSpeed","multiply",5,2),300,10)
    --local x, y, size = world:getTileScreenPosition(round(self.position.x,8),round(self.position.y - self.size - 0.5,8) )
    local x, y = positiontoscreen(round(self.position.x * 8) / 8,
        round((self.position.y - self.size / 2 - 0.5) * 8) / 8 )
    local size = camv / 8

    local width = size * self.size * 3 * 8

    self.health:draw(x-width/2,y,width,szy*0.008,"glued","total",szy*0.001,5,"bars")
    self.health:draw(x-width/2,y,width,szy*0.008,"glued","total",szy*0.001,5,"previews")
    self.health:draw(x-width/2-100,y,width+200,szy*0.035,"glued","total",szy*0.0012,5,"text")

    local txtSize = math.ceil(szy*0.0012)
    love.graphics.setColor(0,0,0,1)
    love.graphics.printf("lvl "..self.level,x-width-100+1,y+szy*0.02,(width*2+200)/txtSize,"center",0,txtSize,txtSize)
    love.graphics.printf("lvl "..self.level,x-width-100-1,y+szy*0.02,(width*2+200)/txtSize,"center",0,txtSize,txtSize)
    love.graphics.printf("lvl "..self.level,x-width-100,y+szy*0.02+1,(width*2+200)/txtSize,"center",0,txtSize,txtSize)
    love.graphics.printf("lvl "..self.level,x-width-100,y+szy*0.02-1,(width*2+200)/txtSize,"center",0,txtSize,txtSize)
    love.graphics.setColor(1,1,1,1)
    love.graphics.printf("lvl "..self.level,x-width-100,y+szy*0.02,(width*2+200)/txtSize,"center",0,txtSize,txtSize)
    --love.graphics.rectangle("fill",x,y,100,5)
    --love.graphics.setColor(1,1,1,1)
    --love.graphics.print((round((self.position.y - self.size / 2 - 0.5) * 8) / 8),0,0)

end

function Entity:draw(inInventory, customX, customY, customSize)
    self:updateFallDamage()
    local x
    local y
    x, y = positiontoscreen(round(self.position.x * 8) / 8,
        round((self.position.y + self.spriteOffsetY) * 8) / 8 - self.spriteOffsetY)
    local spriteX, spriteY = positiontoscreen(round(self.position.x * 8) / 8,
        round((self.position.y + self.spriteOffsetY) * 8) / 8)
    spriteY = spriteY
    if customX ~= nil then spriteX = customX end
    if customY ~= nil then spriteY = customY end
    if inInventory == nil then inInventory = false end

    local size = camv / 8 * self.spriteSize

    if customSize ~= nil then size = customSize end

    self:drawHoldItem(spriteX, spriteY, size)

    --love.graphics.setColor(0, 0, 0, 1)
    --love.graphics.circle("fill", x, y, self.size * camv)
    --love.graphics.setColor(1, 1, 1, 1)
    --love.graphics.circle("fill", x, y, self.size * camv * 0.8)

    if not inInventory then
        love.graphics.setColor(1, 1, 1, 0.2)
        love.graphics.circle("fill", x, y, self.size * camv * 1)
    end

    --print("sprite name : "..self.spriteName)
    --print("animation : "..self.animation)

    if self.spriteName ~= "none" and self.animation ~= "none" and textures["sprites"][self.spriteName] ~= nil then
        --print("draw1")
        
        local colorisationColor = CopyAll(self.colorisation)
        if colorisationColor == nil then colorisationColor = { 1, 1, 1, 0 } end
        --self.lastDamageTakenTime = 0.1
        if self.lastDamageTakenTime < 0.5 then
            colorisationColor = OverrideColor(colorisationColor,{3,3,3,1,(0.5-self.lastDamageTakenTime)*2})
        end
        if self.redTime < 0.5 then
            colorisationColor = OverrideColor(colorisationColor,{3,0,0,1,(0.5-self.redTime)*2})
        end
        if self.greenTime < 0.5 then
            colorisationColor = OverrideColor(colorisationColor,{0,3,0,1,(0.5-self.greenTime)*2})
        end

        self.sprite:draw(self.animation, self.animationTime, self.animationDirection, spriteX, spriteY, size, size,
            { 1, 1, 1, 1 },colorisationColor)
    end

    --love.graphics.print(self.ia, x, y + 100)
end

function Entity:groundItemsUpdate(dt)
    if #world.groundItems > 0 then
        for g = #world.groundItems, 1, -1 do
            if self.inventory[1]:checkIfEmptySpacesAvailable() then
                if world.groundItems[g]:moveEntityUpdate(dt, self.position:copy(), self.size + 5) then
                    local success, amountLeft = self.inventory[1]:addItem(world.groundItems[g]["name"],
                        world.groundItems[g]["amount"], world.groundItems[g]["attributes"])

                    if success then
                        table.remove(world.groundItems, g)
                    else
                        world.groundItems[g].amount = amountLeft
                    end
                end
            end
        end
    end
end
