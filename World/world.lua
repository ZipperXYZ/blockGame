require "class/superClass"
World = SuperClass:extend()
World.className = "World"


local stepOrder = { "none", "stone", "stone2", "grass", "ores", "deco", "done" }
local stepIndex = {}
for i, s in ipairs(stepOrder) do stepIndex[s] = i end


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
    self.chunks = {}
    self.groundItems = {}
    self.particles = {}

    self.parameters = parameters or {}
    self.borderX = self.parameters.borderX or 0
    self.loopX = self.parameters.loopX or (self.borderX*1.4)
    self.borderY = self.parameters.borderY or 0
    self.hasBorder = self.parameters.hasBorder or (self.borderX ~= 0)

    
end

--clear() -- vide le monde de tout ses chunks, gardant toutes ses propriétés les mêmes
function World:clear()
    self.chunks = {}
    self.groundItems = {}
    self.particles = {}
    entities = {}
    spectator = true
end

function World:clearBiomes()
    self.biomeList = {}
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
    local required = stepIndex[step]
    if not required then return false end

    local neighbors = {
        { chunkX + 1, chunkY + 1 }, { chunkX + 1, chunkY }, { chunkX + 1, chunkY - 1 },
        { chunkX,     chunkY - 1 }, { chunkX - 1, chunkY - 1 }, { chunkX - 1, chunkY },
        { chunkX - 1, chunkY + 1 }, { chunkX, chunkY + 1 }
    }

    for _, n in ipairs(neighbors) do
        local nx, ny = n[1], n[2]
        if not self:checkIfChunkExists(nx, ny) then return false end
        local neighborStatus = self.chunks[nx][ny]:getGenerationStatus()
        -- le voisin doit avoir complété au moins l'étape précédente
        if stepIndex[neighborStatus] < required then return false end
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

function World:damageBlock(worldPosX, worldPosY, damage,layer,destroyTopAsWell)
    local destroyed

    if layer == nil then layer = "tiles" end
    if destroyTopAsWell == nil then destroyTopAsWell = true end
    if layer == "top" then layer = "topTiles" end
    if layer == "back" then layer = "backTiles" end

    if self:doesTilePropretyExists(worldPosX, worldPosY, "health"..layer) then
        self:tilePropretyAdd(worldPosX, worldPosY, "health"..layer, -damage)
        self:setTileProprety(worldPosX, worldPosY, "healthMineTimer"..layer, 5)
    else
        self:setTileProprety(worldPosX, worldPosY, "health"..layer, self:getTile(worldPosX, worldPosY,layer).health)
        self:tilePropretyAdd(worldPosX, worldPosY, "health"..layer, -damage)
        self:setTileProprety(worldPosX, worldPosY, "healthMineTimer"..layer, 5)
    end

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
        tile:tileDestroyed(worldPosX, worldPosY)
        if layer == "tiles" and destroyTopAsWell then 
            self:destroyTile(worldPosX, worldPosY,"topTiles",false)
            self:clearTileProprerties(worldPosX, worldPosY,"health".."topTiles")
            self:clearTileProprerties(worldPosX, worldPosY,"healthMineTimer".."topTiles")
            tile:tileDestroyed(worldPosX, worldPosY)
        end
    end
    
    return destroyed
end

--generate(centerX,centerY,length,heigth,biomeList, boolean: force, step) --génére (ou essaille) de générer tout les chunks à l'écran, ou de progresser la génération
--force va forcer jusqu'à ce que tout les chunks sont au minimum au step
--devrait être éxécuter chaque seconde à la position de la caméra ainsi que avec force=false
--pour la gen des structure, force=true pis la taille de la structure
function World:generate(centerX, centerY, length, heigth, force, steps)
    if step == nil then step = self.generationSteps end
    centerX = round(centerX)
    centerY = round(centerY)

    local chunksGenerated = 0

    self:generateChunk(centerX, centerY,force,steps)

    local x, y = 0, 0
    local dx, dy = 1, 0
    local steps = 1

    while math.max(math.abs(x), math.abs(y)) <= math.max(length, heigth) do
        for _ = 1, 2 do
            for _ = 1, steps do
                x = x + dx
                y = y + dy

                if math.abs(x) <= length and math.abs(y) <= heigth then
                    if chunksGenerated <= MaxChunkLoadedPerFrame then
                        if self:generateChunk(centerX + x, centerY + y,force,steps) then
                            chunksGenerated = chunksGenerated + 1 
                        end
                    end
                end
            end
            dx, dy = -dy, dx 
        end
        steps = steps + 1
    end
