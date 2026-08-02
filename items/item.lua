require "class/superClass"
Item = SuperClass:extend()
Item.className = "Item"


function Item:init(itemName,sprite,flags)
    self.itemName = itemName
    self.flags = flags or {}
    self.sprite = textures["sprites"][sprite] or "none"
    self.spriteName = sprite or "none"
    self.description = self.flags.description or {""}


    self.placeBlock = self.flags.placeBlock or "none"
    self.placeBlockCost = self.flags.placeBlockCost or 1
    self.blockPlaceLayer = self.flags.blockPlaceLayer or "tiles"

    self.fullName = self.flags.fullName or (self.itemName)
    self.category = self.flags.category or "none"
    self.subCategory = self.flags.subCategory or "none"

    if self.flags.holdAnimation ~= nil then
        self.holdAnimation = textures["sprites"][self.flags.holdAnimation]
    end


    self.unique = self.flags.unique or false

    if checkifinlist(self.category, {"tool","weapon"}) then
        self.unique = true
    end


    self.stackable = self.flags.stackable or true
    self.maxStack = self.flags.maxStack or 99
    if self.unique then self.stackable = false self.maxStack = 1 end
    
    self.mineDamage = self.flags.mineDamage or 0
    self.blockDamageAmount = self.flags.blockDamageAmount or 0
    self.mineArcAngle = self.flags.mineArcAngle or 180
    self.mineForwardWeight = self.flags.mineForwardWeight or 2
    self.mineWidth = self.flags.mineWidth or 1
    self.mineForwardWeight = self.flags.mineForwardWeight or 2
    self.mineLayer = self.flags.mineLayer or {"tiles"}
    self.minePierce = self.flags.minePierce or false

    self.damage = self.flags.damage or 0
    self.attackRange = self.flags.attackRange or 1
    self.attackRadius = self.flags.attackRadius or 1
    self.attackDirectionRange = self.flags.attackDirectionRange or 100
    self.knockback = self.flags.knockback or 0
    self.dashVelocity = self.flags.dashVelocity or 0
    self.dashTime = self.flags.dashTime or 0
    self.dashGravityMultiplier = self.flags.dashGravityMultiplier or 0.5
    
    self.groundSize = self.flags.groundSize or 0.45
    self.rangeLimit = self.flags.rangeLimit or 8

    self.cooldown = 0.2
    self.charge = self.flags.charge or 0
    self.disableGravityDuringCharge = self.flags.disableGravityDuringCharge or false
    self.moveSpeedDuringCharge = self.flags.moveSpeedDuringCharge or 0.5
    if self.subCategory == "wall" then self.cooldown = 0.05 end
    if self.flags.cooldown ~= nil then self.cooldown = self.flags.cooldown end
    self.desiredInventorySpots = self.flags.desiredInventorySpots or {"none"}
    if self.placeBlock ~= "none" then self.desiredInventorySpots = {"space","x","c"} end
    if self.category == "tool" then self.desiredInventorySpots = {"space"} end
    if self.category == "weapon" then self.desiredInventorySpots = {"leftClick"} end

    --self.canBeUsed = self.flags.canBeUsed or (self.placeBlock~="none")

    self.baseColor = self.flags.baseColor or {1,1,1,1}
    self.baseColorisation = self.flags.baseColorisation or {0,0,0,0}
    
    --self.textures = textures or {["groundDisplay"]="none",[""]}

    table.insert(ItemList,itemName)
end

function Item:getCharge(attributes,entity)
    return round(self.charge,100)
end


function Item:getDashVelocity(attributes,entity)
    return round(self.dashVelocity,100)
end

function Item:getDashGravityMultiplier(attributes,entity)
    return round(self.dashGravityMultiplier,100)
end

function Item:getDashTime(attributes,entity)
    return round(self.dashTime,100)
end


function Item:getDPS(attributes,entity)
    return round((self:getDamage(attributes,entity)) / (self:getCooldown(attributes,entity) + self:getCharge(attributes,entity)),100)
end

function Item:getDamage(attributes,entity)
    local damage = self.damage
    if entity ~= nil then
        damage = damage * entity:getDamage()
    end
    return math.ceil(damage)
end

function Item:getBaseDamage(attributes,entity)
    return self:getDamage(attributes)
end

function Item:getAttackRange(attributes,entity)
    return round(self.attackRange,10)
