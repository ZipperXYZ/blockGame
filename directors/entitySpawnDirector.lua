require "class/superClass"
EntitySpawnDirector = SuperClass:extend()
EntitySpawnDirector.className = "EntitySpawnDirector"

function EntitySpawnDirector:init(position,spawnRadiusMax,spawnRadiusMin,startCredit,creditGain,spawnFrequency,cards,creditGainWaveTime,spawnFrequencyWaveTime,minCreditPerSpawn,maxCreditPerSpawn,maxCredit,maxCreditBank,decay,mobLimit,mobType)
    self.position = position or Vector2(0,0)
    self.spawnRadiusMax = spawnRadiusMax or 50
    self.spawnRadiusMin = spawnRadiusMin or 15
    self.startCredit = startCredit or 30
    self.minCreditPerSpawn = minCreditPerSpawn or 0
    self.maxCreditPerSpawn = maxCreditPerSpawn or 100
    self.maxCredit = maxCredit or 200
    self.maxCreditBank = maxCreditBank or 150
    self.creditGain = creditGain or 3
    self.spawnFrequency = spawnFrequency or 12
    self.decay = decay or 99999999
    self.mobLimit = mobLimit or 1
    self.creditGainWaveTime = creditGainWaveTime or 60
    self.spawnFrequencyWaveTime = spawnFrequencyWaveTime or 95
    self.mobType = mobType or "enemy"

    local sourceCards = cards
    if sourceCards == nil or sourceCards == "all" then
        sourceCards = GlobalEnemyCards
    end

    self.cards = {}
    if sourceCards ~= nil then
        for i = 1, #sourceCards do
            self.cards[i] = sourceCards[i]
        end
    end

    self.time = 0
    self.id = math.random()
    self.credit = self.startCredit
    self.timeTillNextSpawn = 0
    self.inactive = false

end

function EntitySpawnDirector:update(dt)

    self.time = self.time + dt

    if self.time > self.decay then
        self.inactive = true
    end

    if not self.inactive then
        if self.credit < self.maxCreditBank then
            if self.creditGainWaveTime > 0 then
                self.credit = self.credit + dt * self.creditGain * math.sin(self.time/self.creditGainWaveTime/math.pi) * 2
            else
                self.credit = self.credit + dt * self.creditGain
            end
            --self.credit = self.credit + dt * self.creditGain * math.sin(self.time/self.creditGainWaveTime/math.pi) * 2
        end
    end


    --self.spawnFrequencyWaveTime = 0
    if self.spawnFrequencyWaveTime > 0 then
        self.timeTillNextSpawn = self.timeTillNextSpawn + dt * math.sin(self.time/self.spawnFrequencyWaveTime/math.pi) * 2
    else
        self.timeTillNextSpawn = self.timeTillNextSpawn + dt
    end
    if self.timeTillNextSpawn > self.spawnFrequency + 1 then
        self.timeTillNextSpawn = self.spawnFrequency + 1
    end
    --self.timeTillNextSpawn = self.timeTillNextSpawn + dt * math.sin(self.time/self.spawnFrequencyWaveTime/math.pi) * 2

    if self.credit > self.minCreditPerSpawn and self.credit > 0 then
        if self.timeTillNextSpawn > self.spawnFrequency then
            if self:getEnemyFreeSpots() > 0  and (self.maxCredit - self:countAvailableCosts()) < self.maxCredit then
                self:spawn()
                self.timeTillNextSpawn = 0
            end
        end
    end
    
end

function EntitySpawnDirector:countAvailableCosts()
    local costs = self.maxCredit

    if #entities > 0 then
        for i = 1, #entities do
        
            if entities[i].directorId == self.id then
                costs = costs - entities[i].directorCost 
            end

        end
    end
    
    return costs
end

function EntitySpawnDirector:getEnemyFreeSpots()
    local count = 0 

    if #entities > 0 then
        for i = 1, #entities do
        
            if entities[i].directorId == self.id then
                count = count + 1
            end

        end
    end
    
    return self.mobLimit - count
end

