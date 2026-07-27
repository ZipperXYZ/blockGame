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

    if checkifinlist(self.category, {"tool"}) then
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

    self.groundSize = self.flags.groundSize or 0.45
    self.rangeLimit = self.flags.rangeLimit or 8

    self.cooldown = 0.2
    if self.subCategory == "wall" then self.cooldown = 0.05 end
    if self.flags.cooldown ~= nil then self.cooldown = self.flags.cooldown end
    self.desiredInventorySpots = self.flags.desiredInventorySpots or {"none"}
    if self.placeBlock ~= "none" then self.desiredInventorySpots = {"space","x","c"} end
    if self.category == "tool" then self.desiredInventorySpots = {"space"} end

    --self.canBeUsed = self.flags.canBeUsed or (self.placeBlock~="none")

    self.baseColor = self.flags.baseColor or {1,1,1,1}
    
    --self.textures = textures or {["groundDisplay"]="none",[""]}

    table.insert(ItemList,itemName)
end

function Item:getBlockDamagePerSecond(attributes,entity)
    return round((self:getBlockDamageAmount(attributes,entity)* self:getMineDamage(attributes,entity)) / self:getCooldown(attributes,entity),100)
end

function Item:getMineDamage(attributes,entity)
    return round(self.mineDamage,100)
end

function Item:getBlockDamageAmount(attributes,entity)
    return round(self.blockDamageAmount)
end

function Item:getCooldown(attributes,entity)
    return round(self.cooldown,100)
end

function Item:getRange(attributes,entity)
    return round(self.rangeLimit,10)
end

function Item:getPickaxeTargets(entity,attributes,cursorX,cursorY)

    local targetList = {}



    local place = nil
    if not self.minePierce then
        place = world:rayTrace({"tiles"},entity.position:copy(true),Vector2(round(cursorX),round(cursorY)),self.rangeLimit,false,true)
    else
        place = Vector2(round(cursorX),round(cursorY))
        if place:dist(entity.position:copy()) > self.rangeLimit then
            place = entity.position:copy()
            place:moveTowards(Vector2(round(cursorX),round(cursorY)),self.rangeLimit)
        end

        local bloc = place:copy()
        if bloc:dist(entity.position:copy()) <= self.rangeLimit then
            if world:getTile(bloc.x,bloc.y,"tiles").canBeMined and world:getTile(bloc.x,bloc.y,"tiles").name ~= "none" then
                if not checkIfVectorInList(Vector2(bloc.x,bloc.y),targetList,true) then
                    table.insert(targetList,Vector2(bloc.x,bloc.y))
                end
            end
        end
    end

    local baseDirection = entity.position:getDirection360Towards(Vector2(round(cursorX),round(cursorY)))

    for advance = 0, math.ceil(self.rangeLimit*2) do
        for forwardDistance = 0, math.ceil(self.mineWidth*4) do
            for side = -1,1,2 do
                local forwardValue = (advance/2)

                if #targetList < self.blockDamageAmount then

                    local bloc = entity.position:copy()
                    bloc:move(baseDirection,forwardValue )
                    bloc:move(baseDirection + 90 * side,forwardDistance * 0.25/4 )
                    bloc.x = round(bloc.x)
                    bloc.y = round(bloc.y)
                    --local angle

                    if bloc:dist(entity.position:copy()) <= self.rangeLimit then
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
    

    --[[if world:getTile(place.x,place.y,"tiles").canBeMined and world:getTile(place.x,place.y,"tiles").name ~= "none" then
        table.insert(targetList,Vector2(round(place.x),round(place.y)))

        local baseDirection = entity.position:getDirection360Towards(Vector2(round(cursorX),round(cursorY)))
        
        for advance = 1, (self.rangeLimit*2)*math.ceil(math.sqrt(self.blockDamageAmount)+3) do
            for angle = 0, 1 + math.ceil(self.mineArcAngle / 40) do
                for side = -1,1,2 do
                    local angleValue = (self.mineArcAngle/2)/(1 + math.ceil(self.mineArcAngle / 40))*angle
                    local forwardValue = (1/(self.mineArcAngle*angleValue))

                    if #targetList < self.blockDamageAmount then
                        local bloc = place:copy()
                        bloc:move(baseDirection + angleValue * side, (advance/2)*self.mineForwardWeight*(k(1,self.mineForwardWeight,forwardValue)))
                        bloc.x = round(bloc.x)
                        bloc.y = round(bloc.y)
                        
                        if bloc:dist(entity.position:copy()) <= self.rangeLimit then
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

    end]]

    return targetList
    
end

function Item:use(entity,attributes,cursorX,cursorY,slot,stacks)
    local stacksRemove = 0
    local setCooldown = self.cooldown
    local useSuccess = false

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


    if checkifinlist(slot,self.desiredInventorySpots) and self.mineDamage > 0 then

        local destroyedAtLeastATile = false

        local targets = self:getPickaxeTargets(entity,attributes,cursorX,cursorY)
        if #targets > 0 then
            for targ= 1,#targets do
                if world:damageBlock(targets[targ].x, targets[targ].y, self.mineDamage,"tiles",true) then
                    destroyedAtLeastATile = true
                end
            end
        end

        if destroyedAtLeastATile then
            world:updateLights(cursorX,cursorY)
        end

        useSuccess = true

    end



    

    if useSuccess then

        entity:setAnimation("use",1/setCooldown)
        
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
        y = y + self:getLineReturnHeight(sizeMultiplyer) * 0.5
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
        y = y + self:printInfo(draw,{"#muted","Calculated block damage per second: ","#success",(self:getBlockDamagePerSecond(attributes,entity))},screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"base",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
        y = y + self:getLineReturnHeight(sizeMultiplyer) * 0.5
        y = y + self:printInfo(draw,{"#muted","Mine damage: ","#info",self:getMineDamage(attributes,entity)},screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"base",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
        y = y + self:printInfo(draw,{"#muted","Blocks mined: ","#info",self:getBlockDamageAmount(attributes,entity)},screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"base",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
        y = y + self:printInfo(draw,{"#muted","Mine cooldown: ","#info",self:getCooldown(attributes,entity)},screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"base",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
        y = y + self:getLineReturnHeight(sizeMultiplyer) *0.5
        y = y + self:printInfo(draw,{"#muted","Mine range: ","#info",self:getRange(attributes,entity)},screenX + badgeSize + textXOffset + padding * 2,screenY + padding + y,"base",sizeMultiplyer,windowSizeX - badgeSize - textXOffset - padding * 3)
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
        
        self.holdAnimation:draw(entity.animation,entity.animationTime,entity.animationDirection,spriteX,spriteY,size,size,self.baseColor)

    end
end

function Item:draw(state,posX,posY,size,attributes, amount,centerX,centerY)
    if centerX == nil then centerX = false end
    if centerY == nil then centerY = false end
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

        self.sprite:draw(state,0,"right",round(posX),round(posY),round(drawSize),round(drawSize),self.baseColor)
    end
end