require "class/superClass"

Chunk = SuperClass:extend()
Chunk.className = "Chunk"

function Chunk:init(chunkX, chunkY, chunkSize)
    if (not chunkX) or (not chunkY) then
        return
    end
    self.chunkX = chunkX -- changer Chunkx pour chunkX
    self.chunkY = chunkY
    self.chunkSize = chunkSize
    self.generationStatus = "none"
    self.chunkTiles = {}
    self.chunkTiles["tiles"] = {}
    self.chunkTiles["topTiles"] = {}
    self.chunkTiles["backTiles"] = {}
    self.chunkTiles["lights"] = {}
    self.chunkTiles["properties"] = {}
    for ix = 1, self.chunkSize do
        self.chunkTiles["tiles"][ix] = {}
        self.chunkTiles["topTiles"][ix] = {}
        self.chunkTiles["backTiles"][ix] = {}
        self.chunkTiles["lights"][ix] = {}
        self.chunkTiles["properties"][ix] = {}
        for iy = 1, self.chunkSize do
            self.chunkTiles["tiles"][ix][iy] = "dirt"
            self.chunkTiles["topTiles"][ix][iy] = "none"
            self.chunkTiles["backTiles"][ix][iy] = "none"
            self.chunkTiles["lights"][ix][iy] = { 1, 1, 1, 1 }
            self.chunkTiles["properties"][ix][iy] = {}
        end
    end
end

--la pluspart des fonctions ici ne sont pas sensé être utilisé en tant que tels, à par la génération, ils devraient juste être utilisé
--par un objet world


--getTile(xinchunk,yinchunk,layer) --retourne un objet tile selon le nom de la tile
--vue que lua est bien, on pourrait metre comme layer 'light' pis ça donnerait le tableau lumière ({1,1,1,1}) d'une tile au lieu d'un objet tile
function Chunk:getTile(xInChunk, yInChunk, layer)
    if layer == "top" then layer = "topTiles" end
    if layer == "back" then layer = "backTiles" end
    local tile = tiles["none"]

    if self.chunkTiles[layer] == nil then return tiles["none"] end
    if (xInChunk <= 0 or xInChunk > self.chunkSize or yInChunk <= 0 or yInChunk > self.chunkSize) then
        return tiles["none"]
    end

    tile = self.chunkTiles[layer][xInChunk][yInChunk] or "none"

    if layer ~= "lights" and layer ~= "properties" then tile = tiles[tile] end
    return tile
end

function Chunk:getRawTile(xInChunk, yInChunk, layer)
    if layer == "top" then layer = "topTiles" end
    if layer == "back" then layer = "backTiles" end

    if self.chunkTiles[layer] == nil then return "none" end

    if xInChunk <= 0 or xInChunk > self.chunkSize or
        yInChunk <= 0 or yInChunk > self.chunkSize then
        return "none"
    end
    return self.chunkTiles[layer][xInChunk][yInChunk] or "none"
end --placeTile(xinchunk,yinchunk,layer,bool:force)

--layer peut etre soit tile, back et top, usually faudrait checker si une tile peut être placé en top (comme gazon ou les ores)
--la pluspart des tiles peuvent être placé dans tile, mais seulement certaines peuvent être placé dans back (peut être faire une
--fonction canBeWall dans tileDef)
function Chunk:placeTile(tile, xInChunk, yInChunk, layer, force)
    if layer == "top" then layer = "topTiles" end
    if layer == "back" then layer = "backTiles" end
    if self.chunkTiles[layer] == nil then return false end
    if (xInChunk <= 0 or xInChunk > self.chunkSize or yInChunk <= 0 or yInChunk > self.chunkSize) then return false end
    if force or true then
        self.chunkTiles[layer][xInChunk][yInChunk] = tile
        if layer ~= "lights" then self:updateNeighboringLights() end
        return true
    end
end

