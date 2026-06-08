function loadtextures()
  print("loadtextures")
  textures = {}
  textures["textures"] = {}
  textures["textures"]["tiles.png"]=love.graphics.newImage("Textures/tiles.png")
  textures["textures"]["items1.png"]=love.graphics.newImage("Textures/items1.png")
  textures["textures"]["player.png"]=love.graphics.newImage("Textures/player.png")
  textures["quads"] = {}
  textures["sprites"] = {}
  textures["sprites"]["stick"] = Sprite("stick","items1.png",{["parts"] = {"small","medium","big"}},{["setupItem"] = true,["itemQuadrant"]={0,0}})
  textures["sprites"]["player"] = Sprite("player","player.png",{
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
  }, {["mirrorable"] = true})
end

function loadeverything()
  
  loadtextures()
  loadtiles()
  loadItems()
  --loadbiomes()
  loadEntities()
end

function loadtiles()
  tiles = {}
  
  tilelists["stones"]    = {
    "stone", "darkstone", "palestone", "ancientstone",
    "coldstone", "lightstone", "hotstone"
  }
  tilelists["all tiles"] = {
    "none", "dirt", "grass", "purplegrass", "shadowgrass",
    "wheatgrass", "diamond", "stone", "darkstone", "palestone",
    "ancientstone", "coldstone", "lightstone", "hotstone",
    "dirt_wall", "stone_wall", "hotstone_wall", "coldstone_wall"
  }
  tiles["none"]          = Tile("none")

  tiles["dirt"]          = Tile("dirt", "solid", "tiles.png", "dirt",
    {
      ["newQuad"] = { 0, 0, 1, 1, 8, },
      ["border"] = {
        ["quad"] = "dirt_top",
        ["newQuad"] = { 0, 1, 1, 1, 8 }
      },
      ["health"] = 5
    })

  tiles["grass"]         = Tile("grass", "top", "tiles.png", "grass",
    {
      ["newQuad"] = { 1, 0, 1, 1, 8 },
      ["border type"] = "non-solid"
    })

  tiles["purplegrass"]   = Tile("purplegrass", "top", "tiles.png", "purplegrass",
    {
      ["newQuad"] = { 4, 0, 1, 1, 8 },
      ["border type"] = "non-solid"
    })

  tiles["shadowgrass"]   = Tile("shadowgrass", "top", "tiles.png", "shadowgrass",
    {
      ["newQuad"] = { 10, 0, 1, 1, 8 },
      ["border type"] = "non-solid"
    })

  tiles["wheatgrass"]    = Tile("wheatgrass", "top", "tiles.png", "wheatgrass",
    {
      ["newQuad"] = { 11, 0, 1, 1, 8 },
      ["border type"] = "non-solid"
    })

  tiles["diamond"]       = Tile("diamond", "top", "tiles.png", "diamond",
    {
      ["newQuad"] = { 12, 0, 1, 1, 8 },
      ["border type"] = "normal"
    })

  tiles["stone"]         = Tile("stone", "solid", "tiles.png", "stone", {
    ["newQuad"] = { 2, 0, 1, 1, 8 },
    ["border"] = {
      ["quad"] = "stone_top",
      ["newQuad"] = { 2, 1, 1, 1, 8 }
    },
    ["isastone"] = true
  })

  tiles["darkstone"]     = Tile("darkstone", "solid", "tiles.png", "darkstone",
    {
      ["newQuad"] = { 3, 0, 1, 1, 8 },
      ["border"] = {
        ["quad"] = "darkstone_top",
        ["newQuad"] = { 3, 1, 1, 1, 8 }
      },
      ["isastone"] = true
    })

  tiles["palestone"]     = Tile("palestone", "solid", "tiles.png", "palestone",
    {
      ["newQuad"] = { 5, 0, 1, 1, 8 },
      ["border"] = {
        ["quad"] = "palestone_top",
        ["newQuad"] = { 5, 1, 1, 1, 8 }
      },
      ["isastone"] = true
    })
  tiles["ancientstone"]  = Tile("ancientstone", "solid", "tiles.png", "ancientstone",
    {
      ["newQuad"] = { 6, 0, 1, 1, 8 },
      ["border"] = {
        ["quad"] = "ancientstone_top",
        ["newQuad"] = { 6, 1, 1, 1, 8 }
      },
      ["isastone"] = true
    })

  tiles["coldstone"]     = Tile("coldstone", "solid", "tiles.png", "coldstone",
    {
      ["newQuad"] = { 7, 0, 1, 1, 8 },
      ["border"] = {
        ["quad"] = "coldstone_top",
        ["newQuad"] = { 7, 1, 1, 1, 8 }
      },
      ["isastone"] = true
    })

  tiles["lightstone"]    = Tile("lightstone", "solid", "tiles.png", "lightstone",
    {
      ["newQuad"] = { 8, 0, 1, 1, 8 },
      ["border"] = {
        ["quad"] = "lightstone_top",
        ["newQuad"] = { 8, 1, 1, 1, 8 }
      },
      ["isastone"] = true
    })

  tiles["hotstone"]      = Tile("hotstone", "solid", "tiles.png", "hotstone",
    {
      ["newQuad"] = { 9, 0, 1, 1, 8 },
      ["border"] = {
        ["quad"] = "hotstone_top",
        ["newQuad"] = { 9, 1, 1, 1, 8 }
      },
      ["isastone"] = true
    })
  tiles["shadowStone"]   = Tile("shadowStone", "solid", "tiles.png", "shadowStone",
    {
      ["newQuad"] = { 13, 0, 1, 1, 8 },
      ["border"] = {
        ["quad"] = "shadowStone_top",
        ["newQuad"] = { 13, 1, 1, 1, 8 }
      },
      ["isastone"] = true
    })
  tiles["ice"]           = Tile("ice", "solid", "tiles.png", "ice",
    {
      ["newQuad"] = { 14, 0, 1, 1, 8 },
      ["border"] = {
        ["quad"] = "ice_top",
        ["newQuad"] = { 14, 1, 1, 1, 8 }
      },
      ["color"] = { 1, 1, 1, 0.4 },
      ["lightCanGoThrough"] = true
    })
  tiles["sand"]          = Tile("sand", "solid", "tiles.png", "sand",
    {
      ["newQuad"] = { 15, 0, 1, 1, 8 },
      ["border"] = {
        ["quad"] = "sand_top",
        ["newQuad"] = { 15, 1, 1, 1, 8 }
      }
    })
  tiles["magicKelp"]     = Tile("magicKelp", "not-solid", "tiles.png", "magicKelp",
    {
      ["newQuad"] = { 16, 0, 1, 2, 8 },
      ["textureCenterX"] = 4,
      ["textureCenterY"] = 12,
      ["border type"] = "none"
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
  items = {}
  items["none"] = Item("none","none",{})
  items["stick"] = Item("stick","stick",{["category"]="material"})
end

function generateBaseBiomes()
  world:addBiome("none", 0.5, 0.5, -1, 4, 5, 1)
  world:addBiome("coldland", 0.2, 0.4, 0.5, 15, 8, 1)
  world:addBiome("hotland", 0.8, 0.6, 2.5, 30, 8, 1)
  world:addBiome("darkland", 0.5, 0.3, 10, 99999, 1, 1)
  world:addBiome("ancientland", 0.3, 0.9, 5, 50, 8, 0.8)
  world:addBiome("duneland", 0.8, 0.1, 6, 30, 10, 0.5)
  world:addBiome("duneland", 0.7, 0.2, -1, 3, 2, 0.3) --oui, il est en double, une fois à la surface

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