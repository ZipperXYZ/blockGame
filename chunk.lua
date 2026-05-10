require "class/superClass"

Chunk = SuperClass:extend()
Chunk.className = "Chunk"

function Chunk:init(chunkX,chunkY,chunkSize)
    if (not chunkX) or (not chunkY) then
        return
    end
    self.chunkX=chunkX -- changer Chunkx pour chunkX
    self.chunkY=chunkY
    self.chunkSize=chunkSize
    self.generationStatus="none"
    self.tiles={}
    self.tiles["tiles"]={}
    self.tiles["topTiles"]={}
    self.tiles["backTiles"]={}
    self.tiles["lights"]={}
    self.tiles["properties"]={}
    for ix=1, self.chunkSize do
        self.tiles["tiles"][ix]={}
        self.tiles["topTiles"][ix]={}
        self.tiles["backTiles"][ix]={}
        self.tiles["lights"][ix]={}
        self.tiles["properties"][ix]={}
        for iy=1, self.chunkSize do
            self.tiles["tiles"][ix][iy]="dirt"
            self.tiles["topTiles"][ix][iy]="none"
            self.tiles["backTiles"][ix][iy]="none"
            self.tiles["lights"][ix][iy]={1,1,1,1}
            self.tiles["properties"][ix][iy]={}
        end
    end
end

--la pluspart des fonctions ici ne sont pas sensé être utilisé en tant que tels, à par la génération, ils devraient juste être utilisé
--par un objet world


--getTile(xinchunk,yinchunk,layer) --retourne un objet tile selon le nom de la tile
    --vue que lua est bien, on pourrait metre comme layer 'light' pis ça donnerait le tableau lumière ({1,1,1,1}) d'une tile au lieu d'un objet tile
function Chunk:getTile(xInChunk,yInChunk,layer)
    if layer=="top" then layer="topTiles" end
    if layer=="back" then layer="backTiles" end
    local tile=nil
    if self.tiles[layer]==nil then return tiles["none"] end
    if (xInChunk<=0 or xInChunk>self.chunkSize or yInChunk<=0 or yInChunk>self.chunkSize) then return tiles["none"] end
    tile=self.tiles[layer][xInChunk][yInChunk]
    if layer~="lights" and layer~="properties" then tile=tiles[tile] end
    return tile
end
--placeTile(xinchunk,yinchunk,layer,bool:force) 
    --layer peut etre soit tile, back et top, usually faudrait checker si une tile peut être placé en top (comme gazon ou les ores)
    --la pluspart des tiles peuvent être placé dans tile, mais seulement certaines peuvent être placé dans back (peut être faire une
    --fonction canBeWall dans tileDef)
function Chunk:placeTile(tile,xInChunk,yInChunk,layer,force) 
    if layer=="top" then layer="topTiles" end
    if layer=="back" then layer="backTiles" end
    if self.tiles[layer]==nil then return false end
    if (xInChunk<=0 or xInChunk>self.chunkSize or yInChunk<=0 or yInChunk>self.chunkSize) then return false end
    if force or true then
        self.tiles[layer][xInChunk][yInChunk]=tile
        return true
    end
end

function Chunk:destroyTile(xInChunk,yInChunk,layer,force) 
    if layer=="top" then layer="topTiles" end
    if layer=="back" then layer="backTiles" end
    if self.tiles[layer]==nil then return false end
    if (xInChunk<=0 or xInChunk>self.chunkSize or yInChunk<=0 or yInChunk>self.chunkSize) then return false end
    if force or true then
        self.tiles[layer][xInChunk][yInChunk]="none"
        return true
    end
end

--getGenerationStatus() -- return world gen status of the chunk
function Chunk:getGenerationStatus()
    return self.generationStatus
end

