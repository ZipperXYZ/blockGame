require "class/superClass"

World = SuperClass:extend()
World.className = "World"

local stepOrder = {"ng", "stone", "stone2", "grass", "ores", "done"}
local stepIndex = {}
for i, s in ipairs(stepOrder) do stepIndex[s] = i end

function World:init(worldSeed, chunkSize, depthProgression, biomeSize, biomeList, generationSteps)
    self.worldSeed        = worldSeed        or math.random() * 100000
    self.depthProgression = depthProgression or 100
    self.biomeSize        = biomeSize        or 150
    self.chunkSize        = chunkSize        or 10
    self.biomeList        = biomeList        or {}
    self.generationSteps  = generationSteps  or {}
    self.chunks           = {}
end

function World:clear()
    self.chunks = {}
end

-- ─── Conversion ──────────────────────────────────────────────────────────────

function World:convertWorldPosToChunkPos(worldPosX, worldPosY)
    worldPosX = round(worldPosX)
    worldPosY = round(worldPosY)
    local ChunkX      = math.floor(worldPosX / self.chunkSize)
    local ChunkY      = math.floor(worldPosY / self.chunkSize)
    local posInChunkX = (worldPosX % self.chunkSize) + 1
    local posInChunkY = (worldPosY % self.chunkSize) + 1
    return ChunkX, ChunkY, posInChunkX, posInChunkY
end

function World:convertChunkPosToWorldPos(ChunkX, ChunkY, posInChunkX, posInChunkY)
    local worldPosX = ChunkX * self.chunkSize + posInChunkX - 1
    local worldPosY = ChunkY * self.chunkSize + posInChunkY - 1
    return worldPosX, worldPosY
end

-- ─── Chunk checks ────────────────────────────────────────────────────────────

function World:checkIfChunkExists(chunkX, chunkY)
    chunkX = round(chunkX)
    chunkY = round(chunkY)
    if self.chunks == nil             then return false end
    if self.chunks[chunkX] == nil     then return false end
    if self.chunks[chunkX][chunkY] == nil then return false end
    return true
end

