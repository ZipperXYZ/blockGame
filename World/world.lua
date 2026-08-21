require "class/superClass"
World = SuperClass:extend()
World.className = "World"


--local stepOrder = { "none", "stone", "stone2", "grass", "ores", "deco", "done" }
--local stepIndex = {}
--for i, s in ipairs(stepOrder) do stepIndex[s] = i end


--new(worldseed,depthProgression,biomeSize,biomeList,generationSteps) --Biomelist peut être empty,
--  depthProgression correspond au nombre de blocs
--  par progression du monde, comme par exemple, mettre 100 feras en sorte que des enemies vont commencer à spawn à y-100, d'autres à -200 et ça s'applique
--  sur tout genre les mobs, les ores, les tiles, les biomes, les structures etc.
function World:init(worldSeed, chunkSize, depthProgression, biomeSize, biomeList, generationSteps, parameters)
    self.worldSeed = worldSeed or math.random() * 100000
    self.depthProgression = depthProgression or 100
    self.biomeSize = biomeSize or 150
    self.chunkSize = chunkSize or 10
    self.biomeList = biomeList or {}
    self.generationSteps = generationSteps or {}
    self.generationStepIndex = {}
    for i = 1, #self.generationSteps do
        self.generationStepIndex[self.generationSteps[i]] = i
    end
    self.generationSpiralState = nil
    self.chunks = {}
    self.groundItems = {}
    self.particles = {}
    self.textParticles = {}
    self.projectiles = {}

    self.globalDirector = EntitySpawnDirector(Vector2(0,0),50,15,50,3,12,nil,60,95,0,100,200,150,999999999,40)
    self.directors = {}

    self.parameters = parameters or {}
    self.borderX = self.parameters.borderX or 0
    self.loopX = self.parameters.loopX or (self.borderX*1.4)
    self.borderY = self.parameters.borderY or 0
    self.hasBorder = self.parameters.hasBorder or (self.borderX ~= 0)
    self.caveSize = 1.5
    self.time = 0
    if self.parameters.caveSize ~= nil then self.caveSize = self.parameters.caveSize * 1.5 end
    self.directorCreditMultiplier = self.parameters.directorCreditMultiplier or 1
    self.directorSpawnSpeedMultiplier = self.parameters.directorSpawnSpeedMultiplier or 1


    self.mobCap = self.parameters.mobCap or 20

    self.fogActivated = self.parameters.fogActivated or true
    self.itemAttributesMultiplier = self.parameters.itemAttributesMultiplier or 1
    if self.itemAttributesMultiplier == nil then self.itemAttributesMultiplier = 1 end
    self.playerFogDistance = self.parameters.playerFogDistance or 50
    self.playerFog = self.parameters.playerFog or false
    self.currentFogLayer = self.parameters.currentFogLayer or 1
    self.fogViewDistance = self.parameters.fogViewDistance or 6
    self.generationFocusRadius = self.parameters.generationFocusRadius or 4
    self.maxNearChunkStepPasses = self.parameters.maxNearChunkStepPasses or 6
    self.generationTimeBudgetMs = self.parameters.generationTimeBudgetMs or 3.5
    self.farGenerationAttemptRatio = self.parameters.farGenerationAttemptRatio or 0.04
    self.maxFarStepAttemptsPerFrame = self.parameters.maxFarStepAttemptsPerFrame or 2
    self.nonPlayerControlsUpdateInterval = self.parameters.nonPlayerControlsUpdateInterval or 0.05
    self.nonPlayerInventoryUpdateInterval = self.parameters.nonPlayerInventoryUpdateInterval or 0.15
    self.playerInventoryUpdateInterval = self.parameters.playerInventoryUpdateInterval or 0.02
    self.nearGenerationComplete = false
    self.nearGenerationCenterX = nil
    self.nearGenerationCenterY = nil
    self.nearGenerationRadius = nil

    self:placeMainStructures()

    --self.barList = {}
end

--clear() -- vide le monde de tout ses chunks, gardant toutes ses propriétés les mêmes
function World:clear()
    self.chunks = {}
    self.groundItems = {}
    self.particles = {}
    self.generationSpiralState = nil
    self.nearGenerationComplete = false
    self.nearGenerationCenterX = nil
    self.nearGenerationCenterY = nil
    self.nearGenerationRadius = nil
    entities = {}
    spectator = true
end

function World:clearBiomes()
    self.biomeList = {}
end

function World:placeMainStructures()
    self.mainStructureList = {}
    local structureMultipler = minimum(math.ceil(self.borderX/150), 1) *1
    local structureMultipler = 2
    self:placeMainStrucure("dungeon1","dungeon",0,self.borderX*0.5,-((self.borderY/6)*(1-0.35)),self.borderY/12/3,structureMultipler,155,90)
    self:placeMainStrucure("dungeon1","dungeon",0,self.borderX*0.44,-((self.borderY/6)*(2-0.35)),self.borderY/12/3,structureMultipler,140,90)
    self:placeMainStrucure("dungeon1","dungeon",0,self.borderX*0.4,-((self.borderY/6)*(3-0.35)),self.borderY/12/3,structureMultipler,130,90)
    self:placeMainStrucure("dungeon1","dungeon",0,self.borderX*0.35,-((self.borderY/6)*(4-0.35)),self.borderY/12/3,structureMultipler,190,90)
    self:placeMainStrucure("dungeon1","dungeon",0,self.borderX*0.25,-((self.borderY/6)*(5-0.35)),self.borderY/12/3,structureMultipler,180,90)
    
    self:placeMainStrucure("dungeon1","dungeon",0,0,-((self.borderY/6)*(6-0.05)),0,1,110,0)
    --self:placeMainStrucure("dungeon1",0,self.borderX/2,-((self.borderY/6)*(6-0.25)),self.borderY/12/3,3,155)
end

function World:getClosestMainStructure(structureType, worldPosX, worldPosY)
    local closestStructure = nil
    local closestDistance = 9999999999
    local position = Vector2(0, 0)
    worldPosX = self:xLoop(worldPosX)
    local found = false
    for i = 1, #self.mainStructureList do
        local structure = self.mainStructureList[i]
        if structure.type == structureType then
            local distance = dist(worldPosX, worldPosY, structure.x, structure.y)
            if closestDistance == nil or distance < closestDistance then
                closestDistance = distance
                closestStructure = structure
                position = Vector2(structure.x, structure.y)
                found = true
            end
        end
    end
    return found, closestStructure, closestDistance, position
end

function World:xLoop(worldPosX)
    return math.abs((((worldPosX+world.loopX/2)%world.loopX)-world.loopX/2)*2)
end

function World:placeMainStrucure(structureName,structureType,x,xrange,y,yrange,amount,noiseValue,minimumDistanceFromOtherMainStructures)
    structureType = structureType or "none"
    local placed = 0
    local tryIndex = 0
    local maxTries = math.max(amount * 20, amount)

    while placed < amount and tryIndex < maxTries do
        tryIndex = tryIndex + 1
        local structureX = round(x - xrange + xrange*2*noise(noiseValue, self.worldSeed,-13.432563 * tryIndex))
        local structureY = round(y - yrange + yrange*2*noise(-noiseValue, self.worldSeed, 13.53432 * tryIndex))
        local canPlace = true

        if minimumDistanceFromOtherMainStructures ~= nil then
            for j = 1, #self.mainStructureList do
                local otherStructure = self.mainStructureList[j]
                local distance = math.sqrt((structureX - otherStructure.x)^2 + (structureY - otherStructure.y)^2)
                if distance < minimumDistanceFromOtherMainStructures then
                    canPlace = false
                    break
                end
            end
        end

        if canPlace then
            local structure = {}
            structure.name = structureName
            structure.structure = structureName
            structure.type = structureType
            structure.x = structureX
            structure.y = structureY

            table.insert(self.mainStructureList,structure)
            placed = placed + 1
        end

    end
end

--convertWorldPosToChunkPos(worldPosX,worldPosY) --return ChunkX,ChunkY,posInChunkX,posInChunkY
function World:convertWorldPosToChunkPos(worldPosX, worldPosY)
    local ChunkX, ChunkY, posInChunkX, posInChunkY
    worldPosX = round(worldPosX)
    worldPosY = round(worldPosY)
    ChunkX = math.floor(worldPosX / self.chunkSize)
    ChunkY = math.floor(worldPosY / self.chunkSize)
    posInChunkX = ((worldPosX) % self.chunkSize) + 1
    posInChunkY = ((worldPosY) % self.chunkSize) + 1
    return ChunkX, ChunkY, posInChunkX, posInChunkY
end

--convertChunkPosToWorldPos(ChunkX,ChunkY,posInChunkX,posInChunkY) --return worldPosX,worldPosY
function World:convertChunkPosToWorldPos(ChunkX, ChunkY, posInChunkX, posInChunkY)
    local worldPosX, worldPosY
    worldPosX = ChunkX * self.chunkSize + posInChunkX - 1
    worldPosY = ChunkY * self.chunkSize + posInChunkY - 1
    return worldPosX, worldPosY
end