--generate(step,chunkX,chunkY,worldSeed,depthProgression,biomeSize,biomeList) -- generate according to step
function Chunk:generate(step,stepList,worldSeed,depthProgression,biomeSize,biomeList, world)
    if (step == "none") then
        for ix = 1, self.chunkSize do
            for iy = 1, self.chunkSize do
                local wx, wy = self:convertChunkPosToWorldPos(ix,iy)
                self.tiles["tiles"][ix][iy] = world:generateTerrainTile(wx, wy)
                self.tiles["topTiles"][ix][iy]  = "none"
                self.tiles["backTiles"][ix][iy] = "none"
                self.tiles["lights"][ix][iy]    = {1, 1, 1, 1}
            end
        end

        self.generationStatus = "stone"
        return
    end


    if step == "stone" and world:getNeighboringChunks(self.chunkX, self.chunkY, "stone") then
        -- première passe : backs
        for ix = 1, self.chunkSize do
            for iy = 1, self.chunkSize do
                
                local wx, wy = self:convertChunkPosToWorldPos(ix, iy)

                if love.math.noise(wx/14, wy/14, worldSeed-608) < 0.6 then
                    self.tiles["backTiles"][ix][iy] = "dirt_wall"
                end
                if love.math.noise(wx/15, wy/30, worldSeed+100) > (-wy/30) then
                    self.tiles["backTiles"][ix][iy] = "none"
                end
            end
        end
        -- deuxième passe : stone
        for ix = 1, self.chunkSize do
            for iy = 1, self.chunkSize do
                local wx, wy  = self:convertChunkPosToWorldPos(ix, iy)
                local tileRaw = self:getTile(ix, iy, "tiles")
                local backRaw = self:getTile(ix, iy, "backTiles")
                if backRaw == "dirt_wall" then
                    if love.math.noise(wx/8, wy/8, worldSeed+600) > (wy/(dp*3))+0.75 then
                        if not (love.math.noise(wx/45, wy/30, worldSeed+800) > 0.7) then
                            self.tiles["backTiles"][ix][iy] = "stone_wall"
                        end
                    end
                end
                if tileRaw == "dirt" then
                    if love.math.noise(wx/8, wy/8, worldSeed+600) > (wy/(dp*3))+0.75 then
                        if not (love.math.noise(wx/45, wy/30, worldSeed+800) > 0.7) then
                            self.tiles["tiles"][ix][iy] = "stone"
                        end
                    end
                end
            end
        end
        self.generationStatus = "stone2"
        return
    end


    --pas fini
end

--advanceGenerationStatus() --comme un setGenerationStatus, mais change vers le prochain, mis à la fin d'une étape de generate
function Chunk:advanceGenerationStatus(stepList)
    --pas fini
end

--getTerrain(worldPosX,wordPosY,worldSeed,depthProgression,biomeSize,biomeList) -- retourne soit 'air', ou 'dirt' (peut être false or true?)
    --est appliqué à la base base de la génération pour déterminer si il y a de l'air ou du terrain à un endroit
function Chunk:getTerrain(worldPosX,wordPosY,worldSeed,depthProgression,biomeSize,biomeList)
    --pas fini
end

--convertChunkPosToWorldPos(posInChunkX,posInChunkY) --return worldPosX,worldPosY
function Chunk:convertChunkPosToWorldPos(posInChunkX,posInChunkY)
    local worldPosX, worldPosY
    worldPosX=self.chunkX*self.chunkSize+posInChunkX-1 
    worldPosY=self.chunkY*self.chunkSize+posInChunkY-1 
    return worldPosX, worldPosY
end

--getBiome(x,y) --return le nom du biome
function Chunk:getBiome(posInChunkX,posInChunkY,worldSeed,depthProgression,biomeSize,biomeList)

end


--? getBiome , voir world.lua


--new(chunkX,chunkY) --retourne un chunk vide
    --dans chunk il y a un tableau 2d tiles, un tableau 2d back, top, light et properties
    --tiles,back et top comprennent seulement les noms des tiles, pas leur objet en tant que tel
--[[

--ceux si vont être dans world à la place


]]