end

function World:generateChunk(chunkPosX,chunkPosY,force,steps)
    if self:checkIfChunkExists(chunkPosX, chunkPosY) then
        self.chunks[chunkPosX][chunkPosY]:generate(self.chunks[chunkPosX][chunkPosY]:getGenerationStatus(),
            self.generationSteps, self.worldSeed, self.depthProgression, self.biomeSize, self.biomeList, self)

        if not self.chunks[chunkPosX][chunkPosY]:getGenerationStatus() == "done" then
            return true
        end
        else
        if self.chunks == nil then
            self.chunks = {}
        end
        if self.chunks[chunkPosX] == nil then
            self.chunks[chunkPosX] = {}
        end
        if self.chunks[chunkPosX][chunkPosY] == nil then
            self.chunks[chunkPosX][chunkPosY] = Chunk(chunkPosX, chunkPosY, self.chunkSize)
            return true
        end
    end
    return false
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
    self.chunks[chunkx][chunky]:updateNeighboringLights()
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

                local tile = self:getTile(ix + centerX, iy + centerY,"tiles")
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

function World:drawTiles(centerX, centerY, length, heigth, parameters)
    centerX = round(centerX)
    centerY = round(centerY)
    showBiomes = parameters["showBiomes"] or false
    local ix = -length
    local iy = -heigth
    local il = 1
    local layers = { "backTiles", "tiles", "topTiles" } -- changer tile pour tiles
    for il = 1, #layers do
        for ix = -length, length do
            for iy = -heigth, heigth do
                self:drawTile(ix + centerX, iy + centerY, layers[il], self:getTile(ix + centerX, iy + centerY, "lights"))

                if self:doesTilePropretyExists(ix + centerX, iy + centerY, "health"..layers[il])
                    and self:getTile(ix + centerX, iy + centerY,layers[il]).canBeMined
                then
                    self:drawMineAnimation(ix + centerX, iy + centerY,
                        self:getTileProprety(ix + centerX, iy + centerY,"health"..layers[il])
                        / self:getTile(ix + centerX, iy + centerY,layers[il]).health
                    )
                end

                if showBiomes then
                    local screenPosX, screenPosY
                    screenPosX, screenPosY = positiontoscreen(ix + centerX, iy + centerY)
                    love.graphics.print(self:getBiome(ix + centerX, iy + centerY), screenPosX, screenPosY)
                end
                --[[local currentLayer=layers[il]
                tile=self.getTile(ix+centerX, centerY+iy, currentLayer)
                if tile.getName()~="none" then
                    self.drawTile(ix+centerX, centerY+iy, currentLayer)
                end]]
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

function World:drawTile(worldPosX, worldPosY, layer, light)
    local tile = self:getTile(worldPosX, worldPosY, layer)
    local sizeMultiplyer = 1
    if self:doesTilePropretyExists(worldPosX, worldPosY,"size") then
        sizeMultiplyer = self:getTileProprety(worldPosX, worldPosY,"size")
    end
    local size = sizeMultiplyer * round2(camv / 8, 8)
    if light == nil then light = { 1, 1, 1, 1 } end
    if (tile == nil) then
        return
    end

    if tile:getName() ~= "none" then
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
end

