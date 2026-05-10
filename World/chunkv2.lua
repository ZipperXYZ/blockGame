require "class/superClass"

Chunk = SuperClass:extend()
Chunk.className = "Chunk"

function Chunk:init(chunkX, chunkY, chunkSize)
    if (not chunkX) or (not chunkY) then return end
    self.chunkX = chunkX
    self.chunkY = chunkY
    self.chunkSize = chunkSize
    self.generationStatus = "ng"
    self.tiles = {}
    self.tiles["tiles"]      = {}
    self.tiles["topTiles"]   = {}
    self.tiles["backTiles"]  = {}
    self.tiles["lights"]     = {}
    self.tiles["properties"] = {}
    for ix = 1, self.chunkSize do
        self.tiles["tiles"][ix]      = {}
        self.tiles["topTiles"][ix]   = {}
        self.tiles["backTiles"][ix]  = {}
        self.tiles["lights"][ix]     = {}
        self.tiles["properties"][ix] = {}
        for iy = 1, self.chunkSize do
            self.tiles["tiles"][ix][iy]      = "none"
            self.tiles["topTiles"][ix][iy]   = "none"
            self.tiles["backTiles"][ix][iy]  = "none"
            self.tiles["lights"][ix][iy]     = {1, 1, 1, 1}
            self.tiles["properties"][ix][iy] = {}
        end
    end
end

-- retourne un objet tile
function Chunk:getTile(xInChunk, yInChunk, layer)
    if layer == "top"  then layer = "topTiles"  end
    if layer == "back" then layer = "backTiles" end
    if self.tiles[layer] == nil then return tiles["none"] end
    if xInChunk <= 0 or xInChunk > self.chunkSize or
       yInChunk <= 0 or yInChunk > self.chunkSize then
        return tiles["none"]
    end
    local t = self.tiles[layer][xInChunk][yInChunk]
    if layer ~= "lights" and layer ~= "properties" then t = tiles[t] end
    return t
end

-- retourne juste le nom string de la tile (pour la génération)
function Chunk:getTileRaw(xInChunk, yInChunk, layer)
    if layer == "top"  then layer = "topTiles"  end
    if layer == "back" then layer = "backTiles" end
    if self.tiles[layer] == nil then return "none" end
    if xInChunk <= 0 or xInChunk > self.chunkSize or
       yInChunk <= 0 or yInChunk > self.chunkSize then
        return "none"
    end
    return self.tiles[layer][xInChunk][yInChunk] or "none"
end

function Chunk:placeTile(tile, xInChunk, yInChunk, layer, force)
    if layer == "top"  then layer = "topTiles"  end
    if layer == "back" then layer = "backTiles" end
    if self.tiles[layer] == nil then return false end
    if xInChunk <= 0 or xInChunk > self.chunkSize or
       yInChunk <= 0 or yInChunk > self.chunkSize then
        return false
    end
    self.tiles[layer][xInChunk][yInChunk] = tile
    return true
end

function Chunk:destroyTile(xInChunk, yInChunk, layer)
    return self:placeTile("none", xInChunk, yInChunk, layer, true)
end

function Chunk:getGenerationStatus()
    return self.generationStatus
end

function Chunk:convertChunkPosToWorldPos(posInChunkX, posInChunkY)
    local wx = self.chunkX * self.chunkSize + posInChunkX - 1
    local wy = self.chunkY * self.chunkSize + posInChunkY - 1
    return wx, wy
end

