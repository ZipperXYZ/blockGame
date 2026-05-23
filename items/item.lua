require "class/superClass"
Item = SuperClass:extend()
Item.className = "Item"


function Item:init(itemName,sprite,flags)
    self.itemName = itemName
    self.flags = flags or {}
    self.sprite = sprite or "none"

    self.placeBlock = self.flags.placeBlock or "none"
    self.canBeUsed = self.flags.canBeUsed or (self.placeBlock~="none")
    --self.textures = textures or {["groundDisplay"]="none",[""]}

end