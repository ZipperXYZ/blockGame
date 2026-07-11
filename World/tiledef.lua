require "class/superClass"

Tile = SuperClass:extend()
Tile.className = "Tile"

--init()
function Tile:init(tilename, tiletype, textureName, quadName, flags)
    self.name = tilename or "none"
    self.type = tiletype or "empty"
    self.textureName = textureName or "tiles.png"
    self.quadName = quadName or "none"
    self.flags = flags or {}
    self.properties = {}
    self.borderType = self.flags["border type"] or "same block"
    self.border = self.flags["border"] or {}
    self.actualName = self.flags.actualName or self.name
    if self.border == {} then self.borderType = "none" end

    self.textureName = ("Textures/" .. self.textureName)

    --va regarde la liste globale des texture si elle comprend le name de la texture pis si non elle va créer la texture
    if not textures["textures"][self.textureName] and self.textureName ~= "none" then
        textures["textures"][self.textureName] = love.graphics.newImage(self.textureName)
    end

    --va regarde la liste globale des quads si elle comprend le name de la quad pis si non elle va créer la quad selon des paramètres
    if not textures["quads"][self.quadName] and self.quadName ~= "none" then
        textures["quads"][self.quadName] = love.graphics.newQuad(
            self.flags["newQuad"][1] * self.flags["newQuad"][5]
            , self.flags["newQuad"][2] * self.flags["newQuad"][5]
            , self.flags["newQuad"][3] * self.flags["newQuad"][5]
            , self.flags["newQuad"][4] * self.flags["newQuad"][5]
            , textures["textures"][self.textureName])
        self.textureCenterX = self.flags.textureCenterX or (self.flags["newQuad"][3] * self.flags["newQuad"][5] / 2)
        self.textureCenterY = self.flags.textureCenterY or (self.flags["newQuad"][4] * self.flags["newQuad"][5] / 2)
    else
        self.textureCenterX = self.flags.textureCenterX or (4)
        self.textureCenterY = self.flags.textureCenterY or (4)
    end

    --flags comprend tout le reste, la pluspart vont être nil, donc assigner des variables pour tout de base
    -- comme par exemple 'newTile.isStone = flags.isStone or false', 'newTile.canBeMined = flags.canBeMined or true' -- ce sont juste des exemples,
    if self.border.quad ~= "none" and not textures["quads"][self.border.quad] and self.border["newQuad"] then
        textures["quads"][self.border.quad] = love.graphics.newQuad(
            self.border["newQuad"][1] * self.border["newQuad"][5]
            , self.border["newQuad"][2] * self.border["newQuad"][5]
            , self.border["newQuad"][3] * self.border["newQuad"][5]
            , self.border["newQuad"][4] * self.border["newQuad"][5]
            , textures["textures"][self.textureName])
    end
    self.isStone = self.flags.isStone or false
    self.hasCollisions = self.flags.hasCollisions or (self.type == "solid")
    self.canBeMined = self.flags.canBeMined or ((self.type == "not-solid") or (self.type == "solid") or (self.textureName ~= "none"))
    self.color = self.flags.color or { 1, 1, 1, 1 }
    self.canbeWall = self.flags.canBeWall or self.type == "solid"
    self.lightCanGoThrough = self.flags.lightCanGoThrough or self.type ~= "solid"
    self.canBeOverWritten = self.flags.canBeOverWritten or self.type ~= "solid"

    self.particleColor = self.flags.particleColor or {0.45,0.45,0.45,0.5}
    self.particleType = self.flags.particleType or "dust"

    self.actualDropeRate = self.flags.actualDropeRate or 0.1
    self.secondaryDropAmount = self.flags.secondaryDropAmount or 1
    self.secondaryDrop = self.flags.secondaryDrop or "rock"


    self.particleEmit = self.flags.particleEmit or "none"
    self.particleEmitData = self.flags.particleEmitData or {}
    self.particleEmitData.amount = self.particleEmitData.amount or 1
    self.particleEmitData.motion = self.particleEmitData.motion or self.particleEmit
    self.particleEmitData.motionStrength = self.particleEmitData.motionStrength or 1
    self.particleEmitData.motionArcAngle = self.particleEmitData.motionArcAngle or 0
    self.particleEmitData.motionArcSpread = self.particleEmitData.motionArcSpread or 360
    self.particleEmitData.radius = self.particleEmitData.radius or 0.5
    self.particleEmitData.timer = self.particleEmitData.timer or 1
    self.particleEmitData.timerNoise = self.particleEmitData.timerNoise or (self.particleEmitData.timer*0.5)
    self.particleEmitData.color = self.particleEmitData.color or {1,0,1,1}
    self.particleEmitData.colorNoise = self.particleEmitData.colorNoise or {0.05,0.05,0.05,0.05}
    self.particleEmitData.flags = self.particleEmitData.flags or {}
    self.particleEmitData.hasCollisions = self.particleEmitData.hasCollisions or false


    self.health = self.flags.health or 1

    table.insert(tilelists["all tiles"],self.name)
    if self.isStone then table.insert(tilelists["stones"],self.name) end
