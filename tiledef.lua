require "class/superClass"

-- j'ai changer ton code pour qu'il marche

Tile = SuperClass:extend()
Tile.className = "Tile"

function Tile:init(tilename, tiletype, textureName, quadName, flags)
    self.name = tilename or "none"
    self.type = tiletype or "empty"
    self.textureName = textureName or "none"
    self.quadName = quadName or "none"
    self.flags = flags or nil

    --va regarde la liste globale des texture si elle comprend le name de la texture pis si non elle va créer la texture
    if not textures["textures"][textureName] and textureName ~= "none" then
        textures["textures"][textureName] = love.graphics.newImage(textureName)
    end

    --va regarde la liste globale des quads si elle comprend le name de la quad pis si non elle va créer la quad selon des paramètres
    if not textures["quads"][quadName] and quadName ~= "none" then
        textures["quads"][quadName] = love.graphics.newQuad(
            flags["newQuad"][1] * flags["newQuad"][5]
            , flags["newQuad"][2] * flags["newQuad"][5]
            , flags["newQuad"][3] * flags["newQuad"][5]
            , flags["newQuad"][4] * flags["newQuad"][5]
            , textures["textures"][textureName])
    end

    --flags comprend tout le reste, la pluspart vont être nil, donc assigner des variables pour tout de base
    -- comme par exemple 'newTile.isStone = flags.isStone or false', 'newTile.canBeMined = flags.canBeMined or true' -- ce sont juste des exemples,
    self.isStone = flags.isStone or false
    self.canBeMined = flags.canBeMined or true
end

--  il s'agit ici de la défénition d'une tuile, est la même pour chaque tiles du même type dans le monde
--  pour les propriété unique à une tuile (inventaire d'un coffre, orientation, vie de la tuile), utilise
--  getTilePropreties et setTileProprety dans l'objet monde
--new()
--getName()
--getTexture() (ne retourne pas le nom de la texture mais le fichier texture, meme si il est pas storé dedans, il le cherche par son nom)
--getQuad() (ne retourne pas le nom du quad mais le quad en tant que tel, meme si il est pas storé dedans, il le cherche par son nom)
--get... (pour tout les propriétés)
--il n'y a pas de setters vue qu'il s'agie seulement de la défénition des tuiles et ne devrait jamais changer
--? place(), fonction qui se passe quand tu placeras une tile, unique à certain type de tiles, à vérifier
--? remove()
