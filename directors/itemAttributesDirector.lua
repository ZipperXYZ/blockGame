require "class/superClass"
ItemDirector = SuperClass:extend()
ItemDirector.className = "ItemDirector"

function ItemDirector:init(credit,itemsAmount,creditMinPerItem,creditMaxPerItem,levelBias,enchantCreditMultiplier,biome,depth,cards,enchantCards)
    self.credit = credit or 10
    self.itemsAmount = itemsAmount or 1
    self.creditMaxPerItem = ((self.credit/self.itemsAmount)*1.5)
    self.creditMinPerItem = ((self.credit/self.itemsAmount)*0.5)
    if creditMaxPerItem ~= nil then self.creditMaxPerItem = ((self.credit/self.itemsAmount)*creditMaxPerItem) end
    if creditMinPerItem ~= nil then self.creditMinPerItem = ((self.credit/self.itemsAmount)*creditMinPerItem) end
    self.levelBias = levelBias or 1
    self.enchantCreditMultiplier = enchantCreditMultiplier or 1
    self.depth = depth or 0
    self.biome = biome or "any"
    self.cards = cards or {}
    self.enchantCards = enchantCards or {}
end

function ItemDirector:giveItems()
    local itemList = {}
    local credit = self.credit
    --print("ItemDirector:giveItems() - credit: "..credit.." itemsAmount: "..self.itemsAmount.." creditMinPerItem: "..self.creditMinPerItem.." creditMaxPerItem: "..self.creditMaxPerItem)
    --local credit = self.credit
    for i = 1, math.ceil(self.itemsAmount) do
        local creditLimit = maximum((math.random()^1.25)*(self.creditMaxPerItem-self.creditMinPerItem)+self.creditMinPerItem,self.creditMaxPerItem)
        local enchantCredit = (math.random()^0.75)*(self.creditMaxPerItem - creditLimit)+4

        local item, success, remaingCredit = self:rollItem(self.cards,credit,creditLimit,self.enchantCards,enchantCredit,self.enchantCreditMultiplier,self.depth,self.levelBias,self.biome)
        if success then 
            table.insert(itemList,item)
            --print("ItemDirector:giveItems() - Rolled item #"..i.."/"..math.ceil(self.itemsAmount)..": "..item.name.." amount: "..item.amount.." level: "..item.attributes.level.." remaining credit: "..remaingCredit)
            credit = remaingCredit
        end
    end
    return itemList
end

function ItemDirector:getAllAvailableCardsPool(cards,credit,creditLimit,creditCostMultiplier,biome,actualLevel)
    local cardPool = {}
    if cards == nil then cards = ItemCardsList end
    if #cards > 0 then
        for i = 1, #cards do
            local card = cards[i]
            --print("actual cost: "..card.cardCost * creditCostMultiplier.. " min: "..self.creditMinPerItem.." max: "..creditLimit.." credit: "..credit)
            if card.cardCost * creditCostMultiplier >= self.creditMinPerItem and card.cardCost * creditCostMultiplier <= credit and card.cardCost * creditCostMultiplier <= creditLimit then
                if checkifinlist(biome,card.biomes) or checkifinlist("any",card.biomes) then
                    if actualLevel >= card.minLevel and actualLevel <= card.maxLevel then
                        for i2 = 1, math.ceil(card.cardWeight) do
                            table.insert(cardPool,card)
                        end
                    end
                end
            end
        end
    end

    return cardPool
end

function ItemDirector:getAllAvailableEnchantCards(enchantCards,credit,multiplier,biome,itemName,item,enchantType,previousEnchants)
    local cardPool = {}
    if enchantCards == nil then enchantCards = EnchantsList end
    if #enchantCards > 0 then
        for i = 1, #enchantCards do

            local card = enchantCards[i]
            local cardValid = false

            if card.cardCost / multiplier <= credit then
                if checkifinlist(biome,card.biomes) or checkifinlist("any",card.biomes) then
                    if checkifinlist(itemName,card.itemNames) or checkifinlist("any",card.itemNames) then
                        if checkifinlist(item.category,card.itemTypesFilter) or checkifinlist(item.subCategory,card.itemTypesFilter) or checkifinlist("any",card.itemTypesFilter) then
                            if enchantType == "cause" then
                                if card.cardType == "cause" then
                                    cardValid = true
                                end
                            end
                            if enchantType == "condition" then
                                if card.cardType == "condition" then
                                    if previousEnchants[1] ~= nil then
                                        if #card.previousCardFilter == 0 or checkifanyinlist(card.previousCardFilter,previousEnchants[1].cardSubTypes) or checkifinlist("any",card.previousCardFilter) then
                                            cardValid = true
                                        end
                                    end
                                end
                            end
                            if enchantType == "reaction" then
                                if card.cardType == "reaction" then
                                    if previousEnchants[1] ~= nil then
                                        if #card.previousCardFilter == 0 or checkifanyinlist(card.previousCardFilter,previousEnchants[1].cardSubTypes) or checkifinlist("any",card.previousCardFilter) then
                                            cardValid = true
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if cardValid then
                for i2 = 1, math.ceil(card.cardWeight) do
                    table.insert(cardPool,card)
                end
            end
        end
    end
    return cardPool
