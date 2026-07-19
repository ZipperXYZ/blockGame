function loadeverything()
  
  loadtextures()
  loadtiles()
  loadItems()
  GenerateTileItems()
  LoadInterfaces()

  LoadStructureList()
  --loadbiomes()
  loadEntities()
end

function loadtextures()
  print("loadtextures")
  textures = {}
  textures["textures"] = {}
  textures["quads"] = {}
  textures["sprites"] = {}
  textures["textures"]["tiles.png"]=love.graphics.newImage("Textures/tiles.png")
  textures["textures"]["items1.png"]=love.graphics.newImage("Textures/items1.png")
  textures["textures"]["player.png"]=love.graphics.newImage("Textures/player.png")
  textures["textures"]["miscTiles.png"]=love.graphics.newImage("Textures/miscTiles.png")
  textures["textures"]["inventoryIcons.png"]=love.graphics.newImage("Textures/inventoryIcons.png")
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
  textures["sprites"]["stick"] = Sprite("stick","items1.png",{["parts"] = {"small","medium","large"}},{["setupItem"] = true,["itemQuadrant"]={0,0}})
  textures["sprites"]["rock"] = Sprite("rock","items1.png",{["parts"] = {"small","medium"}},{["setupItem"] = true,["itemQuadrant"]={0,8}})
  textures["sprites"]["crudePickaxe"] = Sprite("crudePickaxe","items1.png",{["parts"] = {"small","medium","large"}},{["setupItem"] = true,["itemQuadrant"]={0,4}})
  
  textures["sprites"]["placementPreview"] = Sprite("placementPreview","miscTiles.png",{["gridMultiplication"] = 8, ["spriteSize"] = {1,1},["quads"] = {0,0}, ["spriteCenter"] = {0.5,0.5}},{["type"] = "singleImage"})
  textures["sprites"]["destroyPreviewReady"] = Sprite("destroyPreviewReady","miscTiles.png",{["gridMultiplication"] = 8, ["spriteSize"] = {1,1},["quads"] = {2,0}, ["spriteCenter"] = {0.5,0.5}},{["type"] = "singleImage"})
  textures["sprites"]["destroyPreview"] = Sprite("destroyPreview","miscTiles.png",{["gridMultiplication"] = 8, ["spriteSize"] = {1,1},["quads"] = {1,0}, ["spriteCenter"] = {0.5,0.5}},{["type"] = "singleImage"})
  textures["sprites"]["destroyAnimation"] = Sprite("destroyAnimation","miscTiles.png",{["type"] = "hold", ["timePerFrame"] = 1/9, ["gridMultiplication"] = 8, ["spriteSize"] = {1,1},["quads"] = {{0,1},{1,1},{2,1},{3,1},{4,1},{5,1},{6,1},{7,1},{8,1}}, ["spriteCenter"] = {0.5,0.5}},{["type"] = "singleAnimation"})
  
  textures["sprites"]["player"] = Sprite("player","player.png",{["parts"] = {"idle","walk","jump","use"}},{["setupCharacterAnimation"] =  true, ["animationQuadrant"]={0,0},["spriteSizes"]={1,2},["spriteCenters"]={0.5,1.5}})
  textures["sprites"]["crudePickaxe_Hold"] = Sprite("crudePickaxe_Hold","player.png",{["parts"] = {"idle","walk","jump","use"}},{["setupCharacterAnimation"] =  true, ["animationQuadrant"]={0,1},["spriteSizes"]={1.5,2},["spriteCenters"]={0.75,1.5}})
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

