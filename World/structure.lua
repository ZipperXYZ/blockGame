require "class/superClass"
Structure = SuperClass:extend()
Structure.className = "Structure"


function Structure:init(structureName,type,spawnType,spawnValue,spawnConditions,flags)
    self.name = structureName or "none"
    self.flags = flags or {}


    self.type = type or "none"

    if self.type == "unique" then
        
    end
    if self.type == "complex" then
        
    end
    if self.type == "special" then
        
    end


    self.spawnType = spawnType or "none"
    
    if self.spawnType == "chance" then
        self.spawnChance = spawnValue or 0.001
    end
    if self.spawnType == "definite amount" then
        self.spawnAmount = spawnValue or 1
    end

    
    self.spawnConditions = spawnConditions or {}
    self.spawnConditions.minY = self.spawnConditions.minY or 0
    self.spawnConditions.maxY = self.spawnConditions.maxY or 1000
    self.spawnConditions.biomes = self.spawnConditions.biomes or {"all"}
    self.spawnConditions.blocs = self.spawnConditions.blocs or {"every solid"}
    self.spawnConditions.checkAir = self.spawnConditions.checkAir or "above"
    self.spawnConditions.airNeededX = self.spawnConditions.airNeededX or 1
    self.spawnConditions.airNeededY = self.spawnConditions.airNeededY or 1

    self.afterSpawnOperations = self.flags.afterSpawnOperations or {}


end