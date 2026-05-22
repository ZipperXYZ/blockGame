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
    self.canBeMined = self.flags.canBeMined or true
    self.color = self.flags.color or { 1, 1, 1, 1 }
    self.canbeWall = self.flags.canBeWall or self.type == "solid"
    self.lightCanGoThrough = self.flags.lightCanGoThrough or self.type ~= "solid"
    self.canBeOverWritten = self.flags.canBeOverWritten or self.type ~= "solid"
    self.health = self.flags.health or 1
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