--getNeighboringChunks(chunkX,chunkY) --return une liste de chunk,
--à refaire puisque tu ne peux pas avoir la position globale avec juste une liste de chunks, serait inutile
--peut être retourne la liste de coordonées de chaque chunks et les utilisés de cette façon?
function World:getNeighboringChunks(chunkX, chunkY, step)
    local stepIndex = self.generationStepIndex[step]
    if stepIndex == nil then return false end
    if stepIndex <= 1 then return true end

    local requiredStepIndex = stepIndex - 1

    local neighbors = {
        { chunkX + 1, chunkY + 1 }, { chunkX + 1, chunkY }, { chunkX + 1, chunkY - 1 },
        { chunkX,     chunkY - 1 }, { chunkX - 1, chunkY - 1 }, { chunkX - 1, chunkY },
        { chunkX - 1, chunkY + 1 }, { chunkX, chunkY + 1 }
    }

    for _, n in ipairs(neighbors) do
        local nx, ny = n[1], n[2]
        if not self:checkIfChunkExists(nx, ny) then return false end
        local neighborStatus = self.chunks[nx][ny]:getGenerationStatus()
        local neighborStepIndex = self.generationStepIndex[neighborStatus] or 0
        -- le voisin doit avoir complété au moins l'étape précédente
        if neighborStepIndex < requiredStepIndex then return false end
    end
    return true
end

--checkIfChunkCanGenerate(step) --return true/false, regarde tout les chunks autour pour savoir si il peut générer à une certaine étape
--nomralement ça devrait généréer si tout les chunks autour ont finit l'étape précédante
--je sais pas trop comment comparer les étapes de génération de chunk, peut être une liste de toutes les étapes en paramètre du monde
function World:checkIfChunkCanGenerate(step, chunkX, chunkY)
    return false --pas fini
end

function World:checkIfChunkExists(chunkX, chunkY)
    chunkX = round(chunkX)
    chunkY = round(chunkY)
    if self.chunks == nil then return false end
    if self.chunks[chunkX] == nil then return false end
    if self.chunks[chunkX][chunkY] == nil then return false end
    return true
end

--placeTile(tile,worldPosX,worldPosY,layer,force) --return true/false si ça l'a marcher, force activé pour la genération du monde, force désactivé pour le joueur
----peut être placer une tile fait aussi un updateLight(?)
---
function World:getChunk(chunkX, chunkY)
    if self:checkIfChunkExists(chunkX, chunkY) then
        return self.chunks[chunkX][chunkY]
    end
    return nil
end
function World:placeTile(tile, worldPosX, worldPosY, layer, force,updateLight)
    local chunkX, chunkY, posX, posY = self:convertWorldPosToChunkPos(worldPosX, worldPosY)
    local placeSuccess = false
    if self:checkIfChunkExists(chunkX, chunkY) then
        placeSuccess = self.chunks[chunkX][chunkY]:placeTile(tile, posX, posY, layer, force,updateLight)
    end
    return placeSuccess
end

--destroyTile(worldPosX,worldPosY,layer) --supprime une tile pour laisser 'none' à la place, supprimer aussi certaines properties
function World:destroyTile(worldPosX, worldPosY, layer,updateLight)
    self:placeTile("none", worldPosX, worldPosY, layer, true,updateLight)
    return true
end

--getTile(worldPosX,worldPosY,layer) --return un objet tile (à définir si ça le donne dans un tableau, avec les autres information
--uniques qui sont nécessaires pour mettons l'information unique à une tile, comme son orientation, peut être un getTilePropreties
--qui retourne les propriétés et setTilePropriety(propriety, value) qui set une propriété de la tile, comme l'inventaire d'un
--coffre ou l'orientation d'un bloc)

function World:getBiome(worldPosX, worldPosY)
    local biome = "none"
    local nearCenter = 0.5

    local chunkX, chunkY, posX, posY = self:convertWorldPosToChunkPos(worldPosX, worldPosY)
    if self:checkIfChunkExists(chunkX, chunkY) then
        biome, nearCenter = self.chunks[chunkX][chunkY]:getBiome(worldPosX, worldPosY, self.worldSeed,
            self.depthProgression, self.biomeSize, self.biomeList)
    else
        local temporaryChunk = Chunk(chunkX, chunkY, 1)
        biome, nearCenter = temporaryChunk:getBiome(worldPosX, worldPosY, self.worldSeed, self.depthProgression,
            self.biomeSize, self.biomeList)
    end
    return biome, nearCenter
end

function World:getTile(worldPosX, worldPosY, layer)
    local tile = tiles["none"]

    local chunkX, chunkY, posX, posY = self:convertWorldPosToChunkPos(worldPosX, worldPosY)
    if self:checkIfChunkExists(chunkX, chunkY) then
        tile = self.chunks[chunkX][chunkY]:getTile(posX, posY, layer)
    end
    return tile
end

function World:addChangedTile(tileInfo)
    local chunkX, chunkY, posX, posY = self:convertWorldPosToChunkPos(tileInfo.x, tileInfo.y)
    tileInfo.chunkX = posX
    tileInfo.chunkY = posY
    if self:checkIfChunkExists(chunkX, chunkY) then
        return self.chunks[chunkX][chunkY]:addChangedTile(tileInfo)
    end
    return nil
end

function World:getChangedTile(worldPosX, worldPosY)
    local chunkX, chunkY, posX, posY = self:convertWorldPosToChunkPos(worldPosX, worldPosY)
    if self:checkIfChunkExists(chunkX, chunkY) then
        return self.chunks[chunkX][chunkY]:getChangedTile(posX, posY)
    end
    return nil
end

function World:getRawTile(worldPosX, worldPosY, layer)
    local tile = "none"

    local chunkX, chunkY, posX, posY = self:convertWorldPosToChunkPos(worldPosX, worldPosY)
    if self:checkIfChunkExists(chunkX, chunkY) then
        tile = self.chunks[chunkX][chunkY]:getRawTile(posX, posY, layer)
    end
    return tile
end

--getTilePropreties(worldPosX,worldPosY) --retourne une liste, il n'y a pas de layer pour les propriétés, cela peut être mélangeant mais est bcp plus simple

function World:getTileProprety(worldPosX, worldPosY, property)
    local value = 0
    local chunkX, chunkY, posX, posY = self:convertWorldPosToChunkPos(worldPosX, worldPosY)

    if self:checkIfChunkExists(chunkX, chunkY) then
        value = self.chunks[chunkX][chunkY]:getTileProperty(posX, posY, property)
    end

    return value
end

--setTilePropriety(worldPosX,worldPosY,propriety, value)
function World:setTileProprety(worldPosX, worldPosY, property, value)
    local success = false
    local chunkX, chunkY, posX, posY = self:convertWorldPosToChunkPos(worldPosX, worldPosY)

    if self:checkIfChunkExists(chunkX, chunkY) then
        success = self.chunks[chunkX][chunkY]:setTileProperty(posX, posY, property, value)
    end

    return success
end

function World:tilePropretyAdd(worldPosX, worldPosY, property, value)
    local success = false
    local chunkX, chunkY, posX, posY = self:convertWorldPosToChunkPos(worldPosX, worldPosY)

    if self:checkIfChunkExists(chunkX, chunkY) then
        success = self.chunks[chunkX][chunkY]:setTileProperty(posX, posY, property, (self:getTileProprety(worldPosX, worldPosY, property)) + value)
    end

    return success
end

function World:doesTilePropretyExists(worldPosX, worldPosY, property)
    local exists = false
    local chunkX, chunkY, posX, posY = self:convertWorldPosToChunkPos(worldPosX, worldPosY)

    if self:checkIfChunkExists(chunkX, chunkY) then
        exists = self.chunks[chunkX][chunkY]:DoesTilePropertyExists(posX, posY, property)
    end

    return exists
end

--clearTileProprieties(worldPosX,worldPosY)
function World:clearTileProprerties(worldPosX, worldPosY, property)
    local success = false
    local chunkX, chunkY, posX, posY = self:convertWorldPosToChunkPos(worldPosX, worldPosY)

    if self:checkIfChunkExists(chunkX, chunkY) then
        success = self.chunks[chunkX][chunkY]:clearTileProprerties(posX, posY, property)
    end

    return success
end

function World:damageBlock(worldPosX, worldPosY, damage,layer,destroyTopAsWell,damageSourceInfo)
    local destroyed = false
    --local returnInfo = {}

    if layer == nil then layer = "tiles" end
    if destroyTopAsWell == nil then destroyTopAsWell = true end
    if layer == "top" then layer = "topTiles" end
    if layer == "back" then layer = "backTiles" end

    if damageSourceInfo ~= nil then
        if damageSourceInfo.item ~= nil and damageSourceInfo.entity ~= nil then
            damageSourceInfo.signalInfo.position = Vector2(worldPosX, worldPosY)
            damageSourceInfo.signalInfo = damageSourceInfo.entity:applyEnchantSignal("damagingTile",damageSourceInfo.signalInfo,damageSourceInfo.item,damageSourceInfo.attributes)
            if damageSourceInfo.signalInfo.mineDamageValue ~= nil then
                damage = damageSourceInfo.signalInfo.mineDamageValue
            end
        end
    end

    if self:doesTilePropretyExists(worldPosX, worldPosY, "health"..layer) then
        self:tilePropretyAdd(worldPosX, worldPosY, "health"..layer, -damage)
        self:setTileProprety(worldPosX, worldPosY, "healthMineTimer"..layer, 5)
    else
        self:setTileProprety(worldPosX, worldPosY, "health"..layer, self:getDefaultTileHealth(worldPosX, worldPosY, layer))
        self:tilePropretyAdd(worldPosX, worldPosY, "health"..layer, -damage)
        self:setTileProprety(worldPosX, worldPosY, "healthMineTimer"..layer, 5)
    end


    world:spawnTextParticle((round(damage*10)/10).."",Vector2(worldPosX,worldPosY))

    local tile = self:getTile(worldPosX, worldPosY,layer)

    self:spawnParticles(5,"stoneDust",Vector2(worldPosX, worldPosY),0.5,
        {tile.particleColor[1],tile.particleColor[2],tile.particleColor[3],tile.particleColor[4]}
        , {0.05,0.05,0.05,0.5}, 1, 3,tile.particleType, 5, 0, 360, {})


    self:setTileProprety(worldPosX,worldPosY,"size",1.35)

    if self:doesTilePropretyExists(worldPosX, worldPosY, "health"..layer) and self:getTileProprety(worldPosX, worldPosY,"health"..layer)<=0 then
        destroyed = true
        self:destroyTile(worldPosX, worldPosY,layer,false)
        self:clearTileProprerties(worldPosX, worldPosY,"health"..layer)
        self:clearTileProprerties(worldPosX, worldPosY,"healthMineTimer"..layer)
        if damageSourceInfo ~= nil then
            if damageSourceInfo.item ~= nil and damageSourceInfo.entity ~= nil then
                damageSourceInfo.signalInfo.position = Vector2(worldPosX, worldPosY)
                damageSourceInfo.signalInfo = damageSourceInfo.entity:applyEnchantSignal("breakingTile",damageSourceInfo.signalInfo,damageSourceInfo.item,damageSourceInfo.attributes)
            end
        end


        tile:tileDestroyed(worldPosX, worldPosY)
        if layer == "tiles" and destroyTopAsWell then 
            self:destroyTile(worldPosX, worldPosY,"topTiles",false)
            self:clearTileProprerties(worldPosX, worldPosY,"health".."topTiles")
            self:clearTileProprerties(worldPosX, worldPosY,"healthMineTimer".."topTiles")
            tile:tileDestroyed(worldPosX, worldPosY)
        end
    end
    
    return destroyed, damageSourceInfo