function EntitySpawnDirector:print()
    --debug prints
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("Entity Spawn Director",0,0)
    love.graphics.print("ID : "..self.id,0,12)
    love.graphics.print("Time : "..self.time,0,24)
    love.graphics.print("Credit : "..self.credit,0,36)
    love.graphics.print("Time till next spawn : "..self.timeTillNextSpawn,0,48)
    --love.graphics.print("Available costs : "..self:countAvailableCosts(),0,60)
    --love.graphics.print("Free spots : "..self:getEnemyFreeSpots(),0,72)
    love.graphics.print("credit gain : "..self.creditGain,0,84)
    love.graphics.print("spawn frequency : "..self.spawnFrequency,0,96)
    --love.graphics.print("Actual credit gain : "..(self.creditGain * math.sin(self.time/self.creditGainWaveTime/math.pi) * 2),0,108)
    --love.graphics.print("Actual spawn frequency : "..(self.spawnFrequency * math.sin(self.time/self.spawnFrequencyWaveTime/math.pi) * 2),0,120)
    --love.graphics.print("position : "..self.position.x..","..self.position.y,0,132)
    --love.graphics.print("Inactive : "..tostring(self.inactive),0,144)
    love.graphics.print("minimum credit per spawn : "..self.minCreditPerSpawn,0,156)
    love.graphics.print("maximum credit per spawn : "..self.maxCreditPerSpawn,0,168)
    love.graphics.print("maximum credit : "..self.maxCredit,0,180)
    love.graphics.print("maximum credit bank : "..self.maxCreditBank,0,192)
    --love.graphics.print("decay : "..self.decay,0,204)
    --love.graphics.print("mob limit : "..self.mobLimit,0,216)
    love.graphics.print("mob limit : "..(self.mobLimit-self:getEnemyFreeSpots()).." / "..self.mobLimit,0,216)
    love.graphics.print("credit use : "..(self.maxCredit - self:countAvailableCosts()).." / "..self.maxCredit,0,228)
    --love.graphics.print("credit gain wave time : "..self.creditGainWaveTime,0,228)
    --love.graphics.print("spawn frequency wave time : "..self.spawnFrequencyWaveTime,0,240)
    --love.graphics.print("Cards : "..#self.cards,0,252)
    --love.graphics.print("Cards : ",0,264)
    --for i = 1, #self.cards do
    --    love.graphics.print("Card "..i.." : "..self.cards[i].name,0,264 + i * 12)
    --end
    love.graphics.print("Available cards : "..#self:getAllAvailableCards(self.cards,world:getBiome(self.position.x,self.position.y),self.mobType,self.minCreditPerSpawn,math.max(self.maxCreditPerSpawn,self:countAvailableCosts())),0,252)
    love.graphics.print("Available cards : ",0,264)
    local cards = self:getAllAvailableCards(self.cards,world:getBiome(self.position.x,self.position.y),self.mobType,self.minCreditPerSpawn,math.max(self.maxCreditPerSpawn,self:countAvailableCosts()))
    if # cards > 0 then
        for i = 1, #cards do
            love.graphics.print("Card "..i.." : "..cards[i].name,0,264 + i * 12)
        end
    else
        love.graphics.print("No available cards",0,264)
    end
end

function EntitySpawnDirector:spawn(mobType)
    local mobType = mobType or self.mobType
    local biome = world:getBiome(self.position.x,self.position.y)
    local availableCards = self:getAllAvailableCards(self.cards,biome,mobType,self.minCreditPerSpawn,math.max(self.maxCreditPerSpawn,self:countAvailableCosts()))
    local card,amount,costPerCard = self:rollCard(availableCards,mobType,self.minCreditPerSpawn,math.max(self.maxCreditPerSpawn,self:countAvailableCosts()),1,5)

    if card ~= nil then
        --self.credit = self.credit - card.cardCost
        for i = 1, amount do
            local spawnPosition = self:findSpawnPosition(0,50)
            if spawnPosition ~= nil then
                card:use(spawnPosition,world:getEnvironmentLevel(spawnPosition.y),self.id,costPerCard,mobType)
            end
        end
    end
end

function EntitySpawnDirector:findSpawnPosition(tries,maxTries)
    maxTries = maxTries or 50
    local angle = math.random() * 2 * math.pi
    local radius = math.random(self.spawnRadiusMin, self.spawnRadiusMax)
    local spawnPosition = self.position:copy()
    spawnPosition.x = round(spawnPosition.x + math.cos(angle) * radius)
    spawnPosition.y = round(spawnPosition.y + math.sin(angle) * radius)
    if not world:checkSpawnValidity(spawnPosition) then
        if tries + 1 >= maxTries then
            return nil
        end
        return self:findSpawnPosition(tries + 1, maxTries)
    end

    return spawnPosition
end

function EntitySpawnDirector:rollCard(cards,cardType,minimumCost,maximumCost,minimumSpawnAmount,maximumSpawnAmount)
    --get a random card, based on the weights of the cards, and return it
    local cardPool = {}
    local chosenCard = nil
    local amount = 1
    local cardCost = 1

    if #cards > 0 then
        for i = 1, #cards do
            if cards[i].cardCost >= minimumCost and cards[i].cardCost * minimumSpawnAmount <= maximumCost then
                for j = 1, cards[i].cardWeight do
                    table.insert(cardPool, cards[i])
                end
            end
        end
        chosenCard = cardPool[math.random(1,#cardPool)]
    end

    if chosenCard ~= nil then
        cardCost = chosenCard.cardCost
        local maxAmount = math.min(math.floor(maximumCost / cardCost),maximumSpawnAmount)
        local minAmount = math.max(minimumSpawnAmount,1)
        amount = round(math.random(minAmount,maxAmount))
       self.credit = self.credit - cardCost * amount
    end

    return chosenCard, amount, cardCost
end

function EntitySpawnDirector:getAllAvailableCards(cards,biome,cardType,minimumCost,maximumCost)
    local validCards = {}
    if #cards > 0 then
        for i = 1, #cards do
            if (checkifinlist(biome,cards[i].biomes) or checkifinlist("any",cards[i].biomes)) and cards[i].cardType == cardType and cards[i].cardCost >= minimumCost and cards[i].cardCost <= maximumCost then
                table.insert(validCards, cards[i])
            end
        end
    end
    return validCards
end