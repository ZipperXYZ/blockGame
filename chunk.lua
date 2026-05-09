require "class/superClass"

Chunk = SuperClass:extend()
Chunk.className = "Chunk"

function Chunk:init(chunkX,chunkY,chunkSize)
    if (not chunkX) or (not chunkY) then
        return
    end
    self.ChunkX=chunkX
    self.chunkY=chunkY
    self.chunkSize=chunkSize
    self.generationStatus="none"
    self.tiles={}
    self.backTiles={}
    self.topTiles={}
    self.lights={}
    self.tileProperties={}
    for ix=1, self.chunkSize do
        self.tiles[ix]={}
        self.backTiles[ix]={}
        self.topTiles[ix]={}
        self.lights[ix]={}
        self.tileProperties[ix]={}
        for iy=1, self.chunkSize do
            self.tiles[ix][iy]="dirt"
            self.backTiles[ix][iy]="none"
            self.topTiles[ix][iy]="none"
            self.lights[ix][iy]={1,1,1,1}
            self.tileProperties[ix][iy]={}
        end
    end
end

--la pluspart des fonctions ici ne sont pas sensé être utilisé en tant que tels, à par la génération, ils devraient juste être utilisé
--par un objet world


--getTile(xinchunk,yinchunk,layer) --retourne un objet tile selon le nom de la tile
    --vue que lua est bien, on pourrait metre comme layer 'light' pis ça donnerait le tableau lumière ({1,1,1,1}) d'une tile au lieu d'un objet tile
function Chunk:getTile(xinchunk,yinchunk,layer,force)

end
--placeTile(xinchunk,yinchunk,layer,bool:force) 
    --layer peut etre soit tile, back et top, usually faudrait checker si une tile peut être placé en top (comme gazon ou les ores)
    --la pluspart des tiles peuvent être placé dans tile, mais seulement certaines peuvent être placé dans back (peut être faire une
    --fonction canBeWall dans tileDef)
function Chunk:placeTile(tile,xinchunk,yinchunk,layer,force)

end

--getGenerationStatus() -- return world gen status of the chunk
function Chunk:getGenerationStatus()
    return self.generationStatus
end

--generate(step,chunkX,chunkY,worldSeed,depthProgression,biomeSize,biomeList) -- generate according to step
function Chunk:generate(step,stepList,worldSeed,depthProgression,biomeSize,biomeList)

end

--advanceGenerationStatus() --comme un setGenerationStatus, mais change vers le prochain, mis à la fin d'une étape de generate
function Chunk:advanceGenerationStatus(stepList)

end

--getTerrain(worldPosX,wordPosY,worldSeed,depthProgression,biomeSize,biomeList) -- retourne soit 'air', ou 'dirt' (peut être false or true?)
    --est appliqué à la base base de la génération pour déterminer si il y a de l'air ou du terrain à un endroit
function Chunk:getTerrain(worldPosX,wordPosY,worldSeed,depthProgression,biomeSize,biomeList)

end

--convertChunkPosToWorldPos(posInChunkX,posInChunkY) --return worldPosX,worldPosY
function Chunk:convertChunkPosToWorldPos(posInChunkX,posInChunkY)

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


