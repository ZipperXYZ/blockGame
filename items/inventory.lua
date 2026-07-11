require "class/superClass"
Inventory = SuperClass:extend()
Inventory.className = "Inventory"


function Inventory:init(inventoryName,color,screenPos,sizeX,sizeY,sizeZ,maxStack,tileSize,itemSize,flags)
    self.inventoryName = inventoryName or ""
    self.id = math.random()
    self.color = color or {0.65,0.65,0.65,1}
    self.maxStack = maxStack or 100
    self.sizeX = sizeX or 5
    self.tileSize = tileSize or (0.065)
    self.itemSize = itemSize or (0.065/8)
    self.sizeY = sizeY or 5
    self.sizeZ = sizeZ or 1
    self.currentPage = 1
    self.screenPos = screenPos or Vector2(0.5,0.5)
    self.flags = flags or {}
    self.items = {}
    for page=1,self.sizeZ do
        self.items[page]={}
        for ix=1,self.sizeX do
            self.items[page][ix]={}
            for iy=1,self.sizeY do
                self.items[page][ix][iy]={}
                self.items[page][ix][iy]["amount"]=0
                self.items[page][ix][iy]["name"]="none"
                self.items[page][ix][iy]["attributes"]={}
                self.items[page][ix][iy]["slotAttributes"]={}
            end
        end
    end

    self.anchorX = self.flags["anchorX"] or "middle"
    self.anchorY = self.flags["anchorY"] or "top"
    self.isEquipmentInventory = self.flags["isEquipmentInventory"] or false
    self.isMainInventory = self.flags["isMainInventory"] or false
    self.cheat = self.flags["cheat"] or false

    if self.isEquipmentInventory then
        self:setUpEquipmentInventory()
    else
        --self.items[1][1][1] = {["amount"]=10,["name"]="stick",["attributes"]={},["slotAttributes"]={}}
    end

    if self.isMainInventory then
        self:setupIcons()
        self:setupMainInventory()
    end
end

function Inventory:setupIcons()
    self:setIcon("space",1,1)
    self:setIcon("leftClick",2,1)
    self:setIcon("rightClick",3,1)
    self:setIcon("shift",4,1)
    self:setIcon("r",5,1)
    self:setIcon("x",6,1)
    self:setIcon("c",7,1)

    self:setSlotAttribute("button","space",1,1)
    self:setSlotAttribute("button","leftClick",2,1)
    self:setSlotAttribute("button","rightClick",3,1)
    self:setSlotAttribute("button","shift",4,1)
    self:setSlotAttribute("button","r",5,1)
    self:setSlotAttribute("button","x",6,1)
    self:setSlotAttribute("button","c",7,1)

    self:setSlotAttribute("topIcon","space2",1,1)
    self:setSlotAttribute("topIcon","leftClick2",2,1)
    self:setSlotAttribute("topIcon","rightClick2",3,1)
    self:setSlotAttribute("topIcon","shift2",4,1)
    self:setSlotAttribute("topIcon","r2",5,1)
    self:setSlotAttribute("topIcon","x2",6,1)
    self:setSlotAttribute("topIcon","c2",7,1)

    self:setSlotAttribute("disableItemPickup",true,1,1)
    self:setSlotAttribute("disableItemPickup",true,2,1)
    self:setSlotAttribute("disableItemPickup",true,3,1)
    self:setSlotAttribute("disableItemPickup",true,4,1)
    self:setSlotAttribute("disableItemPickup",true,5,1)
    self:setSlotAttribute("disableItemPickup",true,6,1)
    self:setSlotAttribute("disableItemPickup",true,7,1)
    --self:setItem("crudePickaxe",999,{},1,1,1)
end

function Inventory:setupMainInventory()


    self:setItem("crudePickaxe",1,{},1,1)
    --self:setItemName("crudePickaxe",1,1)
    --self:setItemAmount(1,1,1)
    ---self.items[1][1][1]["amount"] = 1
    --self.items[1][1][1]["name"] = "crudePickaxe"
    --self:addItem("crudePickaxe",1,{})

end

function Inventory:setIcon(icon,ix,iy,page)
    if page == nil then page = self.currentPage end
    if ix <= self.sizeX and ix >= 1 and iy >= 1 and iy <= self.sizeY then
        self.items[page][ix][iy]["slotAttributes"]["icon"] = icon
    end
end