function loadtiles()
  tiles = {}
  tilelists["stones"] = {}
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
      ["newQuad"] = { 0, 0, 1, 1, 8, },
      ["border"] = {
        ["quad"] = "dirt_top",
        ["newQuad"] = { 0, 1, 1, 1, 8 }
      },
      ["health"] = 2.5
    })

  tiles["grass"]         = Tile("grass", "top", "tiles.png", "grass",
    {
      ["newQuad"] = { 1, 0, 1, 1, 8 },
      ["border type"] = "non-solid",
      ["health"] = 0
    })
   tiles["soilGrass"]         = Tile("soilGrass", "top", "tiles.png", "soilGrass",
    {
      ["newQuad"] = { 1, 2, 1, 1, 8 },
      ["border type"] = "non-solid",
      ["health"] = 0,
      ["actualName"] = "soil grass",
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
    ["newQuad"] = { 2, 0, 1, 1, 8 },
    ["border"] = {
      ["quad"] = "stone_top",
      ["newQuad"] = { 2, 1, 1, 1, 8 }
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
  tiles["heavyStone"]         = Tile("heavyStone", "solid", "tiles.png", "heavyStone", {
    ["newQuad"] = { 2, 2, 1, 1, 8 },
    ["border"] = {
      ["quad"] = "heavyStone_top",
      ["newQuad"] = { 2, 3, 1, 1, 8 }
    },
    ["isStone"] = true,
    ["health"] = 12,
    ["actualName"] = "heavy stone",
  })
  tiles["essenceLeaves"]          = Tile("essenceLeaves", "solid", "tiles.png", "essenceLeaves",
    {
      ["newQuad"] = { 3, 2, 1, 1, 8 },
      ["border"] = {
        ["quad"] = "essenceLeaves_top",
        ["newQuad"] = { 3, 4, 1, 1, 8 }
      },
      ["health"] = 0.6,
      ["actualDropeRate"] = 0.4,
      ["lightCanGoThrough"] = true,
      ["actualName"] = "essence leaves",
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
    ["particleEmitData"] = {["amount"]=5,["radius"]=0.3,["color"]={0.9,0.9,0,0.7},["flags"]={["color2"]={0.8,0.2,0.2,0.8},["color3"]={0.4,0.4,0.4,0.9}},["timer"]=3},
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
  items["stick"] = Item("stick","stick",{["category"]="material",["placeBlock"] = "essenceWoodBricks", ["placeBlockCost"] = 5, ["maxStack"] = 300})
  items["rock"] = Item("rock","rock",{["category"]="material",["placeBlock"] = "scrapBlock", ["placeBlockCost"] = 4, ["maxStack"] = 300})
  items["crudePickaxe"] = Item("crudePickaxe","crudePickaxe",{["category"]="tool",["subCategory"] = "pickaxe",["fullName"] = "Crude pickaxe",
    ["cooldown"] = 0.8,
    ["mineDamage"] = 0.8, --1
    ["blockDamageAmount"] = 6, --6
    ["rangeLimit"] = 5,  --6
    ["mineArcAngle"] = 130,
    ["holdAnimation"] = "crudePickaxe_Hold",
  })
  items["crudeSpike"] = Item("crudeSpike","crudePickaxe",{["category"]="tool",["subCategory"] = "pickaxe",["fullName"] = "Crude spike",
    ["cooldown"] = 0.6,
    ["mineDamage"] = 1.2, --1
    ["blockDamageAmount"] = 3, --6
    ["rangeLimit"] = 7,  --6
    ["mineArcAngle"] = 130,
    ["holdAnimation"] = "crudePickaxe_Hold",
  })
  items["crudeSwayPickaxe"] = Item("crudeSwayPickaxe","crudePickaxe",{["category"]="tool",["subCategory"] = "pickaxe",["fullName"] = "Crude sway pickaxe",
    ["cooldown"] = 2.4,
    ["mineDamage"] = 0.8, --1
    ["blockDamageAmount"] = 18, --6
    ["rangeLimit"] = 8,  --6
    ["mineArcAngle"] = 130,
    ["holdAnimation"] = "crudePickaxe_Hold",
  })
  items["crudeSwayHammer"] = Item("crudeSwayHammer","crudePickaxe",{["category"]="tool",["subCategory"] = "pickaxe",["fullName"] = "Crude hammer",
    ["cooldown"] = 2,
    ["mineDamage"] = 4, --1
    ["blockDamageAmount"] = 3, --6
    ["rangeLimit"] = 5,  --6
    ["mineArcAngle"] = 130,
    ["holdAnimation"] = "crudePickaxe_Hold",
  })
  items["crudeDrill"] = Item("crudeDrill","crudePickaxe",{["category"]="tool",["subCategory"] = "pickaxe",["fullName"] = "Crude drill",
    ["cooldown"] = 0.1,
    ["mineDamage"] = 0.6, --1
    ["blockDamageAmount"] = 1, --6
    ["rangeLimit"] = 3,  --6
    ["mineArcAngle"] = 130,
    ["holdAnimation"] = "crudePickaxe_Hold",
  })
  items["crudeShovel"] = Item("crudeShovel","crudePickaxe",{["category"]="tool",["subCategory"] = "pickaxe",["fullName"] = "Crude shovel",
    ["cooldown"] = 1.8,
    ["mineDamage"] = 1.2, --1
    ["blockDamageAmount"] = 9, --6
    ["rangeLimit"] = 6,  --6
    ["mineArcAngle"] = 130,
    ["holdAnimation"] = "crudePickaxe_Hold",
  })
  items["crudeCrowbar"] = Item("crudeCrowbar","crudePickaxe",{["category"]="tool",["subCategory"] = "pickaxe",["fullName"] = "Crude crowbar",
    ["cooldown"] = 1.15,
    ["mineDamage"] = 1.4, --1
    ["blockDamageAmount"] = 5, --6
    ["rangeLimit"] = 8,  --6
    ["mineArcAngle"] = 130,
    ["holdAnimation"] = "crudePickaxe_Hold",
  })
  items["crudeTargetPickaxe"] = Item("crudeTargetPickaxe","crudePickaxe",{["category"]="tool",["subCategory"] = "pickaxe",["fullName"] = "Crude target pickaxe",
    ["cooldown"] = 0.2,
    ["mineDamage"] = 0.25, --1
    ["blockDamageAmount"] = 5, --6
    ["rangeLimit"] = 5,  --6
    ["mineArcAngle"] = 130,
    ["holdAnimation"] = "crudePickaxe_Hold",
  })
  items["paws"] = Item("paws","crudePickaxe",{["category"]="tool",["subCategory"] = "pickaxe",["fullName"] = "Paws",
    ["cooldown"] = 0.3,
    ["mineDamage"] = 1, --1
    ["blockDamageAmount"] = 3, --6
    ["rangeLimit"] = 2,  --6
    ["mineArcAngle"] = 130,
    ["holdAnimation"] = "crudePickaxe_Hold",
  })
  items["coolPickaxe"] = Item("coolPickaxe","crudePickaxe",{["category"]="tool",["subCategory"] = "pickaxe",["fullName"] = "Cool pickaxe",
    ["cooldown"] = 0.3,
    ["mineDamage"] = 2.5,
    ["blockDamageAmount"] = 15,
    ["rangeLimit"] = 20,
    ["mineArcAngle"] = 360,
    ["holdAnimation"] = "crudePickaxe_Hold",
    ["baseColor"] = {0,1,1,1},
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
            if tile.type == "solid" then 
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
  --stage 1
  world:addBiome("none", 0.5, 0.5, -1, 1, 0.3, 1)
  world:addBiome("duneland", 0.7, 0.2, -1, 1, 2, 0.3) --oui, il est en double, une fois à la surface

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


  interfaces["worldCreation"] = Interface("worldCreation",0.5,0.15,0.6,0.8,"bland",{0.6,0.9,0.6,1},{1,1,1,1},{["title"]= "World Cration",["gap"]=0.00,["scrollMargin"]=0.1,["showTitle"] = true})
  interfaces["worldCreation"]:addElement("createButton","button",0.4,0.1,"Start game",{},{},nil,nil)
  interfaces["worldCreation"]:addElement("worldHeigth","options",0.9,0.2,"World deepness :",{"500","1000","1500","2000","2500"},{["textAlign"] = "left",["gap"]=0,["default"] = "1500"},nil,nil)
  interfaces["worldCreation"]:addElement("worldWidth","options",0.9,0.2,"World width :",{"150","300","450","600","750"},{["textAlign"] = "left",["gap"]=0,["default"] = "450"},nil,nil)
  interfaces["worldCreation"]:addElement("cheat","checkbox",0.9,0,"Cheat Toggle",{},{["textAlign"] = "left",["gap"]=0,["default"] = false},nil,nil)
  interfaces["worldCreation"]:addElement("freeCam","checkbox",0.9,0,"Free cam Toggle",{},{["textAlign"] = "left",["gap"]=0,["default"] = false},nil,nil)
  interfaces["worldCreation"]:addElement("lightReach","slider",0.9,0.2,"Light reach",{["round"] = 1,["min"] = 1, ["max"]= 12,["displayMultiplication"]=1},{["textAlign"] = "left",["gap"]=0,["default"] = 6},nil,nil)


  interfaces["settings"] = Interface("settings",0.5,0.15,0.6,0.8,"bland",{0.9,0.6,0.6,1},{1,1,1,1},{["title"]= "Settings",["gap"]=0.00,["scrollMargin"]=0.1,["showTitle"] = true})
  --interfaces["settings"]:addElement("cheat","checkbox",0.9,0,"Cheat Toggle",{},{["textAlign"] = "left",["gap"]=0,["default"] = false},nil,nil)
  --interfaces["settings"]:addElement("lightReach","slider",0.9,0.2,"Light reach",{["round"] = 1,["min"] = 1, ["max"]= 12,["displayMultiplication"]=1},{["textAlign"] = "left",["gap"]=0,["default"] = 6},nil,nil)
  interfaces["settings"]:addElement("chunkRenderDistance","slider",0.9,0.2,"Additional chunk gen distance",{["round"] = 1,["min"] = 20, ["max"]= 50,["displayAddition"]=-20,["displayMultiplication"]=1},{["textAlign"] = "left",["gap"]=0,["default"] = 20},nil,nil)
  interfaces["settings"]:addElement("maxChunkLoadedPerFrame","slider",0.9,0.2,"Max chunks generated per frame",{["round"] = 1,["min"] = 0, ["max"]= 12},{["textAlign"] = "left",["gap"]=0,["default"] = 3},nil,nil)
  interfaces["settings"]:addElement("MapZoom","slider",0.9,0.2,"Map zoom",{["round"] = 0.2,["min"] = 0.4, ["max"]= 5},{["textAlign"] = "left",["gap"]=0,["default"] = 2},nil,nil)
  interfaces["settings"]:addElement("InventorySize","slider",0.9,0.2,"Inventory size",{["round"] = 0.1,["min"] = 0.5, ["max"]= 1.5},{["textAlign"] = "left",["gap"]=0,["default"] = 1},nil,nil)
  interfaces["settings"]:addElement("InventoryTextSize","slider",0.9,0.2,"Inventory text size",{["round"] = 0.1,["min"] = 1, ["max"]= 2},{["textAlign"] = "left",["gap"]=0,["default"] = 1.4},nil,nil)
  interfaces["settings"]:addElement("SelectedFont","slider",0.9,0.2,"Font",{["round"] = 1,["min"] = 1, ["max"]= #Fonts},{["textAlign"] = "left",["gap"]=0,["default"] = 1},nil,nil)
  interfaces["settings"]:addElement("UISize","slider",0.9,0.2,"UI size",{["round"] = 0.1,["min"] = 0.5, ["max"]= 1.5},{["textAlign"] = "left",["gap"]=0,["default"] = 1},nil,nil)
  interfaces["settings"]:addElement("resetUI","button",0.4,0.1,"Reset UI",{},{},nil,nil)


  interfaces["back"] = Interface("back",0.1,-0.05,0.3,0.3,"invisible",{0.6,0.6,0.9,1},{1,1,1,1},{["gap"]=0.03,["scrollMargin"]=0,["elementsStayInBound"]=false})
  interfaces["back"]:addElement("back","button",0.4,0.075,"Back",{},{["gap"]=0},nil,nil)

end