end

function World:getDefaultTileHealth(worldPosX, worldPosY, layer)
    local health = 1
    local tile = self:getTile(worldPosX, worldPosY, layer)
    if tile ~= nil and tile.health ~= nil then
        health = tile.health
    end

    local level = self:getEnvironmentLevel(worldPosY)
    health = health + (health * 0.2 * level)

    return health -- default health if not specified
end

--generate(centerX,centerY,length,heigth,biomeList, boolean: force, step) --génére (ou essaille) de générer tout les chunks à l'écran, ou de progresser la génération
--force va forcer jusqu'à ce que tout les chunks sont au minimum au step
--devrait être éxécuter chaque seconde à la position de la caméra ainsi que avec force=false
--pour la gen des structure, force=true pis la taille de la structure
function World:generate(centerX, centerY, length, heigth, force, steps)
    if steps == nil then steps = self.generationSteps end
    centerX = round(centerX)
    centerY = round(centerY)
    --debugtimeclear("sub")

    local maxChunksPerFrame = MaxChunkLoadedPerFrame or 1
    local stepAttempts = 0
    local maxStepAttemptsPerFrame = maxChunksPerFrame * 18
    if self.maxChunkStepAttemptsPerFrame ~= nil then
        maxStepAttemptsPerFrame = self.maxChunkStepAttemptsPerFrame
    elseif self.maxChunkChecksPerFrame ~= nil then
        maxStepAttemptsPerFrame = self.maxChunkChecksPerFrame
    end
    if maxStepAttemptsPerFrame < (maxChunksPerFrame * 4) then
        maxStepAttemptsPerFrame = maxChunksPerFrame * 4
    end
    local nearRadius = math.min(self.generationFocusRadius or 3, math.max(length, heigth))
    local nearPasses = self.maxNearChunkStepPasses or 6

    local hasTimer = love ~= nil and love.timer ~= nil and love.timer.getTime ~= nil
    local startTime = hasTimer and love.timer.getTime() or 0
    local budgetSeconds = (self.generationTimeBudgetMs or 3.5) / 1000

    local farGuaranteedAttempts = 0
    local farRatio = self.farGenerationAttemptRatio or 0.08
    if farRatio < 0 then farRatio = 0 end
    if farRatio > 0.5 then farRatio = 0.5 end
    if maxStepAttemptsPerFrame > 6 then
        farGuaranteedAttempts = math.max(1, math.floor(maxStepAttemptsPerFrame * farRatio))
    end
    local nearAttemptBudget = maxStepAttemptsPerFrame - farGuaranteedAttempts

    local nearTimeBudgetSeconds = budgetSeconds
    if budgetSeconds > 0 then
        nearTimeBudgetSeconds = budgetSeconds * 0.65
    end

    local phaseAttemptLimit = nil
    local phaseTimeLimit = nil
    local maxFarScanIterations = maxStepAttemptsPerFrame * 8

    local function outOfBudget()
        if phaseAttemptLimit ~= nil and stepAttempts >= phaseAttemptLimit then return true end
        if stepAttempts >= maxStepAttemptsPerFrame then return true end
        if hasTimer and phaseTimeLimit ~= nil and love.timer.getTime() >= phaseTimeLimit then return true end
        if hasTimer and (love.timer.getTime() - startTime) >= budgetSeconds then return true end
        return false
    end

    local function processChunk(chunkX, chunkY, stepPasses)
        if outOfBudget() then return false end
        if math.abs(chunkX - centerX) > length or math.abs(chunkY - centerY) > heigth then return false end

        if self:checkIfChunkExists(chunkX, chunkY) then
            local existingChunk = self.chunks[chunkX][chunkY]
            local attemptedStructureGeneration = self.chunks[chunkX][chunkY]:updateStructureGeneration() --debugtimelog("updateStructureGeneration","sub")
            if attemptedStructureGeneration then
                if outOfBudget() then return false end
            end

            -- Do not burn generation attempts on chunks that are already fully generated.
            if existingChunk:getGenerationStatus() == "done" then
                return true
            end
        end

        for _ = 1, stepPasses do
            if outOfBudget() then return false end
            stepAttempts = stepAttempts + 1
            local generated, stepDone = self:generateChunk(chunkX, chunkY, force, steps) --debugtimelog("generateChunk","sub")
            local generationStep = self.chunks[chunkX][chunkY]:getGenerationStatus()
            if stepDone then
                AttemptAllStructureGenerations(self.chunks[chunkX][chunkY], chunkX, chunkY, self.chunkSize, generationStep, self.generationSteps, self.worldSeed, self.depthProgression, self.biomeList, self.biomeList, self)
                --debugtimelog("AttemptAllStructureGenerations","sub")
            end

            if generationStep == "done" then
                return true
            end

            -- Chunk cannot currently advance further (usually waiting for neighbors).
            if not generated and not stepDone then
                return false
            end
        end

        if self:checkIfChunkExists(chunkX, chunkY) then
            return self.chunks[chunkX][chunkY]:getGenerationStatus() == "done"
        end
        return false
    end

    if self.generationSpiralState == nil then
        self.generationSpiralState = {
            x = 0,
            y = 0,
            dx = 1,
            dy = 0,
            legLength = 1,
            stepsInLeg = 0,
            legsDone = 0,
            radius = math.max(length, heigth)
        }
    end

    local spiral = self.generationSpiralState
    local currentRadius = math.max(length, heigth)
    if spiral.radius ~= currentRadius then
        spiral.x = 0
        spiral.y = 0
        spiral.dx = 1
        spiral.dy = 0
        spiral.legLength = 1
        spiral.stepsInLeg = 0
        spiral.legsDone = 0
        spiral.radius = currentRadius
    end

    local function runFarPhase()
        local farScanIterations = 0
        while (not outOfBudget()) and (farScanIterations < maxFarScanIterations) do
            farScanIterations = farScanIterations + 1
            spiral.x = spiral.x + spiral.dx
            spiral.y = spiral.y + spiral.dy
            spiral.stepsInLeg = spiral.stepsInLeg + 1

            if spiral.stepsInLeg >= spiral.legLength then
                spiral.stepsInLeg = 0
                spiral.dx, spiral.dy = -spiral.dy, spiral.dx
                spiral.legsDone = spiral.legsDone + 1
                if spiral.legsDone % 2 == 0 then
                    spiral.legLength = spiral.legLength + 1
                end
            end

            if math.max(math.abs(spiral.x), math.abs(spiral.y)) > spiral.radius then
                spiral.x = 0
                spiral.y = 0
                spiral.dx = 1
                spiral.dy = 0
                spiral.legLength = 1
                spiral.stepsInLeg = 0
                spiral.legsDone = 0
            elseif math.abs(spiral.x) <= length and math.abs(spiral.y) <= heigth then
                local dist = math.max(math.abs(spiral.x), math.abs(spiral.y))
                if dist > nearRadius then
                    processChunk(centerX + spiral.x, centerY + spiral.y, 1)
                end
            end
        end
    end

    -- Guaranteed far generation first so distant chunks always progress.
    if farGuaranteedAttempts > 0 then
        phaseAttemptLimit = stepAttempts + farGuaranteedAttempts
        local farStartRing = nearRadius + 1
        local farEndRing = math.min(farStartRing + 1, math.max(length, heigth))

        for ring = farStartRing, farEndRing do
            if outOfBudget() then break end
            for dx = -ring, ring do
                if outOfBudget() then break end
                processChunk(centerX + dx, centerY - ring, 1)
                if outOfBudget() then break end
                processChunk(centerX + dx, centerY + ring, 1)
            end
            for dy = -ring + 1, ring - 1 do
                if outOfBudget() then break end
                processChunk(centerX - ring, centerY + dy, 1)
                if outOfBudget() then break end
                processChunk(centerX + ring, centerY + dy, 1)
            end
        end

        -- Use leftover guaranteed-far budget on the far spiral.
        phaseTimeLimit = nil
        runFarPhase()
        phaseAttemptLimit = nil
        phaseTimeLimit = nil
    end

    -- Prioritize nearby chunks only when they are not already complete for this center/radius.
    local skipNearPhase =
        self.nearGenerationComplete and
        self.nearGenerationCenterX == centerX and
        self.nearGenerationCenterY == centerY and
        self.nearGenerationRadius == nearRadius

    if not skipNearPhase then
        local nearAreaComplete = true
        phaseAttemptLimit = stepAttempts + nearAttemptBudget
        if hasTimer then
            phaseTimeLimit = startTime + (budgetSeconds * 0.85)
        end
        for ring = 0, nearRadius do
            if outOfBudget() then
                nearAreaComplete = false
                break
            end
            if ring == 0 then
                if not processChunk(centerX, centerY, nearPasses) then
                    nearAreaComplete = false
                end
            else
                for dx = -ring, ring do
                    if outOfBudget() then
                        nearAreaComplete = false
                        break
                    end
                    if not processChunk(centerX + dx, centerY - ring, nearPasses) then
                        nearAreaComplete = false
                    end
                    if outOfBudget() then
                        nearAreaComplete = false
                        break
                    end
                    if not processChunk(centerX + dx, centerY + ring, nearPasses) then
                        nearAreaComplete = false
                    end
                end
                for dy = -ring + 1, ring - 1 do
                    if outOfBudget() then
                        nearAreaComplete = false
                        break
                    end
                    if not processChunk(centerX - ring, centerY + dy, nearPasses) then
                        nearAreaComplete = false
                    end
                    if outOfBudget() then
                        nearAreaComplete = false
                        break
                    end
                    if not processChunk(centerX + ring, centerY + dy, nearPasses) then
                        nearAreaComplete = false
                    end
                end
            end
        end

        self.nearGenerationComplete = nearAreaComplete
        self.nearGenerationCenterX = centerX
        self.nearGenerationCenterY = centerY
        self.nearGenerationRadius = nearRadius
    end

    phaseAttemptLimit = nil
    phaseTimeLimit = nil

    -- Use a bounded leftover budget for farther chunks.
    local farTailRatio = farRatio * 0.5
    local farTailBudget = math.max(1, math.floor(maxStepAttemptsPerFrame * farTailRatio))
    if self.maxFarStepAttemptsPerFrame ~= nil then
        farTailBudget = self.maxFarStepAttemptsPerFrame
    end
    phaseAttemptLimit = stepAttempts + farTailBudget
    runFarPhase()
    phaseAttemptLimit = nil
