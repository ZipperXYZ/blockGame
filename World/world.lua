require "class/superClass"

World = SuperClass:extend()
World.className = "World"


local stepOrder = { "none", "stone", "stone2", "grass", "ores", "done" }
local stepIndex = {}
for i, s in ipairs(stepOrder) do stepIndex[s] = i end


--new(worldseed,depthProgression,biomeSize,biomeList,generationSteps) --Biomelist peut être empty,
--  depthProgression correspond au nombre de blocs
--  par progression du monde, comme par exemple, mettre 100 feras en sorte que des enemies vont commencer à spawn à y-100, d'autres à -200 et ça s'applique
--  sur tout genre les mobs, les ores, les tiles, les biomes, les structures etc.
function World:init(worldSeed, chunkSize, depthProgression, biomeSize, biomeList, generationSteps)
    self.worldSeed = worldSeed or math.random() * 100000
    self.depthProgression = depthProgression or 100
    self.biomeSize = biomeSize or 150
    self.chunkSize = chunkSize or 10
    self.biomeList = biomeList or {}
    self.generationSteps = generationSteps or {}
    self.chunks = {}
end

--clear() -- vide le monde de tout ses chunks, gardant toutes ses propriétés les mêmes
function World:clear()
    self.chunks = {}
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
function World:placeTile(tile, worldPosX, worldPosY, layer, force)
    local chunkX, chunkY, posX, posY = self:convertWorldPosToChunkPos(worldPosX, worldPosY)
    if self:checkIfChunkExists(chunkX, chunkY) then
        self.chunks[chunkX][chunkY]:placeTile(tile, posX, posY, layer, force)
    end
    return true
end

--destroyTile(worldPosX,worldPosY,layer) --supprime une tile pour laisser 'none' à la place, supprimer aussi certaines properties
function World:destroyTile(worldPosX, worldPosY, layer)
    return true
end

--getTile(worldPosX,worldPosY,layer) --return un objet tile (à définir si ça le donne dans un tableau, avec les autres information
--uniques qui sont nécessaires pour mettons l'information unique à une tile, comme son orientation, peut être un getTilePropreties
--qui retourne les propriétés et setTilePropriety(propriety, value) qui set une propriété de la tile, comme l'inventaire d'un
--coffre ou l'orientation d'un bloc)
function World:getTile(worldPosX, worldPosY, layer)
    local tile = tiles["none"]

    local chunkX, chunkY, posX, posY = self:convertWorldPosToChunkPos(worldPosX, worldPosY)
    if self:checkIfChunkExists(chunkX, chunkY) then
        tile = self.chunks[chunkX][chunkY]:getTile(posX, posY, layer)
    end
    return tile
end

--getTilePropreties(worldPosX,worldPosY) --retourne une liste, il n'y a pas de layer pour les propriétés, cela peut être mélangeant mais est bcp plus simple

function World:getTilePropreties(worldPosX, worldPosY)
    return {}
end

--setTilePropriety(worldPosX,worldPosY,propriety, value)
function World:setTilePropreties(worldPosX, worldPosY, propriety, value)
    return true
end

--clearTileProprieties(worldPosX,worldPosY)
function World:clearTileProprieties(worldPosX, worldPosY, propriety, value)
    return true
end

--generate(centerX,centerY,length,heigth,biomeList, boolean: force, step) --génére (ou essaille) de générer tout les chunks à l'écran, ou de progresser la génération
--force va forcer jusqu'à ce que tout les chunks sont au minimum au step
--devrait être éxécuter chaque seconde à la position de la caméra ainsi que avec force=false
--pour la gen des structure, force=true pis la taille de la structure
function World:generate(centerX, centerY, length, heigth, force, step)
    if step == nil then step = self.generationSteps end
    centerX = round(centerX)
    centerY = round(centerY)

    local ix = 1
    local iy = 1
    for ix = -length, length do
        for iy = -heigth, heigth do
            local chunkPosX = centerX + ix
            local chunkPosY = centerY + iy
            if self:checkIfChunkExists(chunkPosX, chunkPosY) then
                self.chunks[chunkPosX][chunkPosY]:generate(self.chunks[chunkPosX][chunkPosY]:getGenerationStatus(),
                    stepOrder, self.worldSeed, self.depthProgression, self.biomeSize, self.biomeList, self)
            else
                if self.chunks == nil then
                    self.chunks = {}
                end
                if self.chunks[chunkPosX] == nil then
                    self.chunks[chunkPosX] = {}
                end
                if self.chunks[chunkPosX][chunkPosY] == nil then
                    self.chunks[chunkPosX][chunkPosY] = Chunk(chunkPosX, chunkPosY, self.chunkSize)
                end
            end
        end
    end
    return true
