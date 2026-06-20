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

    if self.isEquipmentInventory then
        self:setUpEquipmentInventory()
    else
        self.items[1][1][1] = {["amount"]=10,["name"]="stick",["attributes"]={},["slotAttributes"]={}}
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
                    ["lock"] = "accessory"
                }
            end
        end
        self.items[page][1][1]["slotAttributes"] = {["lock"] = "necklace"}
        self.items[page][1][2]["slotAttributes"] = {["lock"] = "armlet"}
        self.items[page][1][3]["slotAttributes"] = {["lock"] = "armlet"}

        self.items[page][2][1]["slotAttributes"] = {["disabled"] = true}
        self.items[page][2][2]["slotAttributes"] = {["disabled"] = true, ["showCharacter"] = true}
        self.items[page][2][3]["slotAttributes"] = {["lock"] = "charm"}

        self.items[page][3][1]["slotAttributes"] = {["lock"] = "headplate"}
        self.items[page][3][2]["slotAttributes"] = {["lock"] = "chestplate"}
        self.items[page][3][3]["slotAttributes"] = {["lock"] = "leggings"}
    end
    

    
end

function Inventory:draw(mode)
    if mode == nil then mode = "complete" end
    local page = self.currentPage

    local actualScreenPosX,actualScreenPosY, actualTileSize, actualSizeY
    if szx > szy then
        actualTileSize = szy * self.tileSize
    else
        actualTileSize = szx * self.tileSize
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

    for ix=1, self.sizeX do
        for iy=1, actualSizeY do
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
        end
    end

    for ix=1, self.sizeX do
        for iy=1, actualSizeY do
            love.graphics.setColor(1,1,1,1)
            self:drawItem(page,ix,iy,
            (actualScreenPosX + actualTileSize * 0.1) + (ix-1)*(actualTileSize*1.1) + actualTileSize/2
            ,(actualScreenPosY + actualTileSize * 0.1) + (iy-1)*(actualTileSize*1.1) + actualTileSize/2
            ,actualTileSize*0.85)
            --[[
            love.graphics.rectangle("fill"
                ,(actualScreenPosX + actualTileSize * 0.1) + (ix-1)*(actualTileSize*1.1)
                ,(actualScreenPosY + actualTileSize * 0.1) + (iy-1)*(actualTileSize*1.1)
                ,(actualTileSize)
                ,(actualTileSize)
                ,actualTileSize * 0.1
                ,actualTileSize * 0.1
            )]]
        end
    end

    love.graphics.setColor(1,1,1,1)
    love.graphics.print(self.inventoryName,actualScreenPosX+5,actualScreenPosY+5)
    
end

function Inventory:getPosAndSize()

    local actualScreenPosX,actualScreenPosY, actualTileSize, actualSizeY
    if szx > szy then
        actualTileSize = szy * self.tileSize
    else
        actualTileSize = szx * self.tileSize
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
        actualTileSize = szy * self.tileSize
    else
        actualTileSize = szx * self.tileSize
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
            if self.items[self.currentPage][ix][iy]["name"] == "none" then
                available = true
            end
        end
    end

    return available
end

function Inventory:addItem(name,amount,attributes)
    for iy=1 ,self.sizeY do
        for ix=1 ,self.sizeX do
            if amount > 0 then
                if self.items[self.currentPage][ix][iy]["name"] == name then
                    self.items[self.currentPage][ix][iy]["amount"] = self.items[self.currentPage][ix][iy]["amount"] + amount
                    amount = amount - amount
                end
                if self.items[self.currentPage][ix][iy]["name"] == "none" then
                    self.items[self.currentPage][ix][iy]["name"] = name
                    self.items[self.currentPage][ix][iy]["amount"] = amount
                    amount = amount - amount
                    self.items[self.currentPage][ix][iy]["attributes"] = attributes
                end
            end
        end
    end
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
                if self.items[page][tileX][tileY]["amount"] > 0 then
                    love.graphics.setColor(1,1,1,1)
                    love.graphics.printf("x"..self.items[page][tileX][tileY]["amount"],positionX-size/2,positionY+size/2 - 15,size/1.2,"right",0,1.2,1.2)
                end
            end
        end
    end
end