end

function Item:getAttackRadius(attributes,entity)
    return round(self.attackRadius,10)
end

function Item:getAttackDirectionRange(attributes,entity)
    return round(self.attackDirectionRange)
end

function Item:getKnockback(attributes,entity)
    return round(self.knockback,10)
end


function Item:getBlockDamagePerSecond(attributes,entity)
    return round((self:getBlockDamageAmount(attributes,entity)* self:getMineDamage(attributes,entity)) / self:getCooldown(attributes,entity),100)
end

function Item:getMineDamage(attributes,entity)
    return round(self.mineDamage,100)
end

function Item:getMineWidth(attributes,entity)
    return round(self.mineWidth,10)
end

function Item:getBlockDamageAmount(attributes,entity)
    return math.ceil(self.blockDamageAmount)
end

function Item:getCooldown(attributes,entity)
    return round(self.cooldown,100)
end

function Item:getRange(attributes,entity)
    return round(self.rangeLimit,10)
end

local function checkIfTargetInList(value1, targetList)
    if targetList == nil then return false end
    local inside = false
    if #targetList > 0 then
        for j6 = 1, #targetList do
            if targetList[j6].index == value1.index then inside = true end
            if targetList[j6].id == value1.id then inside = true end
        end
    end
    return inside
end

function Item:getAllEntitiesInRadius(entity,position,radius,targetList)
    if targetList == nil then targetList = {} end
    if #entities > 0 then
        for i = 1, #entities do
            if entities[i].state ~= "dead" and entity:canAttack(entities[i]) then
                if entities[i].position:dist(position) <= radius then
                    if world:canLineGoThrough(entities[i].position,position) then
                        if not checkIfTargetInList(entities[i],targetList) then
                            local new = {
                                id = entities[i].id,
                                index = i,
                                position = entities[i].position:copy(),
                                entity = entities[i]
                            }
                            table.insert(targetList,new)
                        end
                    end
                end
            end
        end
    end

    return targetList
end

function Item:getMeleeWeaponTargets(entity,attributes,cursorX,cursorY)

    local targetList = {}

    local baseDirection = entity.position:getDirection360Towards(Vector2(round(cursorX),round(cursorY)))

    for a = 0, math.ceil(self:getAttackRadius(attributes,entity) * 10) do
        local position = entity.position:copy()
        position:move(baseDirection, a / 10)

        targetList = self:getAllEntitiesInRadius(entity, position, self:getAttackRange(attributes,entity), targetList)
    end
    
    return targetList
end

function Item:getPickaxeTargets(entity,attributes,cursorX,cursorY)

    local targetList = {}



    local place = nil
    if not self.minePierce then
        place = world:rayTrace({"tiles"},entity.position:copy(true),Vector2(round(cursorX),round(cursorY)),self:getRange(attributes,entity),false,true)
    else
        place = Vector2(round(cursorX),round(cursorY))
        if place:dist(entity.position:copy()) > self:getRange(attributes,entity) then
            place = entity.position:copy()
            place:moveTowards(Vector2(round(cursorX),round(cursorY)),self:getRange(attributes,entity))
        end

        local bloc = place:copy()
        if bloc:dist(entity.position:copy()) <= self:getRange(attributes,entity) then
            if world:getTile(bloc.x,bloc.y,"tiles").canBeMined and world:getTile(bloc.x,bloc.y,"tiles").name ~= "none" then
                if not checkIfVectorInList(Vector2(bloc.x,bloc.y),targetList,true) then
                    table.insert(targetList,Vector2(bloc.x,bloc.y))
                end
            end
        end
    end

    local baseDirection = entity.position:getDirection360Towards(Vector2(round(cursorX),round(cursorY)))

    for advance = 0, math.ceil(self:getRange(attributes,entity)*2) do
            for forwardDistance = 0, math.ceil(self:getMineWidth(attributes,entity)*4) do
            for side = -1,1,2 do
                local forwardValue = (advance/2)

                if #targetList < self:getBlockDamageAmount(attributes,entity) then

                    local bloc = entity.position:copy()
                    bloc:move(baseDirection,forwardValue )
                    bloc:move(baseDirection + 90 * side,forwardDistance * 0.25/4 )
                    bloc.x = round(bloc.x)
                    bloc.y = round(bloc.y)
                    --local angle

                    if pointInAngleRange(entity.position.x, entity.position.y, baseDirection, bloc.x, bloc.y, 100) then
                            if bloc:dist(entity.position:copy()) <= self:getRange(attributes,entity) then
                            if world:getTile(bloc.x,bloc.y,"tiles").canBeMined and world:getTile(bloc.x,bloc.y,"tiles").name ~= "none" then
                                if not checkIfVectorInList(Vector2(bloc.x,bloc.y),targetList,true) then
                                    table.insert(targetList,Vector2(bloc.x,bloc.y))
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return targetList
    