end

function World:generateChunk(chunkPosX,chunkPosY,force,steps)
    if self:checkIfChunkExists(chunkPosX, chunkPosY) then
        local generated, stepDone = self.chunks[chunkPosX][chunkPosY]:generate(
            self.chunks[chunkPosX][chunkPosY]:getGenerationStatus(),
            self.generationSteps, self.worldSeed, self.depthProgression, self.biomeSize, self.biomeList, self)

        return generated, stepDone
        else
        if self.chunks == nil then
            self.chunks = {}
        end
        if self.chunks[chunkPosX] == nil then
            self.chunks[chunkPosX] = {}
        end
        if self.chunks[chunkPosX][chunkPosY] == nil then
            self.chunks[chunkPosX][chunkPosY] = Chunk(chunkPosX, chunkPosY, self.chunkSize)
            return true, true
        end
    end
    return false, false
end

function World:placePlayerTomb(position,entity)
    --print("trying to place tomb at",position.x,position.y)
    local prohibitedTiles = {"evilShrineFunctioning","evilShrineClosed","evilShrine"}
    local x,y = round(position.x), round(position.y)
    if (not checkifinlist(world:getRawTile(x, y), prohibitedTiles)) and (not self:doesTilePropretyExists(x,y,"entity")) then
        self:placeTile("tomb", x, y, "tiles", true)
        self:setTileProprety(x, y, "entity", entity)
        print("placed tomb at",x,y)
        return true
    end
    for ix = -1, 1 do
        for iy = -1, 1 do
            local nx, ny = x + ix, y + iy
            if (not checkifinlist(world:getRawTile(nx, ny), prohibitedTiles)) and (not self:doesTilePropretyExists(nx,ny,"entity")) then
                self:placeTile("tomb", nx, ny, "tiles", true)
                self:setTileProprety(nx, ny, "entity", entity)
                print("placed tomb at",nx,ny)
                return true
            end
        end
    end
    return false
end

function World:getBought(position)
    if self:doesTilePropretyExists(round(position.x), round(position.y), "buyState") then
        local bought = (self:getTileProprety(round(position.x), round(position.y), "buyState") == "bought")
        return bought
    else
        self:setTileProprety(round(position.x), round(position.y), "buyState", "notBought")
        return false
    end
end

function World:buy(position)
    if not self:getBought(position) then
        self:spawnTextParticle("-"..self:getCost(position).."$",Vector2(position.x,position.y+0.5), 6, 0.3, 1.5,{1,0,0,1},{0,0,0,1},{1,1,1,1}, {})
        self:setTileProprety(round(position.x), round(position.y), "buyState", "bought")
    end
end

function World:generateCost(multiplier,position)
    if self:doesTilePropretyExists(round(position.x), round(position.y), "cost") then

    else
        local cost = (1 + math.abs(1*self:getDepth(position.y)))^1.4
        if CheatMode then
            cost = 0
        end
        self:setTileProprety(round(position.x), round(position.y), "cost", math.ceil(cost * multiplier))

    end
end

function World:getCost(position)
    if self:doesTilePropretyExists(round(position.x), round(position.y), "cost") then
        return self:getTileProprety(round(position.x), round(position.y), "cost")
    else
        return 999
    end
end

function World:openContainer(tileName,tile, position, entity, rows, columns)
    if self:doesTilePropretyExists(round(position.x), round(position.y), "inventory") then
        entity:openInventory(self:getTileProprety(round(position.x), round(position.y), "inventory"))
    else
        local format = "normal"
        if entity ~= nil then
            format = entity.inventoryFormat
        end
        if format == "normal" then
            self:setTileProprety(round(position.x), round(position.y), "inventory",
            Inventory(tileName,CopyAll(tile.containerColor),Vector2(0.5, 0.6),rows,columns,1,100, (0.065), (0.065 / 8),{ ["anchorX"] = "middle", ["anchorY"] = "top", ["isChest"] = true, ["chestInfo"] = {x = position.x, y = position.y} },nil))   
        end
        if format == "vertical" then
            self:setTileProprety(round(position.x), round(position.y), "inventory",
            Inventory(tileName,CopyAll(tile.containerColor),Vector2(0.05, 0.5),rows,columns,1,100, (0.065), (0.065 / 8),{ ["anchorX"] = "left", ["anchorY"] = "top", ["isChest"] = true, ["chestInfo"] = {x = position.x, y = position.y} },nil))   
        end
        self:openContainer(tileName, tile, position, entity, rows, columns)
    end
end

function World:generateContainerLoot(position,credit,itemsAmount,creditMinPerItem,creditMaxPerItem,levelBias,enchantCreditMultiplier,cards,enchantCards)
    if position == nil then return false end
    if creditMaxPerItem ~= nil then creditMaxPerItem = creditMaxPerItem * self.itemAttributesMultiplier end
    if enchantCreditMultiplier ~= nil then enchantCreditMultiplier = enchantCreditMultiplier * self.itemAttributesMultiplier end
    if cards == nil then cards = CopyAll(ItemCardsList) end
    if enchantCards == nil then enchantCards = CopyAll(EnchantsList) end
    if not self:doesTilePropretyExists(round(position.x), round(position.y), "lootGenerated") then

        if self:doesTilePropretyExists(round(position.x), round(position.y), "inventory") then

            local director = ItemDirector(credit*self.itemAttributesMultiplier,itemsAmount,creditMinPerItem,creditMaxPerItem,levelBias,enchantCreditMultiplier,self:getBiome(position.x,position.y),self:getDepth(position.y),cards,enchantCards)
    
            local itemList = director:giveItems()

            if #itemList > 0 then
                self:setTileProprety(round(position.x), round(position.y), "lootGenerated", true)
                self:getTileProprety(round(position.x), round(position.y), "inventory"):addItems(itemList,false)
            else
                local tries = 0
                while true do
                    local director = ItemDirector(credit*self.itemAttributesMultiplier,itemsAmount,creditMinPerItem,creditMaxPerItem,levelBias,enchantCreditMultiplier,self:getBiome(position.x,position.y),self:getDepth(position.y),cards,enchantCards)
    
                    local itemList = director:giveItems()
                    tries = tries + 1
                    if #itemList > 0 or tries >= 10 then
                        if #itemList > 0 then
                            self:setTileProprety(round(position.x), round(position.y), "lootGenerated", true)
                            self:getTileProprety(round(position.x), round(position.y), "inventory"):addItems(itemList,false)
                        end
                        break
                    end
                end
            end
        end 
    end
end

-->biomes:

--getBiomes() --return biomes
function World:getBiomes()
    return self.biomeList
end

--addBiome(biome)
function World:addBiome(biomeName, temperature, wetness, deepnessmin, deepnessmax, deepnesssmooth, likeness)
    if self.biomeList == nil then self.biomeList = {} end
    local biome = {}
    biome.name = biomeName
    biome.option1 = temperature
    biome.option2 = wetness
    biome.deepnessmin = deepnessmin
    biome.deepnessmax = deepnessmax
    biome.likeness = likeness
    biome.deepnesssmooth = deepnesssmooth
    table.insert(self.biomeList, biome)
    return true
