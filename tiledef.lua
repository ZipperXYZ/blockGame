require "class/superClass"

-- j'ai changer ton code pour qu'il marche

Tile = SuperClass:extend()
Tile.className = "Tile"

function Tile:init(tilename,tiletype,textureName,quadName,flags)

    if tilename then
    self.name = tilename
    else
        return
    end
    self.type = tiletype or ""
    self.textureName = textureName or ""
    --va regarde la liste globale des texture si elle comprend le name de la texture pis si non elle va créer la texture
    self.quadName = quadName or ""
    --va regarde la liste globale des quads si elle comprend le name de la quad pis si non elle va créer la quad selon des paramètres
    self.flags = flags or nil
    --flags comprend tout le reste, la pluspart vont être nil, donc assigner des variables pour tout de base
    -- comme par exemple 'newTile.isStone = flags.isStone or false', 'newTile.canBeMined = flags.canBeMined or true' -- ce sont juste des exemples,
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