end

function Item:use(entity,attributes,cursorX,cursorY,slot,stacks)
    local stacksRemove = 0
    local setCooldown = self.cooldown
    local useSuccess = false
    --print("use item",self.itemName,slot,stacks)

    if checkifinlist(slot,self.desiredInventorySpots)then

        if self.placeBlock ~= "none" then

            local place = world:rayTrace({self.blockPlaceLayer},entity.position:copy(),Vector2(round(cursorX),round(cursorY)),self.rangeLimit,true)

            if entity.flyCheat then
                place = Vector2(cursorX,cursorY)
            end

            if place:dist(entity.position)>1 or self.blockPlaceLayer ~= "tiles" then
                if stacks >= self.placeBlockCost then
                    if world:placeTile(self.placeBlock, round(place.x), round(place.y), self.blockPlaceLayer, false) then
                        world:setTileProprety(round(place.x), round(place.y),"size",0)
                        stacksRemove = stacksRemove + self.placeBlockCost
                        useSuccess = true
                    end
                end
            end

        end

    end


    if checkifinlist(slot,self.desiredInventorySpots) and self:getMineDamage(attributes,entity) > 0 then

        local destroyedAtLeastATile = false

        local targets = self:getPickaxeTargets(entity,attributes,cursorX,cursorY)
        if #targets > 0 then
            for targ= 1,#targets do
                if world:damageBlock(targets[targ].x, targets[targ].y, self:getMineDamage(attributes,entity),"tiles",true) then
                    destroyedAtLeastATile = true
                end
            end
        end

        if destroyedAtLeastATile then
            world:updateLights(cursorX,cursorY)
        end

        useSuccess = true

    end



    if checkifinlist(slot,self.desiredInventorySpots) and self:getDamage(attributes,entity) > 0 then

        if self.subCategory == "melee" then

            local targets = self:getMeleeWeaponTargets(entity, attributes, cursorX, cursorY)

            if #targets > 0 then
                for i = 1, #targets do
                    local target = targets[i].entity
                    local maxHealth = target.health:getMax()
                    local damage = self:getDamage(attributes,entity)
                    target:spawnBlood(0.15+1 * math.ceil(damage / maxHealth * 150), 5 + damage * 5 / maxHealth, pointat180(entity.position.x,entity.position.y,target.position.x,target.position.y), 100)
                    target:damage(self:getDamage(attributes,entity),"weapon",entity)
                    if self:getKnockback(attributes,entity) > 0 then
                        target:dash(self:getKnockback(attributes,entity)*5*target.knockbackMultiplier,0.3,pointat180(entity.position.x,entity.position.y,target.position.x,target.position.y),1)
                    end
                end
            end

            useSuccess = true

        end 

    end

    

    if useSuccess then
        if self:getDashVelocity(attributes,entity) > 0 then

            entity:dash(self:getDashVelocity(attributes,entity),self:getDashTime(attributes,entity),pointat180(entity.position.x,entity.position.y,cursorX,cursorY),self:getDashGravityMultiplier(attributes,entity))

        end
    end

    if useSuccess then

        entity:setAnimation("use",1/maximum(setCooldown,0.8))
        
        if self.holdAnimation ~= nil then
            entity.itemHold.name = self.itemName
            entity.itemHold.attributes = attributes
            entity.itemHold.quantity = stacks
        end

    end


    return useSuccess, setCooldown, stacksRemove
end

local function convertTableIntoText(textTable)
    local text = ""
    for i = 1, #textTable do
        if type(textTable[i]) == "string" then
            text = text .. textTable[i]
        end
    end
    return text
end