end

-->biomes:

--getBiomes() --return biomes
function World:getBiomes()
    return self.biomeList
end

--addBiome(biome)
function World:addBiome(biome)
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
function World:updateLight()

end

--getClosestNonSolidTile(worldPosX,wordPosY) --utilisé dans updateLight
function World:getClosestNonSolidTile(worldPosX, wordPosY)

end

function World:drawTiles(centerX, centerY, length, heigth, parameters)
    centerX = round(centerX)
    centerY = round(centerY)
    local ix = -length
    local iy = -heigth
    local il = 1
    local layers = { "backTiles", "tiles", "topTiles" } -- changer tile pour tiles
    for il = 1, #layers do
        for ix = -length, length do
            for iy = -heigth, heigth do
                self:drawTile(ix + centerX, iy + centerY, layers[il])
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

function World:drawTile(worldPosX, worldPosY, layer)
    local tile = self:getTile(worldPosX, worldPosY, layer)

    if (tile == nil) then
        return
    end

    if tile:getName() ~= "none" then
        local screenPosX
        local screenPosY
        screenPosX, screenPosY = positiontoscreen(worldPosX, worldPosY)
        if layer == "topTiles" then
            love.graphics.setColor(1, 1, 1, 1)

            local border = tile:getBorder()
            local borderType = tile:getBorderType()
            local backgroundTile = self:getTile(worldPosX, worldPosY, "tiles")

            if borderType == "normal" then
                love.graphics.draw(tile:getTexture(), tile:getQuad(), round(screenPosX), round(screenPosY), 0,
                    round2(camv / 8, 8), round2(camv / 8, 8), 4, 4)
            end

            if borderType == "non-solid" then
                local borderingTile = self:getTile(worldPosX, worldPosY + 1, "tiles")
                if borderingTile then
                    if (backgroundTile:getType() ~= borderingTile:getType()) then
                        love.graphics.draw(tile:getTexture(), tile:getQuad(), round(screenPosX), round(screenPosY), 0,
                            round2(camv / 8, 8), round2(camv / 8, 8), 4, 4)
                    end
                end
                local borderingTile = self:getTile(worldPosX + 1, worldPosY, "tiles")
                if borderingTile then
                    if (backgroundTile:getType() ~= borderingTile:getType()) then
                        love.graphics.draw(tile:getTexture(), tile:getQuad(), round(screenPosX), round(screenPosY),
                            d180topi(90), round2(camv / 8, 8), round2(camv / 8, 8), 4, 4)
                    end
                end
                local borderingTile = self:getTile(worldPosX, worldPosY - 1, "tiles")
                if borderingTile then
                    if (backgroundTile:getType() ~= borderingTile:getType()) then
                        love.graphics.draw(tile:getTexture(), tile:getQuad(), round(screenPosX), round(screenPosY),
                            d180topi(180), round2(camv / 8, 8), round2(camv / 8, 8), 4, 4)
                    end
                end
                local borderingTile = self:getTile(worldPosX - 1, worldPosY, "tiles")
                if borderingTile then
                    if (backgroundTile:getType() ~= borderingTile:getType()) then
                        love.graphics.draw(tile:getTexture(), tile:getQuad(), round(screenPosX), round(screenPosY),
                            d180topi(270), round2(camv / 8, 8), round2(camv / 8, 8), 4, 4)
                    end
                end
            end
        end
        if layer == "backTiles" or layer == "tiles" then
            local colour = tile:getColor()
            love.graphics.setColor(colour)
            if layer == "backTiles" then
                love.graphics.setColor(colour[1] * 0.4, colour[2] * 0.4, colour[3] * 0.4, colour[4])
            end

            --draw la texture principale
            love.graphics.draw(tile:getTexture(), tile:getQuad(), round(screenPosX), round(screenPosY), 0,
                round2(camv / 8, 8), round2(camv / 8, 8), 4, 4)

            local border = tile:getBorder()
            local borderType = tile:getBorderType()

            --draw les border du bloc
            if borderType ~= "none" then
                local borderingTile = self:getTile(worldPosX, worldPosY + 1, layer)
                if borderingTile then
                    if (borderType == "same block" and tile:getName() ~= borderingTile:getName()) then
                        love.graphics.draw(tile:getTexture(), tile:getBorderQuad(), round(screenPosX), round(screenPosY),
                            0, round2(camv / 8, 8), round2(camv / 8, 8), 4, 4)
                    end
                end
                local borderingTile = self:getTile(worldPosX + 1, worldPosY, layer)
                if borderingTile then
                    if (borderType == "same block" and tile:getName() ~= borderingTile:getName()) then
                        love.graphics.draw(tile:getTexture(), tile:getBorderQuad(), round(screenPosX), round(screenPosY),
                            d180topi(90), round2(camv / 8, 8), round2(camv / 8, 8), 4, 4)
                    end
                end
                local borderingTile = self:getTile(worldPosX, worldPosY - 1, layer)
                if borderingTile then
                    if (borderType == "same block" and tile:getName() ~= borderingTile:getName()) then
                        love.graphics.draw(tile:getTexture(), tile:getBorderQuad(), round(screenPosX), round(screenPosY),
                            d180topi(180), round2(camv / 8, 8), round2(camv / 8, 8), 4, 4)
                    end
                end
                local borderingTile = self:getTile(worldPosX - 1, worldPosY, layer)
                if borderingTile then
                    if (borderType == "same block" and tile:getName() ~= borderingTile:getName()) then
                        love.graphics.draw(tile:getTexture(), tile:getBorderQuad(), round(screenPosX), round(screenPosY),
                            d180topi(270), round2(camv / 8, 8), round2(camv / 8, 8), 4, 4)
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
    if love.math.noise(tileX / 15, tileY / 30, seed + 100) > (-tileY / 20) then
        name = "none"
    end

    return name