end

--removeBiome(biomeName)
function World:removeBiome(biome)
    table.remove(self.biomeList, biome)
    return true
end

--?  getBiome(x,y ...?,worldSeed?,depthProgression?,biomeSize?,biomeList?) , retourne un biome à un certain endroit à partir d'une liste de biome..
--pas sûr si il devrait être ici, ou à un autre endroit
--peut être dans chunk?, en tout cas, à besoin de tout les paramètres lié aux biomes si c'est le cas, mais pas si c'est ici
--retourne aussi une valeure biomeCentreDistance, qui retourne plus proche de 0 ver les bords du biomes et plus proche du 1 vers le centre du biome

-->structures:
--? une liste de structure avec toutes les probabilités incluse dedans
--peut être mais ce qui est sûr c'est que les fonctions de spawns de structures vont exister dans monde
-->entities:
--? est-ce que les entitées interragisseront directment avec le monde? pas sur si ils seront dans le monde, probably not

-->draw:
--drawTiles(centerX,centerY,length,heigth,parameters)
--déssine tout les tuiles à l'écran, ou à un endroit précis, mettre un paramètre précis comme un débug pour montrer le biome
--peut être envoyé dans le parameters, mais il peut être vide aussi
--drawTile(worldPosX,worldPosY,layer)
--dessine une tuile en spécifique dans le monde
--ne peut pas être unique aux classes tile et chunk vue que chaque tuiles intéragit avec les autres (ex. les bordures)


--updateLight(neighboringChunks) -- (getNeighboringChunks())
function World:updateLights(worldPosX, worldPosY)
    local chunkx, chunky = self:convertWorldPosToChunkPos(worldPosX, worldPosY)
    if self:checkIfChunkExists(chunkx, chunky) then
        self.chunks[chunkx][chunky]:updateNeighboringLights()
    end
    --self.chunks[chunkx][chunky]:updateNeighboringLights()
end

function World:updateLight(chunkX, chunkY)
    if self:checkIfChunkExists(chunkX, chunkY) then
        for ix = 1, self.chunkSize do
            for iy = 1, self.chunkSize do
                self:updateLightTile(chunkX, chunkY, ix, iy)
            end
        end
    end
end

function World:updateLightTile(chunkX, chunkY, posX, posY)
    local worldPosX, wordPosY = self:convertChunkPosToWorldPos(chunkX, chunkY, posX, posY)
    local closest = self:getClosestTileWhichLightCanGoThrough(worldPosX, wordPosY, lightreach)
    self:placeTile({ 1 - (closest - 1) / lightreach, 1 - (closest - 1) / lightreach, 1 - (closest - 1) / lightreach, 1 },
        worldPosX, wordPosY, "lights", true)
end

--getClosestNonSolidTile(worldPosX,wordPosY) --utilisé dans updateLight
function World:getClosestTileWhichLightCanGoThrough(worldPosX, wordPosY, reach)
    local closest = 99
    for il = 1, reach do
        t1 = self:getTile(worldPosX + il, wordPosY, "tiles")
        if t1:getLightCanGoThrough() then
            closest = il
            return closest
        end
        t1 = self:getTile(worldPosX - il, wordPosY, "tiles")
        if t1:getLightCanGoThrough() then
            closest = il
            return closest
        end
        t1 = self:getTile(worldPosX, wordPosY - il, "tiles")
        if t1:getLightCanGoThrough() then
            closest = il
            return closest
        end
        t1 = self:getTile(worldPosX, wordPosY + il, "tiles")
        if t1:getLightCanGoThrough() then
            closest = il
            return closest
        end
        for il2 = 0, il do
            t1 = self:getTile(worldPosX + il - il2, wordPosY - il2, "tiles")
            if t1:getLightCanGoThrough() then
                closest = il
                return closest
            end                                                                                                              --
            t1 = self:getTile(worldPosX - il2, wordPosY - il + il2, "tiles")
            if t1:getLightCanGoThrough() then
                closest = il
                return closest
            end
            t1 = self:getTile(worldPosX - il + il2, wordPosY + il2, "tiles")
            if t1:getLightCanGoThrough() then
                closest = il
                return closest
            end
            t1 = self:getTile(worldPosX + il2, wordPosY + il - il2, "tiles")
            if t1:getLightCanGoThrough() then
                closest = il
                return closest
            end
        end
    end
    return closest
end

function World:updateTiles(dt,centerX, centerY,length, heigth, parameters)
    centerX = round(centerX)
    centerY = round(centerY)
    local ix = -length
    local iy = -heigth
    local il = 1
    local layers = { "backTiles", "tiles", "topTiles" }
    for il = 1, #layers do
        for ix = -length, length do
            for iy = -heigth, heigth do
                self:updateHealth(ix + centerX, iy + centerY, layers[il], dt)
                self:updateSize(ix + centerX, iy + centerY, dt)

                local tile = self:getTile(ix + centerX, iy + centerY,layers[il])
                tile:emitParticles(ix + centerX, iy + centerY)
            end
        end
    end
end

function World:updateSize(worldPosX,worldPosY, dt)
    if self:doesTilePropretyExists(worldPosX,worldPosY,"size") then

        self:setTileProprety(worldPosX,worldPosY,"size",k(self:getTileProprety(worldPosX,worldPosY,"size"),1,dt*2.5))

        if self:getTileProprety(worldPosX,worldPosY,"size") > 0.95 and self:getTileProprety(worldPosX,worldPosY,"size") < 1.05 then
            self:clearTileProprerties(worldPosX, worldPosY,"size")
        end

    end
end

function World:updateHealth(worldPosX,worldPosY,layer, dt)
    if self:doesTilePropretyExists(worldPosX,worldPosY,"health"..layer) then

        self:tilePropretyAdd(worldPosX,worldPosY,"healthMineTimer"..layer,-dt) 


        if self:getTileProprety(worldPosX,worldPosY,"healthMineTimer"..layer) <= 0 then
            
            self:tilePropretyAdd(worldPosX,worldPosY,"health"..layer,dt/4)

            if self:getTileProprety(worldPosX,worldPosY,"health"..layer) >= self:getTile(worldPosX,worldPosY,layer).health then
                self:clearTileProprerties(worldPosX, worldPosY,"health"..layer)
                self:clearTileProprerties(worldPosX, worldPosY,"healthMineTimer"..layer)
            end

        end
    end
    
end

function World:fogUpdate(dt)
    if self.fogActivated then
        if #entities > 0 then
            for i = 1,#entities do
                local entity = entities[i]
                if entity.type == "player" then

                    local fogValue = self:getFogLevel(entity.position.x,entity.position.y,999999999,999999999, true)
                    if fogValue > 0 then
                        

                        entity.fogValue = entity.fogValue + (fogValue * dt)/3
                        local damage = entity.health:getValueWithoutDamagePreview("fog") * (entity.fogValue/14)

                        if entity.fogValue > 0 then
                            entity.health:setDamagePreview("fog",damage,{0.1,0,0.35,1},0.1)
                            if entity.fogValue > 1 then
                                entity:damage(damage,"fog")
                                entity.fogValue = 0
                                entity.health:setDamagePreview("fog",0,{0.1,0,0.35,1},0.1)
                            end
                        end
                    end

                end
            end
        end
    end
end

function World:drawFog(centerX, centerY, length, heigth, parameters)
    centerX = centerX
    centerY = centerY
    local ix = -length
    local iy = -heigth
    for ix = -length, length do
        for iy = -heigth, heigth do
            local posX = ix + round(centerX)
            local posY = iy + round(centerY)

            local fogLevel = self:getFogLevel(posX, posY, centerX, centerY)
            if fogLevel > 0 then
                --print("fogLevel", fogLevel)
                local screenPosX, screenPosY, size = self:getTileScreenPosition(posX, posY)
                --local size = round2(camv / 8, 8)
                --love.graphics.setColor(1, 1, 1, fogLevel)
                --love.graphics.rectangle("fill", screenPosX-size*4, screenPosY-size*4, size*8, size*8)
                local animation = "fog"..(maximum(minimum(math.ceil((1-fogLevel)*8),1),8))
                textures["sprites"]["fog"]:draw(animation,self.time,"right",screenPosX,screenPosY,size,size,nil)
            end

        end
    end
end

function World:getFogLevel(posX, posY, centerX, centerY, ignoreEntities)
    if ignoreEntities == nil then ignoreEntities = false end
    local fogLevel = 0
    local depth = self:getDepth(posY)
    local fogSmoothLayer = 0.02
    local fogSmoothCamera = 5
    local fogPlayerDistance = self.playerFogDistance
    if depth > (self.currentFogLayer-0.1) then
        fogLevel = k(0, 1, (depth - (self.currentFogLayer-0.1)) / fogSmoothLayer)
    end

    
    if self:getPlayerAmount() > 1 and (self.playerFog) then
        centerX, centerY = self:getPlayersCenter()
        if dist(posX,posY,centerX,centerY) > fogPlayerDistance then
            fogLevel = k(fogLevel,1,((dist(posX,posY,centerX,centerY)-fogPlayerDistance)/fogSmoothCamera))
        end
    end

    if fogLevel > 1 then fogLevel = 1 end

    if fogLevel > 1 then fogLevel = 1 end
    if (not (ignoreEntities)) then
        if self.fogViewDistance > 0 then
            if #entities > 0 then
                for i = 1,#entities do
                    local entity = entities[i]
                    if entity.type == "player" then
                        if dist(posX,posY,entity.position.x,entity.position.y) <= self.fogViewDistance + fogSmoothCamera then
                            local closeness = ((dist(posX,posY,entity.position.x,entity.position.y)-self.fogViewDistance) / fogSmoothCamera)
                            fogLevel = k(fogLevel, 0, maximum(minimum(1 - closeness,0),1))
                        end
                    end
                end
            end
        end
    end

    if fogLevel > 1 then fogLevel = 1 end


    return fogLevel