function Chunk:updateNeighboringLights()
    world:updateLight(self.chunkX, self.chunkY)
    world:updateLight(self.chunkX + 1, self.chunkY)
    world:updateLight(self.chunkX - 1, self.chunkY)
    world:updateLight(self.chunkX, self.chunkY + 1)
    world:updateLight(self.chunkX + 1, self.chunkY + 1)
    world:updateLight(self.chunkX - 1, self.chunkY + 1)
    world:updateLight(self.chunkX, self.chunkY - 1)
    world:updateLight(self.chunkX - 1, self.chunkY - 1)
    world:updateLight(self.chunkX + 1, self.chunkY - 1)
end

function Chunk:destroyTile(xInChunk, yInChunk, layer, force)
    if layer == "top" then layer = "topTiles" end
    if layer == "back" then layer = "backTiles" end
    if self.chunkTiles[layer] == nil then return false end
    if (xInChunk <= 0 or xInChunk > self.chunkSize or yInChunk <= 0 or yInChunk > self.chunkSize) then return false end
    if force or true then
        self.chunkTiles[layer][xInChunk][yInChunk] = "none"
        if layer ~= "lights" then self:updateNeighboringLights() end
        return true
    end
end

--getGenerationStatus() -- return world gen status of the chunk
function Chunk:getGenerationStatus()
    return self.generationStatus
end

