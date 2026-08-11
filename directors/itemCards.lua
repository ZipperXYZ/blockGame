function LoadItemCards()
    ItemCards = {}
    ItemCardsList = {}

    ItemCard.crudePickaxe = ItemCard(10,5,"crudePickaxe","common","tool",1,{"any"},{})
    ItemCard.crudeSpike = ItemCard(10,5,"crudeSpike","common","tool",1,{"any"},{})
    ItemCard.crudeSwayPickaxe = ItemCard(10,5,"crudeSwayPickaxe","common","tool",1,{"any"},{})
    ItemCard.crudeHammer = ItemCard(10,5,"crudeHammer","common","tool",1,{"any"},{})
    ItemCard.crudeScalpel = ItemCard(10,5,"crudeScalpel","common","tool",1,{"any"},{})
    ItemCard.crudeShovel = ItemCard(10,5,"crudeShovel","common","tool",1,{"any"},{})
    ItemCard.crudeStiffPick = ItemCard(10,5,"crudeStiffPick","common","tool",1,{"any"},{})
    ItemCard.crudeTargetPickaxe = ItemCard(10,5,"crudeTargetPickaxe","common","tool",1,{"any"},{})


    ItemCard.crudeSword = ItemCard(10,40,"crudeSword","common","weapon",1,{"any"},{})


    ItemCard.clearRing = ItemCard(10,15,"clearRing","common","accessory",2.5,{"any"},{})
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