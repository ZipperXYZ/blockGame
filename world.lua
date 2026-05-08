


--new(worldseed,depthProgression,biomeSize,biomeList,generationSteps) --Biomelist peut être empty, 
--  depthProgression correspond au nombre de blocs
--  par progression du monde, comme par exemple, mettre 100 feras en sorte que des enemies vont commencer à spawn à y-100, d'autres à -200 et ça s'applique
--  sur tout genre les mobs, les ores, les tiles, les biomes, les structures etc.
--clear() -- vide le monde de tout ses chunks, gardant toutes ses propriétés les mêmes
--convertWorldPosToChunkPos(worldPosX,worldPosY) --return ChunkX,ChunkY,posInChunkX,posInChunkY
--convertChunkPosToWorldPos(ChunkX,ChunkY,posInChunkX,posInChunkY) --return worldPosX,worldPosY
--getNeighboringChunks(chunkX,chunkY) --return une liste de chunk,
    --à refaire puisque tu ne peux pas avoir la position globale avec juste une liste de chunks, serait inutile
    --peut être retourne la liste de coordonées de chaque chunks et les utilisés de cette façon?
--checkIfChunkCanGenerate(step) --return true/false, regarde tout les chunks autour pour savoir si il peut générer à une certaine étape
    --nomralement ça devrait généréer si tout les chunks autour ont finit l'étape précédante
    --je sais pas trop comment comparer les étapes de génération de chunk, peut être une liste de toutes les étapes en paramètre du monde
--placeTile(worldPosX,worldPosY,layer, bool: force) --return true/false si ça l'a marcher, force activé pour la genération du monde, force désactivé pour le joueur
    ----peut être placer une tile fait aussi un updateLight(?)
--destroyTile(worldPosX,worldPosY,layer) --supprime une tile pour laisser 'none' à la place, supprimer aussi certaines properties
--getTile(worldPosX,worldPosY,layer) --return un objet tile (à définir si ça le donne dans un tableau, avec les autres information
    --uniques qui sont nécessaires pour mettons l'information unique à une tile, comme son orientation, peut être un getTilePropreties
    --qui retourne les propriétés et setTilePropriety(propriety, value) qui set une propriété de la tile, comme l'inventaire d'un
    --coffre ou l'orientation d'un bloc)
--getTilePropreties(worldPosX,worldPosY) --retourne une liste, il n'y a pas de layer pour les propriétés, cela peut être mélangeant mais est bcp plus simple
--setTilePropriety(worldPosX,worldPosY,propriety, value)
--clearTileProprieties(worldPosX,worldPosY)
--generate(centerX,centerY,length,heigth,biomeList, boolean: force, step) --génére (ou essaille) de générer tout les chunks à l'écran, ou de progresser la génération
    --force va forcer jusqu'à ce que tout les chunks sont au minimum au step
    --devrait être éxécuter chaque seconde à la position de la caméra ainsi que avec force=false
    --pour la gen des structure, force=true pis la taille de la structure

-->biomes:
--addBiome(biome)
--getBiomes() --return biomes
--removeBiome(biomeName)
--?  getBiome(x,y ...?,worldSeed?,depthProgression?,biomeSize?,biomeList?) , retourne un biome à un certain endroit à partir d'une liste de biome.. 
    --pas sûr si il devrait être ici, ou à un autre endroit
    --peut être dans chunk?, en tout cas, à besoin de tout les paramètres lié aux biomes si c'est le cas, mais pas si c'est ici
    --retourne aussi une valeure biomeCentreDistance, qui retourne plus proche de 0 ver les bords du biomes et plus proche du 1 vers le centre du biome
-->structures:
    --? une liste de structure avec toutes les probabilités incluse dedans
    --peut être mais ce qui est sûr c'est que les fonctions de spawns de structures vont exister dans monde
-->entities:
    --? est-ce que les entitées interragisseront directment avec le monde? pas sur si ils seront dans le monde, probably not

-->draw:
--drawTiles(centerX,centerY,length,heigth,parameters)
    --déssine tout les tuiles à l'écran, ou à un endroit précis, mettre un paramètre précis comme un débug pour montrer le biome
    --peut être envoyé dans le parameters, mais il peut être vide aussi
--drawTile(worldPosX,worldPosY,layer)
    --dessine une tuile en spécifique dans le monde
    --ne peut pas être unique aux classes tile et chunk vue que chaque tuiles intéragit avec les autres (ex. les bordures)