-- vérifie que les chunks voisins ont au moins complété l'étape précédente
function World:neighborchunksloadcheck(x, y, step)
    local required = stepIndex[step]
    if not required then return false end

    local neighbors = {
        {x+1, y+1}, {x+1, y}, {x+1, y-1},
        {x,   y-1}, {x-1, y-1}, {x-1, y},
        {x-1, y+1}, {x,   y+1}
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

-- ─── Tiles ───────────────────────────────────────────────────────────────────

-- retourne un objet tile
function World:getTile(worldPosX, worldPosY, layer)
    local tile = tiles["none"]
    local chunkX, chunkY, posX, posY = self:convertWorldPosToChunkPos(worldPosX, worldPosY)
    if self:checkIfChunkExists(chunkX, chunkY) then
        tile = self.chunks[chunkX][chunkY]:getTile(posX, posY, layer)
    end
    return tile
end

-- retourne juste le nom string (pour la génération)
function World:getTileRaw(worldPosX, worldPosY, layer)
    if layer == "top"  then layer = "topTiles"  end
    if layer == "back" then layer = "backTiles" end
    local chunkX, chunkY, posX, posY = self:convertWorldPosToChunkPos(worldPosX, worldPosY)
    if not self:checkIfChunkExists(chunkX, chunkY) then return "none" end
    local tileTable = self.chunks[chunkX][chunkY].tiles[layer]
    if not tileTable or not tileTable[posX] then return "none" end
    return tileTable[posX][posY] or "none"
end

function World:placeTile(tile, worldPosX, worldPosY, layer, force)
    local chunkX, chunkY, posX, posY = self:convertWorldPosToChunkPos(worldPosX, worldPosY)
    if not self:checkIfChunkExists(chunkX, chunkY) then return false end
    return self.chunks[chunkX][chunkY]:placeTile(tile, posX, posY, layer, force)
end

function World:destroyTile(worldPosX, worldPosY, layer)
    local chunkX, chunkY, posX, posY = self:convertWorldPosToChunkPos(worldPosX, worldPosY)
    if not self:checkIfChunkExists(chunkX, chunkY) then return false end
    return self.chunks[chunkX][chunkY]:destroyTile(posX, posY, layer)
end

function World:getTilePropreties(worldPosX, worldPosY)
    return {}
end

-- ─── Génération ──────────────────────────────────────────────────────────────

-- génère le terrain de base pour une tile (retourne le nom string)
function World:generateTerrainTile(tileX, tileY)
    local seed = self.worldSeed
    local dp   = self.depthProgression
    local name = "air"

    if love.math.noise(tileX/20, tileY/20, seed) >= 0.25 then
        name = "dirt"
    end
    if love.math.noise(tileX/40, tileY/40, seed-100) < 0.3 then
        name = "air"
    end
    if love.math.noise(tileX/12, tileY/12, seed-500) < 0.35 then
        name = "air"
    end
    if love.math.noise(tileX/5, tileY/5, seed-600) < 0.35 and
       love.math.noise(tileX/15, tileY/15, seed+100) < (tileY/(dp*2))+1 then
        name = "air"
    end
    local n = love.math.noise(tileX/25, tileY/90, seed-200)
    if n < 0.4 and n > 0.36 then
        name = "air"
    end
    if love.math.noise(tileX/15, tileY/30, seed+100) > (-tileY/20) then
        name = "air"
    end

    return name
end

-- génère / avance la génération des chunks autour d'un centre
function World:generate(centerX, centerY, length, height, force, step)
    centerX = round(centerX)
    centerY = round(centerY)
    local buffer = 2

    -- créer tous les chunks + buffer
    for ix = -(length+buffer), length+buffer do
        for iy = -(height+buffer), height+buffer do
            local cx = centerX + ix
            local cy = centerY + iy
            if not self:checkIfChunkExists(cx, cy) then
                if self.chunks[cx] == nil then self.chunks[cx] = {} end
                self.chunks[cx][cy] = Chunk:new(cx, cy, self.chunkSize)
                self.chunks[cx][cy]:generate(self)  -- ng → stone
            end
        end
    end

    -- avancer TOUS les chunks chargés, 5 passes (une par étape)
    for pass = 1, 5 do
        for cx_key, row in pairs(self.chunks) do
            for cy_key, chunk in pairs(row) do
                if chunk:getGenerationStatus() ~= "done" then
                    chunk:generate(self)
                end
            end
        end
    end

    return true
end

-- ─── Biomes ──────────────────────────────────────────────────────────────────

function World:getbiome(x, y)
    local biome       = "none"
    local closestDist = 999999
    local secondDist  = 999999
    local nearcenter  = 0

    local op1 = love.math.noise(x/self.biomeSize,       y/self.biomeSize,       self.worldSeed-5)
    local op2 = love.math.noise(x/(self.biomeSize*1.2), y/(self.biomeSize/1.2), self.worldSeed-10)

    for ib = 1, #self.biomeList do
        local bm = self.biomeList[ib]
        local d  = dist(op1, op2, bm["option1"], bm["option2"]) ^ bm["likeness"]

        local depth    = -y / self.depthProgression
        local enter    = math.max(0, math.min(1, (depth - bm["deepnessmin"]) / bm["deepnesssmooth"]))
        local exitVal  = math.max(0, math.min(1, (bm["deepnessmax"] - depth) / bm["deepnesssmooth"]))
        local ymulti   = math.min(enter, exitVal)

        d = ymulti <= 0 and 999999 or (d / ymulti)

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

function World:getBiomes()  return self.biomeList end

function World:addBiome(biome)
    table.insert(self.biomeList, biome)
    return true
end

function World:removeBiome(biome)
    table.remove(self.biomeList, biome)
    return true
end

-- ─── Draw ────────────────────────────────────────────────────────────────────

function World:drawTiles(centerX, centerY, length, height, parameters)
    centerX = round(centerX)
    centerY = round(centerY)
    local layers = {"backTiles", "tiles", "topTiles"}
    for _, layer in ipairs(layers) do
        for ix = -length, length do
            for iy = -height, height do
                self:drawTile(ix + centerX, iy + centerY, layer)
            end
        end
    end
    return true
end

function World:drawTile(worldPosX, worldPosY, layer)
    local tile = self:getTile(worldPosX, worldPosY, layer)
    if not tile or type(tile) ~= "table" then return end
    if tile:getName() == "none" or tile:getName() == "air" then return end

    local quad = tile:getQuad()
    if not quad then return end

    -- vérifier si la tile au dessus est solide
    local tileAbove = self:getTile(worldPosX, worldPosY + 1, layer)
    local hasBorder = not tileAbove or 
                      tileAbove:getName() == "none" or 
                      tileAbove:getName() == "air" or
                      tileAbove:getType() ~= "solid"

    -- utiliser la border quad si disponible
    if hasBorder and tile.border and tile.border["quad"] then
        local borderQuad = textures["quads"][tile.border["quad"]]
        if borderQuad then quad = borderQuad end
    end

    love.graphics.setColor(1, 1, 1, 1)
    local screenPosX, screenPosY = positiontoscreen(worldPosX, worldPosY)
    love.graphics.draw(
        tile:getTexture(), quad,
        round(screenPosX), round(screenPosY),
        0,
        round2(camv/8, 8), round2(camv/8, 8),
        4, 4
    )
end

-- ─── Lumière ─────────────────────────────────────────────────────────────────

function World:updateLight()
end

function World:getClosestNonSolidTile(worldPosX, worldPosY)
end