end

function ItemDirector:rollItem(cards,credit,creditLimit,enchantCards,enchantCredit,enchantCreditMultiplier,depth,levelBias,biome)
    local item = {}
    local success = false
    local maxEnchantPoints = 15
    item.name = "none"
    item.amount = 0
    item.attributes = {}

    
    local randomLevel = (math.random()^(1/levelBias) +0.5)/1
    local actualLevel = minimum(randomLevel * math.abs(depth) * 20, 1)
    local itemCreditCostMultiplier = randomLevel
    
    --get available cards
    local cardPool = self:getAllAvailableCardsPool(cards,credit,creditLimit,itemCreditCostMultiplier,biome,actualLevel)

    --roll progressively for lower and higher levels if innufiscient cards are available
    if #cardPool == 0 then
        local levelOffset = 0
        local tries = 0
        while #cardPool == 0 and tries < 400 do
            levelOffset = levelOffset + 1

            --lower
            cardPool = {}

            if tries % 2 == 0 then
                randomLevel = (math.random()^(1/(levelBias)) +0.5)/(1+(levelOffset/10)^1.5)
                --if tries > 50 then randomLevel = randomLevel / ((1+(tries-50))^1.75) end
                if tries > 200 then randomLevel = randomLevel / ((1+(tries-200))^1.75) end
                --if tries > 150 then randomLevel = randomLevel / ((1+(tries-150))^2) end
                actualLevel = minimum(randomLevel * math.abs(depth) * 20, 1)
                itemCreditCostMultiplier = randomLevel

                cardPool = self:getAllAvailableCardsPool(cards,credit,creditLimit,itemCreditCostMultiplier,biome,actualLevel)
            end
            --higher
            if tries % 2 == 1 then
                randomLevel = (math.random()^(1/(levelBias)) +0.5)*(1+((levelOffset/10)^1.5))
                --if tries > 50 then randomLevel = randomLevel * ((1+(tries-50))^1.75) end
                if tries > 200 then randomLevel = randomLevel * ((1+(tries-200))^1.75) end
                --if tries > 150 then randomLevel = randomLevel * ((1+(tries-150))^2) end
                actualLevel = minimum(randomLevel * math.abs(depth) * 20, 1)
                itemCreditCostMultiplier = randomLevel

                cardPool = self:getAllAvailableCardsPool(cards,credit,creditLimit,itemCreditCostMultiplier,biome,actualLevel)
            end
            --print("ItemDirector:rollItem() - Rolled item, cardPool size: "..#cardPool.." tries: "..tries.." itemCreditCostMultiplier: "..itemCreditCostMultiplier.." actualLevel: "..actualLevel)
            --cardPool = TableJoin(cardPool1,cardPool2)

            tries = tries + 1
        end
        
    end

    --actually roll item
    if #cardPool > 0 then
        local chosenCard = cardPool[math.random(1,#cardPool)]
        item.name = chosenCard.itemName
        item.amount = math.ceil(math.random(chosenCard.quantityMin,chosenCard.quantityMax))
        item.attributes = CopyAll(chosenCard.itemAttributes)
        if item.attributes.level == nil then
            item.attributes.level = math.ceil(actualLevel)
        end
        success = true
        credit = credit - (chosenCard.cardCost * itemCreditCostMultiplier)
        creditLimit = creditLimit - (chosenCard.cardCost * itemCreditCostMultiplier)
    else
        return item, success, credit
    end

    --enchant item
    local actualItem = items[item.name]
    if actualItem ~= nil then
        if actualItem.canBeEnchanted then
            --print("ItemDirector:rollItem() - Enchanting item: "..item.name.." with enchantCredit: "..(enchantCredit).." and enchantCreditMultiplier: "..enchantCreditMultiplier)
            local enchant, enchantSuccess = self:enchant(item.name,items[item.name],item.attributes,enchantCards,enchantCredit*10,enchantCreditMultiplier,biome)
            
            if enchantSuccess then
                item.attributes.enchants = enchant
            end
        end
    end

    

    return item, success, credit
end

function ItemDirector:enchant(itemName,item,attributes,enchantCards,enchantCredit,multiplier,biome)
    --more or less credit depending on level
    local enchant = {}
    local success = false
    local numberOfEnchants = math.floor((math.random()^1.25)*math.floor(enchantCredit*(multiplier^0.75)/4))
    local creditPerEnchant = enchantCredit / numberOfEnchants

    --repeat until no more credit 
    if numberOfEnchants > 0 then
        for i = 1, numberOfEnchants do

            local newEnchant, enchantSuccess = self:rollCompleteEnchant(itemName,item,attributes,enchantCards,enchantCredit,multiplier,biome)
            
            if enchantSuccess then
                enchantCredit = enchantCredit - creditPerEnchant
                table.insert(enchant,newEnchant)
                --enchantCredit = enchantCredit - (newEnchant.cause.cardCost * multiplier) - (newEnchant.condition.cardCost * multiplier) - (newEnchant.reaction.cardCost * multiplier)
            end

        end
    end
    
    return enchant, success
end

function ItemDirector:rollCompleteEnchant(itemName,item,attributes,enchantCards,enchantCredit,multiplier,biome)
    local causeEnchant = nil
    local conditionEnchant = nil
    local reactionEnchant = nil
    local success = false
    local completeEnchant = {}


    --cause
    local cardPool = self:getAllAvailableEnchantCards(enchantCards,enchantCredit,multiplier,biome,itemName,item,"cause",{})
    if #cardPool > 0 then
        causeEnchant = cardPool[math.random(1,#cardPool)]
        completeEnchant.cause = {}
        completeEnchant.cause.name = causeEnchant.name
        completeEnchant.cause.card = causeEnchant
        completeEnchant.cause.power = 0
        enchantCredit = enchantCredit - (causeEnchant.cardCost / multiplier)
        --print("ItemDirector:rollCompleteEnchant() - Rolled cause enchant: "..causeEnchant.name.." with cardCost: "..causeEnchant.cardCost.." and remaining enchantCredit: "..enchantCredit)
    end

    --condition
    if completeEnchant.cause ~= nil then
        local cardPool = self:getAllAvailableEnchantCards(enchantCards,enchantCredit,multiplier,biome,itemName,item,"condition",{completeEnchant.cause})
        if #cardPool > 0 then
            conditionEnchant = cardPool[math.random(1,#cardPool)]
            completeEnchant.condition = {}
            completeEnchant.condition.name = conditionEnchant.name
            completeEnchant.condition.card = conditionEnchant
            completeEnchant.condition.power = 0
            enchantCredit = enchantCredit - (conditionEnchant.cardCost / multiplier)
            --print("ItemDirector:rollCompleteEnchant() - Rolled condition enchant: "..conditionEnchant.name.." with cardCost: "..conditionEnchant.cardCost.." and remaining enchantCredit: "..enchantCredit)
        end
    end

    --reaction
    if completeEnchant.condition ~= nil then
        local cardPool = self:getAllAvailableEnchantCards(enchantCards,enchantCredit,multiplier,biome,itemName,item,"reaction",{completeEnchant.cause, completeEnchant.condition})
        if #cardPool > 0 then
            reactionEnchant = cardPool[math.random(1,#cardPool)]
            completeEnchant.reaction = {}
            completeEnchant.reaction.name = reactionEnchant.name
            completeEnchant.reaction.card = reactionEnchant
            completeEnchant.reaction.power = 0
            enchantCredit = enchantCredit - (reactionEnchant.cardCost / multiplier)
            --print("ItemDirector:rollCompleteEnchant() - Rolled reaction enchant: "..reactionEnchant.name.." with cardCost: "..reactionEnchant.cardCost.." and remaining enchantCredit: "..enchantCredit)
        end
    end

    if completeEnchant.cause ~= nil and completeEnchant.condition ~= nil and completeEnchant.reaction ~= nil then
        success = true
        print("ItemDirector:rollCompleteEnchant() - Rolled complete enchant with cause: "..completeEnchant.cause.name.." condition: "..completeEnchant.condition.name.." reaction: "..completeEnchant.reaction.name.." and remaining enchantCredit: "..enchantCredit)
        if enchantCredit > 0 then
            completeEnchant.cause.power = (math.random()^1.25)*enchantCredit
            completeEnchant.condition.power = (math.random()^1.25)*enchantCredit
            completeEnchant.reaction.power = (math.random()^1.25)*enchantCredit
        end
    end

    


    return completeEnchant, success
end