end

function World:getPlayersCenter()
    local sumX = 0
    local sumY = 0
    local playerCount = self:getPlayerAmount()
    if #entities > 0 then
        for i = 1, #entities do
            local entity = entities[i]
            if entity.type == "player" then
                sumX = sumX + entity.position.x
                sumY = sumY + entity.position.y
            end
        end
    end
    return sumX / playerCount, sumY / playerCount
end

function World:drawTiles(centerX, centerY, length, heigth, parameters)
    centerX = round(centerX)
    centerY = round(centerY)
    showBiomes = parameters["showBiomes"] or false
    local layers = { "backTiles", "tiles", "topTiles" } -- changer tile pour tiles
    for il = 1, #layers do
        local layer = layers[il]
        for ix = -length, length do
            for iy = -heigth, heigth do
                local worldX = ix + centerX
                local worldY = iy + centerY
                local light = self:getTile(worldX, worldY, "lights")
                local tile = self:getTile(worldX, worldY, layer)

                self:drawTile(worldX, worldY, layer, light, tile)

                local healthProperty = "health" .. layer
                if self:doesTilePropretyExists(worldX, worldY, healthProperty) and tile.canBeMined then
                    self:drawMineAnimation(worldX, worldY,
                        self:getTileProprety(worldX, worldY, healthProperty) / tile.health
                    )
                end

                if showBiomes and il == 1 then
                    local screenPosX, screenPosY = positiontoscreen(worldX, worldY)
                    love.graphics.print(self:getBiome(worldX, worldY), screenPosX, screenPosY)
                end
            end
        end
    end
    return true
end

function World:drawMineAnimation(worldPosX, worldPosY, value)
    local screenPosX, screenPosY, screenSize = self:getTileScreenPosition(worldPosX,worldPosY)

    local sizeMultiplyer = 1
    if self:doesTilePropretyExists(worldPosX, worldPosY,"size") then
        sizeMultiplyer = self:getTileProprety(worldPosX, worldPosY,"size")
    end
    local size = sizeMultiplyer * screenSize

    textures["sprites"]["destroyAnimation"]:drawSA(1-value,"right",screenPosX, screenPosY,size,size,{0,0,0,0.5})
end

function World:drawTile(worldPosX, worldPosY, layer, light, tile)
    if tile == nil then
        tile = self:getTile(worldPosX, worldPosY, layer)
    end
    if light == nil then light = { 1, 1, 1, 1 } end
    if (tile == nil) then
        return
    end

    if tile:getName() == "none" then
        return
    end

    local sizeMultiplyer = 1
    if self:doesTilePropretyExists(worldPosX, worldPosY,"size") then
        sizeMultiplyer = self:getTileProprety(worldPosX, worldPosY,"size")
    end
    local size = sizeMultiplyer * round2(camv / 8, 8)

    local screenPosX
    local screenPosY
    screenPosX, screenPosY = positiontoscreen(worldPosX, worldPosY)
    if layer == "topTiles" then
            love.graphics.setColor(1 * light[1], 1 * light[2], 1 * light[3], 1 * light[4])

            local border = tile:getBorder()
            local borderType = tile:getBorderType()
            local backgroundTile = self:getTile(worldPosX, worldPosY, "tiles")

            

            if borderType == "normal" then 
                love.graphics.draw(tile:getTexture(), tile:getQuad(), round(screenPosX), round(screenPosY), 0,
                    size, size, tile:getTextureCenterX(), tile:getTextureCenterY())
            end

            if borderType == "non-solid" then
                local borderingTile = self:getTile(worldPosX, worldPosY + 1, "tiles")
                if borderingTile then
                    if (backgroundTile:getType() ~= borderingTile:getType()) then
                        love.graphics.draw(tile:getTexture(), tile:getQuad(), round(screenPosX), round(screenPosY), 0,
                            size, size, tile:getTextureCenterX(), tile:getTextureCenterY())
                    end
                end
                local borderingTile = self:getTile(worldPosX + 1, worldPosY, "tiles")
                if borderingTile then
                    if (backgroundTile:getType() ~= borderingTile:getType()) then
                        love.graphics.draw(tile:getTexture(), tile:getQuad(), round(screenPosX), round(screenPosY),
                            d180topi(90), size, size, tile:getTextureCenterX(),
                            tile:getTextureCenterY())
                    end
                end
                local borderingTile = self:getTile(worldPosX, worldPosY - 1, "tiles")
                if borderingTile then
                    if (backgroundTile:getType() ~= borderingTile:getType()) then
                        love.graphics.draw(tile:getTexture(), tile:getQuad(), round(screenPosX), round(screenPosY),
                            d180topi(180), size, size, tile:getTextureCenterX(),
                            tile:getTextureCenterY())
                    end
                end
                local borderingTile = self:getTile(worldPosX - 1, worldPosY, "tiles")
                if borderingTile then
                    if (backgroundTile:getType() ~= borderingTile:getType()) then
                        love.graphics.draw(tile:getTexture(), tile:getQuad(), round(screenPosX), round(screenPosY),
                            d180topi(270), size, size, tile:getTextureCenterX(),
                            tile:getTextureCenterY())
                    end
                end
            end
    end
    if layer == "backTiles" or layer == "tiles" then
            local colour = tile:getColor()

            love.graphics.setColor(colour[1] * light[1], colour[2] * light[2], colour[3] * light[3], colour[4] * light
                [4])
            if layer == "backTiles" then
                love.graphics.setColor(colour[1] * 0.4 * light[1], colour[2] * 0.4 * light[2], colour[3] * 0.4 * light
                    [3], colour[4] * light[4])
            end

            --draw la texture principale
            love.graphics.draw(tile:getTexture(), tile:getQuad(), round(screenPosX), round(screenPosY), 0,
                size, size, tile:getTextureCenterX(), tile:getTextureCenterY())

            local border = tile:getBorder()
            local borderType = tile:getBorderType()

            --draw les border du bloc
            if borderType ~= "none" and camv > 20 then
                local borderingTile = self:getTile(worldPosX, worldPosY + 1, layer)
                if borderingTile then
                    if (borderType == "same block" and tile:getName() ~= borderingTile:getName()) then
                        love.graphics.draw(tile:getTexture(), tile:getBorderQuad(), round(screenPosX), round(screenPosY),
                            0, size, size, tile:getTextureCenterX(),
                            tile:getTextureCenterY())
                    end
                end
                local borderingTile = self:getTile(worldPosX + 1, worldPosY, layer)
                if borderingTile then
                    if (borderType == "same block" and tile:getName() ~= borderingTile:getName()) then
                        love.graphics.draw(tile:getTexture(), tile:getBorderQuad(), round(screenPosX), round(screenPosY),
                            d180topi(90), size, size, tile:getTextureCenterX(),
                            tile:getTextureCenterY())
                    end
                end
                local borderingTile = self:getTile(worldPosX, worldPosY - 1, layer)
                if borderingTile then
                    if (borderType == "same block" and tile:getName() ~= borderingTile:getName()) then
                        love.graphics.draw(tile:getTexture(), tile:getBorderQuad(), round(screenPosX), round(screenPosY),
                            d180topi(180), size, size, tile:getTextureCenterX(),
                            tile:getTextureCenterY())
                    end
                end
                local borderingTile = self:getTile(worldPosX - 1, worldPosY, layer)
                if borderingTile then
                    if (borderType == "same block" and tile:getName() ~= borderingTile:getName()) then
                        love.graphics.draw(tile:getTexture(), tile:getBorderQuad(), round(screenPosX), round(screenPosY),
                            d180topi(270), size, size, tile:getTextureCenterX(),
                            tile:getTextureCenterY())
                    end
                end
            end
    end
end

