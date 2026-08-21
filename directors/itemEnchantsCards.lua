require "class/superClass"
ItemEnchantCard = SuperClass:extend()
ItemEnchantCard.className = "ItemEnchantCard"

--items have randomly generated enchantments, each having three parts : cause, condition, reaction
--they have a score based on the chest the item attribuated to the enchantments, but depending on cause and condition, the reaction will have a multiplier

--cause enchantments :
    --enemy entering radius
    --enemy spotting you
    --enemy loosing sight of you


--condition enchantments :
    --higher vertical level than enemy
    --enemy under a certain health threshold
    --distance from enemy is above a certain threshold
    --distance from enemy is below a certain threshold
    --enemy is an elite
    

--reaction enchantments :
    --chance to stun
    --explode in a radius
    --explode in a radius (dealing damage to tiles)
    --emits projectile
    --inflicts effect
    --increase speed for duration


function LoadItemEnchantmentCards()
    Enchants = {}
    EnchantsList = {}

    Enchants.onEnemyHit = ItemEnchantCard(1, 20, "onEnemyHit", "cause", {"enemy","enemyDamage","damageValue","itemUse"}, {"weapon","accessory"}, 1, {"any"}, {
        checkSignal =
            function (self,signal,signalInfo,power,itemAttributes,item,entity)
                local accepted = false
                if signal == "enemyHit" then
                    accepted = true
                end

                return accepted, signalInfo
            end,
        print = 
            function (self,itemAttributes,item,power,entity)
                return {"#muted"," When ","#alert"," hitting ","#muted"," an ","#enemy","enemy"}
            end,
        getValue = 
            function (self,power,itemAttributes,item,entity)
                return 0
            end,
    })
    Enchants.takingDamage = ItemEnchantCard(1, 10, "takingDamage", "cause", {"player","playerDamage","damageValue","preventHealthGain"}, {"accessory"}, 2.5, {"any"}, {
        checkSignal =
            function (self,signal,signalInfo,power,itemAttributes,item,entity)
                local accepted = false
                if signal == "takingDamage" then
                    accepted = true
                end

                return accepted, signalInfo
            end,
        print = 
            function (self,itemAttributes,item,power,entity)
                return {"#muted"," When ","#damage","taking damage"}
            end,
        getValue = 
            function (self,power,itemAttributes,item,entity)
                return 0
            end,
    })
    Enchants.onEnemyKill = ItemEnchantCard(1, 15, "onEnemyKill", "cause", {"enemy","damageValue","itemUse"}, {"weapon","accessory"}, 3, {"any"}, {
        checkSignal =
            function (self,signal,signalInfo,power,itemAttributes,item,entity)
                local accepted = false
                if signal == "enemyKill" then
                    accepted = true
                end

                return accepted, signalInfo
            end,
        print = 
            function (self,itemAttributes,item,power,entity)
                return {"#muted"," When ","#kill"," killing ","#muted"," an ","#enemy","enemy"}
            end,
        getValue = 
            function (self,power,itemAttributes,item,entity)
                return 0
            end,
    })
    Enchants.breakingTile = ItemEnchantCard(1, 10, "breakingTile", "cause", {"tile","tileDamageValue","itemUse"}, {"tool","accessory"}, 0.2, {"any"}, {
        checkSignal =
            function (self,signal,signalInfo,power,itemAttributes,item,entity)
                local accepted = false
                if signal == "breakingTile" then
                    accepted = true
                end

                return accepted, signalInfo
            end,
        print = 
            function (self,itemAttributes,item,power,entity)
                return {"#muted"," When ","#info","breaking a tile"}
            end,
        getValue =  
            function (self,power,itemAttributes,item,entity)
                return 0
            end,
    })
    Enchants.damagingTile = ItemEnchantCard(1, 10, "damagingTile", "cause", {"tile","tileDamageValue","tileDamage","itemUse","preventHealthGain"}, {"tool","accessory"}, 0.06, {"any"}, {
        checkSignal =
            function (self,signal,signalInfo,power,itemAttributes,item,entity)
                local accepted = false
                if signal == "damagingTile" then
                    accepted = true
                end

                return accepted, signalInfo
            end,
        print = 
            function (self,itemAttributes,item,power,entity)
                return {"#muted"," When ","#info","damaging a tile"}
            end,
        getValue =  
            function (self,power,itemAttributes,item,entity)
                return 0
            end,
    })
    Enchants.shootingBow = ItemEnchantCard(1, 10, "shootingBow", "cause", {"projectileShoot","projectileDamageValue","itemUse"}, {"ranged","accessory"}, 0.2, {"any"}, {
        checkSignal =
            function (self,signal,signalInfo,power,itemAttributes,item,entity)
                local accepted = false
                if signal == "shootingBow" then
                    accepted = true
                end

                return accepted, signalInfo
            end,
        print = 
            function (self,itemAttributes,item,power,entity)
                return {"#muted"," When ","#info","shooting projectiles"}
            end,
        getValue =  
            function (self,power,itemAttributes,item,entity)
                return 0
            end,
    })
    Enchants.jump = ItemEnchantCard(2, 10, "jump", "cause", {"player","playerJump","preventHealthGain","jump"}, {"accessory"}, 0.2, {"any"}, {
        checkSignal =
            function (self,signal,signalInfo,power,itemAttributes,item,entity)
                local accepted = false
                if signal == "jump" then
                    accepted = true
                end

                return accepted, signalInfo
            end,
        print = 
            function (self,itemAttributes,item,power,entity)
                return {"#muted"," When ","#info","jumping"}
            end,
        getValue =  
            function (self,power,itemAttributes,item,entity)
                return 0
            end,
    })


    --conditions :

    Enchants.noCondition = ItemEnchantCard(3, 40, "noCondition", "condition", {}, {"any"}, 0.5, {"any"}, {
        checkCondition =
            function (self,power,itemAttributes,item,entity,signalInfo)
                local success = true

                return success, signalInfo
            end,
        print = 
            function (self,itemAttributes,item,power,entity)
                return {}
            end,
        getValue = 
            function (self,power,itemAttributes,item,entity)
                return 0
            end,
    })
    Enchants.grounded = ItemEnchantCard(1, 10, "grounded", "condition", {}, {"any"}, 1.5, {"any"}, {
        previousCardAntiFilter = {"jump"},
        checkCondition =
            function (self,power,itemAttributes,item,entity,signalInfo)
                local success = false
                if entity:isGrounded() then
                    success = true
                end

                return success, signalInfo
            end,
        print = 
            function (self,itemAttributes,item,power,entity)
                return {"#muted",", while ","#condition","grounded"}
            end,
        getValue = 
            function (self,power,itemAttributes,item,entity)
                return 0
            end,
    })
    Enchants.airborne = ItemEnchantCard(1, 10, "airborne", "condition", {}, {"any"}, 2, {"any"}, {
        previousCardAntiFilter = {"jump"},
        checkCondition =
            function (self,power,itemAttributes,item,entity,signalInfo)
                local success = false
                if not entity:isGrounded() then
                    success = true
                end

                return success, signalInfo
            end,
        print = 
            function (self,itemAttributes,item,power,entity)
                return {"#muted",", while ","#condition","airborne"}
            end,
        getValue = 
            function (self,power,itemAttributes,item,entity)
                return 0
            end,
    })
    Enchants.fullHealth = ItemEnchantCard(1, 15, "fullHealth", "condition", {"playerFullHealth","preventHealthGain"}, {"any"}, 2, {"any"}, {
        checkCondition =
            function (self,power,itemAttributes,item,entity,signalInfo)
                local success = false
                if entity.health:isFull("hp") then
                    success = true
                end

                return success, signalInfo
            end,
        print = 
            function (self,itemAttributes,item,power,entity)
                return {"#muted",", while at ","#condition","full health"}
            end,
        getValue = 
            function (self,power,itemAttributes,item,entity)
                return 0
            end,
    })
    Enchants.lowHealth = ItemEnchantCard(1, 8, "lowHealth", "condition", {}, {"any"}, 3.5, {"any"}, {
        checkCondition =
            function (self,power,itemAttributes,item,entity,signalInfo)
                local success = false
                if entity.health:getValue("hp") / entity.health:getMax("hp") <= self:getValue(power,itemAttributes,item,entity)/100 then
                    success = true
                end

                return success, signalInfo
            end,
        print = 
            function (self,itemAttributes,item,power,entity)
                return {"#muted",", while ","#condition","health under ","#value",self:getValue(power,itemAttributes,item,entity).."%"}
            end,
        getValue = 
            function (self,power,itemAttributes,item,entity)
                local kv = 0.03
                local min = 10
                local max = 65
                local multiplier = 2
                local value = (max-min) * (math.log(1 + kv * (power*multiplier))/ (1 + math.log(1 + kv * (power*multiplier)))) + min
                value = round(value)

                return value
            end,
    })
    Enchants.enemyFullHealth = ItemEnchantCard(1, 10, "enemyFullHealth", "condition", {}, {"any"}, 2.5, {"any"}, {
        previousCardFilter = {"enemyDamage"},
        checkCondition =
            function (self,power,itemAttributes,item,entity,signalInfo)
                local success = false
                if signalInfo.enemy ~= nil then
                    if signalInfo.enemy.health:isFull("hp") then
                        success = true
                    end
                end

                return success, signalInfo
            end,
        print = 
            function (self,itemAttributes,item,power,entity)
                return {"#muted",", while ","#enemy","enemy","#muted"," is on ","#condition","full health"}
            end,
        getValue = 
            function (self,power,itemAttributes,item,entity)
                return 0
            end,
    })
    Enchants.enemyIsBoss = ItemEnchantCard(1, 6, "enemyIsBoss", "condition", {}, {"any"}, 7, {"any"}, {
        previousCardFilter = {"enemyDamage"},
        checkCondition =
            function (self,power,itemAttributes,item,entity,signalInfo)
                local success = false
                if signalInfo.enemy ~= nil then
                    if signalInfo.enemy.isBoss then
                        success = true
                    end
                end

                return success, signalInfo
            end,
        print = 
            function (self,itemAttributes,item,power,entity)
                return {"#muted",", while ","#enemy","enemy","#muted"," is a ","#boss","boss"}
            end,
        getValue = 
            function (self,power,itemAttributes,item,entity)
                return 0
            end,
    })


    --reactions : 

    Enchants.increaseDamage = ItemEnchantCard(1, 25, "increaseDamage", "reaction", {}, {"any"}, nil, {"any"}, {
        previousCardFilter = {"enemyDamage"},
        use =
            function (self,power,itemAttributes,item,entity,signalInfo)
                local success = false

                if signalInfo ~= nil and signalInfo.damageValue ~= nil then
                    signalInfo.damageValue = signalInfo.damageValue  * (1 + self:getValue(power,itemAttributes,item,entity)/100)
                    success = true
                end

                return success, signalInfo
            end,
        print = 
            function (self,itemAttributes,item,power,entity)
                return {"#muted",", increase ","#damage"," damage ","#muted","by ","#value",self:getValue(power,itemAttributes,item,entity).."%"}
            end,
        getValue = 
            function (self,power,itemAttributes,item,entity)
                local value = ((power*20) ^ 0.5)
                value = round(value)

                return value
            end,
    })
    Enchants.increaseCriticalStrikeChance = ItemEnchantCard(1, 15, "increaseCriticalStrikeChance", "reaction", {}, {"any"}, nil, {"any"}, {
        previousCardFilter = {"enemyDamage"},
        use =
            function (self,power,itemAttributes,item,entity,signalInfo)
                local success = false

                if signalInfo ~= nil and signalInfo.criticalChance ~= nil then
                    signalInfo.criticalChance = k(signalInfo.criticalChance, 1 , self:getValue(power,itemAttributes,item,entity)/100)
                    success = true
                end

                return success, signalInfo
            end,
        print = 
            function (self,itemAttributes,item,power,entity)
                return {"#muted",", increase ","#damage"," critical strike ","#muted","chance by ","#value",self:getValue(power,itemAttributes,item,entity).."%"}
            end,
        getValue = 
            function (self,power,itemAttributes,item,entity)
                local kv = 0.05
                local multiplier = 2
                local value = 100 * (math.log(1 + kv * (power*multiplier))/ (1 + math.log(1 + kv * (power*multiplier))))
                value = round(value)

                return value
            end,
    })
    Enchants.increaseMineDamage = ItemEnchantCard(1, 20, "increaseMineDamage", "reaction", {}, {"tool","accessory"}, nil, {"any"}, {
        previousCardFilter = {"tileDamage"},
        use =
            function (self,power,itemAttributes,item,entity,signalInfo)
                local success = false

                if signalInfo ~= nil and signalInfo.mineDamageValue ~= nil then
                    signalInfo.mineDamageValue = signalInfo.mineDamageValue  * (1 + self:getValue(power,itemAttributes,item,entity)/100)
                    success = true
                end

                return success, signalInfo
            end,
        print = 
            function (self,itemAttributes,item,power,entity)
                return {"#muted",", increase ","#damage","tool damage ","#muted","by ","#value",self:getValue(power,itemAttributes,item,entity).."%"}
            end,
        getValue = 
            function (self,power,itemAttributes,item,entity)
                local value = ((power*50) ^ 0.75)
                value = round(value)

                return value
            end,
    })
    Enchants.multiShot = ItemEnchantCard(1, 17, "multiShot", "reaction", {}, {"ranged","accessory"}, nil, {"any"}, {
        previousCardFilter = {"projectileShoot"},
        use =
            function (self,power,itemAttributes,item,entity,signalInfo)
                local success = false

                if signalInfo ~= nil then
                    signalInfo.projectileDamage = signalInfo.projectileDamage * (self:getRadius(power,itemAttributes,item,entity))
                    signalInfo.projectileAmount = signalInfo.projectileAmount * (self:getValue(power,itemAttributes,item,entity))

                    success = true
                end

                return success, signalInfo
            end,
        print = 
            function (self,itemAttributes,item,power,entity)
                return {"#muted",", multiply amount of projectiles by ","#value",self:getValue(power,itemAttributes,item,entity),"#muted"," but only deal ","#damage",(self:getRadius(power,itemAttributes,item,entity)*100).."%","#muted"," of the original damage"}
            end,
        getRadius = 
            function (self,power,itemAttributes,item,entity)
                local radius = 1
                -- in this case, the function doesnt refer to radius but the damage amount
                local projectileAmount = self:getValue(power,itemAttributes,item,entity)
                radius = radius / (1 + ((1 + (power*4) ^ 0.7) - 1) * 0.3)

                radius = round(radius,100)
                return radius
            end,
        getValue = 
            function (self,power,itemAttributes,item,entity)
                local value = math.ceil(1 + (power*4) ^ 0.7)
                return value
            end,
    })
    Enchants.giveHealth = ItemEnchantCard(2, 5, "giveHealth", "reaction", {}, {"any"}, nil, {"any"}, {
        previousCardAntiFilter = {"playerFullHealth","playerDamage"},--,"preventHealthGain"},
        use =
            function (self,power,itemAttributes,item,entity,signalInfo)
                local success = false

                if entity.health ~= nil then
                    local value = self:getValue(power,itemAttributes,item,entity)
                    --entity.health:increase("hp", value)
                    entity:gainHealth(math.ceil((value/100)*maximum(entity.health:getMax("hp"),100)),"hp","giveHealth Enchant",entity)
                    success = true
                end

                return success, signalInfo
            end,
        print = 
            function (self,itemAttributes,item,power,entity)
                return {"#muted",", heal ","#value",self:getValue(power,itemAttributes,item,entity).."% ","#muted"," of maximum ","#health"," health"}
            end,
        getValue = 
            function (self,power,itemAttributes,item,entity)
                --starts at 0 from power 0, then increases slowly and slowly never reaching 100% but getting ever closer ot it
                local kv = 0.008
                local min = 1
                local multiplier = 2
                local value = (100-min) * (math.log(1 + kv * (power*multiplier))/ (1 + math.log(1 + kv * (power*multiplier)))) + min
                value = round(value)

                return value
            end,
    })
    Enchants.decreaseDamageTaken = ItemEnchantCard(1, 10, "decreaseDamageTaken", "reaction", {}, {"any"}, nil, {"any"}, {
        previousCardFilter = {"playerDamage"},
        use =
            function (self,power,itemAttributes,item,entity,signalInfo)
                local success = false

                if signalInfo ~= nil and signalInfo.damageValue ~= nil then
                    signalInfo.damageValue = signalInfo.damageValue  * (1 - self:getValue(power,itemAttributes,item,entity)/100)
                    success = true
                end

                return success, signalInfo
            end,
        print = 
            function (self,itemAttributes,item,power,entity)
                return {"#muted",", decrease ","#damage"," damage taken ","#muted","by ","#value",self:getValue(power,itemAttributes,item,entity).."%"}
            end,
        getValue = 
            function (self,power,itemAttributes,item,entity)
                local kv = 0.03
                local multiplier = 1
                local value = 100 * (math.log(1 + kv * (power*multiplier))/ (1 + math.log(1 + kv * (power*multiplier))))
                value = round(value)

                return value
            end,
    })
    Enchants.decreaseCooldown = ItemEnchantCard(1, 10, "decreaseCooldown", "reaction", {}, {"tool","accessory"}, nil, {"any"}, {
        previousCardFilter = {"itemUse"},
        use =
            function (self,power,itemAttributes,item,entity,signalInfo)
                local success = false

                if signalInfo ~= nil and signalInfo.cooldownValue ~= nil then
                    signalInfo.cooldownValue = signalInfo.cooldownValue  * (1 - self:getValue(power,itemAttributes,item,entity)/100)
                    success = true
                end

                return success, signalInfo
            end,
        print = 
            function (self,itemAttributes,item,power,entity)
                return {"#muted",", decrease ","#cooldown"," cooldown ","#muted","by ","#value",self:getValue(power,itemAttributes,item,entity).."%"}
            end,
        getValue = 
            function (self,power,itemAttributes,item,entity)
                local kv = 0.2
                local multiplier = 2
                local value = 100 * (math.log(1 + kv * (power*multiplier))/ (1 + math.log(1 + kv * (power*multiplier))))
                value = round(value)

                return value
            end,
    })
    Enchants.dropXP = ItemEnchantCard(2, 4, "dropXP", "reaction", {}, {"any"}, nil, {"any"}, {
        use =
            function (self,power,itemAttributes,item,entity,signalInfo)
                local success = false

                if signalInfo ~= nil then
                    world:spawnXPparticles(self:getValue(power,itemAttributes,item,entity),signalInfo.position:copy())
                    success = true
                end

                return success, signalInfo
            end,
        print = 
            function (self,itemAttributes,item,power,entity)
                return {"#muted",", drop ","#xp",self:getValue(power,itemAttributes,item,entity),"#xp"," xp"}
            end,
        getValue = 
            function (self,power,itemAttributes,item,entity)
                local value = ((power*100) ^ 0.7)/10
                value = round(value,100)

                return value
            end,
    })
    Enchants.dropCoin = ItemEnchantCard(2, 3, "dropCoin", "reaction", {}, {"any"}, nil, {"any"}, {
        use =
            function (self,power,itemAttributes,item,entity,signalInfo)
                local success = false

                if signalInfo ~= nil then
                    world:spawnCoinParticles(self:getValue(power,itemAttributes,item,entity),signalInfo.position:copy())
                    success = true
                end

                return success, signalInfo
            end,
        print = 
            function (self,itemAttributes,item,power,entity)
                return {"#muted",", drop ","#coin",self:getValue(power,itemAttributes,item,entity),"#coin"," coins"}
            end,
        getValue = 
            function (self,power,itemAttributes,item,entity)
                local value = ((power*100) ^ 0.4)/40
                value = round(value,100)

                return value
            end,
    })
    Enchants.dropBomb = ItemEnchantCard(4, 1, "dropBomb", "reaction", {}, {"any"}, nil, {"any"}, {
        use =
            function (self,power,itemAttributes,item,entity,signalInfo)
                local success = false

                if signalInfo ~= nil then
                    
                    Projectile("bomb",signalInfo.position:copy(), Vector2(0,12),"bomb",entity,{
                        name = item.name,
                        item = item,
                        attributes = itemAttributes,
                    }, {
                        animationType = "time",
                        knockback = 5,
                        gravity = 0.5,
                        bounceFactor = 0.95,
                        explodeDamage = self:getValue(power,itemAttributes,item,entity),
                        explodeRadius = self:getRadius(power,itemAttributes,item,entity),
                        explodeTimer = 6,
                        explodeTileDamage = self:getValue(power,itemAttributes,item,entity),
                    },true)
                    --world:spawnXPparticles(self:getValue(power,itemAttributes,item,entity),signalInfo.position:copy())
                    success = true
                end

                return success, signalInfo
            end,
        print = 
            function (self,itemAttributes,item,power,entity)
                return {"#muted",", drop a ","#enemy"," bomb","#muted"," that deals ","#damage",self:getValue(power,itemAttributes,item,entity),"#damage"," damage","#muted"," in a radius of ","#value",self:getRadius(power,itemAttributes,item,entity)}
            end,
        getRadius =
            function (self,power,itemAttributes,item,entity)
                local radius = 2 + ((power*100) ^ 0.5)/10
                radius = round(radius,10)

                return radius
            end,
        getValue = 
            function (self,power,itemAttributes,item,entity)
                local value = 1 + ((power*100) ^ 0.35)/7
                value = round(value,10)

                return value
            end,
    })

