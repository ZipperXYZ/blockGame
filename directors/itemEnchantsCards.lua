require "class/superClass"
ItemEnchantCard = SuperClass:extend()
ItemEnchantCard.className = "ItemEnchantCard"

--items have randomly generated enchantments, each having three parts : cause, condition, reaction
--they have a score based on the chest the item attribuated to the enchantments, but depending on cause and condition, the reaction will have a multiplier

--cause enchantments :
    -- on enemy hit
    --when taking damage
    --on enemy kill
    --breaking a tile
    --taking fall damage
    --on jump
    --using said item
    --using any item
    --enemy entering radius
    --enemy spotting you
    --enemy loosing sight of you
    --destroying a block


--condition enchantments :
    --no condition
    --grounded
    --airborne
    --same vertical level
    --enemy has full health
    --on full health
    --under a certain health threshold
    --enemy under a certain health threshold
    --above a certain health threshold
    --enemy above a certain health threshold
    --distance from enemy is above a certain threshold
    --distance from enemy is below a certain threshold
    --enemy is a boss
    --enemy is an elite
    

--reaction enchantments :
    --chance to stun
    --explode in a radius
    --explode in a radius (dealing damage to tiles)
    --emits projectile
    --inflicts effect
    --drop xp
    --give health
    --increase damage to enemy
    --decrease damage taken
    --increase speed for duration

function LoadItemEnchantmentCards()
    Enchants = {}
    EnchantsList = {}

    Enchants.onEnemyHit = ItemEnchantCard(1, 15, "onEnemyHit", "cause", {"enemy","enemyDamage","damageValue"}, {"weapon","accessory"}, {}, 1, {"any"}, {})
    Enchants.takingDamage = ItemEnchantCard(1, 10, "takingDamage", "cause", {"player","playerDamage","damageValue"}, {"any"}, {}, 2.5, {"any"}, {})
    Enchants.onEnemyKill = ItemEnchantCard(1, 15, "onEnemyKill", "cause", {"enemy","damageValue"}, {"weapon","accessory"}, {}, 3, {"any"}, {})

    Enchants.noCondition = ItemEnchantCard(3, 30, "noCondition", "condition", {}, {"any"}, {}, 0.5, {"any"}, {})
    Enchants.grounded = ItemEnchantCard(1, 10, "grounded", "condition", {}, {"any"}, {}, 2, {"any"}, {})
    Enchants.airborne = ItemEnchantCard(1, 10, "airborne", "condition", {}, {"any"}, {}, 1.5, {"any"}, {})

    Enchants.increaseDamage = ItemEnchantCard(1, 10, "increaseDamage", "reaction", {}, {"any"}, {"enemyDamage"}, nil, {"any"}, {})
    Enchants.giveHealth = ItemEnchantCard(2, 10, "giveHealth", "reaction", {}, {"any"}, {}, nil, {"any"}, {})
    Enchants.decreaseDamageTaken = ItemEnchantCard(1, 10, "decreaseDamageTaken", "reaction", {}, {"any"}, {"playerDamage"}, nil, {"any"}, {})

end


---@param cardType '"cause"'|'"condition"'|'"reaction"'
function ItemEnchantCard:init(cardCost,cardWeight,name,cardType,cardSubTypes,itemTypesFilter,previousCardFilter,creditMultiplier,biomes,flags)
    self.cardCost = cardCost or 1
    self.cardWeight = cardWeight or 10
    self.cardType = cardType or "reaction"
    self.cardSubTypes = cardSubTypes or {}
    self.itemTypesFilter = itemTypesFilter or {"any"}
    --any, tool, weapon, melee, ranged, armor, accessory
    self.biomes = biomes or {"any"}
    self.name = name or "none"
    self.previousCardFilter = previousCardFilter or {}
    self.creditMultiplier = creditMultiplier or 1
    --credit multiplier for the reaction enchantment, based on the cause and condition enchantments
    self.flags = CopyAll(flags) or {}
    self.itemNames = self.flags.itemNames or {"any"}

    self.print = 
    function (self,itemAttributes,item,power,entity)
        local printTable = {}
        printTable = {"#silent",self.cardType,"#muted"," Name: ","#info",self.name,"#muted"," Power: ","#danger",self:getValue(power,itemAttributes,item,entity)}
        return printTable
    end
    if self.flags.print ~= nil then
        self.print = self.flags.print
    end

    self.getValue =
    function (self,power,itemAttributes,item,entity)
        local value = round(power,100)

        return value
    end
    if self.flags.getValue ~= nil then
        self.getValue = self.flags.getValue
    end


    self.checkSignal =
    function (self,signal,signalInfo,power,itemAttributes,item,entity)
        local accepted = false

        return accepted
    end
    if self.flags.checkSignal ~= nil then
        self.checkSignal = self.flags.checkSignal
    end
    
    self.checkCondition =
    function (self,power,itemAttributes,item,entity,signalInfo)
        local success = false

        return success
    end
    if self.flags.checkCondition ~= nil then
        self.checkCondition = self.flags.checkCondition
    end

    self.use =
    function (self,power,itemAttributes,item,entity,signalInfo)
        local success = false

        return success
    end
    if self.flags.use ~= nil then
        self.use = self.flags.use
    end
    
    

    table.insert(EnchantsList,self)
end

function enchantReceiveSignal(signalName,signalInfo,cause,condition,reaction,itemAttributes,item,entity)
    local success = false
    
    if cause ~= nil and condition ~= nil and reaction ~= nil then

        if cause.card:checkSignal(signalName,signalInfo,cause.power,itemAttributes,item,entity) then

            if condition.card:checkCondition(condition.power,itemAttributes,item,entity,signalInfo) then
                success = reaction:use(reaction.power,itemAttributes,item,entity)
            end

        end

    end

    return success
    
end

--functions :

--receiveSignal(signal)

--checkCondition()
--use()

--print()

--getValue() based on whatever enchant and credit used for the enchant, for example damage, it will give the value, example : 
    --increaseDamage.getValue(credit) -> returns the increased damage based on the credit used