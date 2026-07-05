require "class/superClass"
Item = SuperClass:extend()
Item.className = "Item"


function Item:init(itemName,sprite,flags)
    self.itemName = itemName
    self.flags = flags or {}
    self.sprite = textures["sprites"][sprite] or "none"
    self.spriteName = sprite or "none"


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

function Item:getPickaxeTargets(entity,attributes,cursorX,cursorY)

    local targetList = {}

    local place = world:rayTrace({"tiles"},entity.position:copy(true),Vector2(round(cursorX),round(cursorY)),self.rangeLimit,false,true)

    if world:getTile(place.x,place.y,"tiles").canBeMined and world:getTile(place.x,place.y,"tiles").name ~= "none" then
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

    end

    return targetList
    
end

function Item:use(entity,attributes,cursorX,cursorY,slot,stacks)
    local stacksRemove = 0
    local setCooldown = self.cooldown
    local useSuccess = false

    if checkifinlist(slot,self.desiredInventorySpots)then

        if self.placeBlock ~= "none" then

            local place = world:rayTrace({self.blockPlaceLayer},entity.position:copy(),Vector2(round(cursorX),round(cursorY)),self.rangeLimit,true)

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


    if checkifinlist(slot,self.desiredInventorySpots) and self.category == "tool" then

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




function Item:drawHolding(entity,spriteX,spriteY,size,attributes,quantity)
    if self.holdAnimation ~= nil then
        
        self.holdAnimation:draw(entity.animation,entity.animationTime,entity.animationDirection,spriteX,spriteY,size,size,self.baseColor)

    end
end

function Item:draw(state,posX,posY,size,attributes)
    if self.itemName ~= "none" then

        if state == "large" and (not self.sprite:doesAnimationExist("large")) then state = "medium" end
        if state == "small" and (not self.sprite:doesAnimationExist("small")) then state = "medium" end
        if state == "medium" and (not self.sprite:doesAnimationExist("medium")) then state = "small" end

        local drawSize = size/8
        if state == "small" then drawSize = size / 8 end
        if state == "medium" then drawSize = size / 16 end
        if state == "large" then drawSize = size / 32 end
        self.sprite:draw(state,0,"right",posX,posY,drawSize,drawSize,self.baseColor)
    end
end