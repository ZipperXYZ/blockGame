Tile = {}

Tile.__index = Tile

function Tile.new(tilename,tiletype,textureName,quadName,flags)
    local newTile = {}

    if tilename then
    newTile.name = tilename
    else
        return
    end
    newTile.type = tiletype
    newTile.textureName = textureName
    --va regarde la liste globale des texture si elle comprend le name de la texture pis si non elle va créer la texture
    newTile.quadName = quadName
    --va regarde la liste globale des quads si elle comprend le name de la quad pis si non elle va créer la quad selon des paramètres
    newTile.flags = flags
    --flags comprend tout le reste, la pluspart vont être nil, donc assigner des variables pour tout de base
    -- comme par exemple 'newTile.isStone = flags.isStone or false', 'newTile.canBeMined = flags.canBeMined or true' -- ce sont juste des exemples,

    setmetatable(newTile,Tile)
    return newTile
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