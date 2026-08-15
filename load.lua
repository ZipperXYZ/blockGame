function loadeverything()
  
  loadtextures()
  loadtiles()
  loadItems()
  GenerateTileItems()
  LoadInterfaces()

  LoadStructureList()
  --loadbiomes()
  LoadSpawnCards()
  loadEntities()

  LoadItemCards()
  LoadItemEnchantmentCards()

  LoadItemSets()
end

function loadtextures()
  print("loadtextures")
  textures = {}
  textures["textures"] = {}
  textures["quads"] = {}
  textures["sprites"] = {}

  textures["textures"]["colorisationShader"]= love.graphics.newShader([[
    extern vec3 tintColor;
    extern float strength;

    vec4 effect(vec4 color, Image texture, vec2 tc, vec2 sc)
    {
        vec4 tex = Texel(texture, tc);

        // grayscale value
        float gray = (tex.r + tex.g + tex.b) / 3.0;

        // target tinted color
        vec3 tinted = gray * tintColor;

        // blend original -> tinted
        vec3 finalColor = mix(tex.rgb, tinted, strength);

        return vec4(finalColor, tex.a);
    }
    ]])

  textures["textures"]["tiles.png"]=love.graphics.newImage("Textures/tiles.png")
  textures["textures"]["items1.png"]=love.graphics.newImage("Textures/items1.png")
  textures["textures"]["player.png"]=love.graphics.newImage("Textures/player.png")
  textures["textures"]["miscTiles.png"]=love.graphics.newImage("Textures/miscTiles.png")
  textures["textures"]["inventoryIcons.png"]=love.graphics.newImage("Textures/inventoryIcons.png")
  textures["textures"]["projectiles.png"]=love.graphics.newImage("Textures/projectiles.png")
  textures["sprites"]["inventoryIcons"] = Sprite("inventoryIcons","inventoryIcons.png",{
    ["parts"] = {"space","leftClick","rightClick","shift","r","x","c","space2","leftClick2","rightClick2","shift2","r2","x2","c2","headplate","chestplate","leggings","necklace","armlet","charm","accessory"},
    ["space"] ={
      ["type"] = "still", ["timePerFrame"] = 1, ["gridMultiplication"] = 16, ["spriteSize"] = {1,1}, ["spriteCenter"] = {0.5,0.5}, ["quads"] = {{0,0}}
    },
    ["leftClick"] ={
      ["type"] = "still", ["timePerFrame"] = 1, ["gridMultiplication"] = 16, ["spriteSize"] = {1,1}, ["spriteCenter"] = {0.5,0.5}, ["quads"] = {{1,0}}
    },
    ["rightClick"] ={
      ["type"] = "still", ["timePerFrame"] = 1, ["gridMultiplication"] = 16, ["spriteSize"] = {1,1}, ["spriteCenter"] = {0.5,0.5}, ["quads"] = {{2,0}}
    },
    ["shift"] ={
      ["type"] = "still", ["timePerFrame"] = 1, ["gridMultiplication"] = 16, ["spriteSize"] = {1,1}, ["spriteCenter"] = {0.5,0.5}, ["quads"] = {{3,0}}
    },
    ["r"] ={
      ["type"] = "still", ["timePerFrame"] = 1, ["gridMultiplication"] = 16, ["spriteSize"] = {1,1}, ["spriteCenter"] = {0.5,0.5}, ["quads"] = {{4,0}}
    },
    ["x"] ={
      ["type"] = "still", ["timePerFrame"] = 1, ["gridMultiplication"] = 16, ["spriteSize"] = {1,1}, ["spriteCenter"] = {0.5,0.5}, ["quads"] = {{5,0}}
    },
    ["c"] ={
      ["type"] = "still", ["timePerFrame"] = 1, ["gridMultiplication"] = 16, ["spriteSize"] = {1,1}, ["spriteCenter"] = {0.5,0.5}, ["quads"] = {{6,0}}
    },
    ["space2"] ={
      ["type"] = "still", ["timePerFrame"] = 1, ["gridMultiplication"] = 16, ["spriteSize"] = {1,1}, ["spriteCenter"] = {0.5,0.5}, ["quads"] = {{0,1}}
    },
    ["leftClick2"] ={
      ["type"] = "still", ["timePerFrame"] = 1, ["gridMultiplication"] = 16, ["spriteSize"] = {1,1}, ["spriteCenter"] = {0.5,0.5}, ["quads"] = {{1,1}}
    },
    ["rightClick2"] ={
      ["type"] = "still", ["timePerFrame"] = 1, ["gridMultiplication"] = 16, ["spriteSize"] = {1,1}, ["spriteCenter"] = {0.5,0.5}, ["quads"] = {{2,1}}
    },
    ["shift2"] ={
      ["type"] = "still", ["timePerFrame"] = 1, ["gridMultiplication"] = 16, ["spriteSize"] = {1,1}, ["spriteCenter"] = {0.5,0.5}, ["quads"] = {{3,1}}
    },
    ["r2"] ={
      ["type"] = "still", ["timePerFrame"] = 1, ["gridMultiplication"] = 16, ["spriteSize"] = {1,1}, ["spriteCenter"] = {0.5,0.5}, ["quads"] = {{4,1}}
    },
    ["x2"] ={
      ["type"] = "still", ["timePerFrame"] = 1, ["gridMultiplication"] = 16, ["spriteSize"] = {1,1}, ["spriteCenter"] = {0.5,0.5}, ["quads"] = {{5,1}}
    },
    ["c2"] ={
      ["type"] = "still", ["timePerFrame"] = 1, ["gridMultiplication"] = 16, ["spriteSize"] = {1,1}, ["spriteCenter"] = {0.5,0.5}, ["quads"] = {{6,1}}
    },
    ["headplate"] ={
      ["type"] = "still", ["timePerFrame"] = 1, ["gridMultiplication"] = 16, ["spriteSize"] = {1,1}, ["spriteCenter"] = {0.5,0.5}, ["quads"] = {{0,2}}
    },
    ["chestplate"] ={
      ["type"] = "still", ["timePerFrame"] = 1, ["gridMultiplication"] = 16, ["spriteSize"] = {1,1}, ["spriteCenter"] = {0.5,0.5}, ["quads"] = {{1,2}}
    },
    ["leggings"] ={
      ["type"] = "still", ["timePerFrame"] = 1, ["gridMultiplication"] = 16, ["spriteSize"] = {1,1}, ["spriteCenter"] = {0.5,0.5}, ["quads"] = {{2,2}}
    },
    ["necklace"] ={
      ["type"] = "still", ["timePerFrame"] = 1, ["gridMultiplication"] = 16, ["spriteSize"] = {1,1}, ["spriteCenter"] = {0.5,0.5}, ["quads"] = {{3,2}}
    },
    ["armlet"] ={
      ["type"] = "still", ["timePerFrame"] = 1, ["gridMultiplication"] = 16, ["spriteSize"] = {1,1}, ["spriteCenter"] = {0.5,0.5}, ["quads"] = {{4,2}}
    },
    ["charm"] ={
      ["type"] = "still", ["timePerFrame"] = 1, ["gridMultiplication"] = 16, ["spriteSize"] = {1,1}, ["spriteCenter"] = {0.5,0.5}, ["quads"] = {{5,2}}
    },
    ["accessory"] ={
      ["type"] = "still", ["timePerFrame"] = 1, ["gridMultiplication"] = 16, ["spriteSize"] = {1,1}, ["spriteCenter"] = {0.5,0.5}, ["quads"] = {{6,2}}
    }
  }, {})
  textures["sprites"]["essenceStick"] = Sprite("essenceStick","items1.png",{["parts"] = {"small","medium","large"}},{["setupItem"] = true,["itemQuadrant"]={0,0}})
  textures["sprites"]["rock"] = Sprite("rock","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={0,8}})
  textures["sprites"]["unknown"] = Sprite("unknown","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={7,0}})

  textures["sprites"]["crudePickaxe"] = Sprite("crudePickaxe","items1.png",{["parts"] = {"small","medium","large"}},{["setupItem"] = true,["itemQuadrant"]={0,4}})
  textures["sprites"]["crudeSpike"] = Sprite("crudeSpike","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={0,12}})
  textures["sprites"]["crudeSwayPickaxe"] = Sprite("crudeSwayPickaxe","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={0,16}})
  textures["sprites"]["crudeHammer"] = Sprite("crudeHammer","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={0,20}})
  textures["sprites"]["crudeScalpel"] = Sprite("crudeScalpel","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={0,24}})
  textures["sprites"]["crudeShovel"] = Sprite("crudeShovel","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={0,28}})
  textures["sprites"]["crudeStiffPick"] = Sprite("crudeStiffPick","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={0,32}})
  textures["sprites"]["crudeTargetPickaxe"] = Sprite("crudeTargetPickaxe","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={0,36}})
  textures["sprites"]["crudeSword"] = Sprite("crudeSword","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={0,40}})

  textures.sprites.thunderBirdFeather = Sprite("thunderBirdFeather","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={0,44}})
  textures.sprites.angelFeather = Sprite("angelFeather","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={0,48}})
  textures.sprites.crudeBow = Sprite("crudeBow","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={0,56}})
  textures.sprites.bombItem = Sprite("bombItem","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={0,60}})
  textures.sprites.stick = Sprite("stick","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={0,64}})
  
  textures.sprites.clearRing = Sprite("clearRing","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={7,4}})
  textures.sprites.pickaxeTop = Sprite("pickaxeTop","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={7,8}})
  textures.sprites.spikeTop = Sprite("spikeTop","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={7,12}})
  textures.sprites.swayPickaxeTop = Sprite("swayPickaxeTop","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={7,16}})
  textures.sprites.hammerTop = Sprite("hammerTop","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={7,20}})
  textures.sprites.chiselTop = Sprite("chiselTop","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={7,24}})
  textures.sprites.shovelTop = Sprite("shovelTop","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={7,28}})
  textures.sprites.stiffPickTop = Sprite("stiffPickTop","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={7,32}})
  textures.sprites.targetPickaxeTop = Sprite("targetPickaxeTop","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={7,36}})
  textures.sprites.smallSwordTop = Sprite("smallSwordTop","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={7,40}})
  textures.sprites.swordTop = Sprite("swordTop","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={7,44}})
  textures.sprites.bigSwordTop = Sprite("bigSwordTop","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={7,48}})
  textures.sprites.lanceTop = Sprite("lanceTop","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={7,52}})
  textures.sprites.ringTop = Sprite("ringTop","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={7,56}})
  textures.sprites.bowTop = Sprite("bowTop","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={7,60}})
  
  textures.sprites.toolBase = Sprite("toolBase","items1.png",{parts = {"small","medium"}},{setupItem = true,itemQuadrant={14,0}})
  textures.sprites.toolBaseSmall = Sprite("toolBaseSmall","items1.png",{parts = {"small","medium"}},{setupItem = true,itemQuadrant={14,4}})
  textures.sprites.toolBaseSmall2 = Sprite("toolBaseSmall2","items1.png",{parts = {"small","medium"}},{setupItem = true,itemQuadrant={14,8}})
  textures.sprites.spikeTopCrystal = Sprite("spikeTopCrystal","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={14,12}})
  textures.sprites.swayPickaxeTopCrystal = Sprite("swayPickaxeTopCrystal","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={14,16}})
  textures.sprites.hammerTopCrystal = Sprite("hammerTopCrystal","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={14,20}})
  textures.sprites.chiselTopCrystal = Sprite("chiselTopCrystal","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={14,24}})
  textures.sprites.shovelTopCrystal = Sprite("shovelTopCrystal","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={14,28}})
  textures.sprites.stiffPickTopCrystal = Sprite("stiffPickTopCrystal","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={14,32}})
  textures.sprites.targetPickaxeTopCrystal = Sprite("targetPickaxeTopCrystal","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={14,36}})
  textures.sprites.smallSwordTopCrystal = Sprite("smallSwordTopCrystal","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={14,40}})
  textures.sprites.swordTopCrystal = Sprite("swordTopCrystal","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={14,44}})
  textures.sprites.bigSwordTopCrystal = Sprite("bigSwordTopCrystal","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={14,48}})
  textures.sprites.lanceTopCrystal = Sprite("lanceTopCrystal","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={14,52}})
  textures.sprites.pickaxeTopCrystal = Sprite("pickaxeTopCrystal","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={14,56}})
  textures.sprites.ringTopCrystal = Sprite("ringTopCrystal","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={14,64}})
  textures.sprites.bowTopCrystal = Sprite("bowTopCrystal","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={14,68}})

  textures.sprites.fireRing = Sprite("fireRing","items1.png",{parts = {"small","medium"}},{setupItem = true,itemQuadrant={21,0}})
  textures.sprites.coldRing = Sprite("coldRing","items1.png",{parts = {"small","medium"}},{setupItem = true,itemQuadrant={21,4}})
  textures.sprites.natureRing = Sprite("natureRing","items1.png",{parts = {"small","medium"}},{setupItem = true,itemQuadrant={21,8}})
  textures.sprites.goldRing = Sprite("goldRing","items1.png",{parts = {"small","medium"}},{setupItem = true,itemQuadrant={21,12}})
  textures.sprites.voidRing = Sprite("voidRing","items1.png",{parts = {"small","medium"}},{setupItem = true,itemQuadrant={21,16}})
  textures.sprites.healthNecklace = Sprite("healthNecklace","items1.png",{parts = {"small","medium"}},{setupItem = true,itemQuadrant={21,20}})
  textures.sprites.greaterHealthNecklace = Sprite("greaterHealthNecklace","items1.png",{parts = {"small","medium"}},{setupItem = true,itemQuadrant={21,24}})
  textures.sprites.movementArtifact = Sprite("movementArtifact","items1.png",{parts = {"small","medium"}},{setupItem = true,itemQuadrant={21,28}})
  textures.sprites.glassArtifact = Sprite("glassArtifact","items1.png",{parts = {"small","medium"}},{setupItem = true,itemQuadrant={21,32}})

  textures.sprites.bowBase = Sprite("toolBase","items1.png",{parts = {"small","medium"}},{setupItem = true,itemQuadrant={28,0}})
  textures.sprites.ringCrystal = Sprite("toolTop","items1.png",{parts = {"small","medium"}},{setupItem = true,itemQuadrant={28,4}})
  textures.sprites.pickaxeTopTough = Sprite("pickaxeTopTough","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={28,8}})
  textures.sprites.spikeTopTough = Sprite("spikeTopTough","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={28,12}})
  textures.sprites.swayPickaxeTopTough = Sprite("swayPickaxeTopTough","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={28,16}})
  textures.sprites.hammerTopTough = Sprite("hammerTopTough","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={28,20}})
  textures.sprites.chiselTopTough = Sprite("chiselTopTough","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={28,24}})
  textures.sprites.shovelTopTough = Sprite("shovelTopTough","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={28,28}})
  textures.sprites.stiffPickTopTough = Sprite("stiffPickTopTough","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={28,32}})
  textures.sprites.targetPickaxeTopTough = Sprite("targetPickaxeTopTough","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={28,36}})
  textures.sprites.smallSwordTopTough = Sprite("smallSwordTopTough","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={28,40}})
  textures.sprites.swordTopTough = Sprite("swordTopTough","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={28,44}})
  textures.sprites.bigSwordTopTough = Sprite("bigSwordTopTough","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={28,48}})
  textures.sprites.lanceTopTough = Sprite("lanceTopTough","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={28,52}})
  textures.sprites.ringTopTough = Sprite("ringTopTough","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={28,56}})
  textures.sprites.bowTopTough = Sprite("bowTopTough","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={28,60}})




  textures["sprites"]["placementPreview"] = Sprite("placementPreview","miscTiles.png",{["gridMultiplication"] = 8, ["spriteSize"] = {1,1},["quads"] = {0,0}, ["spriteCenter"] = {0.5,0.5}},{["type"] = "singleImage"})
  textures["sprites"]["destroyPreviewReady"] = Sprite("destroyPreviewReady","miscTiles.png",{["gridMultiplication"] = 8, ["spriteSize"] = {1,1},["quads"] = {2,0}, ["spriteCenter"] = {0.5,0.5}},{["type"] = "singleImage"})
  textures["sprites"]["destroyPreview"] = Sprite("destroyPreview","miscTiles.png",{["gridMultiplication"] = 8, ["spriteSize"] = {1,1},["quads"] = {1,0}, ["spriteCenter"] = {0.5,0.5}},{["type"] = "singleImage"})
  textures["sprites"]["destroyAnimation"] = Sprite("destroyAnimation","miscTiles.png",{["type"] = "hold", ["timePerFrame"] = 1/9, ["gridMultiplication"] = 8, ["spriteSize"] = {1,1},["quads"] = {{0,1},{1,1},{2,1},{3,1},{4,1},{5,1},{6,1},{7,1},{8,1}}, ["spriteCenter"] = {0.5,0.5}},{["type"] = "singleAnimation"})
  



  textures["sprites"]["player"] = Sprite("player","player.png",{["parts"] = {"idle","walk","jump","use"}},{["setupCharacterAnimation"] =  true, ["animationQuadrant"]={0,0},["spriteSizes"]={1,2},["spriteCenters"]={0.5,1.5}})
  textures["sprites"]["slime"] = Sprite("slime","player.png",{["parts"] = {"idle","walk","jump","use"}},{["setupCharacterAnimation"] =  true, ["animationQuadrant"]={1,0},["spriteSizes"]={1,2},["spriteCenters"]={0.5,1.5}})
  textures["sprites"]["bigSlime"] = Sprite("bigSlime","player.png",{["parts"] = {"idle","walk","jump","use"}},{["setupCharacterAnimation"] =  true, ["animationQuadrant"]={3,0},["spriteSizes"]={2,2},["spriteCenters"]={1,2}})
  textures["sprites"]["bear"] = Sprite("bear","player.png",{["parts"] = {"idle","walk","jump","use"}},{["setupCharacterAnimation"] =  true, ["animationQuadrant"]={5,0},["spriteSizes"]={3,2},["spriteCenters"]={1.5,2}})
  textures["sprites"]["skeleton"] = Sprite("skeleton","player.png",{["parts"] = {"idle","walk","jump","use"}},{["setupCharacterAnimation"] =  true, ["animationQuadrant"]={2,0},["spriteSizes"]={1,2},["spriteCenters"]={0.5,1.5}})
  textures["sprites"]["crudePickaxe_Hold"] = Sprite("crudePickaxe_Hold","player.png",{["parts"] = {"idle","walk","jump","use"}},{["setupCharacterAnimation"] =  true, ["animationQuadrant"]={0,1},["spriteSizes"]={1.5,2},["spriteCenters"]={0.75,1.5}})
  
  textures["sprites"]["toolBase_Hold"] = Sprite("toolBase_Hold","player.png",{["parts"] = {"idle","walk","jump","use"}},{["setupCharacterAnimation"] =  true, ["animationQuadrant"]={0,3},["spriteSizes"]={1.5,2},["spriteCenters"]={0.75,1.5}})
  textures["sprites"]["toolTop_Hold"] = Sprite("toolTop_Hold","player.png",{["parts"] = {"idle","walk","jump","use"}},{["setupCharacterAnimation"] =  true, ["animationQuadrant"]={1.5,3},["spriteSizes"]={1.5,2},["spriteCenters"]={0.75,1.5}})
  
  
  textures["sprites"]["crudeSword_Hold"] = Sprite("crudeSword_Hold","player.png",{["parts"] = {"idle","walk","jump","use"}},{["setupCharacterAnimation"] =  true, ["animationQuadrant"]={0,2},["spriteSizes"]={2,2},["spriteCenters"]={1,1.5}})
  textures["sprites"]["slimeSpike_Hold"] = Sprite("slimeSpike_Hold","player.png",{["parts"] = {"idle","walk","jump","use"}},{["setupCharacterAnimation"] =  true, ["animationQuadrant"]={2,2},["spriteSizes"]={2,2},["spriteCenters"]={1,1.5}})
  textures["sprites"]["bigSlimeSpike_Hold"] = Sprite("bigSlimeSpike_Hold","player.png",{["parts"] = {"idle","walk","jump","use"}},{["setupCharacterAnimation"] =  true, ["animationQuadrant"]={4,2},["spriteSizes"]={3,2},["spriteCenters"]={1.5,2}})

  textures.sprites.meleeWeaponBase_Hold = Sprite("meleeWeaponBase_Hold","player.png",{parts = {"idle","walk","jump","use"}},{setupCharacterAnimation =  true, animationQuadrant={0,4},spriteSizes={2,2},spriteCenters={1,1.5}})
  textures.sprites.meleeWeaponTop_Hold = Sprite("meleeWeaponTop_Hold","player.png",{parts = {"idle","walk","jump","use"}},{setupCharacterAnimation =  true, animationQuadrant={2,4},spriteSizes={2,2},spriteCenters={1,1.5}})
  textures.sprites.crudeBow_Hold = Sprite("crudeBow_Hold","player.png",{parts = {"idle","walk","jump","use"}},{setupCharacterAnimation =  true, animationQuadrant={0,5},spriteSizes={2,2},spriteCenters={1,1.5}})
  textures.sprites.bowBase_Hold = Sprite("bowBase_Hold","player.png",{parts = {"idle","walk","jump","use"}},{setupCharacterAnimation =  true, animationQuadrant={0,6},spriteSizes={2,2},spriteCenters={1,1.5}})
  textures.sprites.bowTop_Hold = Sprite("bowTop_Hold","player.png",{parts = {"idle","walk","jump","use"}},{setupCharacterAnimation =  true, animationQuadrant={2,6},spriteSizes={2,2},spriteCenters={1,1.5}})
  
  
  textures.sprites.arrow = Sprite("arrow","projectiles.png",{
    timePerFrame = 180/5,
    gridMultiplication = 9,
    spriteSize = {1,1},
    spriteCenter = {5/9,5/9},
    quads = {{0,0},{1,0},{2,0},{3,0},{4,0}}
  }, {
    mirrorable = true,
    type = "singleAnimation",
  })
  textures.sprites.arrowBase = Sprite("arrowBase","projectiles.png",{
    timePerFrame = 180/5,
    gridMultiplication = 9,
    spriteSize = {1,1},
    spriteCenter = {5/9,5/9},
    quads = {{5,0},{6,0},{7,0},{8,0},{9,0}}
  }, {
    mirrorable = true,
    type = "singleAnimation",
  })
  textures.sprites.arrowTop = Sprite("arrowTop","projectiles.png",{
    timePerFrame = 180/5,
    gridMultiplication = 9,
    spriteSize = {1,1},
    spriteCenter = {5/9,5/9},
    quads = {{5,1},{6,1},{7,1},{8,1},{9,1}}
  }, {
    mirrorable = true,
    type = "singleAnimation",
  })
  textures.sprites.arrowTopCrystal = Sprite("arrowTopCrystal","projectiles.png",{
    timePerFrame = 180/5,
    gridMultiplication = 9,
    spriteSize = {1,1},
    spriteCenter = {5/9,5/9},
    quads = {{5,2},{6,2},{7,2},{8,2},{9,2}}
  }, {
    mirrorable = true,
    type = "singleAnimation",
  })
  textures.sprites.arrowTopTough = Sprite("arrowTopTough","projectiles.png",{
    timePerFrame = 180/5,
    gridMultiplication = 9,
    spriteSize = {1,1},
    spriteCenter = {5/9,5/9},
    quads = {{5,3},{6,3},{7,3},{8,3},{9,3}}
  }, {
    mirrorable = true,
    type = "singleAnimation",
  })
  textures.sprites.bomb = Sprite("bomb","projectiles.png",{
    timePerFrame = 1/4,
    gridMultiplication = 9,
    spriteSize = {1,1},
    spriteCenter = {5/9,5/9},
    quads = {{0,1},{1,1},{2,1},{3,1}}
  }, {
    mirrorable = false,
    type = "singleAnimation",
  })
  textures.sprites.fog = Sprite("fog","tiles.png",{
    ["parts"] = {"fog1","fog2","fog3","fog4","fog5","fog6","fog7","fog8","fog9","fog10","fog11","fog12"},
    ["fog1"] ={
      ["type"] = "repeat",
      ["timePerFrame"] = 0.5/4,
      ["gridMultiplication"] = 8,
      ["spriteSize"] = {1,1},
      ["spriteCenter"] = {0.5,0.5},
      ["quads"] = {{0,6},{0,7},{0,8},{0,9}}
    },
    ["fog2"] ={
      ["type"] = "repeat",
      ["timePerFrame"] = 0.5/4,
      ["gridMultiplication"] = 8,
      ["spriteSize"] = {1,1},
      ["spriteCenter"] = {0.5,0.5},
      ["quads"] = {{1,6},{1,7},{1,8},{1,9}}
    },
    ["fog3"] ={
      ["type"] = "repeat",
      ["timePerFrame"] = 0.5/4,
      ["gridMultiplication"] = 8,
      ["spriteSize"] = {1,1},
      ["spriteCenter"] = {0.5,0.5},
      ["quads"] = {{2,6},{2,7},{2,8},{2,9}}
    },
    ["fog4"] ={
      ["type"] = "repeat",
      ["timePerFrame"] = 0.5/4,
      ["gridMultiplication"] = 8,
      ["spriteSize"] = {1,1},
      ["spriteCenter"] = {0.5,0.5},
      ["quads"] = {{3,6},{3,7},{3,8},{3,9}}
    },
    ["fog5"] ={
      ["type"] = "repeat",
      ["timePerFrame"] = 0.5/4,
      ["gridMultiplication"] = 8,
      ["spriteSize"] = {1,1},
      ["spriteCenter"] = {0.5,0.5},
      ["quads"] = {{4,6},{4,7},{4,8},{4,9}}
    },
    ["fog6"] ={
      ["type"] = "repeat",
      ["timePerFrame"] = 0.5/4,
      ["gridMultiplication"] = 8,
      ["spriteSize"] = {1,1},
      ["spriteCenter"] = {0.5,0.5},
      ["quads"] = {{5,6},{5,7},{5,8},{5,9}}
    },
    ["fog7"] ={
      ["type"] = "repeat",
      ["timePerFrame"] = 0.5/4,
      ["gridMultiplication"] = 8,
      ["spriteSize"] = {1,1},
      ["spriteCenter"] = {0.5,0.5},
      ["quads"] = {{6,6},{6,7},{6,8},{6,9}}
    },
    ["fog8"] ={
      ["type"] = "repeat",
      ["timePerFrame"] = 0.5/4,
      ["gridMultiplication"] = 8,
      ["spriteSize"] = {1,1},
      ["spriteCenter"] = {0.5,0.5},
      ["quads"] = {{7,6},{7,7},{7,8},{7,9}}
    },
  }, {
    mirrorable = false,
  })
  
  --[[textures["sprites"]["player"] = Sprite("player","player.png",{
    ["parts"] = {"idle","walk","jump","use"},
    ["idle"] ={
      ["type"] = "still",
      ["timePerFrame"] = 1,
      ["gridMultiplication"] = 8,
      ["spriteSize"] = {1,2},
      ["spriteCenter"] = {0.5,1.5},
      ["quads"] = {{0,0}}
    },
    ["walk"] ={
      ["type"] = "repeat",
      ["timePerFrame"] = 1/8*6,
      ["gridMultiplication"] = 8,
      ["spriteSize"] = {1,2},
      ["spriteCenter"] = {0.5,1.5},
      ["quads"] = {{0,2},{1,2},{2,2},{3,2},{4,2},{5,2}}
    },
    ["jump"] ={
      ["type"] = "hold",
      ["timePerFrame"] = 0.2,
      ["gridMultiplication"] = 8,
      ["spriteSize"] = {1,2},
      ["spriteCenter"] = {0.5,1.5},
      ["quads"] = {{0,4},{1,4},{2,4},{3,4},{4,4}}
    },
    ["use"] ={
      ["type"] = "repeat&needsToEnd",
      ["timePerFrame"] = 0.1,
      ["gridMultiplication"] = 8,
      ["spriteSize"] = {1,2},
      ["spriteCenter"] = {0.5,1.5},
      ["quads"] = {{0,6},{1,6},{2,6},{2,6},{3,6}}
    }
  }, {["mirrorable"] = true})]]
end

function LoadSpawnCards()
  GlobalEnemyCards = {}
  --EntitySpawnCard(cardCost,cardWeight,cardType,biomes,name,sprite,ai,flags)
  table.insert(GlobalEnemyCards,
    EntitySpawnCard(3,100,"enemy",{"any"},"slime","slime","regular",{
      team = "enemy",
      size =  0.4,
      health = 15,
      damage = 1.1,
      xpGiveOnDeath = 15,
      knockbackMultiplier = 1.4,
      movevementSpeed = 0.3,
      movementType = "hoplike",
      bloodColor = {0.8,0.4,0.1,1},
      bloodColorNoise = {0.1,0.1,0.1,0},
      aiInfo = {
        ["attentionTime"] = 5,
        ["sightRange"] = 5,
      },
      startItems = {
        {name = "slimeSpike", attributes = {dropOnDeath = false}}
      }
    })
  )
  table.insert(GlobalEnemyCards,
    EntitySpawnCard(12,100,"enemy",{"any"},"big slime","bigSlime","regular",{
      team = "enemy",
      size =  0.85,
      health = 40,
      damage = 1.1,
      xpGiveOnDeath = 40,
      knockbackMultiplier = 0.4,
      movevementSpeed = 0.2,
      movementType = "hoplike",
      bloodColor = {0.8,0.4,0.1,1},
      bloodColorNoise = {0.1,0.1,0.1,0},
      aiInfo = {
        ["attentionTime"] = 5,
        ["sightRange"] = 10,
      },
      startItems = {
        {name = "bigSlimeSpike", attributes = {dropOnDeath = false}}
      },
    })
  )
  table.insert(GlobalEnemyCards,
    EntitySpawnCard(15,100,"enemy",{"any"},"Bear","bear","regular",{
      team = "enemy",
      size =  0.85,
      health = 55,
      damage = 1.1,
      movementAnimationSpeed = 3,
      xpGiveOnDeath = 70,
      knockbackMultiplier = 1.2,
      movevementSpeed = 0.2,
      movementType = "humanlike",
      aiInfo = {
        jumpFrequency = 0.25,
      },
      startItems = {
        {name = "bigSlimeSpike", attributes = {dropOnDeath = false}}
      },
    })
  )
  table.insert(GlobalEnemyCards,
    EntitySpawnCard(8,300,"enemy",{"any"},"skeleton","skeleton","regular",{
      team = "enemy",
      size =  0.4,
      health = 25,
      xpGiveOnDeath = 25,
      damage = 1.2,
      movevementSpeed = 0.5,
      movementType = "humanlike",
      bloodColor = {0.6,0.6,0.6,1},
      bloodColorNoise = {0.1,0.1,0.1,0}
    })
  )
  -- --skeletra
  --skeletor
  --skeletang
end

function loadtiles()
  tiles = {}
  tilelists["stones"] = {}
  tilelists["dirts"] = {}
  tilelists["all tiles"] = {}
  --[[tilelists["stones"]    = {
    "stone", "darkstone", "palestone", "ancientstone",
    "coldstone", "lightstone", "hotstone"
  }]]
  --[[tilelists["all tiles"] = {
    "none", "dirt", "grass", "purplegrass", "shadowgrass",
    "wheatgrass", "diamond", "stone", "darkstone", "palestone",
    "ancientstone", "coldstone", "lightstone", "hotstone",
    "dirt_wall", "stone_wall", "hotstone_wall", "coldstone_wall"
  }]]
  tiles["none"]          = Tile("none",nil,nil,nil,{["canBeMined"] = false})

  tiles["dirt"]          = Tile("dirt", "solid", "tiles.png", "dirt",
    {
      ["newQuad"] = { 7, 2, 1, 1, 8, },
      ["border"] = {
        ["quad"] = "dirt_top",
        ["newQuad"] = { 7, 3, 1, 1, 8 }
      },
      ["health"] = 2.5,
      ["isDirt"] = true,
    })

  tiles["essenceGrass"]         = Tile("essenceGrass", "top", "tiles.png", "essenceGrass",
    {
      ["newQuad"] = { 1, 0, 1, 1, 8 },
      ["border type"] = "non-solid",
      ["actualName"] = "essenceGrass",
      ["health"] = 0
    })
   tiles["grass"]         = Tile("grass", "top", "tiles.png", "grass",
    {
      ["newQuad"] = { 1, 2, 1, 1, 8 },
      ["border type"] = "non-solid",
      ["health"] = 0,
      ["actualName"] = "grass",
    })

  tiles["purplegrass"]   = Tile("purplegrass", "top", "tiles.png", "purplegrass",
    {
      ["newQuad"] = { 4, 0, 1, 1, 8 },
      ["border type"] = "non-solid",
      ["health"] = 0
    })

  tiles["shadowgrass"]   = Tile("shadowgrass", "top", "tiles.png", "shadowgrass",
    {
      ["newQuad"] = { 10, 0, 1, 1, 8 },
      ["border type"] = "non-solid",
      ["health"] = 0
    })

  tiles["wheatgrass"]    = Tile("wheatgrass", "top", "tiles.png", "wheatgrass",
    {
      ["newQuad"] = { 11, 0, 1, 1, 8 },
      ["border type"] = "non-solid",
      ["health"] = 0
    })

  tiles["diamond"]       = Tile("diamond", "top", "tiles.png", "diamond",
    {
      ["newQuad"] = { 12, 0, 1, 1, 8 },
      ["border type"] = "normal",
      ["health"] = 1
    })

  tiles["stone"]         = Tile("stone", "solid", "tiles.png", "stone", {
    ["newQuad"] = { 2, 2, 1, 1, 8 },
    ["border"] = {
      ["quad"] = "stone_top",
      ["newQuad"] = { 2, 3, 1, 1, 8 }
    },
    ["isStone"] = true,
    ["health"] = 5
  })

  tiles["darkstone"]     = Tile("darkstone", "solid", "tiles.png", "darkstone",
    {
      ["newQuad"] = { 3, 0, 1, 1, 8 },
      ["border"] = {
        ["quad"] = "darkstone_top",
        ["newQuad"] = { 3, 1, 1, 1, 8 }
      },
      ["isStone"] = true,
      ["health"] = 10
    })

  tiles["palestone"]     = Tile("palestone", "solid", "tiles.png", "palestone",
    {
      ["newQuad"] = { 5, 0, 1, 1, 8 },
      ["border"] = {
        ["quad"] = "palestone_top",
        ["newQuad"] = { 5, 1, 1, 1, 8 }
      },
      ["isStone"] = true,
      ["health"] = 1.5
    })
  tiles["ancientstone"]  = Tile("ancientstone", "solid", "tiles.png", "ancientstone",
    {
      ["newQuad"] = { 6, 0, 1, 1, 8 },
      ["border"] = {
        ["quad"] = "ancientstone_top",
        ["newQuad"] = { 6, 1, 1, 1, 8 }
      },
      ["isStone"] = true,
      ["health"] = 2.5
    })

  tiles["coldstone"]     = Tile("coldstone", "solid", "tiles.png", "coldstone",
    {
      ["newQuad"] = { 7, 0, 1, 1, 8 },
      ["border"] = {
        ["quad"] = "coldstone_top",
        ["newQuad"] = { 7, 1, 1, 1, 8 }
      },
      ["isStone"] = true,
      ["health"] = 3.5
    })

  tiles["lightstone"]    = Tile("lightstone", "solid", "tiles.png", "lightstone",
    {
      ["newQuad"] = { 8, 0, 1, 1, 8 },
      ["border"] = {
        ["quad"] = "lightstone_top",
        ["newQuad"] = { 8, 1, 1, 1, 8 }
      },
      ["isStone"] = true,
      ["health"] = 6
    })

  tiles["hotstone"]      = Tile("hotstone", "solid", "tiles.png", "hotstone",
    {
      ["newQuad"] = { 9, 0, 1, 1, 8 },
      ["border"] = {
        ["quad"] = "hotstone_top",
        ["newQuad"] = { 9, 1, 1, 1, 8 }
      },
      ["isStone"] = true,
      ["health"] = 10
    })
  tiles["shadowStone"]   = Tile("shadowStone", "solid", "tiles.png", "shadowStone",
    {
      ["newQuad"] = { 13, 0, 1, 1, 8 },
      ["border"] = {
        ["quad"] = "shadowStone_top",
        ["newQuad"] = { 13, 1, 1, 1, 8 }
      },
      ["isStone"] = true,
      ["health"] = 22
    })
  tiles["ice"]           = Tile("ice", "solid", "tiles.png", "ice",
    {
      ["newQuad"] = { 14, 0, 1, 1, 8 },
      ["border"] = {
        ["quad"] = "ice_top",
        ["newQuad"] = { 14, 1, 1, 1, 8 }
      },
      ["color"] = { 1, 1, 1, 0.4 },
      ["lightCanGoThrough"] = true,
      ["health"] = 0.5
    })
  tiles["sand"]          = Tile("sand", "solid", "tiles.png", "sand",
    {
      ["newQuad"] = { 15, 0, 1, 1, 8 },
      ["border"] = {
        ["quad"] = "sand_top",
        ["newQuad"] = { 15, 1, 1, 1, 8 }
      },
      ["health"] = 1.2
    })
  tiles["magicKelp"]     = Tile("magicKelp", "not-solid", "tiles.png", "magicKelp",
    {
      ["newQuad"] = { 16, 0, 1, 2, 8 },
      ["textureCenterX"] = 4,
      ["textureCenterY"] = 12,
      ["border type"] = "none",
      ["health"] = 0.5
    })
  tiles["scrapBlock"]          = Tile("scrapBlock", "solid", "tiles.png", "scrapBlock",
    {
      ["newQuad"] = { 17, 0, 1, 1, 8 },
      ["border"] = {
        ["quad"] = "scrapBlock_top",
        ["newQuad"] = { 17, 1, 1, 1, 8 }
      },
      ["actualName"] = "scrap block",
      ["health"] = 2.2,
      ["actualDropeRate"] = 0,
      ["secondaryDropAmount"] = 4,
    })
  tiles["glass"]          = Tile("glass", "solid", "tiles.png", "glass",
    {
      ["newQuad"] = { 18, 0, 1, 1, 8 },
      ["border"] = {
        ["quad"] = "glass_top",
        ["newQuad"] = { 18, 1, 1, 1, 8 }
      },
      ["health"] = 2.2,
      ["actualDropeRate"] = 1,
      ["lightCanGoThrough"] = true,
      ["color"] = {1,1,1,0.6},
    })
  tiles["soil"]          = Tile("soil", "solid", "tiles.png", "soil",
    {
      ["newQuad"] = { 0, 2, 1, 1, 8, },
      ["border"] = {
        ["quad"] = "soil_top",
        ["newQuad"] = { 0, 3, 1, 1, 8 }
      },
      ["health"] = 12
    })
  tiles["essenceStone"]         = Tile("essenceStone", "solid", "tiles.png", "essenceStone", {
    ["newQuad"] = { 2, 0, 1, 1, 8 },
    ["border"] = {
      ["quad"] = "essenceStone_top",
      ["newQuad"] = { 2, 1, 1, 1, 8 }
    },
    ["isStone"] = true,
    ["health"] = 12,
    ["actualName"] = "essence stone",
  })
  tiles["essenceDirt"]          = Tile("essenceDirt", "solid", "tiles.png", "essenceDirt",
    {
      ["newQuad"] = { 0, 0, 1, 1, 8, },
      ["border"] = {
        ["quad"] = "essenceDirt_top",
        ["newQuad"] = { 0, 1, 1, 1, 8 }
      },
      ["health"] = 3,
      ["actualName"] = "essence dirt",
      ["isDirt"] = true,
    })
  tiles["essenceLeaves"]          = Tile("essenceLeaves", "solid", "tiles.png", "essenceLeaves",
    {
      ["newQuad"] = { 3, 2, 1, 1, 8 },
      ["border"] = {
        ["quad"] = "essenceLeaves_top",
        ["newQuad"] = { 3, 3, 1, 1, 8 }
      },
      ["health"] = 0.6,
      ["actualDropeRate"] = 0.4,
      ["lightCanGoThrough"] = true,
      ["actualName"] = "essence leaves",
      ["secondaryDrop"] = "essenceStick",
      ["secondaryDropAmount"] = 2,
    })
  tiles["leaves"]          = Tile("leaves", "solid", "tiles.png", "leaves",
    {
      ["newQuad"] = { 8, 2, 1, 1, 8 },
      ["border"] = {
        ["quad"] = "leaves_top",
        ["newQuad"] = { 8, 3, 1, 1, 8 }
      },
      ["health"] = 0.6,
      ["actualDropeRate"] = 0.4,
      ["lightCanGoThrough"] = true,
      ["actualName"] = "leaves",
      ["secondaryDrop"] = "stick",
      ["secondaryDropAmount"] = 2,
    })
  tiles["essenceWood"]         = Tile("essenceWood", "solid", "tiles.png", "essenceWood", {
    ["newQuad"] = { 4, 2, 1, 1, 8 },
    ["border"] = {
      ["quad"] = "essenceWood_top",
      ["newQuad"] = { 4, 3, 1, 1, 8 }
    },
    ["health"] = 3,
    ["actualName"] = "Essence wood",
    ["secondaryDrop"] = "essenceStick",
    ["secondaryDropAmount"] = 5,
  })
  tiles["wood"]         = Tile("wood", "solid", "tiles.png", "wood", {
    ["newQuad"] = { 9, 2, 1, 1, 8 },
    ["border"] = {
      ["quad"] = "wood_top",
      ["newQuad"] = { 9, 3, 1, 1, 8 }
    },
    ["health"] = 1.8,
    ["actualName"] = "Wood",
    ["secondaryDrop"] = "stick",
    ["secondaryDropAmount"] = 5,
  })
  tiles["cactus"]         = Tile("cactus", "solid", "tiles.png", "cactus", {
    ["newQuad"] = { 10, 2, 1, 1, 8 },
    ["border"] = {
      ["quad"] = "cactus_top",
      ["newQuad"] = { 10, 3, 1, 1, 8 }
    },
    ["health"] = 1.8,
    ["actualName"] = "Cactus",
    ["secondaryDrop"] = "stick",
    ["secondaryDropAmount"] = 5,
  })
  tiles["essenceWoodBricks"]         = Tile("essenceWoodBricks", "solid", "tiles.png", "essenceWoodBricks", {
    ["newQuad"] = { 5, 2, 1, 1, 8 },
    ["border"] = {
      ["quad"] = "essenceWoodBricks_top",
      ["newQuad"] = { 5, 3, 1, 1, 8 }
    },
    ["health"] = 3,
    ["actualName"] = "Essence wood bricks",
    ["secondaryDrop"] = "essenceStick",
    ["secondaryDropAmount"] = 5,
  })
  tiles["woodBricks"]         = Tile("woodBricks", "solid", "tiles.png", "woodBricks", {
    ["newQuad"] = { 6, 4, 1, 1, 8 },
    ["border"] = {
      ["quad"] = "woodBricks_top",
      ["newQuad"] = { 6, 5, 1, 1, 8 }
    },
    ["health"] = 3,
    ["actualName"] = "Wood bricks",
    ["secondaryDrop"] = "stick",
    ["secondaryDropAmount"] = 5,
  })
  tiles["woodPlatform"]         = Tile("woodPlatform", "platform", "tiles.png", "woodPlatform", {
    ["newQuad"] = { 5, 4, 1, 1, 8 },
    ["border"] = {
      ["quad"] = "woodPlatform_top",
      ["newQuad"] = { 5, 5, 1, 1, 8 }
    },
    ["health"] = 3,
    ["actualName"] = "Wood platform",
    ["secondaryDrop"] = "stick",
    ["secondaryDropAmount"] = 5,
  })
  tiles["campfire"]         = Tile("campfire", "non-solid", "tiles.png", "campfire", {
    ["newQuad"] = { 6, 2, 1, 1, 8 },
    ["border type"] = "none",
    ["health"] = 0.5,
    ["secondaryDrop"] = "stick",
    ["secondaryDropAmount"] = 8,
    ["particleEmit"] = "fire",
    ["particleEmitData"] = {chance = 0.32,["amount"]=5,["radius"]=0.3,["color"]={0.9,0.9,0,0.7},["flags"]={["color2"]={0.8,0.2,0.2,0.8},["color3"]={0.4,0.4,0.4,0.9}},["timer"]=3},
  })
  tiles.crate         = Tile("crate", "non-solid", "tiles.png", "crate", {
    newQuad = {0, 4, 1, 1, 8 },
    border = {
      quad = "crate_top",
      newQuad = {0, 5, 1, 1, 8 }
    },
    health = 999,
    isContainer = true,
    containerRows = 1,
    containerColumns = 1,
    actualName = "crate",
    onInteract = 
      function (self, x, y, entity)
        world:openContainer(self.actualName,self, Vector2(x,y), entity, self.containerRows, self.containerColumns)
        world:generateContainerLoot(Vector2(x,y),2,1,nil,nil,0.5,0.5)
      end
  })
  tiles.goldCrate         = Tile("goldCrate", "non-solid", "tiles.png", "goldCrate", {
    newQuad = {1, 4, 1, 1, 8 },
    border = {
      quad = "goldCrate_top",
      newQuad = {1, 5, 1, 1, 8 }
    },
    health = 999,
    isContainer = true,
    containerRows = 1,
    containerColumns = 1,
    actualName = "Gold crate",
    onInteract = 
      function (self, x, y, entity)
        world:openContainer(self.actualName,self, Vector2(x,y), entity, self.containerRows, self.containerColumns)
        world:generateContainerLoot(Vector2(x,y),3.5,1,nil,nil,1,1)
      end
  })
  tiles.emeraldCrate         = Tile("emeraldCrate", "non-solid", "tiles.png", "emeraldCrate", {
    newQuad = {2, 4, 1, 1, 8 },
    border = {
      quad = "emeraldCrate_top",
      newQuad = {2, 5, 1, 1, 8 }
    },
    health = 999,
    isContainer = true,
    containerRows = 1,
    containerColumns = 1,
    actualName = "Emerald crate",
    onInteract = 
      function (self, x, y, entity)
        world:openContainer(self.actualName,self, Vector2(x,y), entity, self.containerRows, self.containerColumns)
        world:generateContainerLoot(Vector2(x,y),4.5,1,nil,nil,1.5,1.5)
      end
  })
  tiles.diamondCrate         = Tile("diamondCrate", "non-solid", "tiles.png", "diamondCrate", {
    newQuad = {3, 4, 1, 1, 8 },
    border = {
      quad = "diamondCrate_top",
      newQuad = {3, 5, 1, 1, 8 }
    },
    health = 999,
    isContainer = true,
    containerRows = 1,
    containerColumns = 1,
    actualName = "Diamond crate",
    onInteract = 
      function (self, x, y, entity)
        world:openContainer(self.actualName,self, Vector2(x,y), entity, self.containerRows, self.containerColumns)
        world:generateContainerLoot(Vector2(x,y),6,1,nil,nil,2,2)
      end
  })
  tiles.voidCrate         = Tile("voidCrate", "non-solid", "tiles.png", "voidCrate", {
    newQuad = {4, 4, 1, 1, 8 },
    border = {
      quad = "voidCrate_top",
      newQuad = {4, 5, 1, 1, 8 }
    },
    health = 999,
    isContainer = true,
    containerRows = 1,
    containerColumns = 1,
    actualName = "Void crate",
    onInteract = 
      function (self, x, y, entity)
        world:openContainer(self.actualName,self, Vector2(x,y), entity, self.containerRows, self.containerColumns)
        world:generateContainerLoot(Vector2(x,y),8,1,nil,nil,3,2.5)
      end
  })
  tiles.chest         = Tile("chest", "non-solid", "tiles.png", "chest", {
    newQuad = {11, 2, 1, 1, 8 },
    border = {
      quad = "chest_top",
      newQuad = {11, 3, 1, 1, 8 }
    },
    health = 999,
    isContainer = true,
    containerRows = 4,
    containerColumns = 4,
    actualName = "Chest",
    onInteract = 
      function (self, x, y, entity)
        world:openContainer(self.actualName,self, Vector2(x,y), entity, self.containerRows, self.containerColumns)
        world:generateContainerLoot(Vector2(x,y),14,4,nil,nil,1.1,1)
      end
  })
  tiles.blueChest         = Tile("blueChest", "non-solid", "tiles.png", "blueChest", {
    newQuad = {12, 2, 1, 1, 8 },
    border = {
      quad = "blueChest_top",
      newQuad = {12, 3, 1, 1, 8 }
    },
    health = 999,
    isContainer = true,
    containerRows = 3,
    containerColumns = 3,
    actualName = "Blue Chest",
    onInteract = 
      function (self, x, y, entity)
        world:openContainer(self.actualName,self, Vector2(x,y), entity, self.containerRows, self.containerColumns)
        world:generateContainerLoot(Vector2(x,y),18,3,nil,nil,2,1.2)
      end
  })
  tiles.templeChest         = Tile("templeChest", "non-solid", "tiles.png", "templeChest", {
    newQuad = {17, 4, 3, 2, 8,  },
    textureCenterX = 12,
    textureCenterY = 12,
    borderType = "none",
    health = 999,
    isContainer = true,
    containerRows = 6,
    containerColumns = 3,
    actualName = "Temple Chest",
    onInteract = 
      function (self, x, y, entity)
        world:openContainer(self.actualName,self, Vector2(x,y), entity, self.containerRows, self.containerColumns)
        world:generateContainerLoot(Vector2(x,y),26,4,nil,nil,2.2,1.3)
      end
  })
  tiles.templeBlock = Tile("templeBlock","solid","tiles.png","templeBlock", {
    newQuad = {13,2,1,1,8},
    border = {
      quad = "templeBlock_top",
      newQuad = {13, 3, 1, 1, 8}
    },
    health = 30,
    actualName = "temple block"
  })
  tiles.rightTempleStair = Tile("rightTempleStair","rightStair","tiles.png","rightTempleStair", {
    newQuad = {14,2,1,1,8},
    borderType = "none",
    health = 30,
    actualName = "temple stairs"
  })
  tiles.leftTempleStair = Tile("leftTempleStair","leftStair","tiles.png","leftTempleStair", {
    newQuad = {15,2,1,1,8},
    borderType = "none",
    health = 30,
    actualName = "temple stairs"
  })
  tiles.templePatternBlock = Tile("templePatternBlock","solid","tiles.png","templePatternBlock", {
    newQuad = {16,2,1,1,8},
    borderType = "none",
    health = 30,
    actualName = "temple pattern block"
  })
  tiles.templeLateralBlock = Tile("templeLateralBlock","solid","tiles.png","templeLateralBlock", {
    newQuad = {17,2,1,1,8},
    border = {
      quad = "templeLateralBlock_top",
      newQuad = {17, 3, 1, 1, 8}
    },
    health = 30,
    actualName = "temple lateral block"
  })
  tiles.templePlatform = Tile("templePlatform","platform","tiles.png","templePlatform", {
    newQuad = {13,4,1,1,8},
    borderType = "none",
    health = 30,
    actualName = "temple platform"
  })
  tiles.templeColumn = Tile("templeColumn","non-solid","tiles.png","templeColumn", {
    newQuad = {14,4,1,1,8},
    borderType = "none",
    health = 30,
    actualName = "temple column"
  })
  tiles.templeVines = Tile("templeVines", "top", "tiles.png", "Temple Vines",
    {
      newQuad = { 18, 2, 1, 1, 8 },
      ["border type"] = "non-solid",
      health = 0,
      actualName = "Temple Vines",
    })
  tiles.templeBush = Tile("templeBush","solid","tiles.png","templeBush", {
    newQuad = {19,2,1,1,8},
    border = {
      quad = "templeBush_top",
      newQuad = {19, 3, 1, 1, 8}
    },
    health = 1,
    actualName = "temple bush block",
    secondaryDrop = "stick",
    secondaryDropAmount = 5,
  })
  tiles.evilShrine = Tile("evilShrine","non-solid","tiles.png","evilShrine", {
    newQuad = {8,4,5,3,8},
    borderType = "none",
    health = 99999,
    actualName = "evil shrine",
    particleEmit = "evilShrineCircle",
    particleEmitData = {  chance = 1, delay = 240, amount = 1, motion = "floating", motionStrength = 0, motionArcAngle = 0, motionArcSpread = 360, radius = 0, timer = 4, timerNoise = 0, color = {1,0,0,0.4}, colorNoise = {0.05,0.05,0.05,0.05}, flags = { appearanceType = "circle", size = 0.5, sizeMotion = 0.75}, hasCollisions = false }
  })
end

function loadEntities()
  --textures["sprites"] = {}
  --[[entities["player"] = Entity("Player", "player", "player", "tiles.png", 100, 0, "player",
    {
      ["newQuad"] = { 15, 0, 1, 1, 8 }
    })]]
end

function loadItems()
  ItemList = {}
  items = {}
  items["none"] = Item("none","none",{})
  --items["stick"] = Item("stick","stick",{["category"]="material"})
  items["stick"] = Item("stick","stick",{["category"]="material",["placeBlock"] = "woodBricks", ["placeBlockCost"] = 5, ["maxStack"] = 300})
  items["essenceStick"] = Item("essenceStick","essenceStick",{["category"]="material",["placeBlock"] = "woodBricks", ["placeBlockCost"] = 5, ["maxStack"] = 300})
  items["rock"] = Item("rock","rock",{["category"]="material",["placeBlock"] = "scrapBlock", ["placeBlockCost"] = 4,["fullName"] = "Scrap pebbles", ["maxStack"] = 300})
  items.crudePickaxe = Item("crudePickaxe","crudePickaxe",{category="tool",subCategory = "pickaxe",fullName = "Crude pickaxe",
    cooldown = 0.8,
    cooldownSpeedPerLevel = 0.03,
    mineDamage = 0.8, --1
    mineDamagePerLevel = 0.03,
    blockDamageAmount = 6, --6
    rangeLimit = 5,  --6
    rangeLimitPerLevel = 0.15,
    mineWidth = 3,
    holdAnimation = "crudePickaxe_Hold",
    description = {"#silent","A crude pickaxe made of sticks and rocks. It can serve a lot more than you might think."},
  })
  items["crudeSpike"] = Item("crudeSpike","crudeSpike",{["category"]="tool",["subCategory"] = "pickaxe",["fullName"] = "Crude spike",
    ["cooldown"] = 0.6,
    ["cooldownSpeedPerLevel"] = 0.02,
    ["mineDamage"] = 1.2, --1
    ["mineDamagePerLevel"] = 0.06,
    ["blockDamageAmount"] = 3, --6
    ["rangeLimit"] = 7,  --6
    ["rangeLimitPerLevel"] = 0.2,
    ["mineWidth"] = 1,
    ["holdAnimation"] = "crudePickaxe_Hold",
  })
  items["crudeSwayPickaxe"] = Item("crudeSwayPickaxe","crudeSwayPickaxe",{["category"]="tool",["subCategory"] = "pickaxe",["fullName"] = "Crude sway pickaxe",
    ["cooldown"] = 2.4,
    ["mineDamage"] = 0.8, --1
    ["mineDamagePerLevel"] = 0.02,
    ["blockDamageAmount"] = 18, --6
    ["blockDamageAmountPerLevel"] = 0.8,
    ["rangeLimit"] = 8,  --6
    ["rangeLimitPerLevel"] = 0.3,
    ["mineWidth"] = 6,
    ["holdAnimation"] = "crudePickaxe_Hold",
  })
  items["crudeHammer"] = Item("crudeHammer","crudeHammer",{["category"]="tool",["subCategory"] = "pickaxe",["fullName"] = "Crude hammer",
    ["cooldown"] = 2,
    ["cooldownSpeedPerLevel"] = 0.05,
    ["mineDamage"] = 4, --1
    ["mineDamagePerLevel"] = 0.1,
    ["blockDamageAmount"] = 3, --6
    ["rangeLimit"] = 5,  --6
    ["rangeLimitPerLevel"] = 0.2,
    ["mineWidth"] = 2,
    ["holdAnimation"] = "crudePickaxe_Hold",
  })
  items["crudeScalpel"] = Item("crudeScalpel","crudeScalpel",{["category"]="tool",["subCategory"] = "pickaxe",["fullName"] = "Crude scalpel",
    ["cooldown"] = 0.1,
    ["mineDamage"] = 0.6, --1
    ["mineDamagePerLevel"] = 0.06,
    ["blockDamageAmount"] = 1, --6
    ["rangeLimit"] = 3,  --6
    ["rangeLimitPerLevel"] = 0.03,
    ["mineWidth"] = 1,
    ["holdAnimation"] = "crudePickaxe_Hold",
  })
  items["crudeShovel"] = Item("crudeShovel","crudeShovel",{["category"]="tool",["subCategory"] = "pickaxe",["fullName"] = "Crude shovel",
    ["cooldown"] = 1.8,
    ["cooldownSpeedPerLevel"] = 0.04,
    ["mineDamage"] = 1.2, --1
    ["blockDamageAmount"] = 9, --6
    ["blockDamageAmountPerLevel"] = 0.3,
    ["rangeLimit"] = 6,  --6
    ["rangeLimitPerLevel"] = 0.3,
    ["mineWidth"] = 3,
    ["holdAnimation"] = "crudePickaxe_Hold",
  })
  items["crudeStiffPick"] = Item("crudeStiffPick","crudeStiffPick",{["category"]="tool",["subCategory"] = "pickaxe",["fullName"] = "Crude stiff pick",
    ["cooldown"] = 1.15,
    ["mineDamage"] = 1.4, --1
    ["mineDamagePerLevel"] = 0.08,
    ["blockDamageAmount"] = 5, --6
    ["blockDamageAmountPerLevel"] = 0.1,
    ["rangeLimit"] = 8,  --6
    ["rangeLimitPerLevel"] = 0.07,
    ["mineWidth"] = 3,
    ["holdAnimation"] = "crudePickaxe_Hold",
  })
  items["crudeTargetPickaxe"] = Item("crudeTargetPickaxe","crudeTargetPickaxe",{["category"]="tool",["subCategory"] = "pickaxe",["fullName"] = "Crude target pickaxe",
    ["cooldown"] = 0.2,
    ["mineDamage"] = 0.25, --1
    ["mineDamagePerLevel"] = 0.0075,
    ["blockDamageAmount"] = 5, --6
    ["blockDamageAmountPerLevel"] = 0.2,
    ["rangeLimit"] = 5,  --6
    ["rangeLimitPerLevel"] = 0.25,
    ["mineWidth"] = 0.8,
    ["holdAnimation"] = "crudePickaxe_Hold",
  })
  items["paws"] = Item("paws","crudePickaxe",{["category"]="tool",["subCategory"] = "pickaxe",["fullName"] = "Paws",
    ["cooldown"] = 0.3,
    ["mineDamage"] = 1, --1
    ["mineDamagePerLevel"] = 0.1,
    ["blockDamageAmount"] = 3, --6
    ["rangeLimit"] = 2,  --6
    ["mineWidth"] = 3,
    ["holdAnimation"] = "crudePickaxe_Hold",
  })
  items["coolPickaxe"] = Item("coolPickaxe","crudePickaxe",{["category"]="tool",["subCategory"] = "pickaxe",["fullName"] = "Cool pickaxe",
    ["cooldown"] = 0.3,
    ["mineDamage"] = 2.5,
    ["blockDamageAmount"] = 15,
    ["rangeLimit"] = 20,
    ["mineWidth"] = 5,
    ["holdAnimation"] = "crudePickaxe_Hold",
    ["baseColor"] = {0,1,1,1},
  })
  items["ultimatePickaxe"] = Item("ultimatePickaxe","crudePickaxe",{["category"]="tool",["subCategory"] = "pickaxe",["fullName"] = "Ultimate pickaxe",
    ["cooldown"] = 0,
    ["mineDamage"] = math.huge,
    ["blockDamageAmount"] = math.huge,
    ["rangeLimit"] = 500,
    ["mineWidth"] = 20,
    ["holdAnimation"] = "crudePickaxe_Hold",
    ["baseColor"] = {1,0,1,1},
  })
  items["devPickaxe"] = Item("devPickaxe","crudePickaxe",{["category"]="tool",["subCategory"] = "pickaxe",["fullName"] = "Dev pickaxe",
    ["cooldown"] = 0.05,
    ["mineDamage"] = 9999,
    ["blockDamageAmount"] = 1,
    ["rangeLimit"] = 99,
    ["mineWidth"] = 1,
    ["holdAnimation"] = "crudePickaxe_Hold",
    ["baseColor"] = {1,0,0,1},
    ["minePierce"] = true,
    ["mineLayer"] = {"tiles","backTiles"}
  })
  items.crudeSword = Item("crudeSword","crudeSword",{["category"]="weapon",["subCategory"] = "melee",["fullName"] = "Crude sword",
    cooldown = 2,
    damage = 8,
    damagePerLevel = 2,
    attackRange = 3.2,
    attackRadius = 1, 
    attackDirectionRange = 100,
    holdAnimation = "crudeSword_Hold",
    charge = 0.3,
    moveSpeedDuringCharge = 0.4,
    dashVelocity = 8,
    dashTime = 0.2,
    knockback = 1,
  })
  items.crudeBow = Item("crudeBow","crudeBow",{["category"]="weapon",["subCategory"] = "ranged",["fullName"] = "Crude bow",
    cooldown = 5,
    damage = 18,
    damagePerLevel = 4.5,
    holdAnimation = "crudeBow_Hold",
    charge = 0.1,
    moveSpeedDuringCharge = 0.4,
    knockback = 1,
    projectileBounceFactor = 0.9,
    projectileVelocity = 30,
    projectileGravity = 0.5,
    onUse = function (self,entity,attributes,cursorX,cursorY,slot,stacks,flags) 
      local onUseSuccess, onUseCooldown, onUseStacksRemove
      onUseSuccess = false

      local projectileFlags = {}
      projectileFlags.animationType = "orientation"
      
      onUseSuccess, onUseCooldown, onUseStacksRemove = self:spawnProjectile(entity, attributes, cursorX, cursorY,slot,stacks,projectileFlags)

      return onUseSuccess, onUseCooldown, onUseStacksRemove
    end
  })
  items.bomb = Item("bomb","bombItem",{["category"]="weapon",["subCategory"] = "ranged",["fullName"] = "Bomb",
    cooldown = 0.5,
    projectileExplosionDamage = 60,
    projectileExplosionDamagePerLevel = 1,
    projectileExplosionRadius = 5,
    projectileExplosionTime = 6,
    projectileExplosionTileDamage = 10,
    projectileExplosionTileDamagePerLevel = 0.2,
    knockback = 5,
    projectileVelocity = 20,
    projectileGravity = 0.5,
    projectileBounceFactor = 0.95,
    projectileName = "bomb",
    projectileSprite = "bomb",
    maxStack = 200,
    unique = false,
    maxEnchants = 0,
    onUse = function (self,entity,attributes,cursorX,cursorY,slot,stacks,flags) 
      local onUseSuccess, onUseCooldown, onUseStacksRemove
      onUseSuccess = false

      if stacks > 0 then
        local passFlags = {}
        onUseStacksRemove = 1
        passFlags.animationType = "time"
        passFlags.particleTimer = 0.08
        passFlags.size = 0.45
        passFlags.spawnParticles =
        function (self)
            local pos = self.position:copy()
            pos.y = pos.y + 0.35
            world:spawnParticles(3,"fire",pos,0.1,{0.9,0.9,0,0.7}, {0.05,0.05,0.05,0.05}, 1, 0,"fire", 1, -90, 30, {["color2"]={0.8,0.2,0.2,0.8},["color3"]={0.4,0.4,0.4,0.9}})
        end

        onUseSuccess, onUseCooldown = self:spawnProjectile(entity, attributes, cursorX, cursorY,slot,stacks,passFlags)
      
      end

      return onUseSuccess, onUseCooldown, onUseStacksRemove
    end
  })
  items.slimeSpike = Item("slimeSpike","unknown",{["category"]="weapon",["subCategory"] = "melee",["fullName"] = "Slime spike",
    cooldown = 3,
    damage = 3,
    attackRange = 1,
    attackRadius = 2.5, 
    attackDirectionRange = 360,
    charge = 1,
    moveSpeedDuringCharge = 0,
    knockback = 0.5,
    holdAnimation = "slimeSpike_Hold",
  })
  items.bigSlimeSpike = Item("bigSlimeSpike","unknown",{["category"]="weapon",["subCategory"] = "melee",["fullName"] = "Big slime spike",
    cooldown = 5,
    damage = 6,
    attackRange = 1,
    attackRadius = 3, 
    attackDirectionRange = 360,
    charge = 0.5,
    moveSpeedDuringCharge = 0,
    knockback = 1.5,
    holdAnimation = "bigSlimeSpike_Hold",
  })
  items.bearAttack = Item("bearAttack","unknown",{["category"]="weapon",["subCategory"] = "melee",["fullName"] = "Bear attack",
    cooldown = 6,
    damage = 15,
    attackRange = 0.5,
    attackRadius = 3, 
    attackDirectionRange = 360,
    charge = 1,
    moveSpeedDuringCharge = 0,
    knockback = 1.5,
    dashVelocity = 30,
    dashTime = 0.2,
  })
  items.thunderBirdFeather = Item("thunderBirdFeather","thunderBirdFeather",{["category"]="movement",["subCategory"] = "dash",["fullName"] = "Thunder bird feather",
    cooldown = 6,
    cooldownSpeedPerLevel = 0.03,
    useFreely = true,
    dashVelocity = 18,
    dashTime = 0.4,
    dashGravityMultiplier = 0.2,
  })
  items.angelFeather = Item("angelFeather","angelFeather",{["category"]="movement",["subCategory"] = "dash",["fullName"] = "Angel feather",
    cooldown = 2.5,
    cooldownSpeedPerLevel = 0.03,
    useFreely = true,
    dashDirection = "up",
    dashStopVelocityY = true,
    dashVelocity = 16,
    dashTime = 0.04,
    dashGravityMultiplier = 0,
  })
  items.clearRing = Item("clearRing","clearRing",{["category"]="accessory",["subCategory"] = "ring",["fullName"] = "Clear ring",
    description = {"#silent","A ring with no innate properties. Can be used to hold enchants"},
  })
  items.fireRing = Item("fireRing","fireRing",{["category"]="accessory",["subCategory"] = "ring",["fullName"] = "Fire ring",
    description = {"#silent","A ring with no damage and speed increasing properties, also more prone to enchants"},
    damageMultiplier = 1.25,
    speedMultiplier = 1.1,
  })
  items.coldRing = Item("coldRing","coldRing",{["category"]="accessory",["subCategory"] = "ring",["fullName"] = "Cold ring",
    description = {"#silent","A ring with cold but stronger properties, also more prone to enchants"},
    damageMultiplier = 1.2,
    cooldownReductionMultiplier = 0.9,
    speedMultiplier = 0.9,
  })
  items.natureRing = Item("natureRing","natureRing",{["category"]="accessory",["subCategory"] = "ring",["fullName"] = "Nature ring",
    description = {"#silent","A ring that increases passive regen, also more prone to enchants"},
    regenMultiplier = 1.3,
    healthMaxMultiplier = 1.1,
  })
  items.goldRing = Item("goldRing","goldRing",{["category"]="accessory",["subCategory"] = "ring",["fullName"] = "Gold ring",
    description = {"#silent","A ring with no innate properties, also more prone to enchants"},
    healthMaxMultiplier = 1.2,
  })
  items.voidRing = Item("voidRing","voidRing",{["category"]="accessory",["subCategory"] = "ring",["fullName"] = "Void ring",
    description = {"#silent","A ring with cooldown and gravity reduction properties, also more prone to enchants"},
    healthMaxMultiplier = 0.85,
    cooldownReductionMultiplier = 1.35,
    gravityMultiplier = 0.8,
  })
  items.healthNecklace = Item("healthNecklace","healthNecklace",{["category"]="accessory",["subCategory"] = "necklace",["fullName"] = "Health necklace",
    description = {"#silent","A necklace that gives a small health boost"},
    healthMaxMultiplier = 1.1,
  })
  items.greaterHealthNecklace = Item("greaterHealthNecklace","greaterHealthNecklace",{["category"]="accessory",["subCategory"] = "necklace",["fullName"] = "Greater Health necklace",
    description = {"#silent","A necklace that gives a larger health boost, for a portion or your movement speed"},
    healthMaxMultiplier = 1.25,
    regenMultiplier = 1.1,
    speedMultiplier = 0.85,
    --baseColorisation =  {0.8,0.4,1,2},
  })
  items.movementArtifact = Item("movementArtifact","movementArtifact",{["category"]="accessory",["subCategory"] = "artifact",["fullName"] = "Movement artifact",
    description = {"#silent","An artifact that increases your movement capabilities"},
    speedMultiplier = 1.3,
    jumpStrengthMultiplier = 1.1,
    --baseColorisation =  {0.8,0.4,1,2},
  })
  items.glassArtifact = Item("glassArtifact","glassArtifact",{["category"]="accessory",["subCategory"] = "artifact",["fullName"] = "Glass artifact",
    description = {"#silent","An artifact that increases your combat capabilities for your health"},
    damageMultiplier = 1.4,
    cooldownReductionMultiplier = 1.4,
    regenMultiplier = 1.2,
    healthMaxMultiplier = 0.6,
    --baseColorisation =  {0.8,0.4,1,2},
  })
end

function GenerateTileItems()
  if #tilelists["all tiles"] > 0 then 
    for i = 1, #tilelists["all tiles"] do
      local tileName = tilelists["all tiles"][i]
      local tile = tiles[tileName]
      if tileName ~= "none" then
        if items[tileName] == nil  then
          if tile.flags ~= nil then
            textures["sprites"][tileName.."_tile"] = Sprite(tileName.."_tile",tile.textureName,{["parts"] = {"small","medium"},
                ["small"] ={
                  ["type"] = "still",
                  ["timePerFrame"] = 1,
                  ["gridMultiplication"] = tile.flags["newQuad"][5],
                  ["spriteSize"] = {tile.flags["newQuad"][3]/2,tile.flags["newQuad"][4]/2},
                  ["spriteCenter"] = {
                    (tile.textureCenterX / tile.flags["newQuad"][5])-0.25,
                    (tile.textureCenterY / tile.flags["newQuad"][5])-0.25
                  },
                  ["quads"] = {{tile.flags["newQuad"][1],tile.flags["newQuad"][2]}}
                },
                ["medium"] ={
                  ["type"] = "still",
                  ["timePerFrame"] = 1,
                  ["gridMultiplication"] = tile.flags["newQuad"][5],
                  ["spriteSize"] = {tile.flags["newQuad"][3],tile.flags["newQuad"][4]},
                  ["spriteCenter"] = {
                    tile.textureCenterX / tile.flags["newQuad"][5],
                    tile.textureCenterY / tile.flags["newQuad"][5]
                  },
                  ["quads"] = {{tile.flags["newQuad"][1],tile.flags["newQuad"][2]}}
                },
                },{})
            if tile.type == "top" then 
              items[tileName] = Item(tileName,tileName.."_tile",{["placeBlock"]=tileName,["category"]="bloc",["subCategory"]="top",["groundSize"] = 0.23,["blockPlaceLayer"]="topTiles"})
            else
              items[tileName] = Item(tileName,tileName.."_tile",{["placeBlock"]=tileName,["category"]="bloc",["subCategory"]="front tile",["groundSize"] = 0.23}) 
            end
            if tile.type == "solid" or tile.type == "not-solid" or tile.type == "non-solid" then 
              items[tileName.." wall"] = Item(tileName.." wall",tileName.."_tile",{["placeBlock"]=tileName,["category"]="bloc",["subCategory"]="wall",["groundSize"] = 0.23,["blockPlaceLayer"]="backTiles",["baseColor"]={0.6,0.6,0.6,1}}) 
            end
          else

          end
          
        end
      end
    end
  end


  --[[
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
    ]]
end

function generateBaseBiomes()
  --biomeName, temperature, wetness, deepnessmin, deepnessmax, deepnesssmooth, likeness
  --stage 1
  world:addBiome("none", 0.5, 0.5, -0.5, 1, 0.3, 0.45)
  world:addBiome("duneland", 0.7, 0.2, -0.5, 1, 0.3, 0.5)
  world:addBiome("essenceLand", 0.3, 0.8, -0.5, 1, 0.3, 0.75)

  --stage 2
  world:addBiome("coldland", 0.2, 0.4, 0.7, 2, 0.3, 1)
  --stage 3
  world:addBiome("hotland", 0.8, 0.6, 1.7, 3, 0.3, 1)
  --stage 4
  world:addBiome("ancientland", 0.3, 0.9, 2.7, 4, 0.3, 0.8)
  --stage 5
  world:addBiome("darkland", 0.8, 0.6, 3.7, 6, 0.3, 1)

  --[[
  world:addBiome("none", 0.5, 0.5, -1, 4, 5, 1)
  world:addBiome("coldland", 0.2, 0.4, 0.5, 15, 8, 1)
  world:addBiome("hotland", 0.8, 0.6, 2.5, 30, 8, 1)
  world:addBiome("darkland", 0.5, 0.3, 10, 99999, 1, 1)
  world:addBiome("ancientland", 0.3, 0.9, 5, 50, 8, 0.8)
  world:addBiome("duneland", 0.8, 0.1, 6, 30, 10, 0.5)
  world:addBiome("duneland", 0.7, 0.2, -1, 3, 2, 0.3) --oui, il est en double, une fois à la surface
  ]]

  --[[
  world:addBiome("none",0.5,0.5,-1,99999,5,1)
  world:addBiome("coldland",0.2,0.4,-1,99999,8,1)
  world:addBiome("hotland",0.8,0.6,-1,99999,8,1)
  world:addBiome("darkland",0.5,0.3,-1,99999,1,1)
  world:addBiome("ancientland",0.3,0.9,-1,99999,8,0.8)
  world:addBiome("duneland",0.7,0.2,-1,99999,10,1.2)]]
end

function generateRandomBiomeList()
  world:clearBiomes()
  if math.random() > 0.6 then world:addBiome("none", 0.5, 0.5, math.random() * 3 - 1, 99999, 5, 1) end
  if math.random() > 0.6 then world:addBiome("coldland", 0.2, 0.4, math.random() * 3 - 1, 99999, 3, 1) end
  if math.random() > 0.6 then world:addBiome("hotland", 0.8, 0.6, math.random() * 3 - 1, 99999, 1, 1) end
  if math.random() > 0.6 then world:addBiome("darkland", 0.5, 0.3, math.random() * 3 - 1, 99999, 1, 1) end
  if math.random() > 0.6 then world:addBiome("ancientland", 0.3, 0.9, math.random() * 3 - 1, 99999, 1, 0.2) end
  if math.random() > 0.6 then world:addBiome("duneland", 0.7, 0.2, math.random() * 3 - 1, 99999, 5, 1) end
end

function LoadInterfaces()

  interfaces = {}

  interfaces["mainMenu"] = Interface("MainMenu",0.5,0.35,0.6,0.6,"invisible",{0.6,0.6,0.9,1},{1,1,1,1},{["gap"]=0.03,["scrollMargin"]=0})
  interfaces["mainMenu"]:addElement("playButton","button",0.4,0.1,"Play",{},{},nil,nil)
  interfaces["mainMenu"]:addElement("settingsButton","button",0.4,0.1,"Settings",{},{},nil,nil)
  interfaces["mainMenu"]:addElement("quitButton","button",0.4,0.1,"Quit",{},{},nil,nil)


  interfaces["pause"] = Interface("pause",0.5,0.3,0.6,0.6,"invisible",{0.6,0.6,0.9,1},{1,1,1,1},{["gap"]=0.03,["scrollMargin"]=0})
  interfaces["pause"]:addElement("returnButton","button",0.4,0.1,"Back",{},{},nil,nil)
  interfaces["pause"]:addElement("retryButton","button",0.4,0.1,"Retry",{},{},nil,nil)
  interfaces["pause"]:addElement("leaveGameButton","button",0.4,0.1,"Quit",{},{},nil,nil)


  interfaces["worldCreation"] = Interface("worldCreation",0.5,0.15,0.6,0.8,"bland",{0.6,0.9,0.6,1},{1,1,1,1},{["title"]= "World Creation",["gap"]=0.00,["scrollMargin"]=0.1,["showTitle"] = true})
  interfaces["worldCreation"]:addElement("createButton","button",0.4,0.1,"Create world",{},{},nil,nil)
  --multiple choices
  interfaces["worldCreation"]:addElement("worldHeigth","options",0.9,0.2,"World deepness :",{"1000","2000","3000","5000","7000"},{["textAlign"] = "left",["gap"]=0,["default"] = "3000"},nil,nil)
  interfaces["worldCreation"]:addElement("worldWidth","options",0.9,0.2,"World width :",{"150","300","450","600","750"},{["textAlign"] = "left",["gap"]=0,["default"] = "450"},nil,nil)
  interfaces["worldCreation"]:addElement("biomeSize","options",0.9,0.2,"Biome size :",{"50","100","150","250","400"},{["textAlign"] = "left",["gap"]=0,["default"] = "150"},nil,nil)
  interfaces["worldCreation"]:addElement("terrainSize","options",0.9,0.2,"Terrain & caves size :",{"0.5","1","2","3","5","10"},{["textAlign"] = "left",["gap"]=0,["default"] = "1"},nil,nil)
  interfaces["worldCreation"]:addElement("worldseed","textinput",0.9,0.08,"World seed",{},{["textAlign"] = "left",["gap"]=0,["default"] = "", acceptOnly = "digits", placeHolder = "random"},nil,nil)
  --checkboxes
  interfaces["worldCreation"]:addElement("cheat", "checkbox",0.9,0,"Cheat Toggle",{},{["textAlign"] = "left",["gap"]=0,["default"] = false},nil,nil)
  interfaces["worldCreation"]:addElement("freeCam","checkbox",0.9,0,"Free cam Toggle",{},{["textAlign"] = "left",["gap"]=0,["default"] = false},nil,nil)
  interfaces["worldCreation"]:addElement("flyCheat","checkbox",0.9,0,"Fly & noClip Toggle",{},{["textAlign"] = "left",["gap"]=0,["default"] = false},nil,nil)
  interfaces["worldCreation"]:addElement("BuilderCheat","checkbox",0.9,0,"Builder Cheat Toggle",{},{["textAlign"] = "left",["gap"]=0,["default"] = false},nil,nil)
  --sliders
  interfaces["worldCreation"]:addElement("lightReach","slider",0.9,0.2,"Light reach",{["round"] = 1,["min"] = 1, ["max"]= 12,["displayMultiplication"]=1},{["textAlign"] = "left",["gap"]=0,["default"] = 6},nil,nil)
  interfaces["worldCreation"]:addElement("directorCreditMultiplier","slider",0.9,0.2,"Director credit multiplier",{["round"] = 0.1,["min"] = 0, ["max"]= 10,["displayMultiplication"]=1},{["textAlign"] = "left",["gap"]=0,["default"] = 1},nil,nil)
  interfaces["worldCreation"]:addElement("directorSpawnSpeedMultiplier","slider",0.9,0.2,"Director spawn speed multiplier",{["round"] = 0.1,["min"] = 0.1, ["max"]= 10,["displayMultiplication"]=1},{["textAlign"] = "left",["gap"]=0,["default"] = 1},nil,nil)
  --interfaces["worldCreation"]:addElement("seed","slider",0.9,0.2,"World seed",{["round"] = 1,["min"] = 1, ["max"]= 9999999,["displayMultiplication"]=1},{["textAlign"] = "left",["gap"]=0,["default"] = 6},nil,nil)
  interfaces["worldCreation"]:addElement("resetWorldCreation","button",0.3,0.08,"Default",{},{},nil,nil)


  interfaces["settings"] = Interface("settings",0.5,0.15,0.6,0.8,"bland",{0.9,0.6,0.6,1},{1,1,1,1},{["title"]= "Settings",["gap"]=0.00,["scrollMargin"]=0.1,["showTitle"] = true})
  interfaces["settings"]:addElement("resetSettings","button",0.4,0.1,"Reset Settings",{},{},nil,nil)
  --interfaces["settings"]:addElement("cheat","checkbox",0.9,0,"Cheat Toggle",{},{["textAlign"] = "left",["gap"]=0,["default"] = false},nil,nil)
  --interfaces["settings"]:addElement("lightReach","slider",0.9,0.2,"Light reach",{["round"] = 1,["min"] = 1, ["max"]= 12,["displayMultiplication"]=1},{["textAlign"] = "left",["gap"]=0,["default"] = 6},nil,nil)
  interfaces["settings"]:addElement("chunkRenderDistance","slider",0.9,0.2,"Additional chunk gen distance",{["round"] = 1,["min"] = 20, ["max"]= 50,["displayAddition"]=-20,["displayMultiplication"]=1},{["textAlign"] = "left",["gap"]=0,["default"] = 20},nil,nil)
  interfaces["settings"]:addElement("maxChunkLoadedPerFrame","slider",0.9,0.2,"Max chunks generated per frame",{["round"] = 1,["min"] = 0, ["max"]= 50},{["textAlign"] = "left",["gap"]=0,["default"] = 9},nil,nil)
  interfaces["settings"]:addElement("HealthBarStyle","options",0.9,0.2,"Health bar sections style :",{"seperated","glued"},{["textAlign"] = "left",["gap"]=0,["default"] = "seperated"},nil,nil)
  interfaces["settings"]:addElement("HealthBarPosition","options",0.9,0.2,"Health bar position :",{"top","bottom"},{["textAlign"] = "left",["gap"]=0,["default"] = "bottom"},nil,nil)
  interfaces["settings"]:addElement("MapZoom","slider",0.9,0.2,"Map zoom",{["round"] = 0.2,["min"] = 0.4, ["max"]= 5},{["textAlign"] = "left",["gap"]=0,["default"] = 2},nil,nil)
  interfaces["settings"]:addElement("fullscreen", "checkbox",0.9,0,"Fullscreen",{},{["textAlign"] = "left",["gap"]=0,["default"] = false},nil,nil)
  interfaces["settings"]:addElement("InventorySize","slider",0.9,0.2,"Inventory size",{["round"] = 0.1,["min"] = 0.5, ["max"]= 1.5},{["textAlign"] = "left",["gap"]=0,["default"] = 1},nil,nil)
  interfaces["settings"]:addElement("InventoryTextSize","slider",0.9,0.2,"Inventory text size",{["round"] = 0.1,["min"] = 1, ["max"]= 2},{["textAlign"] = "left",["gap"]=0,["default"] = 1.4},nil,nil)
  interfaces["settings"]:addElement("SelectedFont","slider",0.9,0.2,"Font",{["round"] = 1,["min"] = 1, ["max"]= #Fonts},{["textAlign"] = "left",["gap"]=0,["default"] = 1},nil,nil)
  interfaces["settings"]:addElement("UISize","slider",0.9,0.2,"UI size",{["round"] = 0.1,["min"] = 0.5, ["max"]= 1.5},{["textAlign"] = "left",["gap"]=0,["default"] = 1},nil,nil)
  interfaces["settings"]:addElement("resetUI","button",0.4,0.1,"Reset UI",{},{},nil,nil)
  


  interfaces["back"] = Interface("back",0.1,-0.05,0.3,0.3,"invisible",{0.6,0.6,0.9,1},{1,1,1,1},{["gap"]=0.03,["scrollMargin"]=0,["elementsStayInBound"]=false})
  interfaces["back"]:addElement("back","button",0.4,0.075,"Back",{},{["gap"]=0},nil,nil)

end
function LoadItemSets()
  LoadItemSet("copper",nil,{0.7,0.35,0,0.65},nil,{0.8,0.4,0.05,0.5},{damageM=1.2,cooldownM=1.4,rangeM=0.9,blockAmountM=1.2,weightM=0.8,enchantM=1.2,minLevel=0,maxLevel = 10})
  LoadItemSet("iron",nil,{0.8,0.85,0.9,0.65},nil,{0.8,0.4,0.05,0.5},{damageM=1.5,cooldownM=1.3,rangeM=0.9,blockAmountM=1.2,weightM=0.75,enchantM=1.2,minLevel=4,maxLevel = 17})
  LoadItemSet("silver",nil,{0.55,0.7,0.9,0.75},nil,{0.8,0.4,0.05,0.5},{damageM=1.3,cooldownM=1.15,rangeM=0.8,blockAmountM=0.7,weightM=0.65,enchantM=0.75,minLevel=8,maxLevel=20, toolSpriteNameAdd = "Tough"})
  LoadItemSet("lead",nil,{0.2,0.22,0.6,0.65},nil,{0.8,0.4,0.05,0.5},{damageM=2,cooldownM=1.6,rangeM=0.7,blockAmountM=1.2,weightM=0.60,enchantM=1.8,minLevel=10,maxLevel=24})
  LoadItemSet("gold",nil,{1,0.85,0.5,0.75},nil,{0.5,0.4,0.2,0.5},{damageM=1.9,cooldownM=0.8,rangeM=1.2,blockAmountM=1,weightM=0.4,enchantM=1.6,minLevel=14,maxLevel=30, toolSpriteNameAdd = "Tough"})
  LoadItemSet("mithril",nil,{0.3,0.9,0.7,0.65},nil,{0.3,0.25,0.05,0.5},{damageM=2.5,cooldownM=1.4,rangeM=1,blockAmountM=1,weightM=0.3,enchantM=2.5,minLevel=22,maxLevel=45, toolSpriteNameAdd = "Tough"})

  LoadItemSet("tin",nil,{0.85,0.83,0.78,0.65},nil,{0.8,0.4,0.05,0.5},{damageM=1.22,cooldownM=1.35,rangeM=0.92,blockAmountM=1.15,weightM=0.75,enchantM=1.25,minLevel=1,maxLevel=12})
  LoadItemSet("bronze",nil,{0.6,0.35,0.05,0.7},nil,{0.5,0.4,0.18,0.6},{damageM=1.35,cooldownM=1.25,rangeM=0.95,blockAmountM=1.1,weightM=0.74,enchantM=1.3,minLevel=3,maxLevel=15, toolSpriteNameAdd = "Tough"})
  LoadItemSet("nickel",nil,{0.7,0.74,0.72,0.7},nil,{0.8,0.4,0.05,0.5},{damageM=1.45,cooldownM=1.18,rangeM=0.94,blockAmountM=1.05,weightM=0.72,enchantM=1.45,minLevel=6,maxLevel=18})
  LoadItemSet("cobalt",nil,{0.25,0.45,0.9,0.72},nil,{0.3,0.5,0.9,0.62},{damageM=1.55,cooldownM=1.05,rangeM=1.03,blockAmountM=0.95,weightM=0.70,enchantM=1.7,minLevel=10,maxLevel=26, toolSpriteNameAdd = "Tough"})
  LoadItemSet("steel",nil,{0.55,0.6,0.66,0.95},nil,{0.5,0.25,0.05,0.5},{damageM=1.7,cooldownM=1.22,rangeM=0.96,blockAmountM=1.15,weightM=0.68,enchantM=1.6,minLevel=12,maxLevel=28, toolSpriteNameAdd = "Tough"})
  LoadItemSet("fossil",nil,{0.99,0.92,0.7,0.8},nil,{0.9,0.82,0.5,0.58},{damageM=1.6,cooldownM=0.88,rangeM=1.12,blockAmountM=0.85,weightM=0.66,enchantM=1.95,minLevel=15,maxLevel=32, toolSpriteNameAdd = "Tough"})
  LoadItemSet("obsidian",nil,{0.22,0.1,0.35,0.78},nil,{0.25,0.12,0.4,0.62},{damageM=2.2,cooldownM=1.3,rangeM=0.93,blockAmountM=1.2,weightM=0.64,enchantM=2.4,minLevel=20,maxLevel=42})
  LoadItemSet("quartz",nil,{0.9,0.95,1,0.85},nil,{0.3,0.25,0.32,0.5},{damageM=1.5,cooldownM=0.92,rangeM=1.16,blockAmountM=0.78,weightM=0.62,enchantM=2.1,minLevel=18,maxLevel=36,toolSpriteNameAdd = "Crystal"})
  LoadItemSet("moonstone",nil,{0.66,0.76,1,0.72},nil,{0.35,0.2,0.5,0.52},{damageM=1.75,cooldownM=0.82,rangeM=1.08,blockAmountM=0.8,weightM=0.58,enchantM=2.6,minLevel=24,maxLevel=46, toolSpriteNameAdd = "Tough"})
  LoadItemSet("sunsteel",nil,{0.9,0.9,0.25,0.58},nil,{1,0.5,0.3,0.9},{damageM=2.1,cooldownM=0.95,rangeM=1.1,blockAmountM=0.9,weightM=0.56,enchantM=2.8,minLevel=28,maxLevel=50, toolSpriteNameAdd = "Tough"})
  LoadItemSet("jade",nil,{0.2,0.8,0.5,0.7},nil,{0.8,0.4,0.05,0.5},{damageM=1.65,cooldownM=1.1,rangeM=1,blockAmountM=1,weightM=0.53,enchantM=2.2,minLevel=16,maxLevel=34,toolSpriteNameAdd = "Crystal"})
  LoadItemSet("amethyst",nil,{0.85,0.6,0.95,0.85},{0.18,0.08,0.28,0.5},{0.74,0.5,0.96,0.56},{damageM=1.85,cooldownM=0.9,rangeM=1.05,blockAmountM=0.82,weightM=0.5,enchantM=3,minLevel=30,maxLevel=54,toolSpriteNameAdd = "Crystal"})
  LoadItemSet("topaz",nil,{1,0.6,0.35,0.72},nil,{0.4,0.2,0.05,0.5},{damageM=1.95,cooldownM=0.78,rangeM=1.18,blockAmountM=0.75,weightM=0.45,enchantM=2.7,minLevel=26,maxLevel=48,toolSpriteNameAdd = "Crystal"})
  LoadItemSet("garnet",nil,{0.78,0.2,0.26,0.75},nil,{0.8,0.4,0.05,0.5},{damageM=2.05,cooldownM=1.02,rangeM=0.98,blockAmountM=1.05,weightM=0.4,enchantM=2.9,minLevel=27,maxLevel=49})
  LoadItemSet("tungsten",nil,{0.3,0.34,0.38,0.8},nil,{0.2,0.2,0.3,0.5},{damageM=2.4,cooldownM=1.28,rangeM=0.95,blockAmountM=1.18,weightM=0.35,enchantM=2.6,minLevel=32,maxLevel=58, toolSpriteNameAdd = "Tough"})
  LoadItemSet("titanium",nil,{0.52,0.72,0.86,0.7},{0.16,0.2,0.24,0.5},{0.56,0.78,0.9,0.5},{damageM=2.3,cooldownM=0.74,rangeM=1.1,blockAmountM=0.88,weightM=0.3,enchantM=3.1,minLevel=34,maxLevel=62, toolSpriteNameAdd = "Tough"})
  LoadItemSet("platinum",nil,{0.86,0.9,0.95,0.75},nil,{0.4,0.4,0.2,0.5},{damageM=2,cooldownM=0.7,rangeM=1.15,blockAmountM=0.8,weightM=0.25,enchantM=3.2,minLevel=38,maxLevel=70})
  LoadItemSet("orichalcum",nil,{0.28,0.9,0.82,0.75},nil,{0.25,0.7,0.68,0.58},{damageM=2.6,cooldownM=0.98,rangeM=1.04,blockAmountM=0.92,weightM=0.2,enchantM=3.3,minLevel=40,maxLevel=78,toolSpriteNameAdd = "Crystal"})
  LoadItemSet("voidstone",nil,{0.18,0.08,0.24,0.85},nil,{0.2,0.1,0.3,0.65},{damageM=2.75,cooldownM=1.12,rangeM=0.9,blockAmountM=1.1,weightM=0.15,enchantM=3.4,minLevel=44,maxLevel=90,toolSpriteNameAdd = "Crystal"})
  LoadItemSet("adamantite",nil,{1,0.15,0.15,0.78},nil,{0.78,0.98,1,0.55},{damageM=2.85,cooldownM=0.62,rangeM=1.2,blockAmountM=0.72,weightM=0.13,enchantM=3.45,minLevel=50,maxLevel=999, toolSpriteNameAdd = "Tough"})

  LoadItemSet("diamond",nil,{0.7,1,1,0.75},nil,{0.2,0.3,0.3,0.5},{damageM=3,cooldownM=0.5,rangeM=1.2,blockAmountM=0.7,weightM=0.1,enchantM=3.5,minLevel=50,maxLevel=999,toolSpriteNameAdd = "Crystal"})

  
end
function LoadItemSet(name,topColor,topColorisation,baseColor,baseColorisation,flags)
  topColor = topColor or nil
  topColorisation = topColorisation or nil
  baseColor = baseColor or nil
  baseColorisation = baseColorisation or nil
  flags = flags or {}
  damageM = flags.damageM or 1
  cooldownM = flags.cooldownM or 1
  rangeM = flags.rangeM or 1
  blockAmountM = flags.blockAmountM or 1
  weightM = flags.weightM or 1
  costM = flags.costM or 1
  enchantM = flags.enchantM or 1
  minLevel = flags.minLevel or 0
  maxLevel = flags.maxLevel or 999
  toolSpriteNameAdd = flags.toolSpriteNameAdd or ""

  local function addSetTool(toolName, topSprite,baseSprite, stats)
    items[toolName] = Item(toolName,
    {
      {sprite = baseSprite,colorisation = baseColorisation, color = baseColor},
      {sprite = topSprite,colorisation = topColorisation, color = topColor},
    }
    ,{category = "tool",subCategory = "pickaxe",fullName = toolName,
      cooldown = stats.cooldown * cooldownM,
      mineDamage = stats.mineDamage * damageM,
      blockDamageAmount = stats.blockDamageAmount * blockAmountM,
      rangeLimit = stats.rangeLimit * rangeM,
      mineWidth = stats.mineWidth,
      holdAnimation =
      {
        {sprite = "toolBase_Hold",colorisation = baseColorisation, color = baseColor},
        {sprite = "toolTop_Hold",colorisation = topColorisation, color = topColor},
      },
    })

    if stats.cooldownSpeedPerLevel ~= nil then
      items[toolName].cooldownSpeedPerLevel = stats.cooldownSpeedPerLevel / cooldownM
    end
    if stats.mineDamagePerLevel ~= nil then
      items[toolName].mineDamagePerLevel = stats.mineDamagePerLevel * damageM
    end
    if stats.blockDamageAmountPerLevel ~= nil then
      items[toolName].blockDamageAmountPerLevel = stats.blockDamageAmountPerLevel * blockAmountM
    end
    if stats.rangeLimitPerLevel ~= nil then
      items[toolName].rangeLimitPerLevel = stats.rangeLimitPerLevel * rangeM
    end
    ItemCard[toolName] = ItemCard(10*costM,math.ceil(75*weightM),toolName,"common","tool",1*enchantM,{"any"},{
      minLevel = minLevel,
      maxLevel = maxLevel,
    })
  end

  local function addSetWeapon(toolName, topSprite,baseSprite, subCategory, stats, weaponBase,weaponTop)
    local weaponFlags = CopyAll(stats)

      if weaponBase == nil then
        weaponBase = "meleeWeaponBase_Hold"
      end
      if weaponTop == nil then
        weaponTop = "meleeWeaponTop_Hold"
      end
    
      weaponFlags.category = "weapon"
      weaponFlags.subCategory = subCategory
      weaponFlags.fullName = toolName
      weaponFlags.holdAnimation = {
        {sprite = weaponBase,colorisation = baseColorisation, color = baseColor},
        {sprite = weaponTop,colorisation = topColorisation, color = topColor},
      }

    if topColorisation ~= nil then
      weaponFlags.swingColor = OverrideColor(CopyAll(topColorisation),{0.8,0.8,0.8,0.8},0.5)
    end
    
    if stats.cooldown ~= nil then
      weaponFlags.cooldown = stats.cooldown * cooldownM
    end
    if stats.damage ~= nil then
      weaponFlags.damage = stats.damage * damageM
    end
    if stats.damagePerLevel ~= nil then
      weaponFlags.damagePerLevel = stats.damagePerLevel * damageM
    end
    if stats.blockDamageAmount ~= nil then
      weaponFlags.blockDamageAmount = stats.blockDamageAmount * blockAmountM
    end
    if stats.blockDamageAmountPerLevel ~= nil then
      weaponFlags.blockDamageAmountPerLevel = stats.blockDamageAmountPerLevel * blockAmountM
    end
    if stats.rangeLimit ~= nil then
      weaponFlags.rangeLimit = stats.rangeLimit * rangeM
    end
    if stats.rangeLimitPerLevel ~= nil then
      weaponFlags.rangeLimitPerLevel = stats.rangeLimitPerLevel * rangeM
    end
    if stats.attackRange ~= nil then
      weaponFlags.attackRange = stats.attackRange * rangeM
    end
    if stats.attackRadius ~= nil then
      weaponFlags.attackRadius = stats.attackRadius
    end
    if stats.attackDirectionRange ~= nil then
      weaponFlags.attackDirectionRange = stats.attackDirectionRange
    end
    if stats.charge ~= nil then
      weaponFlags.charge = stats.charge
    end
    if stats.moveSpeedDuringCharge ~= nil then
      weaponFlags.moveSpeedDuringCharge = stats.moveSpeedDuringCharge
    end
    if stats.dashVelocity ~= nil then
      weaponFlags.dashVelocity = stats.dashVelocity * blockAmountM
    end
    if stats.dashTime ~= nil then
      weaponFlags.dashTime = stats.dashTime
    end
    if stats.dashGravityMultiplier ~= nil then
      weaponFlags.dashGravityMultiplier = stats.dashGravityMultiplier
    end
    if stats.knockback ~= nil then
      weaponFlags.knockback = stats.knockback
    end
    if stats.projectileVelocity ~= nil then
      weaponFlags.projectileVelocity = stats.projectileVelocity * ((blockAmountM+0.2)^0.5)
    end
    if stats.projectileGravity ~= nil then
      weaponFlags.projectileGravity = stats.projectileGravity / enchantM
    end
    if stats.projectileBounceFactor ~= nil then
      weaponFlags.projectileBounceFactor = stats.projectileBounceFactor
    end
    if stats.projectileMovementSlide ~= nil then
      weaponFlags.projectileMovementSlide = stats.projectileMovementSlide
    end
    if stats.projectileSprite ~= nil then
      weaponFlags.projectileSprite = stats.projectileSprite
    end
    if stats.projectileName ~= nil then
      weaponFlags.projectileName = stats.projectileName
    end
    if stats.onUse ~= nil then
      weaponFlags.onUse = stats.onUse
    end

    items[toolName] = Item(toolName,
    {
      {sprite = baseSprite,colorisation = baseColorisation, color = baseColor},
      {sprite = topSprite,colorisation = topColorisation, color = topColor},
    }
    ,weaponFlags)

    if stats.cooldownSpeedPerLevel ~= nil then
      items[toolName].cooldownSpeedPerLevel = stats.cooldownSpeedPerLevel / cooldownM
    end
    ItemCard[toolName] = ItemCard(10*costM,math.ceil(150*weightM),toolName,"common","weapon",1*enchantM,{"any"},{
      minLevel = minLevel,
      maxLevel = maxLevel,
    })
  end

  addSetTool(name.." pickaxe", "pickaxeTop"..toolSpriteNameAdd, "toolBase", {
    cooldown = 0.8,
    cooldownSpeedPerLevel = 0.03,
    mineDamage = 0.8,
    mineDamagePerLevel = 0.03,
    blockDamageAmount = 6,
    rangeLimit = 5,
    rangeLimitPerLevel = 0.15,
    mineWidth = 3,
  })

  addSetTool(name.." spike", "spikeTop"..toolSpriteNameAdd, "toolBase", {
    cooldown = 0.6,
    cooldownSpeedPerLevel = 0.02,
    mineDamage = 1.2,
    mineDamagePerLevel = 0.06,
    blockDamageAmount = 3,
    rangeLimit = 7,
    rangeLimitPerLevel = 0.2,
    mineWidth = 1,
  })

  addSetTool(name.." sway pickaxe", "swayPickaxeTop"..toolSpriteNameAdd, "toolBase", {
    cooldown = 2.4,
    mineDamage = 0.8,
    mineDamagePerLevel = 0.02,
    blockDamageAmount = 18,
    blockDamageAmountPerLevel = 0.8,
    rangeLimit = 8,
    rangeLimitPerLevel = 0.3,
    mineWidth = 6,
  })

  addSetTool(name.." hammer", "hammerTop"..toolSpriteNameAdd, "toolBase", {
    cooldown = 2,
    cooldownSpeedPerLevel = 0.05,
    mineDamage = 4,
    mineDamagePerLevel = 0.1,
    blockDamageAmount = 3,
    rangeLimit = 5,
    rangeLimitPerLevel = 0.2,
    mineWidth = 2,
  })

  addSetTool(name.." scalpel", "chiselTop"..toolSpriteNameAdd, "toolBaseSmall", {
    cooldown = 0.12,
    mineDamage = 0.5,
    mineDamagePerLevel = 0.05,
    blockDamageAmount = 0.4,
    rangeLimit = 3,
    rangeLimitPerLevel = 0.03,
    mineWidth = 1,
  })

  addSetTool(name.." shovel", "shovelTop"..toolSpriteNameAdd, "toolBase", {
    cooldown = 1.8,
    cooldownSpeedPerLevel = 0.04,
    mineDamage = 1.2,
    blockDamageAmount = 9,
    blockDamageAmountPerLevel = 0.3,
    rangeLimit = 6,
    rangeLimitPerLevel = 0.3,
    mineWidth = 3,
  })

  addSetTool(name.." stiff pick", "stiffPickTop"..toolSpriteNameAdd, "toolBase", {
    cooldown = 1.15,
    mineDamage = 1.4,
    mineDamagePerLevel = 0.08,
    blockDamageAmount = 5,
    blockDamageAmountPerLevel = 0.1,
    rangeLimit = 8,
    rangeLimitPerLevel = 0.07,
    mineWidth = 3,
  })

  addSetTool(name.." target pickaxe", "targetPickaxeTop"..toolSpriteNameAdd, "toolBase", {
    cooldown = 0.2,
    mineDamage = 0.25,
    mineDamagePerLevel = 0.0075,
    blockDamageAmount = 5,
    blockDamageAmountPerLevel = 0.2,
    rangeLimit = 5,
    rangeLimitPerLevel = 0.25,
    mineWidth = 0.8,
  })



  addSetWeapon(name.." knife", "smallSwordTop"..toolSpriteNameAdd, "toolBase", "melee", {
    cooldown = 1,
    cooldownSpeedPerLevel = 0.02,
    damage = 6,
    damagePerLevel = 0.35,
    attackRange = 2.5,
    attackRadius = 1, 
    charge = 0.2,
    moveSpeedDuringCharge = 0.8,
    dashVelocity = 8,
    dashTime = 0.2,
    knockback = 0.6,
  })
  addSetWeapon(name.." sword", "swordTop"..toolSpriteNameAdd, "toolBase", "melee", {
    cooldown = 2.4,
    cooldownSpeedPerLevel = 0.01,
    damage = 14,
    damagePerLevel = 1.4,
    attackRange = 4,
    attackRadius = 1, 
    charge = 0.5,
    moveSpeedDuringCharge = 0.4,
    dashVelocity = 8,
    dashTime = 0.3,
    knockback = 1.2,
  })
  addSetWeapon(name.." big sword", "bigSwordTop"..toolSpriteNameAdd, "toolBase", "melee", {
    cooldown = 4.3,
    cooldownSpeedPerLevel = 0,
    damage = 25,
    damagePerLevel = 2.8,
    attackRange = 2.5,
    attackRadius = 2, 
    charge = 0.8,
    moveSpeedDuringCharge = 0.15,
    dashVelocity = 8,
    dashTime = 0.15,
    dashGravityMultiplier = 0.75,
    knockback = 2,
  })
  addSetWeapon(name.." spear", "lanceTop"..toolSpriteNameAdd, "toolBase", "melee", {
    cooldown = 3,
    cooldownSpeedPerLevel = 0.015,
    damage = 13,
    damagePerLevel = 0.8,
    attackRange = 6,
    attackRadius = 1, 
    charge = 0.3,
    moveSpeedDuringCharge = 0.5,
    dashVelocity = 10,
    dashTime = 0.5,
    dashGravityMultiplier = 0.01,
    knockback = 1,
  })
  addSetWeapon(name.." bow", "bowTop"..toolSpriteNameAdd, "bowBase", "ranged", {
    cooldown = 5,
    damage = 18,
    damagePerLevel = 1.1,
    charge = 0.1,
    moveSpeedDuringCharge = 0.4,
    knockback = 1,
    projectileVelocity = 35,
    projectileGravity = 0.5,
    projectileSprite = {
      {sprite = "arrowBase",colorisation = baseColorisation, color = baseColor},
      {sprite = "arrowTop"..toolSpriteNameAdd,colorisation = topColorisation, color = topColor}
    },
    onUse = function (self,entity,attributes,cursorX,cursorY,slot,stacks,flags) 
      local onUseSuccess, onUseCooldown, onUseStacksRemove
      onUseSuccess = false

      local projectileFlags = CopyAll(flags)
      projectileFlags.animationType = "orientation"
      
      onUseSuccess, onUseCooldown, onUseStacksRemove = self:spawnProjectile(entity, attributes, cursorX, cursorY,slot,stacks,projectileFlags)

      return onUseSuccess, onUseCooldown, onUseStacksRemove
    end
  }, "bowBase_Hold", "bowTop_Hold")
  --[[addSetWeapon(name.." ring", "ringTop"..toolSpriteNameAdd, "ringCrystal", "melee", {
    cooldown = 3,
    cooldownSpeedPerLevel = 0.015,
    damage = 10,
    damagePerLevel = 0.6,
    attackRange = 6,
    attackRadius = 1, 
    charge = 0.3,
    moveSpeedDuringCharge = 0.5,
    dashVelocity = 10,
    dashTime = 0.5,
    dashGravityMultiplier = 0.01,
    knockback = 1,
  })]]
  --[[items.crudeSword = Item("crudeSword","crudeSword",{["category"]="weapon",["subCategory"] = "melee",["fullName"] = "Crude sword",
    cooldown = 2,
    damage = 8,
    damagePerLevel = 2,
    attackRange = 3.2,
    attackRadius = 1, 
    attackDirectionRange = 100,
    holdAnimation = "crudeSword_Hold",
    charge = 0.3,
    moveSpeedDuringCharge = 0.4,
    dashVelocity = 8,
    dashTime = 0.2,
    knockback = 1,
  })]]
end