require "class/superClass"
Inventory = SuperClass:extend()
Inventory.className = "Inventory"


function Inventory:init(inventoryName,color,screenPos,sizeX,sizeY,sizeZ,maxStack,tileSize,itemSize,flags)
    self.inventoryName = inventoryName or ""
    self.id = math.random()
    self.color = color or {0.65,0.65,0.65,1}
    self.maxStack = maxStack or 100
    self.sizeX = sizeX or 5
    self.tileSize = tileSize or ((8+1)*5)
    self.tileSize = itemSize or ((1)*5)
    self.sizeY = sizeY or 5
    self.sizeZ = sizeZ or 1
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
        self.items[1][1] = {["amount"]=10,["name"]="stick",["attributes"]={},["slotAttributes"]={}}
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