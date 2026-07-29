require "class/superClass"
EntitySpawnDirector = SuperClass:extend()
EntitySpawnDirector.className = "EntitySpawnDirector"

function EntitySpawnDirector:init(startCredit,creditGain,spawnFrequency,cards,creditGainWaveTime,spawnFrequencyWaveTime,minCreditPerSpawn,maxCreditPerSpawn,maxCredit,maxCreditBank,decay,mobLimit)

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

    if cards == nil or cards == "all" then
        self.cards = CopyAll(GlobalEnemyCards)
    else
        self.cards = CopyAll(cards)
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
            self.credit = self.credit + dt * self.creditGain * math.sin(self.time/self.creditGainWaveTime/math.pi) * 2
        end
    end


    self.timeTillNextSpawn = self.timeTillNextSpawn + dt * math.sin(self.time/self.spawnFrequencyWaveTime/math.pi) * 2

    if self.credit > self.minCreditPerSpawn then
        if self.timeTillNextSpawn > self.spawnFrequency then
            if self:getEnemyFreeSpots() > 0 then
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

function EntitySpawnDirector:spawn()
    
end

function EntitySpawnDirector:rollCard(biome,cardType,minimumCost,maximumCost)
    
end