require "class/superClass"
Structure = SuperClass:extend()
Structure.className = "Structure"

local function pickDeterministic(values, seedValue)
    if type(values) ~= "table" or #values == 0 then
        return nil
    end

    local hash = math.sin((seedValue + 1) * 12.9898) * 43758.5453
    local fraction = hash - math.floor(hash)
    local index = math.floor(fraction * #values) + 1
    if index < 1 then index = 1 end
    if index > #values then index = #values end
    return values[index]
end


function Structure:init(structureName,type,id,spawnStep,spawnTries,spawnChance,maxSpawnTries,spawnConditions,data,flags)
    self.name = structureName or "none"
    self.flags = flags or {}

    self.id = id or 1

    self.sizeX = nil
    self.sizeY = nil
    self.data = data or nil


    self.type = type or "none"

    if self.type == "unique" then
        if self.data.structure.topTiles ~= nil then
            self.sizeX = #self.data.structure.tiles[1]
            self.sizeY = #self.data.structure.tiles
        end
        if self.data.structure.backTiles ~= nil then
            self.sizeX = #self.data.structure.tiles[1]
            self.sizeY = #self.data.structure.tiles
        end
        if self.data.structure.tiles ~= nil then
            self.sizeX = #self.data.structure.tiles[1]
            self.sizeY = #self.data.structure.tiles
        end
    end
    if self.type == "complex" then
        
    end
    if self.type == "special" then
        
    end



    --self.spawnType = spawnType or "none"
    self.spawnStep = spawnStep or 0.01
    self.spawnChance = spawnChance or 0.01
    self.spawnTries = spawnTries or 8
    self.maxSpawnTries = maxSpawnTries or 10



    

    --[[
    if self.spawnType == "chance" then
        
    end
    if self.spawnType == "definite amount" then
        self.spawnAmount = spawnValue or 1
    end]]

    
    self.spawnConditions = spawnConditions or {}
    self.spawnConditions.minY = self.spawnConditions.minY or 0
    self.spawnConditions.maxY = self.spawnConditions.maxY or 6
    self.spawnConditions.biomes = self.spawnConditions.biomes or {"all"}
    --self.spawnConditions.blocs = self.spawnConditions.blocs or {"every solid"}
    self.spawnConditions.needsGround = self.spawnConditions.needsGround or true
    self.spawnConditions.checkAir = self.spawnConditions.checkAir or "above"
    self.spawnConditions.airNeededX = self.spawnConditions.airNeededX or 1
    self.spawnConditions.airNeededY = self.spawnConditions.airNeededY or 1

    self.afterSpawnOperations = self.flags.afterSpawnOperations or {}


end

function Structure:forceSpawn(worldX,worldY)
    --print("required to force spawn structure "..self.name.." at "..worldX..","..worldY)
    local worldSeed = world.worldSeed
    local chunkX, chunkY, posInChunkX, posInChunkY = world:convertWorldPosToChunkPos(worldX, worldY)
    local actualSpawnx = worldX
    local actualSpawny = worldY
    local chunk = world:getChunk(chunkX, chunkY)
    local chunkWidth = world.chunkSize
    for i = 1, self.spawnTries do
            local spawned = false
            for try = 1, self.maxSpawnTries do
                if not spawned then
                   local x = math.ceil(noise(chunkX*1.5+try,chunkY*1.4-12000 - try * 100,worldSeed-5160+i*0.8, 100 + self.id)*chunkWidth)
                   local y = math.ceil(noise(chunkX*1.5+try,chunkY*1.4-6000 - try * 200,worldSeed-5360+i*0.8, 100 + self.id)*chunkWidth)
                   if self:getSpawnAvailability(chunkX,chunkY,x,y) then
                        spawned = true

                        actualSpawnx = chunkX * chunkWidth + x - 1
                        actualSpawny = chunkY * chunkWidth + y - 1
                   end
                end
            end
    end


    local structureData = {}

    structureData.x = actualSpawnx
    structureData.y = actualSpawny
    structureData.name = self.name
    structureData.structure = self
    structureData.chunkListGenerated = {}
    --structureData.forced = true
    structureData.seed = noise(chunkX,chunkY-800,worldSeed-9160,20 )

    table.insert(chunk.structures, structureData)
end

function Structure:attemptSpawn(chunk, chunkX,chunkY,chunkWidth, generationStep, stepList, worldSeed, depthProgression, biomeSize, biomeList, world)
    --print("attempting to spawn structure "..self.name.." at chunk "..chunkX..","..chunkY.." at step "..generationStep)
    for i = 1, self.spawnTries do
        if noise(chunkX*1.2+i*1.3,chunkY*1.2-10000,worldSeed-5860-i*1.6,100 + self.id) < self.spawnChance then
            local spawned = false
            for try = 1, self.maxSpawnTries do
                if not spawned then
                   local x = math.ceil(noise(chunkX*1.5+try,chunkY*1.4-12000 - try * 100,worldSeed-5160+i*0.8, 100 + self.id)*chunkWidth)
                   local y = math.ceil(noise(chunkX*1.5+try,chunkY*1.4-6000 - try * 200,worldSeed-5360+i*0.8, 100 + self.id)*chunkWidth)
                   if self:getSpawnAvailability(chunkX,chunkY,x,y) then
                        spawned = true

                        local structureData = {}

                        structureData.x = chunkX * chunkWidth + x - 1
                        structureData.y = chunkY * chunkWidth + y - 1
                        structureData.name = self.name
                        structureData.structure = self
                        structureData.chunkListGenerated = {}
                        structureData.seed = noise(chunkX,chunkY-800,worldSeed-9160-i,20 + try )

                        table.insert(chunk.structures, structureData)
                   end
                end
            end
            
        end
    end
end

function Structure:getSpawnAvailability(chunkX,chunkY,x,y)
    --return true
    local worldPosX, worldPosY = world:convertChunkPosToWorldPos(chunkX, chunkY, x, y)
    local biome = world:getBiome(worldPosX, worldPosY)
    if not checkifinlist(biome,self.spawnConditions.biomes) and not checkifinlist("all",self.spawnConditions.biomes) then
        return false
    end
    if self.spawnConditions.needsGround then
        
        

        if self.spawnConditions.checkAir == "above" then
            if tiles[world:generateTerrainTile(worldPosX,worldPosY-1)].type ~= "solid" then
                return false
            end

            for checkY = 0, self.spawnConditions.airNeededY - 1 do
                for checkX = -math.floor(self.spawnConditions.airNeededX/2), math.floor(self.spawnConditions.airNeededX/2) do
                    local worldPosX, worldPosY = world:convertChunkPosToWorldPos(chunkX, chunkY, x + checkX, y + checkY)
                    local blocInPlace = tiles[world:generateTerrainTile(worldPosX,worldPosY)]
                    if blocInPlace.type == "solid" then
                        return false
                    end
                end
            end
        end

        if self.spawnConditions.checkAir == "below" then
            if tiles[world:generateTerrainTile(worldPosX,worldPosY+1)].type ~= "solid" then
                return false
            end

            for checkY = 0, self.spawnConditions.airNeededY - 1 do
                for checkX = -math.floor(self.spawnConditions.airNeededX/2), math.floor(self.spawnConditions.airNeededX/2) do
                    local worldPosX, worldPosY = world:convertChunkPosToWorldPos(chunkX, chunkY, x + checkX, y - checkY)
                    local blocInPlace = tiles[world:generateTerrainTile(worldPosX,worldPosY)]
                    if blocInPlace.type == "solid" then
                        return false
                    end
                end
            end
        end

    end
    return true
end

function Structure:generate(chunk,centerWorldPosX,centerWorldPosY,seed,structureData)
    --print("generating structure "..self.name.." at "..centerWorldPosX..","..centerWorldPosY)
    local completed = true
    if self.type == "unique" then
        if structureData == nil then
            return false
        end
        for x = 1, self.sizeX do
            for y = 1, self.sizeY do
                local worldPosX = centerWorldPosX + x - self.data.center.x
                local worldPosY = centerWorldPosY + self.data.center.y - y
                local chunkX, chunkY, posInChunkX, posInChunkY = world:convertWorldPosToChunkPos(worldPosX, worldPosY)
                if not checkifinlist("cx"..chunkX.."cy"..chunkY,structureData.chunkListGenerated) then
                    if not self:chunkGenerate(chunk, chunkX, chunkY, seed, centerWorldPosX, centerWorldPosY, structureData) then
                        completed = false
                    end
                end
            end
        end
    end
    
    return completed
end

function Structure:chunkGenerate(chunk, chunkX, chunkY, seed, centerWorldPosX,centerWorldPosY, structureData)
    --print("generating structure chunk at "..chunkX..","..chunkY.." for structure "..self.name)
    if structureData ~= nil and structureData.forced or world:getNeighboringChunks(chunkX, chunkY, self.spawnStep) or self.spawnStep == "none" then
        for posInChunkX = 1, chunk.chunkSize do
            for posInChunkY = 1, chunk.chunkSize do
                local worldPosX = chunkX * chunk.chunkSize + posInChunkX - 1
                local worldPosY = chunkY * chunk.chunkSize + posInChunkY - 1
                -- position relative in the structure data
                local posInStructureX = (chunkX * chunk.chunkSize + posInChunkX - 1) - centerWorldPosX + self.data.center.x
                local posInStructureY = centerWorldPosY + self.data.center.y - (chunkY * chunk.chunkSize + posInChunkY - 1)
                if posInStructureX > 0 and posInStructureX <= self.sizeX and posInStructureY > 0 and posInStructureY <= self.sizeY then


                    if self.data.structure.tiles ~= nil then
                        local tileData = self.data.structure.tiles[posInStructureY][posInStructureX]
                        if tileData ~= nil then
                            local tileInfo = self.data.tileTable[tileData]
                            if tileInfo ~= nil then
                                local bloc = tileInfo.bloc
                                if bloc == nil and tileInfo.blocs ~= nil then
                                    local randomList = {}
                                    for j = 1, #tileInfo.blocs do
                                        for amount = 1,tileInfo.blocs[j]["weight"] do
                                            table.insert(randomList,tileInfo.blocs[j]["bloc"])
                                        end
                                    end
                                    bloc = pickDeterministic(randomList, seed + posInChunkX * 1000 + posInChunkY * 10000)
                                end
                                local blocInplace = world:getRawTile(worldPosX, worldPosY, "tiles")
                                local blocInPlaceType = tiles[world:generateTerrainTile(worldPosX, worldPosY)].type
                                if (tileInfo.replace == "all") or (blocInplace == "none" and tileInfo.replace == "air") or (tileInfo.replace == "solid" and blocInPlaceType == "solid") or (tileInfo.replace == blocInplace) then
                                    world:placeTile(bloc, worldPosX, worldPosY, "tiles", true, false)
                                end
                            end
                        end
                    end

                    if self.data.structure.topTiles ~= nil then
                        local tileData = self.data.structure.topTiles[posInStructureY][posInStructureX]
                        if tileData ~= nil then
                            local tileInfo = self.data.tileTable[tileData]
                            if tileInfo ~= nil then
                                local bloc = tileInfo.bloc
                                if bloc == nil and tileInfo.blocs ~= nil then
                                    local randomList = {}
                                    for j = 1, #tileInfo.blocs do
                                        for amount = 1,tileInfo.blocs[j]["weight"] do
                                            table.insert(randomList,tileInfo.blocs[j]["bloc"])
                                        end
                                    end
                                    bloc = pickDeterministic(randomList, seed + posInChunkX * 1000 + posInChunkY * 10000)
                                end
                                local blocInplace = world:getRawTile(worldPosX, worldPosY, "topTiles")
                                if (tileInfo.replace == "all") or (blocInplace == "none" and tileInfo.replace == "air") or (tileInfo.replace == "solid" and tiles[blocInplace].type == "solid") or (tileInfo.replace == blocInplace) then
                                    world:placeTile(bloc, worldPosX, worldPosY, "topTiles", true, false)
                                end
                            end
                        end
                    end

                    if self.data.structure.backTiles ~= nil then
                        local tileData = self.data.structure.backTiles[posInStructureY][posInStructureX]
                        if tileData ~= nil then
                            local tileInfo = self.data.tileTable[tileData]
                            if tileInfo ~= nil then
                                local bloc = tileInfo.bloc
                                if bloc == nil and tileInfo.blocs ~= nil then
                                    local randomList = {}
                                    for j = 1, #tileInfo.blocs do
                                        for amount = 1,tileInfo.blocs[j]["weight"] do
                                            table.insert(randomList,tileInfo.blocs[j]["bloc"])
                                        end
                                    end
                                    bloc = pickDeterministic(randomList, seed + posInChunkX * 1000 + posInChunkY * 10000)
                                end
                                local blocInplace = world:getRawTile(worldPosX, worldPosY, "backTiles")
                                if (tileInfo.replace == "all") or (blocInplace == "none" and tileInfo.replace == "air") or (tileInfo.replace == "solid" and tiles[blocInplace].type == "solid") or (tileInfo.replace == blocInplace) then
                                    world:placeTile(bloc, worldPosX, worldPosY, "backTiles", true, false)
                                end
                            end
                        end
                    end
                    

                end
            end
        end
        
        table.insert(structureData.chunkListGenerated,"cx"..chunkX.."cy"..chunkY)
                if chunk ~= nil then
                    chunk:updateNeighboringLights()
                end
        return true
    end

    return false
end