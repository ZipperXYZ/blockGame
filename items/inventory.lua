require "class/superClass"
Inventory = SuperClass:extend()
Inventory.className = "Inventory"


function Inventory:init(inventoryName,sizeX,sizeY,maxStack,color,screenPos)
    self.inventoryName = inventoryName or ""
    self.id = math.random()
    self.color = color or {0.65,0.65,0.65,1}
    self.maxStack = maxStack or 100
    self.sizeX = sizeX or 5
    self.tileSize = sizeX or 5
    self.sizeY = sizeY or 5
    self.screenPos = screenPos or Vector2(0.5,0.5)
    self.items = {}
    for ix=1,self.sizeX do
        self.items[ix]={}
        for iy=1,self.sizeY do
            self.items[ix][iy]={}
            self.items[ix][iy]["amount"]=0
            self.items[ix][iy]["name"]="none"
        end
    end
end