function World:generateTerrainTile(tileX, tileY, biome, distanceFromBiomeEdge)
    local seed = self.worldSeed
    local dp   = self.depthProgression
    local name = "none"

    if biome == nil or distanceFromBiomeEdge == nil then
        biome, distanceFromBiomeEdge = self:getBiome(tileX, tileY)
    end

    if love.math.noise(tileX / 20 / self.caveSize, tileY / 20 / self.caveSize, seed) >= 0.25 then
        name = "dirt"
    end
    if love.math.noise(tileX / 40 / self.caveSize, tileY / 40 / self.caveSize, seed - 100) < 0.3 then
        name = "none"
    end
    if love.math.noise(tileX / 12 / self.caveSize, tileY / 12 / self.caveSize, seed - 500) < 0.35 then
        name = "none"
    end
    if love.math.noise(tileX / 5 / self.caveSize, tileY / 5 / self.caveSize, seed - 600) < 0.35 and
        love.math.noise(tileX / 15 / self.caveSize, tileY / 15 / self.caveSize, seed + 100) < (tileY / (dp * 2)) + 1 then
        name = "none"
    end

    local n = love.math.noise(tileX / 150 / self.caveSize, tileY / 30 / self.caveSize, seed - 450)
        if n < 0.4 and n > 0.36 then
            name = "none"
        end

    if biome ~= "coldland" then
        local n = love.math.noise(tileX / 25 / self.caveSize, tileY / 90 / self.caveSize, seed - 200)
        if n < 0.4 and n > 0.36 then
            name = "none"
        end
        
    end

    --specific biomes
    

    if biome == "hotland" then
        if distanceFromBiomeEdge < 0.15 then
            name = "dirt"
        else
            name = "dirt"
            if love.math.noise(tileX / 25 / self.caveSize, tileY / 15 / self.caveSize, seed - 225) < 0.4
                or love.math.noise(tileX / 25 / self.caveSize, tileY / 15 / self.caveSize, seed - 225) > 0.6 then
                name = "none"
            end
        end
    end

    if biome == "coldland" then
        if love.math.noise(tileX / 7 / self.caveSize, tileY / 7 / self.caveSize, seed - 1055) < 0.4 * distanceFromBiomeEdge then
            name = "none"
        end
    end

    if biome == "darkland" then
        name = "dirt"
        if love.math.noise(tileX / 20 / self.caveSize, tileY / 20 / self.caveSize, seed - 805) < 0.45 and distanceFromBiomeEdge > 0.2 then
            name = "none"
        end
    end

    if biome == "ancientland" then
        name = "dirt"
        if love.math.noise(tileX / 15 / self.caveSize, tileY / 5 / self.caveSize, seed - 505) < 1.3 * distanceFromBiomeEdge then
            name = "none"
        end
        if love.math.noise(tileX / 15 / self.caveSize, tileY / 5 / self.caveSize, seed - 505) < 0.45 then
            name = "dirt"
        end
        if love.math.noise(tileX / 10 / self.caveSize, tileY / 10 / self.caveSize, seed - 570) < 0.38 * distanceFromBiomeEdge then
            name = "dirt"
        end
    end

    --ground

    if love.math.noise(tileX / 15 / self.caveSize, tileY / 30 / self.caveSize, seed + 100) > (-tileY / 20) then
        name = "none"
    end


    --edgelands
    if biome == "edgeLands" then
        name = "dirt"
    end

    --debug
    if false then
        if tileY % 50 == 0 then
            name = "dirt"
        else
            name = "none"
        end
    end

    return name
end

function World:getSeed()
    return self.worldSeed
end

function World:getPlayerAmount()
    local playerAmount = 0
    if #entities > 0 then
        for i = 1, #entities do
            local entity = entities[i]
            if entity.ai == "player" or entity.type == "player" then
                playerAmount = playerAmount + 1
            end
        end
    end
    return playerAmount
end

function World:isBossPresent()
    local bossPresent = false
    if #entities > 0 then
        for i = 1, #entities do
            local entity = entities[i]
            if entity.isBoss then
                bossPresent = true
                break
            end
        end
    end
    return bossPresent
end

function World:advanceFog(x, y)
    self:spawnTextParticle("The fog dissipates...",Vector2(x,y), 6, 0.3, 1.5,{1,1,1,1},{0.3,0,0.6,1},{1,0,1,1}, {appearAnimation = true})

    local depth = self:getDepth(y)
    if depth > self.currentFogLayer-0.6 then
        self.currentFogLayer = self.currentFogLayer + 1
        if self.currentFogLayer > 5.5 then
            self.currentFogLayer = 99999
        end
    end
    
end

function World:bossEvent(source, position, data)
    local depth = world:getDepth(position.y)
    local multiplier = (1 + math.abs((minimum(depth,0.9)*1.5) ^ 2))
    local credit = (120+ math.random(60)) * multiplier * (self:getPlayerAmount()^0.5)

    table.insert(self.directors, EntitySpawnDirector(position:copy(),7,0,credit,0,0.01,nil,0,0,1,credit,credit*2,credit*2,0,20,"boss",{mode = "chooseHighest"}))

end

function World:updateEntities(dt)
    local nop = self:getPlayerAmount()
    local player = 0
    if #entities > 0 then
        for i = 1, #entities do
            local entity = entities[i]

            entity:entityUpdate(dt) debugtimelog("entityUpdate","update")

            local isPlayer = (entity.ai == "player") or (entity.type == "player")

            if isPlayer then
                player = player + 1
                entity:controlsUpdate(dt,player) debugtimelog("entitycontrolsUpdate","update")
            else
                entity._controlsUpdateAccumulator = (entity._controlsUpdateAccumulator or 0) + dt
                if entity._controlsUpdateAccumulator >= self.nonPlayerControlsUpdateInterval then
                    entity:controlsUpdate(entity._controlsUpdateAccumulator,0) debugtimelog("entitycontrolsUpdate","update")
                    entity._controlsUpdateAccumulator = 0
                end
            end

            entity:interactUpdate(dt) debugtimelog("entityinteractUpdate","update")
            --
            local movementUpdatesPerTick = maximum(minimum(math.ceil(dt / (1/90)), 1),20)
            for j = 1, movementUpdatesPerTick do
                local subDt = dt / movementUpdatesPerTick
                entity:movementUpdate(subDt) debugtimelog("entitymovementUpdate","update")
                entity:collisionWithEntities(subDt) debugtimelog("entitycollisionWithEntities","update")
                entity:collisionUpdate(subDt) debugtimelog("entityCollisionUpdate","update")
            end

            if isPlayer then
                --entity:InventoryItemsUpdate(dt) debugtimelog("entityInventoryItemsUpdate","update")
                entity._inventoryItemsUpdateAccumulator = (entity._inventoryItemsUpdateAccumulator or 0) + dt
                if entity._inventoryItemsUpdateAccumulator >= self.playerInventoryUpdateInterval then
                    entity:InventoryItemsUpdate(entity._inventoryItemsUpdateAccumulator) debugtimelog("entityInventoryItemsUpdate","update")
                    entity._inventoryItemsUpdateAccumulator = 0
                end
            else
                entity._inventoryItemsUpdateAccumulator = (entity._inventoryItemsUpdateAccumulator or 0) + dt
                if entity._inventoryItemsUpdateAccumulator >= self.nonPlayerInventoryUpdateInterval then
                    entity:InventoryItemsUpdate(entity._inventoryItemsUpdateAccumulator) debugtimelog("entityInventoryItemsUpdate","update")
                    entity._inventoryItemsUpdateAccumulator = 0
                end
            end

            entity:groundItemsUpdate(dt) debugtimelog("entityGroundItemsUpdate","update")
            entity:animationUpdate(dt) debugtimelog("entityanimationUpdate","update")
            player = entity:camUpdate(dt,player) debugtimelog("entitycamUpdate","update")
            if entity.type == "player" then entity:playerUpdate(dt) debugtimelog("entityplayerUpdate","update") end
        end
    end
    if #entities > 0 then
        for i = #entities, 1, -1 do
            local remove = entities[i]:entityDeathUpdate(dt)
            if remove then
                table.remove(entities,i)
            end
        end
    end
end

function World:updateDirectors(dt)
    if self.globalDirector then
        self.globalDirector:update(dt)
    end
    if self.directors then
        for i = 1, #self.directors do
            self.directors[i]:update(dt)
        end
    end
end

function World:getColision(worldPosX, worldPosY)
    tile = self:getTile(worldPosX, worldPosY, "tiles")
    return tile:getColision()
end

function World:getDepth(y)
    return -y / self.depthProgression
end

function World:getEnvironmentLevel(y)
    --example :
    --depth 0 : 1
    --depth 0.5 : 5
    --depth 1 : 11
    --depth 2 : 27
    --depth 3 : 50
    --depth 4 : 78
    --depth 5 : 111
    --depth 6 : 150
    return (1 + math.abs(self:getDepth(y)* 3)^ 1.7)
end

function World:checkSpawnValidity(position,space)
    local valid = false
    if space == nil then space = 1 end
    if self:getColision(position.x - math.floor(space/2), position.y - math.floor(space/2)) == false then
        if self:getColision(position.x - math.floor(space/2), position.y - 1 - math.floor(space/2)) == true then
            valid = true
        end
    end
    if space >= 2 then
        for ix = 1, space do
            for iy = 1, space do
                if self:getColision(position.x - math.floor(space/2) + ix - 1, position.y + iy - math.floor(space/2) - 1) then
                    valid = false
                end
            end
            if not self:getColision(position.x - math.floor(space/2) + ix - 1, position.y - math.floor(space/2) - 1) then
                valid = false
            end
        end
    end

    return valid
end

function World:canLineGoThrough(position1,position2,precision)
    local canGoThrough = true
    precision = precision or 3
    for i = 1, math.ceil(position1:dist(position2)*precision) do
        local pos = position1:copy()
        pos:moveTowards(position2,i/precision)
        if self:getColision(pos.x,pos.y) then
            canGoThrough = false
        end
    end
    return canGoThrough
end

function World:spawnEntity(type, worldPosX, worldPosY)
    aiType = "none"
    if type == "player" then aiType = "player" end
    --table.insert(entities,Entity(type, type, "none", Vector2(worldPosX, worldPosY), 1, 0.9, 0, aiType, {}))
    table.insert(entities, Entity(type, type, "player", Vector2(worldPosX, worldPosY), 100, 0.45, 0, aiType, {}))

    return true
end

function World:getMouseTile(roundedToTile)
    roundedToTile = roundedToTile or false
    if (roundedToTile) then
        return Vector2(round(mxworldpos), round(myworldpos))
    else
        return Vector2(mxworldpos, myworldpos)
    end
end