--generate(step,chunkX,chunkY,worldSeed,depthProgression,biomeSize,biomeList) -- generate according to step
function Chunk:generate(step, stepList, worldSeed, depthProgression, biomeSize, biomeList, world)
    if (step == "none") then
        for ix = 1, self.chunkSize do
            for iy = 1, self.chunkSize do
                local wx, wy                         = self:convertChunkPosToWorldPos(ix, iy)
                self.chunkTiles["tiles"][ix][iy]     = world:generateTerrainTile(wx, wy)
                self.chunkTiles["topTiles"][ix][iy]  = "none"
                self.chunkTiles["backTiles"][ix][iy] = "none"
                self.chunkTiles["lights"][ix][iy]    = { 1, 1, 1, 1 }
            end
        end

        --self.generationStatus = "stone"
        self:advanceGenerationStatus(stepList)
        return
    end


    if step == "stone" and world:getNeighboringChunks(self.chunkX, self.chunkY, "stone") then
        -- première passe : backs
        for ix = 1, self.chunkSize do
            for iy = 1, self.chunkSize do
                local wx, wy = self:convertChunkPosToWorldPos(ix, iy)

                if love.math.noise(wx / 14, wy / 14, worldSeed - 608) < 0.6 then
                    self.chunkTiles["backTiles"][ix][iy] = "dirt"
                end
                if love.math.noise(wx / 15, wy / 30, worldSeed + 100) > (-wy / 30) then
                    self.chunkTiles["backTiles"][ix][iy] = "none"
                end
            end
        end
        -- deuxième passe : stone
        for ix = 1, self.chunkSize do
            for iy = 1, self.chunkSize do
                local wx, wy  = self:convertChunkPosToWorldPos(ix, iy)
                local tileRaw = self:getRawTile(ix, iy, "tiles")
                local backRaw = self:getRawTile(ix, iy, "backTiles")
                if backRaw == "dirt" then
                    if love.math.noise(wx / 8, wy / 8, worldSeed + 600) > (wy / (depthProgression * 3)) + 0.75 then
                        if not (love.math.noise(wx / 45, wy / 30, worldSeed + 800) > 0.7) then
                            self.chunkTiles["backTiles"][ix][iy] = "stone"
                        end
                    end
                end
                if tileRaw == "dirt" then
                    if love.math.noise(wx / 8, wy / 8, worldSeed + 600) > (wy / (depthProgression * 3)) + 0.75 then
                        if not (love.math.noise(wx / 45, wy / 30, worldSeed + 800) > 0.7) then
                            self.chunkTiles["tiles"][ix][iy] = "stone"
                        end
                    end
                end
            end
        end
        self:advanceGenerationStatus(stepList)
        return
    end

    if step == "stone2" and world:getNeighboringChunks(self.chunkX, self.chunkY, "stone2") then
        for ix = 1, self.chunkSize do
            for iy = 1, self.chunkSize do
                local wx, wy  = self:convertChunkPosToWorldPos(ix, iy)
                local tileRaw = self:getRawTile(ix, iy, "tiles")
                local backRaw = self:getRawTile(ix, iy, "backTiles")
                local biome   = self:getBiome(wx, wy, worldSeed, depthProgression, biomeSize, biomeList)
                if checkifinlist(tileRaw, tilelists["stones"]) then
                    if biome == "hotland" then self.chunkTiles["tiles"][ix][iy] = "hotstone" end
                    if biome == "coldland" then
                        self.chunkTiles["tiles"][ix][iy] = "coldstone"
                        if love.math.noise(wx / 30, wy / 22, worldSeed - 855) < 0.4 then
                            self.chunkTiles["tiles"][ix][iy] = "ice"
                        end
                    end
                    if biome == "darkland" then self.chunkTiles["tiles"][ix][iy] = "shadowStone" end
                    if biome == "ancientland" then self.chunkTiles["tiles"][ix][iy] = "ancientstone" end
                end
                if checkifinlist(tileRaw, tilelists["stones"]) or tileRaw == "dirt" then
                    if biome == "duneland" then self.chunkTiles["tiles"][ix][iy] = "sand" end
                end
                if checkifinlist(backRaw, tilelists["stones"]) then
                    if biome == "hotland" then self.chunkTiles["backTiles"][ix][iy] = "hotstone" end
                    if biome == "coldland" then
                        self.chunkTiles["backTiles"][ix][iy] = "coldstone"
                        if love.math.noise(wx / 30, wy / 22, worldSeed - 855) < 0.4 then
                            self.chunkTiles["backTiles"][ix][iy] = "ice"
                        end
                    end
                    if biome == "darkland" then self.chunkTiles["backTiles"][ix][iy] = "shadowStone" end
                    if biome == "duneland" then self.chunkTiles["backTiles"][ix][iy] = "sand" end
                    if biome == "ancientland" then self.chunkTiles["backTiles"][ix][iy] = "ancientstone" end
                end
                if checkifinlist(backRaw, tilelists["stones"]) or backRaw == "dirt" then
                    if biome == "duneland" then self.chunkTiles["backTiles"][ix][iy] = "sand" end
                end
                if checkifinlist(tileRaw, tilelists["stones"]) then
                    if love.math.noise(wx / 35, wy / 35, worldSeed - 580) > (wy / (depthProgression * 5)) + 1.8 then
                        if love.math.noise(wx / 8, wy / 8, worldSeed + 242) > 0.72 or
                            love.math.noise(wx / 8, wy / 8, worldSeed + 242) < 0.1 then
                            self.chunkTiles["tiles"][ix][iy] = "lightstone"
                        end
                    end
                end
                if tileRaw == "stone" then
                    if love.math.noise(wx / 22, wy / 22, worldSeed + 950) > (wy / (depthProgression * 5)) + 0.75 then
                        if love.math.noise(wx / 8, wy / 18, worldSeed + 900) > 0.725 or
                            love.math.noise(wx / 8, wy / 18, worldSeed + 900) < 0.275 then
                            self.chunkTiles["tiles"][ix][iy] = "darkstone"
                        end
                    end
                end
                if checkifinlist(tileRaw, { "stone", "darkstone" }) then
                    if love.math.noise(wx / 35, wy / 35, worldSeed + 975) > (wy / (depthProgression * 5)) + 1 then
                        if love.math.noise(wx / 35, wy / 12, worldSeed + 505) > 0.75 or
                            love.math.noise(wx / 35, wy / 12, worldSeed + 505) < 0.275 then
                            self.chunkTiles["tiles"][ix][iy] = "palestone"
                        end
                    end
                end
                if checkifinlist(tileRaw, tilelists["stones"]) then
                    if love.math.noise(wx / 35, wy / 35, worldSeed - 580) > (wy / (depthProgression * 5)) + 1.2 then
                        if love.math.noise(wx / 8, wy / 12, worldSeed + 545) > 0.75 or
                            love.math.noise(wx / 8, wy / 12, worldSeed + 545) < 0.2 then
                            self.chunkTiles["tiles"][ix][iy] = "ancientstone"
                        end
                    end
                end
            end
        end
        self:advanceGenerationStatus(stepList)
        return
    end

    if step == "grass" and world:getNeighboringChunks(self.chunkX, self.chunkY, "grass") then
        for ix = 1, self.chunkSize do
            for iy = 1, self.chunkSize do
                local wx, wy  = self:convertChunkPosToWorldPos(ix, iy)
                local tileRaw = self:getRawTile(ix, iy, "tiles")

                if checkifinlist(tileRaw, { "dirt", "stone" }) then
                    if not (love.math.noise(wx / 20, wy / 20, worldSeed + 800) > (wy / (depthProgression * 3)) + 0.85) then
                        self.chunkTiles["topTiles"][ix][iy] = "grass"
                    end
                end
                if self.chunkTiles["topTiles"][ix][iy] == "grass" then
                    if love.math.noise(wx / 80, wy / 80, worldSeed - 122) > 0.65 then
                        self.chunkTiles["topTiles"][ix][iy] = "wheatgrass"
                    end
                end
                if checkifinlist(tileRaw, { "dirt", "stone", "darkstone" }) then
                    if not (love.math.noise(wx / 20, wy / 20, worldSeed + 520) < (wy / (depthProgression * 5)) + 0.85) and
                        love.math.noise(wx / 40, wy / 40, worldSeed + 585) < 0.35 then
                        self.chunkTiles["topTiles"][ix][iy] = "purplegrass"
                    end
                end
                if checkifinlist(tileRaw, tilelists["stones"]) then
                    if not (love.math.noise(wx / 20, wy / 20, worldSeed + 455) < (wy / (depthProgression * 6)) + 1.2) and
                        love.math.noise(wx / 90, wy / 90, worldSeed + 588) < 0.3 then
                        self.chunkTiles["topTiles"][ix][iy] = "shadowgrass"
                    end
                end
            end
        end
        self:advanceGenerationStatus(stepList)
        return
    end

    if step == "ores" and world:getNeighboringChunks(self.chunkX, self.chunkY, "ores") then
        for ix = 1, self.chunkSize do
            for iy = 1, self.chunkSize do
                local wx, wy  = self:convertChunkPosToWorldPos(ix, iy)
                local tileRaw = self:getRawTile(ix, iy, "tiles")
                if checkifinlist(tileRaw, tilelists["stones"]) then
                    if not (love.math.noise(wx / 20, wy / 20, worldSeed + 452) < (wy / (depthProgression * 20)) + 0.75) and
                        love.math.noise(wx / 6, wy / 12, worldSeed + 588) < 0.2 then
                        self.chunkTiles["topTiles"][ix][iy] = "diamond"
                    end
                end
            end
        end
        
        self:advanceGenerationStatus(stepList)
        return
    end

    if step == "deco" and world:getNeighboringChunks(self.chunkX, self.chunkY, "deco") then
        for ix = 1, self.chunkSize do
            for iy = 1, self.chunkSize do
                local wx, wy  = self:convertChunkPosToWorldPos(ix, iy)
                local tileRaw = self:getRawTile(ix, iy, "tiles")
                local topTileUnderRaw = world:getRawTile(wx, wy-1, "topTiles")

                if tiles[tileRaw]:canTileBeOverWritten() and topTileUnderRaw == "purplegrass" then
                    if love.math.noise(wx / 0.6, wy / 0.6, worldSeed + 152) < 0.2 then
                        self:placeTile("magicKelp",ix, iy,"tiles",true)
                    end
                end
            end
        end

        self:advanceGenerationStatus(stepList)
        return
    end


    --pas fini
