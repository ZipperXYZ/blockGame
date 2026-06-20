require "class/superClass"
Item = SuperClass:extend()
Item.className = "Item"


function Item:init(itemName,sprite,flags)
    self.itemName = itemName
    self.flags = flags or {}
    self.sprite = textures["sprites"][sprite] or "none"
    self.spriteName = sprite or "none"

    self.placeBlock = self.flags.placeBlock or "none"
    self.stackable = self.flags.stackable or true
    self.category = self.flags.category or "none"
    self.mineDamage = self.flags.mineDamage or 1
    self.damage = self.flags.damage or 1
    self.canBeUsed = self.flags.canBeUsed or (self.placeBlock~="none")
    --self.textures = textures or {["groundDisplay"]="none",[""]}

end

function Item:draw(state,posX,posY,size,attributes)
    if self.itemName ~= "none" then
        local drawSize = size/8
        if state == "small" then drawSize = size / 8 end
        if state == "medium" then drawSize = size / 16 end
        if state == "big" then drawSize = size / 32 end
        self.sprite:draw(state,0,"right",posX,posY,drawSize,drawSize,{1,1,1,1})
    end
end