function World:rayTrace(hitLayers,startPos,targetPos,distanceLimit,endBeforeColliding,continueAfterTarget,radius,checkFrequency)
    if radius == nil then radius = 0 end
    if checkFrequency == nil then checkFrequency = 1/startPos:dist(targetPos)/radius end-- end 
    if checkFrequency < 0.1 or true then checkFrequency = 0.1 end
    if endBeforeColliding == nil then endBeforeColliding = true end
    if distanceLimit == nil then distanceLimit = 99 end
    if continueAfterTarget == nil then continueAfterTarget = false end

    if continueAfterTarget then targetPos:moveTowards(startPos,-999) end
    
    local hardLimit = 2000
    local currentPos = startPos:copy()
    local nextPos = startPos:copy()
    local hitEnd = true
    local hitNegativeFirst = false
    local count = 1

    while (hitEnd) do
        count = count + 1
        
        if hitEnd then
            nextPos =  currentPos:moveTowardsPredict(targetPos,checkFrequency)
            if #hitLayers >0 then
                for ilayer = 1, #hitLayers do
                    local layer2 = hitLayers[ilayer]
                    local tile = self:getTile(nextPos.x,nextPos.y,layer2)
                    local middleTile = self:getTile(nextPos.x,nextPos.y,"tiles")

                    if (tile.name == "none" and layer2 == "backTiles") then hitNegativeFirst = true end
                    if (tile.name == "none" and layer2 == "backTiles") then hitNegativeFirst = true end

                    if (tile.type == "solid" and layer2 == "tiles")  or
                        (tile.name ~= "none" and layer2 == "backTiles" and hitNegativeFirst) or
                        ((middleTile.type == "solid" and tile.name ~= "none") and (layer2 == "topTiles" or layer2 == "top")) 
                    then
                        --if layer2 == (layer2 == "topTiles" or layer2 == "top") then currentPos:moveTowards(targetPos,checkFrequency) end
                        hitEnd = false
                    end

                end
            end

        end

        if nextPos:dist(startPos) > distanceLimit then
            hitEnd = false
        end

        if count > hardLimit then
            hitEnd = false
        end

        if hitEnd or (not endBeforeColliding) then currentPos:moveTowards(targetPos,checkFrequency) end
        
    end

    return currentPos
end

function World:DrawEntities()
    for i = #entities, 1, -1 do
        entities[i]:draw()
        ---love.graphics.draw(entities[ix]:getTexture(), entities[ix]:getSprite(), entities[ix]:getPosition():getY(),
        --    entities[ix]:getPosition():getX(),
        --    0, round2(camv / 8, 8), round2(camv / 8, 8), 4, 4)
    end
end

function World:drawEntitiesHealthBars()
    for i = 1, #entities do
        entities[i]:drawHealthBars()
        ---love.graphics.draw(entities[ix]:getTexture(), entities[ix]:getSprite(), entities[ix]:getPosition():getY(),
        --    entities[ix]:getPosition():getX(),
        --    0, round2(camv / 8, 8), round2(camv / 8, 8), 4, 4)
    end
end

function World:DrawUi(playerNumber)
    debugtimeclear("sub")
    for i = 1, #entities do
        if entities[i].id == Cameras[playerNumber].entityFollow then
            entities[i]:DrawUI()
        end
    end
end

function World:spawnTextParticle(text,position, time, size, height,color,outlineColor,animationColor, flags)

    table.insert(self.textParticles,TextParticle(text,position:copy(), time, size, height,color,outlineColor,animationColor, flags))
end

function World:spawnXPparticles(value,position)
    local count = minimum(maximum(math.abs(math.ceil(value/10)), 10), 1)

    local getXPColor = function (value)
        local color = {0,0,0,0.5}
        if value < 3 then
            color = {0.85,1,1,0.5}
        elseif value < 10 then
            color = {0.7,1,1,0.6}
        elseif value < 18 then
            color = {0.5,1,1,0.7}
        elseif value < 27 then
            color = {0.35,1,1,0.8}
        elseif value < 50 then
            color = {0.2,1,1,0.9}
        elseif value < 100 then
            color = {0,0.7,1,1}
        elseif value < 200 then
            color = {0,0.3,1,1}
        elseif value < 300 then
            color = {0.3,0,1,1}
        elseif value < 400 then
            color = {0,0,0.8,1}
        elseif value < 500 then
            color = {0.4,0,0.8,1}
        else
            color = {0.8,0,0.8,1}
        end
        return color
    end

    for ip = 1, count do
        local singularValue = value/count
        local spawnPos = position:copy()
        spawnPos:move(math.random(360),math.random()*0.5)
        local spawnColor = getXPColor(singularValue)
        local lightColor = CopyAll(spawnColor)
        lightColor[4] = lightColor[4]*0.6
        local spawnFlags = {}
        spawnFlags.velocity = Vector2(0,0)
        spawnFlags.velocity:move(math.random(360),math.random()*1)
        spawnFlags.xpValue = singularValue
        spawnFlags.lightColor = lightColor
        spawnFlags.flashColor = {1,1,1,1}
        spawnFlags.flashTime = 0.5
        local time = 10 + math.abs((singularValue/3)^0.5) + math.random()*1

        table.insert(self.particles,Particle("xp",spawnPos, spawnColor,time,"floating",spawnFlags))
    end
end

function World:spawnCoinParticles(value,position)
    local count = minimum(maximum(math.abs(math.ceil(value/10)), 10), 1)

    

    for ip = 1, count do
        local color = {1,0.8,0,1}
        local singularValue = value/count
        if singularValue < 1 then color = {0.6,0.6,0.65,1} end
        local spawnPos = position:copy()
        spawnPos:move(math.random(360),math.random()*0.5)
        local spawnColor = CopyAll(color)
        local spawnFlags = {}
        spawnFlags.velocity = Vector2(0,0)
        spawnFlags.velocity:move(math.random(360),math.random()*1)
        spawnFlags.coinValue = singularValue
        local lightColor = CopyAll(color)
        lightColor[3] = lightColor[3]*0.7
        lightColor[2] = lightColor[2]*0.7
        lightColor[1] = lightColor[1]*0.7
        spawnFlags.lightColor = lightColor
        spawnFlags.flashColor = {1,1,1,1}
        spawnFlags.flashTime = 2
        --spawnFlags.flashColor = {1,1,1,1}
        --spawnFlags.flashTime = 2
        local time = 10 + math.abs((singularValue/3)^0.5) + math.random()*1

        table.insert(self.particles,Particle("coin",spawnPos, spawnColor,time,"dust",spawnFlags))
    end
end

function World:spawnParticles(count,name,position,radius,color, colorNoise, timer, timerNoise,motion, motionStrength, motionArcAngle, motionArcSpread, flags)
    if motionStrength == nil then motionStrength = 0 end
    if motionArcAngle == nil then motionArcAngle = -90 end
    if motionArcSpread == nil then motionArcSpread = 360 end
    if count>0 then
        for ip =1, math.ceil(count) do
            local spawnPos = position:copy()
            spawnPos:move(math.random(360),math.random()*radius)
            local spawnColor = CopyAll({color[1]+math.random()*colorNoise[1], color[2]+math.random()*colorNoise[2], color[3]+math.random()*colorNoise[3], color[4]+math.random()*colorNoise[4]})
            local spawnFlags = CopyAll(flags)
            spawnFlags.velocity = Vector2(0,0)
            spawnFlags.velocity:move(motionArcAngle+(math.random()-0.5)*2*motionArcSpread,math.random()*motionStrength)

            table.insert(self.particles,Particle(name,spawnPos, spawnColor,timer + math.random()*timerNoise,motion,spawnFlags))
        end
    end
end

function World:updateParticles(dt)
    if #self.particles > 0 then
        for i=#self.particles,1,-1 do
            local die = self.particles[i]:update(dt)
            if die then
                table.remove(self.particles,i)
            end
        end
    end
    if #self.textParticles > 0 then
        for i=#self.textParticles,1,-1 do
            local die = self.textParticles[i]:update(dt)
            if die then
                table.remove(self.textParticles,i)
            end
        end
    end
end

function World:drawParticles()
    if #self.particles > 0 then
        for i=1, #self.particles do
            self.particles[i]:draw()
        end
    end
end

function World:drawTextParticles()
    if #self.textParticles > 0 then
        for i=1, #self.textParticles do
            self.textParticles[i]:draw()
        end
    end
end

function World:spawnGroundItem(itemName, position, velocity, quantity, attributes, flags)
    table.insert(self.groundItems, GroundItem(itemName, position, velocity, quantity, attributes, flags) )
end

function World:groundItemsUpdate(dt)
    if #self.groundItems > 0 then
        for i = #self.groundItems, 1, -1 do
            if self.groundItems[i]:update(dt) then table.remove(self.groundItems,i) end
        end
    end
end

function World:drawGroundItems(dt)
    if #self.groundItems > 0 then
        for i = 1, #self.groundItems do
            self.groundItems[i]:draw()
        end
    end
end

function World:projectileUpdate(dt)
    if #self.projectiles > 0 then
        for i = #self.projectiles, 1, -1 do
            local die = self.projectiles[i]:update(dt)
            if die then
                table.remove(self.projectiles, i)
            end
        end
    end
end

function World:drawProjectiles()
    if #self.projectiles > 0 then
        for i = 1, #self.projectiles do
            self.projectiles[i]:draw()
        end
    end
end

function World:getTileScreenPosition(tileX,tileY)
    local size = camv/8
    local x,y = positiontoscreen(tileX,tileY)
    return x,y,size
end