end


---@param cardType '"cause"'|'"condition"'|'"reaction"'
function ItemEnchantCard:init(cardCost,cardWeight,name,cardType,cardSubTypes,itemTypesFilter,creditMultiplier,biomes,flags)
    self.cardCost = cardCost or 1
    self.cardWeight = cardWeight or 10
    self.cardType = cardType or "reaction"
    self.cardSubTypes = cardSubTypes or {}
    self.itemTypesFilter = itemTypesFilter or {"any"}
    --any, tool, weapon, melee, ranged, armor, accessory
    self.biomes = biomes or {"any"}
    self.name = name or "none"
    
    self.creditMultiplier = creditMultiplier or 1
    --credit multiplier for the reaction enchantment, based on the cause and condition enchantments
    self.flags = CopyAll(flags) or {}
    self.itemNames = self.flags.itemNames or {"any"}

    self.previousCardFilter = self.flags.previousCardFilter or {}
    self.previousCardAntiFilter = self.flags.previousCardAntiFilter or {}

    self.print = 
    function (self,itemAttributes,item,power,entity)
        local printTable = {}
        printTable = {"#silent",self.cardType,"#muted"," Name: ","#info",self.name,"#muted"," Power: ","#danger",self:getValue(power,itemAttributes,item,entity)}
        return printTable
    end
    if self.flags.print ~= nil then
        self.print = self.flags.print
    end
    if self.flags.getRadius ~= nil then
        self.getRadius = self.flags.getRadius
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

        return accepted, signalInfo
    end
    if self.flags.checkSignal ~= nil then
        self.checkSignal = self.flags.checkSignal
    end
    
    self.checkCondition =
    function (self,power,itemAttributes,item,entity,signalInfo)
        local success = false

        return success, signalInfo
    end
    if self.flags.checkCondition ~= nil then
        self.checkCondition = self.flags.checkCondition
    end

    self.use =
    function (self,power,itemAttributes,item,entity,signalInfo)
        local success = false
        --local returnParameters = {}

        return success, signalInfo
    end
    if self.flags.use ~= nil then
        self.use = self.flags.use
    end
    
    

    table.insert(EnchantsList,self)
end

function enchantReceiveSignal(signalName,signalInfo,cause,condition,reaction,itemAttributes,item,entity)
    local success = false
    --local returnParameters = {}

    if cause ~= nil and condition ~= nil and reaction ~= nil then

        local accepted, signalInfo = cause.card:checkSignal(signalName,signalInfo,cause.power,itemAttributes,item,entity)
        if accepted then

            if condition.card:checkCondition(condition.power,itemAttributes,item,entity,signalInfo) then
                success, signalInfo = reaction.card:use(reaction.power,itemAttributes,item,entity,signalInfo)
            end

        end

    end

    return success, signalInfo
    
end

--functions :

--receiveSignal(signal)

--checkCondition()
--use()

--print()

--getValue() based on whatever enchant and credit used for the enchant, for example damage, it will give the value, example : 
    --increaseDamage.getValue(credit) -> returns the increased damage based on the credit used