-- génération — avance d'une étape par appel
function Chunk:generate(world)
    local step = self.generationStatus
    local seed = world.worldSeed
    local dp   = world.depthProgression

    -- ÉTAPE 1 : générer le terrain de base
    if step == "ng" then
        for ix = 1, self.chunkSize do
            for iy = 1, self.chunkSize do
                local wx, wy = self:convertChunkPosToWorldPos(ix, iy)
                self.tiles["tiles"][ix][iy]     = world:generateTerrainTile(wx, wy)
                self.tiles["topTiles"][ix][iy]  = "none"
                self.tiles["backTiles"][ix][iy] = "none"
                self.tiles["lights"][ix][iy]    = {1, 1, 1, 1}
            end
        end
        self.generationStatus = "stone"
        return
    end

    -- ÉTAPE 2 : pierre et murs
    if step == "stone" and world:neighborchunksloadcheck(self.chunkX, self.chunkY, "stone") then
        -- première passe : backs
        for ix = 1, self.chunkSize do
            for iy = 1, self.chunkSize do
                local wx, wy = self:convertChunkPosToWorldPos(ix, iy)
                if love.math.noise(wx/14, wy/14, seed-608) < 0.6 then
                    self.tiles["backTiles"][ix][iy] = "dirt_wall"
                end
                if love.math.noise(wx/15, wy/30, seed+100) > (-wy/30) then
                    self.tiles["backTiles"][ix][iy] = "none"
                end
            end
        end
        -- deuxième passe : stone
        for ix = 1, self.chunkSize do
            for iy = 1, self.chunkSize do
                local wx, wy  = self:convertChunkPosToWorldPos(ix, iy)
                local tileRaw = self:getTileRaw(ix, iy, "tiles")
                local backRaw = self:getTileRaw(ix, iy, "backTiles")
                if backRaw == "dirt_wall" then
                    if love.math.noise(wx/8, wy/8, seed+600) > (wy/(dp*3))+0.75 then
                        if not (love.math.noise(wx/45, wy/30, seed+800) > 0.7) then
                            self.tiles["backTiles"][ix][iy] = "stone_wall"
                        end
                    end
                end
                if tileRaw == "dirt" then
                    if love.math.noise(wx/8, wy/8, seed+600) > (wy/(dp*3))+0.75 then
                        if not (love.math.noise(wx/45, wy/30, seed+800) > 0.7) then
                            self.tiles["tiles"][ix][iy] = "stone"
                        end
                    end
                end
            end
        end
        self.generationStatus = "stone2"
        return
    end

    -- ÉTAPE 3 : variantes de pierre et biomes
    if step == "stone2" and world:neighborchunksloadcheck(self.chunkX, self.chunkY, "stone2") then
        for ix = 1, self.chunkSize do
            for iy = 1, self.chunkSize do
                local wx, wy  = self:convertChunkPosToWorldPos(ix, iy)
                local tileRaw = self:getTileRaw(ix, iy, "tiles")
                local backRaw = self:getTileRaw(ix, iy, "backTiles")
                local biome   = world:getbiome(wx, wy)

                if checkifinlist(tileRaw, tilelists["stones"]) then
                    if biome == "hotland"  then self.tiles["tiles"][ix][iy] = "hotstone"  end
                    if biome == "coldland" then self.tiles["tiles"][ix][iy] = "coldstone" end
                end
                if checkifinlist(backRaw, tilelists["stones"]) then
                    if biome == "hotland"  then self.tiles["backTiles"][ix][iy] = "hotstone_wall"  end
                    if biome == "coldland" then self.tiles["backTiles"][ix][iy] = "coldstone_wall" end
                end
                if checkifinlist(tileRaw, tilelists["stones"]) then
                    if love.math.noise(wx/35, wy/35, seed-580) > (wy/(dp*5))+1.8 then
                        if love.math.noise(wx/8, wy/8, seed+242) > 0.72 or
                           love.math.noise(wx/8, wy/8, seed+242) < 0.1 then
                            self.tiles["tiles"][ix][iy] = "lightstone"
                        end
                    end
                end
                if tileRaw == "stone" then
                    if love.math.noise(wx/22, wy/22, seed+950) > (wy/(dp*5))+0.75 then
                        if love.math.noise(wx/8, wy/18, seed+900) > 0.725 or
                           love.math.noise(wx/8, wy/18, seed+900) < 0.275 then
                            self.tiles["tiles"][ix][iy] = "darkstone"
                        end
                    end
                end
                if checkifinlist(tileRaw, {"stone", "darkstone"}) then
                    if love.math.noise(wx/35, wy/35, seed+975) > (wy/(dp*5))+1 then
                        if love.math.noise(wx/35, wy/12, seed+505) > 0.75 or
                           love.math.noise(wx/35, wy/12, seed+505) < 0.275 then
                            self.tiles["tiles"][ix][iy] = "palestone"
                        end
                    end
                end
                if checkifinlist(tileRaw, tilelists["stones"]) then
                    if love.math.noise(wx/35, wy/35, seed-580) > (wy/(dp*5))+1.2 then
                        if love.math.noise(wx/8, wy/12, seed+545) > 0.75 or
                           love.math.noise(wx/8, wy/12, seed+545) < 0.2 then
                            self.tiles["tiles"][ix][iy] = "ancientstone"
                        end
                    end
                end
            end
        end
        self.generationStatus = "grass"
        return
    end

    -- ÉTAPE 4 : herbe et tops
    if step == "grass" and world:neighborchunksloadcheck(self.chunkX, self.chunkY, "grass") then
        for ix = 1, self.chunkSize do
            for iy = 1, self.chunkSize do
                local wx, wy  = self:convertChunkPosToWorldPos(ix, iy)
                local tileRaw = self:getTileRaw(ix, iy, "tiles")

                if checkifinlist(tileRaw, {"dirt", "stone"}) then
                    if not (love.math.noise(wx/20, wy/20, seed+800) > (wy/(dp*3))+0.85) then
                        self.tiles["topTiles"][ix][iy] = "grass"
                    end
                end
                if self.tiles["topTiles"][ix][iy] == "grass" then
                    if love.math.noise(wx/80, wy/80, seed-122) > 0.65 then
                        self.tiles["topTiles"][ix][iy] = "wheatgrass"
                    end
                end
                if checkifinlist(tileRaw, {"dirt", "stone", "darkstone"}) then
                    if not (love.math.noise(wx/20, wy/20, seed+520) < (wy/(dp*5))+0.85) and
                       love.math.noise(wx/40, wy/40, seed+585) < 0.35 then
                        self.tiles["topTiles"][ix][iy] = "purplegrass"
                    end
                end
                if checkifinlist(tileRaw, tilelists["stones"]) then
                    if not (love.math.noise(wx/20, wy/20, seed+455) < (wy/(dp*6))+1.2) and
                       love.math.noise(wx/90, wy/90, seed+588) < 0.3 then
                        self.tiles["topTiles"][ix][iy] = "shadowgrass"
                    end
                end
            end
        end
        self.generationStatus = "ores"
        return
    end

    -- ÉTAPE 5 : ores
    if step == "ores" and world:neighborchunksloadcheck(self.chunkX, self.chunkY, "ores") then
        for ix = 1, self.chunkSize do
            for iy = 1, self.chunkSize do
                local wx, wy  = self:convertChunkPosToWorldPos(ix, iy)
                local tileRaw = self:getTileRaw(ix, iy, "tiles")
                if checkifinlist(tileRaw, tilelists["stones"]) then
                    if not (love.math.noise(wx/20, wy/20, seed+452) < (wy/(dp*20))+0.75) and
                       love.math.noise(wx/6, wy/12, seed+588) < 0.2 then
                        self.tiles["topTiles"][ix][iy] = "diamond"
                    end
                end
            end
        end
        self.generationStatus = "done"
        return
    end
end