function Inventory:setUpEquipmentInventory()
    self.sizeX = 3
    if self.sizeY < 3 then self.sizeY = 3 end
    for page=1,self.sizeZ do
        self.items[page]={}
        for ix=1,self.sizeX do
            self.items[page][ix]={}
            for iy=1,self.sizeY do
                self.items[page][ix][iy]={}
                self.items[page][ix][iy]["amount"]=0
                self.items[page][ix][iy]["name"]="none"
                self.items[page][ix][iy]["attributes"]={}
                self.items[page][ix][iy]["slotAttributes"]={
                    ["lock"] = "accessory",
                    ["icon"] = "accessory"
                }
            end
        end
        self.items[page][1][1]["slotAttributes"] = {["lock"] = "necklace", ["icon"] = "necklace"}
        self.items[page][1][2]["slotAttributes"] = {["lock"] = "armlet", ["icon"] = "armlet"}
        self.items[page][1][3]["slotAttributes"] = {["lock"] = "armlet", ["icon"] = "armlet"}

        self.items[page][2][2]["slotAttributes"] = {["disabled"] = true}
        self.items[page][2][3]["slotAttributes"] = {["disabled"] = true, ["showCharacter"] = true}
        self.items[page][2][1]["slotAttributes"] = {["lock"] = "charm", ["icon"] = "charm"}

        self.items[page][3][1]["slotAttributes"] = {["lock"] = "headplate",["icon"] = "headplate"}
        self.items[page][3][2]["slotAttributes"] = {["lock"] = "chestplate",["icon"] = "chestplate"}
        self.items[page][3][3]["slotAttributes"] = {["lock"] = "leggings",["icon"] = "leggings"}
    end
    

    
end

function Inventory:slotUpdate(dt,entity,ix,iy,page)
    if page == nil then page = self.currentPage end
    if ix <= self.sizeX and ix >= 1 and iy >= 1 and iy <= self.sizeY then

        if not self:doesSlotAttributeExists("disabled",ix,iy,page) then
            self:setSlotAttribute("disabled",false,ix,iy,page)
        end
        if not self:doesSlotAttributeExists("disableItemPickup",ix,iy,page) then
            self:setSlotAttribute("disableItemPickup",false,ix,iy,page)
        end


        if self:getSlotAttribute("useAnimation",ix,iy,page) >= 0 then
            self:setSlotAttribute("useAnimation",self:getSlotAttribute("useAnimation",ix,iy,page) - dt,ix,iy,page)
        else
            self:setSlotAttribute("useAnimation",0,ix,iy,page)
            self:setSlotAttribute("useAnimationMax",1,ix,iy,page)
        end


        if self:doesSlotAttributeExists("cooldown",ix,iy,page) then
            self:setSlotAttribute("cooldown",self:getSlotAttribute("cooldown",ix,iy,page) - dt,ix,iy,page)
        else
            self:setSlotAttribute("cooldown",0,ix,iy,page)
            self:setSlotAttribute("cooldownMax",0,ix,iy,page)
        end


        if (not self:getSlotAttribute("disabled",ix,iy,page)) or (self:getSlotAttribute("disabled",ix,iy,page) == 0) then

            local button = self:getSlotAttribute("button",ix,iy,page)..""

            if button ~= "0" then
                local itemName, itemAmount, itemAttributes = self:getItem(ix,iy,page)
                
                if items[itemName] ~= nil and itemName ~= "none" and entity.controls[button] and self:getSlotAttribute("cooldown",ix,iy,page) <= 0 then
                    local item = items[itemName]
                    local useSuccess, setCooldown, stacksRemove = item:use(entity,itemAttributes,entity:getAim().x,entity:getAim().y,button,itemAmount)
                    if useSuccess then

                        self:setSlotAttribute("cooldown",setCooldown,ix,iy,page)
                        self:setSlotAttribute("cooldownMax",setCooldown,ix,iy,page)

                        self:setItem(nil,itemAmount-stacksRemove,nil,ix,iy,page)

                        self:setSlotAttribute("useAnimation",minimum(maximum(setCooldown,1),0.25),ix,iy,page)
                        self:setSlotAttribute("useAnimationMax",minimum(maximum(setCooldown,1),0.25),ix,iy,page)

                    end
                end
            end

            local itemName, itemAmount, itemAttributes = self:getItem(ix,iy,page)

            if itemAmount <= 0 then
                self:setItem("none",0,{},ix,iy,page)
            end

        end

    end
end

