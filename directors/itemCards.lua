function LoadItemCards()
    ItemCards = {}
    ItemCardsList = {}

    ItemCard.crudePickaxe = ItemCard(10,200,"crudePickaxe","common","tool",1,{"any"},{maxLevel = 8})
    ItemCard.crudeSpike = ItemCard(10,200,"crudeSpike","common","tool",1,{"any"},{maxLevel = 8})
    ItemCard.crudeSwayPickaxe = ItemCard(10,200,"crudeSwayPickaxe","common","tool",1,{"any"},{maxLevel = 8})
    ItemCard.crudeHammer = ItemCard(10,200,"crudeHammer","common","tool",1,{"any"},{maxLevel = 8})
    ItemCard.crudeScalpel = ItemCard(10,200,"crudeScalpel","common","tool",1,{"any"},{maxLevel = 8})
    ItemCard.crudeShovel = ItemCard(10,200,"crudeShovel","common","tool",1,{"any"},{maxLevel = 8})
    ItemCard.crudeStiffPick = ItemCard(10,200,"crudeStiffPick","common","tool",1,{"any"},{maxLevel = 8})
    ItemCard.crudeTargetPickaxe = ItemCard(10,200,"crudeTargetPickaxe","common","tool",1,{"any"},{maxLevel = 8})


    ItemCard.crudeSword = ItemCard(10,1600,"crudeSword","common","weapon",1,{"any"},{maxLevel = 8})


    ItemCard.clearRing = ItemCard(10,800,"clearRing","common","accessory",2.5,{"any"},{maxLevel = 8})
end

require "class/superClass"
ItemCard = SuperClass:extend()
ItemCard.className = "ItemCard"


function ItemCard:init(cardCost,cardWeight,itemName,cardRarity,cardType,enchantCreditMultiplier,biomes,flags)
    self.cardCost = cardCost or 1
    self.cardWeight = cardWeight or 10
    self.cardRarity = cardRarity or "common"
    self.cardType = cardType or "none"
    --any, tool, weapon, melee, ranged, armor, accessory
    self.biomes = biomes or {"any"}
    self.itemName = itemName or "none"
    self.enchantCreditMultiplier = enchantCreditMultiplier or 1
    --credit multiplier for the reaction enchantment, based on the cause and condition enchantments
    self.flags = CopyAll(flags) or {}

    self.enchantBlacklist = self.flags.enchantBlacklist or {}
    self.quantityMin = self.flags.quantityMin or 1
    self.quantityMax = self.flags.quantityMax or 1
    self.maxLevel = self.flags.maxLevel or 9999
    self.minLevel = self.flags.minLevel or 1
    self.itemAttributes = self.flags.itemAttributes or {}

    table.insert(ItemCardsList,self)
end