function Item:drawToolTip(draw,screenX,screenY,sizeMultiplyer,maxX,attributes,amount,entity)
    windowSizeX = maxX
    windowSizeY = 0

    if screenX > szx - windowSizeX then screenX = szx - windowSizeX end
    

    local badgeSize = 0
    local padding = 10
    local textXOffset = 0

    if draw then
        windowSizeY = self:drawToolTip(false,screenX,screenY,sizeMultiplyer,maxX,attributes,amount,entity)
        if screenY > szy - windowSizeY then screenY = szy - windowSizeY end
        love.graphics.setColor(0,0,0,0.8)
        love.graphics.rectangle("fill",screenX,screenY,windowSizeX,windowSizeY,5,5)
        love.graphics.setColor(0.8,0.8,0.8,1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line",screenX,screenY,windowSizeX,windowSizeY,5,5)
    end

    if self.sprite ~= nil and self.itemName ~= "none" then
        local displaySize = nil
        local itemSizeMultiplyer = 1
        if self.sprite:doesAnimationExist("small") then displaySize = "small" itemSizeMultiplyer = 0.25 end
        if self.sprite:doesAnimationExist("medium") then displaySize = "medium" itemSizeMultiplyer = 0.5 end
        if self.sprite:doesAnimationExist("large") then displaySize = "large" itemSizeMultiplyer = 1 end

        badgeSize = sizeMultiplyer * itemSizeMultiplyer
            
        if draw then
            love.graphics.setColor(0.1,0.1,0.15,0.8)
            love.graphics.rectangle("fill",screenX + padding - 2,screenY + padding - 2,badgeSize + 4,badgeSize + 4,5,5)
            love.graphics.setColor(0.8,0.8,0.8,1)
            love.graphics.rectangle("line",screenX + padding - 2,screenY + padding - 2,badgeSize + 4,badgeSize + 4,5,5)

            self:draw(displaySize,round(screenX + padding),round(screenY + padding),badgeSize,attributes,amount,true,true)
        end
        if badgeSize > 0 then textXOffset = textXOffset + padding end
    end

    local y = 0

    y = y + self:printInfo(draw,{"#title",self.fullName},screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"title",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
    if self.description ~= nil and convertTableIntoText(self.description) ~= "" then
        y = y + self:printInfo(draw,self.description,screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"base",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
    end
    
    if self.placeBlock ~= nil and self.placeBlock ~= "none" then
        if self.placeBlock ~= self.itemName then
            if self.placeBlockCost > 1 then
                y = y + self:printInfo(draw,{"#muted","Use ","#alert",self.placeBlockCost,"#muted"," to place: ","#success",self.placeBlock},screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"base",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
            else
                y = y + self:printInfo(draw,{"#muted","Can be used to place: ","#success",self.placeBlock},screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"base",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
            end
            -- y = y + self:printInfo(draw,{"#muted","Can be used to place: ","#success",self.placeBlock},screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"base",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
        end    
        if self.blockPlaceLayer == "tiles" then
            y = y + self:printInfo(draw,{"#muted","Can be ","#info","Placed","#muted"," on an empty space"},screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"base",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
        end
        if self.blockPlaceLayer == "back" or self.blockPlaceLayer == "backTiles" then
            y = y + self:printInfo(draw,{"#muted","Is a placeable ","#info","Wall"},screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"base",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
        end
        if self.blockPlaceLayer == "top" or self.blockPlaceLayer == "topTiles" then
            y = y + self:printInfo(draw,{"#muted","Can be placed on ","#info","Top ","#muted","of other tiles"},screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"base",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
        end
    end

    if self.mineDamage > 0 then
        y = y + self:getLineReturnHeight(sizeMultiplyer) * 0.5
        y = y + self:printInfo(draw,{"#muted","Calculated block damage per second: ","#success",(self:getBlockDamagePerSecond(attributes,entity))},screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"base",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
        y = y + self:getLineReturnHeight(sizeMultiplyer) * 0.5
        y = y + self:printInfo(draw,{"#muted","Mine damage: ","#info",self:getMineDamage(attributes,entity)},screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"base",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
        y = y + self:printInfo(draw,{"#muted","Blocks mined: ","#info",self:getBlockDamageAmount(attributes,entity)},screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"base",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
        y = y + self:printInfo(draw,{"#muted","Mine cooldown: ","#info",self:getCooldown(attributes,entity)},screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"base",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
        y = y + self:getLineReturnHeight(sizeMultiplyer) *0.5
        y = y + self:printInfo(draw,{"#muted","Mine range: ","#info",self:getRange(attributes,entity)},screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"base",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
    end

    if self.damage > 0 then
        if self.subCategory == "melee" then
            y = y + self:getLineReturnHeight(sizeMultiplyer) * 0.5
            y = y + self:printInfo(draw,{"#silent","Melee weapon"},screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"base",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
            y = y + self:printInfo(draw,{"#muted","Calculated DPS : ","#success",(self:getDPS(attributes,entity))},screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"base",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
            y = y + self:getLineReturnHeight(sizeMultiplyer) * 0.5
            y = y + self:printInfo(draw,{"#muted","attack damage: ","#info",self:getBaseDamage(attributes,entity)},screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"base",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
            y = y + self:printInfo(draw,{"#muted","cooldown: ","#info",self:getCooldown(attributes,entity)},screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"base",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
            y = y + self:printInfo(draw,{"#muted","charge time: ","#info",self:getCharge(attributes,entity)},screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"base",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
            if self.moveSpeedDuringCharge ~= 1 then
                y = y + self:printInfo(draw,{"#silent","When charging, reduce speed to : ","#info",round(self.moveSpeedDuringCharge*100),"#muted","%"},screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"base",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
            end
            y = y + self:getLineReturnHeight(sizeMultiplyer) * 0.5
            y = y + self:printInfo(draw,{"#muted","reach: ","#info",self:getAttackRange(attributes,entity)},screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"base",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
            y = y + self:printInfo(draw,{"#muted","radius: ","#info",self:getAttackRadius(attributes,entity)},screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"base",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
            y = y + self:printInfo(draw,{"#muted","knockback: ","#info",self:getKnockback(attributes,entity)},screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"base",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
        end
    end

    if self:getDashVelocity(attributes,entity) > 0 then
        y = y + self:getLineReturnHeight(sizeMultiplyer) * 0.5
        local velo = self:getDashVelocity(attributes,entity)
        local time = self:getDashTime(attributes,entity)
        y = y + self:printInfo(draw,{"#muted","use this item to dash forward at a speed of ","#alert",velo.." blocs per second",
            "#muted"," for ","#alert",time,"#muted"," seconds"
        },screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"base",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
        y = y + self:printInfo(draw,{"#muted","(total distance traveled : ","#info",round(velo * time,100),"#muted"," blocks)"},screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"base",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
        if self:getDashGravityMultiplier(attributes,entity) ~= 1 then
            y = y + self:printInfo(draw,{"#silent","When used, reduce gravity to : ","#info",round(self:getDashGravityMultiplier(attributes,entity)*100),"#muted","%"},screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"base",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
        end
    end

    if windowSizeY < badgeSize + padding * 2 then windowSizeY = badgeSize + padding * 2 end
    if windowSizeY < y + padding * 2 then windowSizeY = y + padding * 2 end

    return windowSizeY
end

function Item:getLineReturnHeight(sizeMultiplyer)
    return self:printInfo(false,{"123"},0,0,"base",sizeMultiplyer,100)
end

local function normalizeRichText(textTable)
    if type(textTable) ~= "table" then
        return textTable
    end

    local normalized = {}
    for i = 1, #textTable do
        local value = textTable[i]
        if value == nil then value = "" end

        if value == "#title" then value = {1,1,1,1} end
        if value == "#danger" then value = {1,0.6,0.6,1} end
        if value == "#success" then value = {0.6,1,0.6,1} end
        if value == "#info" then value = {0.6,0.6,1,1} end
        if value == "#alert" then value = {1,1,0.6,1} end
        if value == "#base" then value = {0.8,0.8,0.8,1} end
        if value == "#muted" then value = {0.6,0.6,0.6,1} end
        if value == "#silent" then value = {0.4,0.4,0.4,1} end

        if value == "#red" then value = {1,0.6,0.6,1} end
        if value == "#red!" then value = {1,0,0,1} end
        if value == "#green" then value = {0.6,1,0.6,1} end
        if value == "#green!" then value = {0,1,0,1} end
        if value == "#blue" then value = {0.6,0.6,1,1} end
        if value == "#blue!" then value = {0,0,1,1} end
        if value == "#yellow" then value = {1,1,0.6,1} end
        if value == "#yellow!" then value = {1,1,0,1} end
        if value == "#cyan" then value = {0.6,1,1,1} end
        if value == "#cyan!" then value = {0,1,1,1} end
        if value == "#magenta" then value = {1,0.6,1,1} end
        if value == "#magenta!" then value = {1,0,1,1} end
        if value == "#purple" then value = {0.8,0.6,1,1} end
        if value == "#purple!" then value = {0.5,0,0.5,1} end
        if value == "#orange" then value = {1,0.8,0.6,1} end
        if value == "#orange!" then value = {1,0.5,0,1} end

        normalized[#normalized + 1] = value
    end

    return normalized
end

function Item:printInfo(draw,textTable,x,y,size,sizeMultiplyer,maxX)
    if type(size) ~= "number" then 
        if type(size) == "string" then
            if size == "title" then size = 0.022 end
            if size == "base" then size = 0.015 end
        else
            size = 0.015
        end
    end

    local normalizedText = normalizeRichText(textTable)

    if draw then
        love.graphics.setColor(0.8,0.8,0.8,1)
        love.graphics.printf(normalizedText,x,y,maxX/(size * sizeMultiplyer),"left",0,size * sizeMultiplyer, size * sizeMultiplyer)
    end
    local textWidth, textHeight = GetTextSize(normalizedText,maxX/(size * sizeMultiplyer),size * sizeMultiplyer)

    return textHeight
end

function GetTextSize(text, xLimit, size)
    local font = Font
    local scale = 1
    if type(size) == "number" and size > 0 then
        scale = size
    end

    -- Convert colored text tables into a plain string.
    local plainText
    if type(text) == "table" then
        local parts = {}

        for _, v in ipairs(text) do
            if type(v) == "string" then
                parts[#parts + 1] = v
            elseif type(v) == "number" or type(v) == "boolean" then
                parts[#parts + 1] = tostring(v)
            end
        end

        plainText = table.concat(parts)
    else
        plainText = tostring(text)
    end

    plainText = plainText:gsub("\r\n", "\n")
    plainText = plainText:gsub("\n+$", "")

    if plainText:match("^%s*$") then
        return 0, 0
    end

    -- No wrapping.
    if not xLimit then
        local lines = select(2, plainText:gsub("\n", "")) + 1
        local maxWidth = 0
        for line in (plainText .. "\n"):gmatch("(.-)\n") do
            local lineWidth = font:getWidth(line)
            if lineWidth > maxWidth then
                maxWidth = lineWidth
            end
        end
        return maxWidth * scale, lines * font:getHeight() * scale
    end

    -- Same wrapping as love.graphics.printf().
    local width, wrapped = font:getWrap(plainText, xLimit)
    local height = #wrapped * font:getHeight() * scale

    return width * scale, height
end


function Item:drawHolding(entity,spriteX,spriteY,size,attributes,quantity)
    if self.holdAnimation ~= nil then
        
        self.holdAnimation:draw(entity.animation,entity.animationTime,entity.animationDirection,spriteX,spriteY,size,size,self.baseColor,self.baseColorisation)

    end
end

function Item:draw(state,posX,posY,size,attributes, amount,centerX,centerY,ignorePositionRounding,ignoreSizeRounding)
    if centerX == nil then centerX = false end
    if centerY == nil then centerY = false end
    if ignorePositionRounding == nil then ignorePositionRounding = false end
    if ignoreSizeRounding == nil then ignoreSizeRounding = false end
    if self.itemName ~= "none" then

        if state == "large" and (not self.sprite:doesAnimationExist("large")) then state = "medium" end
        if state == "small" and (not self.sprite:doesAnimationExist("small")) then state = "medium" end
        if state == "medium" and (not self.sprite:doesAnimationExist("medium")) then state = "small" end

        local drawSize = size/8
        if state == "small" then drawSize = size / 8 end
        if state == "medium" then drawSize = size / 16 end
        if state == "large" then drawSize = size / 32 end
        if centerX then posX = posX + size/2 end
        if centerY then posY = posY + size/2 end

        if not ignorePositionRounding then
            posX = round(posX)
            posY = round(posY)
        end

        if not ignoreSizeRounding then
            drawSize = round(drawSize)
        end
        self.sprite:draw(state,0,"right",posX,posY,drawSize,drawSize,self.baseColor,self.baseColorisation)
    end
end