function Inventory:updateCheat()
    --CheatInventoryScroll
    if love.keyboard.isDown("left") then CheatInventoryScroll = CheatInventoryScroll - 1 end
    if love.keyboard.isDown("right") then CheatInventoryScroll = CheatInventoryScroll + 1 end

    for ix = 1, self.sizeX do
        for iy = 1, self.sizeY do
            local itemName = ItemList[(((ix+(iy-1)*self.sizeX)+CheatInventoryScroll-1) % #ItemList) + 1]

            self:setItem(itemName,items[itemName].maxStack,{},ix,iy)
        end
    end
end

function Inventory:getTileSize()
    return self.tileSize * InventorySize
end

function Inventory:getItemSize()
    return self.itemSize * InventorySize
end

function Inventory:draw(mode,entity,flags)
    if self.cheat then self:updateCheat() end
    if mode == nil then mode = "complete" end
    if flags == nil then flags = {} end
    if flags["hightlights"] == nil then flags["hightlights"] = {} end
    --if #flags.hightlights > 1 then print(flags.hightlights[1]) end
    local page = self.currentPage


    local actualScreenPosX,actualScreenPosY, actualTileSize, actualSizeY
    if szx > szy then
        actualTileSize = szy * self:getTileSize()
    else
        actualTileSize = szx * self:getTileSize()
    end
    if mode == "firstLine" then
        actualSizeY = 1
    else
        actualSizeY = self.sizeY
    end


    actualScreenPosX = szx * self.screenPos.x
    if self.anchorX == "middle" then
        actualScreenPosX = actualScreenPosX - ((self.sizeX * actualTileSize * 1.1) + actualTileSize * 0.1)/2
    end
    if self.anchorX == "right" then
        actualScreenPosX = actualScreenPosX - ((self.sizeX * actualTileSize * 1.1) + actualTileSize * 0.1)
    end

    actualScreenPosY = szy * self.screenPos.y
    if self.anchorY == "middle" then
        actualScreenPosY = actualScreenPosY - ((actualSizeY * actualTileSize * 1.1) + actualTileSize * 0.1)/2
    end
    if self.anchorY == "bottom" then
        actualScreenPosY = actualScreenPosY - ((actualSizeY * actualTileSize * 1.1) + actualTileSize * 0.1)
    end


    love.graphics.setColor(self.color[1]*0.75,self.color[2]*0.75,self.color[3]*0.75,self.color[4]*0.75)
    love.graphics.rectangle("fill"
        ,actualScreenPosX,actualScreenPosY
        ,((self.sizeX * actualTileSize * 1.1) + actualTileSize * 0.1)
        ,((actualSizeY * actualTileSize * 1.1) + actualTileSize * 0.1)
        ,actualTileSize * 0.1
        ,actualTileSize * 0.1
    )

    --draw slots
    for ix=1, self.sizeX do
        for iy=1, actualSizeY do

            if (not self:getSlotAttribute("disabled",ix,iy,page)) or (self:getSlotAttribute("disabled",ix,iy,page) == 0) then

                --draw base slots + lighter for mouse hover
                love.graphics.setColor(self.color[1],self.color[2],self.color[3],self.color[4])
                if mx > (actualScreenPosX + actualTileSize * 0.1) + (ix-1)*(actualTileSize*1.1)
                    and mx < (actualScreenPosX + actualTileSize * 0.1) + (ix-1)*(actualTileSize*1.1) + actualTileSize
                    and my > (actualScreenPosY + actualTileSize * 0.1) + (iy-1)*(actualTileSize*1.1)
                    and my < (actualScreenPosY + actualTileSize * 0.1) + (iy-1)*(actualTileSize*1.1) + actualTileSize
                then
                    love.graphics.setColor(k(self.color[1],1,0.5),k(self.color[2],1,0.5),k(self.color[3],1,0.5),self.color[4])
                end
                love.graphics.rectangle("fill"
                    ,(actualScreenPosX + actualTileSize * 0.1) + (ix-1)*(actualTileSize*1.1)
                    ,(actualScreenPosY + actualTileSize * 0.1) + (iy-1)*(actualTileSize*1.1)
                    ,(actualTileSize)
                    ,(actualTileSize)
                    ,actualTileSize * 0.1
                    ,actualTileSize * 0.1
                )
                
                
                local itemName, itemAmount, itemAttributes = self:getItem(ix,iy)

                --draw cooldown
                if self:getSlotAttribute("cooldown",ix,iy)>0 then

                    local cooldownRatio = self:getSlotAttribute("cooldown",ix,iy)/self:getSlotAttribute("cooldownMax",ix,iy)

                    love.graphics.setColor(0,0,0,0.5)

                    love.graphics.rectangle("fill"
                        ,(actualScreenPosX + actualTileSize * 0.1) + (ix-1)*(actualTileSize*1.1)
                        ,(actualScreenPosY + (actualTileSize * 0.1) + actualTileSize*(1-cooldownRatio)) + (iy-1)*(actualTileSize*1.1)
                        ,(actualTileSize)
                        ,(actualTileSize*cooldownRatio)
                        ,actualTileSize * 0.1
                        ,actualTileSize * 0.1
                    )
                end

                --light up for button press
                if self:getSlotAttribute("button",ix,iy).."" ~= "0" then
                    if entity.controls[self:getSlotAttribute("button",ix,iy)] then
                        love.graphics.setColor(1,1,1,0.5)
                        love.graphics.setLineWidth(3)
                        love.graphics.rectangle("line"
                            ,(actualScreenPosX + actualTileSize * 0.1) + (ix-1)*(actualTileSize*1.1)
                            ,(actualScreenPosY + actualTileSize * 0.1) + (iy-1)*(actualTileSize*1.1)
                            ,(actualTileSize)
                            ,(actualTileSize)
                            ,actualTileSize * 0.1
                            ,actualTileSize * 0.1
                        )
                    end
                end

                love.graphics.setColor(1,1,1,0.5)
                local x,y,size = self:getTilePosAndSize(ix,iy)

                --draw slot icon
                if self:getSlotAttribute("icon",ix,iy).."" ~= "0" then
                    
                    if itemName == "none" then
                        textures["sprites"]["inventoryIcons"]:draw(self:getSlotAttribute("icon",ix,iy),0,"right",
                        x + size/2,
                        y + size/2,
                        size/16 * 0.85,
                        size/16 * 0.85,
                        {1,1,1,0.5})
                    end

                    --draw highligts
                    if checkifinlist(self:getSlotAttribute("icon",ix,iy),flags.hightlights) then
                        love.graphics.setColor(1,1,0,0.1+gettimeloop(1,0.3,true))
                        love.graphics.rectangle("fill"
                            ,(actualScreenPosX + actualTileSize * 0.1) + (ix-1)*(actualTileSize*1.1)
                            ,(actualScreenPosY + actualTileSize * 0.1) + (iy-1)*(actualTileSize*1.1)
                            ,(actualTileSize)
                            ,(actualTileSize)
                            ,actualTileSize * 0.1
                            ,actualTileSize * 0.1
                        )
                    end

                end
            end
        end
    end

    --draw items
    for ix=1, self.sizeX do
        for iy=1, actualSizeY do

            if (not self:getSlotAttribute("disabled",ix,iy,page)) or (self:getSlotAttribute("disabled",ix,iy,page) == 0) then
                    
                love.graphics.setColor(1,1,1,1)

                -- change size
                local sizeMultiplyer = 0.85

                if self:getSlotAttribute("useAnimation",ix,iy) >= 0 then
                    sizeMultiplyer = sizeMultiplyer * (1 + 0.25 * self:getSlotAttribute("useAnimation",ix,iy) / self:getSlotAttribute("useAnimationMax",ix,iy))
                end

                --draw item
                self:drawItem(page,ix,iy,
                (actualScreenPosX + actualTileSize * 0.1) + (ix-1)*(actualTileSize*1.1) + actualTileSize/2
                ,(actualScreenPosY + actualTileSize * 0.1) + (iy-1)*(actualTileSize*1.1) + actualTileSize/2
                ,actualTileSize*sizeMultiplyer)

                --draw top icon
                local itemName, itemAmount, itemAttributes = self:getItem(ix,iy)

                if self:getSlotAttribute("topIcon",ix,iy).."" ~= "0" and itemName ~= "none" then
                    local x,y,size = self:getTilePosAndSize(ix,iy)

                    textures["sprites"]["inventoryIcons"]:draw(self:getSlotAttribute("topIcon",ix,iy),0,"right",
                    x + size/2,
                    y + size/2,
                    size/16 * 0.85,
                    size/16 * 0.85,
                    {1,1,1,0.3})
                end

            end

            --draw player in inventory
            if self:getSlotAttribute("showCharacter",ix,iy) == true then
                local x,y,size = self:getTilePosAndSize(ix,iy)

                entity:draw(true,x+size/2,y+size/2,size/8)

            end

        end
    end

    love.graphics.setColor(1,1,1,1)
    love.graphics.printf(self.inventoryName,actualScreenPosX+5,actualScreenPosY+5,999,"left",0,InventoryTextSize,InventoryTextSize)
    
end

function Inventory:getPosAndSize()

    local actualScreenPosX,actualScreenPosY, actualTileSize, actualSizeY
    if szx > szy then
        actualTileSize = szy * self:getTileSize()
    else
        actualTileSize = szx * self:getTileSize()
    end
    actualSizeY = self.sizeY

    actualScreenPosX = szx * self.screenPos.x
    if self.anchorX == "middle" then
        actualScreenPosX = actualScreenPosX - ((self.sizeX * actualTileSize * 1.1) + actualTileSize * 0.1)/2
    end
    if self.anchorX == "right" then
        actualScreenPosX = actualScreenPosX - ((self.sizeX * actualTileSize * 1.1) + actualTileSize * 0.1)
    end

    actualScreenPosY = szy * self.screenPos.y
    if self.anchorY == "middle" then
        actualScreenPosY = actualScreenPosY - ((actualSizeY * actualTileSize * 1.1) + actualTileSize * 0.1)/2
    end
    if self.anchorY == "bottom" then
        actualScreenPosY = actualScreenPosY - ((actualSizeY * actualTileSize * 1.1) + actualTileSize * 0.1)
    end

    local posX = actualScreenPosX
    local posY = actualScreenPosY
    local sizeX = ((self.sizeX * actualTileSize * 1.1) + actualTileSize * 0.1)
    local sizeY =  ((self.sizeY * actualTileSize * 1.1) + actualTileSize * 0.1)

    return posX,posY,sizeX,sizeY
end

function Inventory:getTilePosAndSize(ix,iy)

    local actualScreenPosX,actualScreenPosY, actualTileSize, actualSizeY
    if szx > szy then
        actualTileSize = szy * self:getTileSize()
    else
        actualTileSize = szx * self:getTileSize()
    end
    actualSizeY = self.sizeY

    actualScreenPosX = szx * self.screenPos.x
    if self.anchorX == "middle" then
        actualScreenPosX = actualScreenPosX - ((self.sizeX * actualTileSize * 1.1) + actualTileSize * 0.1)/2
    end
    if self.anchorX == "right" then
        actualScreenPosX = actualScreenPosX - ((self.sizeX * actualTileSize * 1.1) + actualTileSize * 0.1)
    end

    actualScreenPosY = szy * self.screenPos.y
    if self.anchorY == "middle" then
        actualScreenPosY = actualScreenPosY - ((actualSizeY * actualTileSize * 1.1) + actualTileSize * 0.1)/2
    end
    if self.anchorY == "bottom" then
        actualScreenPosY = actualScreenPosY - ((actualSizeY * actualTileSize * 1.1) + actualTileSize * 0.1)
    end

    local posX = (actualScreenPosX + actualTileSize * 0.1) + (ix-1)*(actualTileSize*1.1) 
    local posY = (actualScreenPosY + actualTileSize * 0.1) + (iy-1)*(actualTileSize*1.1)
    local size = actualTileSize

    return posX,posY,size
end

function Inventory:checkIfEmptySpacesAvailable()
    local available = false
    for ix=1 ,self.sizeX do
        for iy=1 ,self.sizeY do
            if (not self:getSlotAttribute("disabled",ix,iy)) or (self:getSlotAttribute("disabled",ix,iy) == 0) then
                if not self:getSlotAttribute("disableItemPickup",ix,iy) then
                    if self.items[self.currentPage][ix][iy]["name"] == "none" then
                        available = true
                    end
                end
            end
        end
    end

    return available
end

function Inventory:setAttribute(attribute,value,ix,iy,page)
    if page == nil then page = self.currentPage end
    if ix <= self.sizeX and ix >= 1 and iy >= 1 and iy <= self.sizeY then
        if attribute ~= nil and value ~= nil then 
            self.items[page][ix][iy]["attributes"][attribute] = value 
        end
    end
end

function Inventory:getAttribute(attribute,ix,iy,page)
    if page == nil then page = self.currentPage end
    if ix <= self.sizeX and ix >= 1 and iy >= 1 and iy <= self.sizeY then
        if attribute ~= nil then 
            return self.items[page][ix][iy]["attributes"][attribute]
        end
    end
    return 0
end

function Inventory:doesAttributeExists(attribute,ix,iy,page)
    if page == nil then page = self.currentPage end
    if ix <= self.sizeX and ix >= 1 and iy >= 1 and iy <= self.sizeY then
        if attribute ~= nil then 
            return true
        end
    end
    return false
end

function Inventory:setSlotAttribute(attribute,value,ix,iy,page)
    if page == nil then page = self.currentPage end
    if ix <= self.sizeX and ix >= 1 and iy >= 1 and iy <= self.sizeY then
        if attribute ~= nil and value ~= nil then 
            self.items[page][ix][iy]["slotAttributes"][attribute] = value 
        end
    end
end

function Inventory:getSlotAttribute(attribute,ix,iy,page)
    if page == nil then page = self.currentPage end
    if ix <= self.sizeX and ix >= 1 and iy >= 1 and iy <= self.sizeY then
        if attribute ~= nil then 
            if self.items[page][ix][iy]["slotAttributes"][attribute] ~= nil then
                return self.items[page][ix][iy]["slotAttributes"][attribute]
            end
        end
    end
    return 0
end

function Inventory:doesSlotAttributeExists(attribute,ix,iy,page)
    if page == nil then page = self.currentPage end
    if ix <= self.sizeX and ix >= 1 and iy >= 1 and iy <= self.sizeY then
        if attribute ~= nil then 
            if self.items[page][ix][iy]["slotAttributes"][attribute] ~= nil then
                return true
            end
        end
    end
    return false
end


function Inventory:getItem(ix,iy,page)
    if page == nil then page = self.currentPage end
    if ix <= self.sizeX and ix >= 1 and iy >= 1 and iy <= self.sizeY then
        return self.items[page][ix][iy]["name"], self.items[page][ix][iy]["amount"], self.items[page][ix][iy]["attributes"]
    end
    return "none",0,{}
end

function Inventory:getItemName(ix,iy,page)
    if page == nil then page = self.currentPage end
    if ix <= self.sizeX and ix >= 1 and iy >= 1 and iy <= self.sizeY then
        return self.items[page][ix][iy]["name"]
    end
    return "none"
end

function Inventory:getItemAmount(ix,iy,page)
    if page == nil then page = self.currentPage end
    if ix <= self.sizeX and ix >= 1 and iy >= 1 and iy <= self.sizeY then
        return self.items[page][ix][iy]["amount"]
    end
    return 0
end

function Inventory:getItemAttributes(ix,iy,page)
    if page == nil then page = self.currentPage end
    if ix <= self.sizeX and ix >= 1 and iy >= 1 and iy <= self.sizeY then
        return self.items[page][ix][iy]["attributes"]
    end
    return {}
end

function Inventory:resetItem(ix,iy,page)
    if page == nil then page = self.currentPage end
    if ix <= self.sizeX and ix >= 1 and iy >= 1 and iy <= self.sizeY then
        if (not self:getSlotAttribute("disabled",ix,iy,page)) or (self:getSlotAttribute("disabled",ix,iy,page) == 0) then
            self.items[page][ix][iy]["name"] = ""
            self.items[page][ix][iy]["amount"] = 0
            self.items[page][ix][iy]["attributes"] = {}
        end
    end
end

function Inventory:setItem(name,amount,attributes,ix,iy,page)
    if page == nil then page = self.currentPage end
    if ix <= self.sizeX and ix >= 1 and iy >= 1 and iy <= self.sizeY then
        if (not self:getSlotAttribute("disabled",ix,iy,page)) or (self:getSlotAttribute("disabled",ix,iy,page) == 0) then
            if name ~= nil then self.items[page][ix][iy]["name"] = name end
            if amount ~= nil then self.items[page][ix][iy]["amount"] = amount end
            if attributes ~= nil then self.items[page][ix][iy]["attributes"] = attributes end
        end
    end
end

function Inventory:setItemName(name,ix,iy,page)
    if page == nil then page = self.currentPage end
    if ix <= self.sizeX and ix >= 1 and iy >= 1 and iy <= self.sizeY then
        if (not self:getSlotAttribute("disabled",ix,iy,page)) or (self:getSlotAttribute("disabled",ix,iy,page) == 0) then
            if name ~= nil then self.items[page][ix][iy]["name"] = name end
        end
    end
end

function Inventory:setItemAmount(amount,ix,iy,page)
    if page == nil then page = self.currentPage end
    if ix <= self.sizeX and ix >= 1 and iy >= 1 and iy <= self.sizeY then
        if (not self:getSlotAttribute("disabled",ix,iy,page)) or (self:getSlotAttribute("disabled",ix,iy,page) == 0) then
            if amount ~= nil then self.items[page][ix][iy]["amount"] = amount end
        end
    end
end

function Inventory:itemAmountAdd(amount,ix,iy,page)
    if page == nil then page = self.currentPage end
    if ix <= self.sizeX and ix >= 1 and iy >= 1 and iy <= self.sizeY then
        if (not self:getSlotAttribute("disabled",ix,iy,page)) or (self:getSlotAttribute("disabled",ix,iy,page) == 0) then
            if amount ~= nil then self.items[page][ix][iy]["amount"] = self.items[page][ix][iy]["amount"] + amount end
        end
    end
end

function Inventory:setItemAttributes(attributes,ix,iy,page)
    if page == nil then page = self.currentPage end
    if ix <= self.sizeX and ix >= 1 and iy >= 1 and iy <= self.sizeY then
        if (not self:getSlotAttribute("disabled",ix,iy,page)) or (self:getSlotAttribute("disabled",ix,iy,page) == 0) then
            if attributes ~= nil then self.items[page][ix][iy]["attributes"] = attributes end
        end
    end
end

function Inventory:addItem(name,amount,attributes)
    local available,success,slotX, slotY
    available = false
    success = false

    for iy=1 ,self.sizeY do
        for ix=1 ,self.sizeX do
            if (not self:getSlotAttribute("disabled",ix,iy)) or (self:getSlotAttribute("disabled",ix,iy) == 0) then

                if amount > 0 then
                    if (self.items[self.currentPage][ix][iy]["name"] == name and self:getItemAmount(ix,iy) < items[name].maxStack) and (not available) then
                        available = true
                        slotX = ix
                        slotY = iy
                    end
                    if self.items[self.currentPage][ix][iy]["name"] == "none" and (not self:getSlotAttribute("disableItemPickup",ix,iy)) then
                        if not available then
                            available = true
                            slotX = ix
                            slotY = iy
                        end
                    end
                end

            end
        end
    end

    if available then
        local add = maximum(amount, items[name].maxStack - self:getItemAmount(slotX,slotY))

        self:setItem(name,self:getItemAmount(slotX,slotY) + add,attributes,slotX,slotY)

        self:setSlotAttribute("useAnimation",0.5,slotX,slotY,page)
        self:setSlotAttribute("useAnimationMax",0.5,slotX,slotY,page)
        amount = amount - add
        if amount <=0 then
            success = true
        end
    end

    return success, amount
end

function Inventory:throwEveryItem(x,y)
    for ip=1, #self.items do
        for ix=1, #self.sizeX do
            for iy=1, #self.sizeY do
                world:spawnGroundItem(self.items[ip][ix][iy]["name"], Vector2(x,y), Vector2((math.random()-0.5)*30,10+ math.random(10)), self.items[ip][ix][iy]["amount"], self.items[ip][ix][iy]["attributes"], {["pickupTimer"] = 1})
                self.items[ip][ix][iy]["name"] = "none"
                self.items[ip][ix][iy]["amount"] = 0
                self.items[ip][ix][iy]["attributes"] = {}
            end
        end
    end
end

function Inventory:drawItem(page,tileX,tileY,positionX,positionY,size)
    if page>0 and page<=#self.items and tileX>0 and tileX<=#self.items[page] and tileY>0 and tileY<=#self.items[page][tileX] then
        
        if self.items[page][tileX][tileY]["name"] ~= "none" then
            
            local drawFormat = medium
            if items[self.items[page][tileX][tileY]["name"]] ~= nil then
                items[self.items[page][tileX][tileY]["name"]]:draw("medium",positionX,positionY,size,self.items[page][tileX][tileY]["attributes"])
                if self.items[page][tileX][tileY]["amount"] > 1 then
                    love.graphics.setColor(1,1,1,1)
                    love.graphics.printf("x"..self.items[page][tileX][tileY]["amount"],positionX-size/2,positionY+size/2 - 15,size/(InventoryTextSize),"right",0,InventoryTextSize,InventoryTextSize)
                end
            end
        end
    end
end