end

function World:getbiome(x, y)
    local biome       = "none"
    local closestDist = 999999
    local secondDist  = 999999
    local nearcenter  = 0

    local op1         = love.math.noise(x / self.biomeSize, y / self.biomeSize, self.worldSeed - 5)
    local op2         = love.math.noise(x / (self.biomeSize * 1.2), y / (self.biomeSize / 1.2), self.worldSeed - 10)

    for ib = 1, #self.biomeList do
        local bm      = self.biomeList[ib]
        local d       = dist(op1, op2, bm["option1"], bm["option2"]) ^ bm["likeness"]

        local depth   = -y / self.depthProgression
        local enter   = math.max(0, math.min(1, (depth - bm["deepnessmin"]) / bm["deepnesssmooth"]))
        local exitVal = math.max(0, math.min(1, (bm["deepnessmax"] - depth) / bm["deepnesssmooth"]))
        local ymulti  = math.min(enter, exitVal)

        d             = ymulti <= 0 and 999999 or (d / ymulti)

        if d < closestDist then
            secondDist  = closestDist
            closestDist = d
            biome       = bm["name"]
        elseif d < secondDist then
            secondDist = d
        end
    end

    nearcenter = math.max(0, math.min(1, 1 - (closestDist / secondDist)))
    return biome, nearcenter
end

function World:placeEntity(entityName, worldPosX, worldPosY)

end