end

--advanceGenerationStatus() --comme un setGenerationStatus, mais change vers le prochain, mis à la fin d'une étape de generate
function Chunk:advanceGenerationStatus(stepList)
    if nextinlistroll(self.generationStatus,stepList) == "done" then world:updateLight(self.chunkX, self.chunkY) end
    self.generationStatus = nextinlistroll(self.generationStatus,stepList)
    --pas fini
end

--getTerrain(worldPosX,wordPosY,worldSeed,depthProgression,biomeSize,biomeList) -- retourne soit 'air', ou 'dirt' (peut être false or true?)
--est appliqué à la base base de la génération pour déterminer si il y a de l'air ou du terrain à un endroit
function Chunk:getTerrain(worldPosX, wordPosY, worldSeed, depthProgression, biomeSize, biomeList)
    --pas fini
end

--convertChunkPosToWorldPos(posInChunkX,posInChunkY) --return worldPosX,worldPosY
function Chunk:convertChunkPosToWorldPos(posInChunkX, posInChunkY)
    local worldPosX, worldPosY
    worldPosX = self.chunkX * self.chunkSize + posInChunkX - 1
    worldPosY = self.chunkY * self.chunkSize + posInChunkY - 1
    return worldPosX, worldPosY
end

--getBiome(x,y) --return le nom du biome
function Chunk:getBiome(worldPosX, worldPosY, worldSeed, depthProgression, biomeSize, biomeList)
    local biome = "none"

    -- biome confidence
    -- 0 = near edge
    -- 1 = near center
    local nearCenter = 0

    local closestDist = math.huge
    local secondDist = math.huge

    -- biome noise coordinates
    local op1 = noise(
        worldPosX / biomeSize,
        worldPosY / biomeSize,
        worldSeed - 5
    )

    local op2 = love.math.noise(
        worldPosX / (biomeSize * 1.2),
        worldPosY / (biomeSize / 1.2),
        worldSeed - 10
    )

    for ib = 1, #biomeList do
        local currentBiome = biomeList[ib]

        -- distance from biome point
        local dx = op1 - currentBiome.option1
        local dy = op2 - currentBiome.option2

        local distance1 =
            math.sqrt(dx * dx + dy * dy)
            ^ currentBiome.likeness

        ------------------------------------------------
        -- DEPTH INFLUENCE
        ------------------------------------------------

        local depth = (-worldPosY / depthProgression)

        local minDepth = currentBiome.deepnessmin
        local maxDepth = currentBiome.deepnessmax
        local smooth = currentBiome.deepnesssmooth

        -- smooth entering
        local enter = (depth - minDepth) / smooth

        -- smooth leaving
        local exit = (maxDepth - depth) / smooth

        -- clamp
        if enter < 0 then enter = 0 end
        if enter > 1 then enter = 1 end

        if exit < 0 then exit = 0 end
        if exit > 1 then exit = 1 end

        -- final depth multiplier
        local depthStrength = math.min(enter, exit)

        ------------------------------------------------
        -- APPLY DEPTH
        ------------------------------------------------

        if depthStrength <= 0 then
            distance1 = math.huge
        else
            distance1 = distance1 / depthStrength
        end

        ------------------------------------------------
        -- TRACK 2 CLOSEST BIOMES
        ------------------------------------------------

        if distance1 < closestDist then
            secondDist = closestDist

            closestDist = distance1

            biome = currentBiome.name
        elseif distance1 < secondDist then
            secondDist = distance1
        end
    end

    ------------------------------------------------
    -- BIOME CENTER CONFIDENCE
    ------------------------------------------------

    -- no competing biome
    if secondDist == math.huge then
        nearCenter = 1
    elseif secondDist > 0 then
        nearCenter =
            1 - (closestDist / secondDist)

        if nearCenter < 0 then
            nearCenter = 0
        end

        if nearCenter > 1 then
            nearCenter = 1
        end
    else
        nearCenter = 1
    end

    return biome, nearCenter
end

--? getBiome , voir world.lua


--new(chunkX,chunkY) --retourne un chunk vide
--dans chunk il y a un tableau 2d tiles, un tableau 2d back, top, light et properties
--tiles,back et top comprennent seulement les noms des tiles, pas leur objet en tant que tel
--[[

--ceux si vont être dans world à la place


]]
