require "class/superClass"
Item = SuperClass:extend()
Item.className = "Item"


function Item:init(itemName,sprite,flags)
    self.itemName = itemName
    self.flags = flags or {}
    self.sprite = textures["sprites"][sprite] or "none"
    self.spriteName = sprite or "none"


    self.placeBlock = self.flags.placeBlock or "none"
    self.blockPlaceLayer = self.flags.blockPlaceLayer or "tiles"

    self.fullName = self.flags.fullName or (self.itemName)
    self.category = self.flags.category or "none"
    self.subCategory = self.flags.subCategory or "none"


    self.unique = self.flags.unique or false

    if checkifinlist(self.category, {"tool"}) then
        self.unique = true
    end


    self.stackable = self.flags.stackable or true
    self.maxStack = self.flags.maxStack or 99
    if self.unique then self.stackable = false self.maxStack = 1 end
    
    self.mineDamage = self.flags.mineDamage or 0
    self.blockDamageAmount = self.flags.blockDamageAmount or 0
    self.damage = self.flags.damage or 0

    self.groundSize = self.flags.groundSize or 0.45
    self.rangeLimit = self.flags.rangeLimit or 8

    self.cooldown = self.flags.cooldown or 0.25
    self.desiredInventorySpots = self.flags.desiredInventorySpots or {"none"}
    if self.placeBlock ~= "none" then self.desiredInventorySpots = {"space","x","c"} end
    if self.category == "tool" then self.desiredInventorySpots = {"space"} end

    --self.canBeUsed = self.flags.canBeUsed or (self.placeBlock~="none")

    self.baseColor = self.flags.baseColor or {1,1,1,1}
    
    --self.textures = textures or {["groundDisplay"]="none",[""]}

    table.insert(ItemList,itemName)
end

function Item:use(entity,attributes,cursorX,cursorY,slot)
    local removeStacks = 0
    local setCooldown = self.cooldown
    local useSuccess = false

    if slot == "space" or slot == "x" or slot == "c" then

        if self.placeBlock ~= "none" then

            local place = world:rayTrace({self.blockPlaceLayer},entity.position:copy(),Vector2(cursorX,cursorY),self.rangeLimit,true)

            if place:dist(entity.position)>1 or self.blockPlaceLayer ~= "tiles" then
                if world:placeTile(self.placeBlock, round(place.x), round(place.y), self.blockPlaceLayer, false) then
                    removeStacks = removeStacks + 1
                    useSuccess = true
                end
            end

        end

    end

    if slot == "space" and self.category == "tool" then

        useSuccess = true

    end




    return useSuccess, setCooldown, removeStacks
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