end

function Tile:emitParticles(x,y,dt)
    if self.particleEmit ~= "none" and self.particleEmit ~= nil then
        if math.random()>0.92 then
            
            world:spawnParticles(
                self.particleEmitData.amount,
                self.particleEmitData.name,
                Vector2(x,y):copy(),
                self.particleEmitData.radius,
                self.particleEmitData.color, 
                self.particleEmitData.colorNoise, 
                self.particleEmitData.timer, 
                self.particleEmitData.timerNoise,
                self.particleEmitData.motion, 
                self.particleEmitData.motionStrength, 
                self.particleEmitData.motionArcAngle, 
                self.particleEmitData.motionArcSpread, 
                CopyAll(self.particleEmitData.flags))
        end
    end
end

function Tile:tileDestroyed(x,y)
    if math.random()< self.actualDropeRate then
        world:spawnGroundItem(self.name, Vector2(x,y), Vector2(0,0), 1, {}, {})
    else
        if self.secondaryDrop ~= "none" and self.secondaryDrop ~= nil and self.secondaryDropAmount > 0 then
            local quantity = math.ceil(math.random()*self.secondaryDropAmount)
            if quantity>0  then
                world:spawnGroundItem(self.secondaryDrop, Vector2(x,y), Vector2(0,0), quantity, {}, {})
            end
            
        end
    end
    
end

--getName()
function Tile:getName()
    return self.name
end

--getTexture() (ne retourne pas le nom de la texture mais le fichier texture, meme si il est pas storé dedans, il le cherche par son nom)
function Tile:getTexture()
    return textures["textures"][self.textureName]
end

--getQuad() (ne retourne pas le nom du quad mais le quad en tant que tel, meme si il est pas storé dedans, il le cherche par son nom)
function Tile:getQuad()
    return textures["quads"][self.quadName]
end

--get... (pour tout les propriétés)
function Tile:getType()
    return self.type
end

function Tile:getFlags()
    return self.flags
end

function Tile:getBorder()
    return self.border
end

function Tile:getBorderType()
    return self.borderType
end

function Tile:getLightCanGoThrough()
    return self.lightCanGoThrough
end

function Tile:canTileBeOverWritten()
    return self.canBeOverWritten
end

function Tile:getColor()
    return self.color
end

function Tile:getBorderQuad()
    return textures["quads"][self.border.quad]
end

function Tile:getColision()
    return self.hasCollisions
end

function Tile:getTextureCenterX()
    return self.textureCenterX
end

function Tile:getTextureCenterY()
    return self.textureCenterY
end

--  il s'agit ici de la défénition d'une tuile, est la même pour chaque tiles du même type dans le monde
--  pour les propriété unique à une tuile (inventaire d'un coffre, orientation, vie de la tuile), utilise
--  getTilePropreties et setTileProprety dans l'objet monde

--il n'y a pas de setters vue qu'il s'agie seulement de la défénition des tuiles et ne devrait jamais changer

--? place(), fonction qui se passe quand tu placeras une tile, unique à certain type de tiles, à vérifier
--? remove()
