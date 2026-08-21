function LoadItemCards()
    ItemCards = {}
    ItemCardsList = {}

    ItemCard.crudePickaxe = ItemCard(10,100,"crudePickaxe","common","tool",1,{"any"},{maxLevel = 4})
    ItemCard.crudeSpike = ItemCard(10,100,"crudeSpike","common","tool",1,{"any"},{maxLevel = 4})
    ItemCard.crudeSwayPickaxe = ItemCard(10,100,"crudeSwayPickaxe","common","tool",1,{"any"},{maxLevel = 4})
    ItemCard.crudeHammer = ItemCard(10,100,"crudeHammer","common","tool",1,{"any"},{maxLevel = 4})
    ItemCard.crudeScalpel = ItemCard(10,100,"crudeScalpel","common","tool",1,{"any"},{maxLevel = 4})
    ItemCard.crudeShovel = ItemCard(10,100,"crudeShovel","common","tool",1,{"any"},{maxLevel = 4})
    ItemCard.crudeStiffPick = ItemCard(10,100,"crudeStiffPick","common","tool",1,{"any"},{maxLevel = 4})
    ItemCard.crudeTargetPickaxe = ItemCard(10,100,"crudeTargetPickaxe","common","tool",1,{"any"},{maxLevel = 4})


    ItemCard.crudeSword = ItemCard(10,400,"crudeSword","common","weapon",1,{"any"},{maxLevel = 5})
    ItemCard.crudeBow = ItemCard(10,400,"crudeBow","common","weapon",1,{"any"},{maxLevel = 5})
    ItemCard.bomb = ItemCard(10,250,"bomb","common","weapon",1,{"any"},{minLevel = 5, quantityMin = 5, quantityMax = 20})


    ItemCard.clearRing = ItemCard(10,800,"clearRing","common","accessory",2.5,{"any"},{maxLevel = 8})
    ItemCard.coldRing = ItemCard(10,600,"coldRing","common","accessory",4,{"any"},{minLevel = 5, maxLevel = 50})
    ItemCard.fireRing = ItemCard(10,400,"fireRing","common","accessory",6,{"any"},{minLevel = 10, maxLevel = 100})
    ItemCard.natureRing = ItemCard(10,300,"natureRing","common","accessory",8,{"any"},{minLevel = 15, maxLevel = 500})
    ItemCard.goldRing = ItemCard(10,200,"goldRing","common","accessory",10,{"any"},{minLevel = 20, maxLevel = 1000})
    ItemCard.voidRing = ItemCard(10,100,"voidRing","common","accessory",13,{"any"},{minLevel = 30, maxLevel = 999999999})
    
    ItemCard.healthNecklace = ItemCard(10,250,"healthNecklace","common","accessory",1.5,{"any"},{minLevel = 0, maxLevel = 40})
    ItemCard.greaterHealthNecklace = ItemCard(10,180,"greaterHealthNecklace","common","accessory",1.8,{"any"},{minLevel = 10, maxLevel = 999999999})
    ItemCard.movementArtifact = ItemCard(10,140,"movementArtifact","common","accessory",0.8,{"any"},{minLevel = 15, maxLevel = 999999999})
    ItemCard.glassArtifact = ItemCard(10,140,"glassArtifact","common","accessory",1.3,{"any"},{minLevel = 20, maxLevel = 999999999})
    
    
    ItemCard.thunderBirdFeather = ItemCard(10,60,"thunderBirdFeather","common","movement",0,{"any"},{minLevel = 0, maxLevel = 999999999})
    ItemCard.angelFeather = ItemCard(10,60,"angelFeather","common","movement",0,{"any"},{minLevel = 0, maxLevel = 999999999})
    ItemCard.lumiFeather = ItemCard(10,30,"lumiFeather","common","movement",0,{"any"},{minLevel = 10, maxLevel = 999999999})

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