function World:generateTerrainTile(tileX, tileY)
    local seed = self.worldSeed
    local dp   = self.depthProgression
    local name = "none"

    if love.math.noise(tileX / 20, tileY / 20, seed) >= 0.25 then
        name = "dirt"
    end
    if love.math.noise(tileX / 40, tileY / 40, seed - 100) < 0.3 then
        name = "none"
    end
    if love.math.noise(tileX / 12, tileY / 12, seed - 500) < 0.35 then
        name = "none"
    end
    if love.math.noise(tileX / 5, tileY / 5, seed - 600) < 0.35 and
        love.math.noise(tileX / 15, tileY / 15, seed + 100) < (tileY / (dp * 2)) + 1 then
        name = "none"
    end
    local n = love.math.noise(tileX / 25, tileY / 90, seed - 200)
    if n < 0.4 and n > 0.36 then
        name = "none"
    end

    --specific biomes
    local biome, distanceFromBiomeEdge = self:getBiome(tileX, tileY)

    if biome == "hotland" then
        if distanceFromBiomeEdge < 0.15 then
            name = "dirt"
        else
            name = "dirt"
            if love.math.noise(tileX / 25, tileY / 15, seed - 225) < 0.4
                or love.math.noise(tileX / 25, tileY / 15, seed - 225) > 0.6 then
                name = "none"
            end
        end
    end

    if biome == "coldland" then
        if love.math.noise(tileX / 7, tileY / 7, seed - 1055) < 0.4 * distanceFromBiomeEdge then
            name = "none"
        end
    end

    if biome == "darkland" then
        name = "dirt"
        if love.math.noise(tileX / 20, tileY / 20, seed - 805) < 0.45 and distanceFromBiomeEdge > 0.2 then
            name = "none"
        end
    end

    if biome == "ancientland" then
        name = "dirt"
        if love.math.noise(tileX / 15, tileY / 5, seed - 505) < 1.3 * distanceFromBiomeEdge then
            name = "none"
        end
        if love.math.noise(tileX / 10, tileY / 10, seed - 570) < 0.38 * distanceFromBiomeEdge then
            name = "dirt"
        end
    end

    --ground

    if love.math.noise(tileX / 15, tileY / 30, seed + 100) > (-tileY / 20) then
        name = "none"
    end

    return name
end

function World:getSeed()
    return self.worldSeed
end

function World:updateEntities(dt)
    if #entities > 0 then
        for i = 1, #entities do
            entities[i]:controlsUpdate(dt)
            entities[i]:movementUpdate(dt)
            entities[i]:collisionWithEntities(dt)
            entities[i]:collisionUpdate(dt)
            entities[i]:InventoryItemsUpdate(dt)
            entities[i]:groundItemsUpdate(dt)
            entities[i]:animationUpdate(dt)
            entities[i]:camUpdate(dt)
            if entities[i].type == "player" then entities[i]:playerUpdate(dt) end
        end
    end
end

function World:getColision(worldPosX, worldPosY)
    tile = self:getTile(worldPosX, worldPosY, "tiles")
    return tile:getColision()
end

function World:spawnEntity(type, worldPosX, worldPosY)
    aiType = "none"
    if type == "player" then aiType = "human" end
    --table.insert(entities,Entity(type, type, "none", Vector2(worldPosX, worldPosY), 1, 0.9, 0, aiType, {}))
    table.insert(entities, Entity(type, type, "player", Vector2(worldPosX, worldPosY), 1, 0.425, 0, aiType, {}))

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
    for i = 1, #entities do
        entities[i]:draw()
        ---love.graphics.draw(entities[ix]:getTexture(), entities[ix]:getSprite(), entities[ix]:getPosition():getY(),
        --    entities[ix]:getPosition():getX(),
        --    0, round2(camv / 8, 8), round2(camv / 8, 8), 4, 4)
    end
end

function World:DrawUi()
    for i = 1, #entities do
        if entities[i].id == camEntityFollow then
            entities[i]:DrawUI()
        end
    end
end

function World:spawnParticles(count,name,position,radius,color, colorNoise, timer, timerNoise,motion, motionStrength, motionArcAngle, motionArcSpread, flags)
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
end

function World:drawParticles()
    if #self.particles > 0 then
        for i=1, #self.particles do
            self.particles[i]:draw()
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

function World:getTileScreenPosition(tileX,tileY)
    local size = camv/8
    local x,y = positiontoscreen(tileX,tileY)
    return x,y,size
end