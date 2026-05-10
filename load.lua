function loadtextures()

  --[[textures["textures"]={}
  textures["textures"]["tileset"]=love.graphics.newImage("tiles.png")
  --toute les déclarations de texture ici sont pas mal inutile, vue que maintenant on peut les intégrés dans les lignes de création de tiles, items, entitiees
  textures["quads"]={}
  textures["quads"]["dirt"]=love.graphics.newQuad(0,0,8,8,textures["textures"]["tileset"])
  textures["quads"]["dirt_top"]=love.graphics.newQuad(0,8,8,8,textures["textures"]["tileset"])
  textures["quads"]["dirt_top2"]=love.graphics.newQuad(0,16,8,8,textures["textures"]["tileset"])
  textures["quads"]["grass"]=love.graphics.newQuad(8,0,8,8,textures["textures"]["tileset"])
  textures["quads"]["stone"]=love.graphics.newQuad(16,0,8,8,textures["textures"]["tileset"])
  textures["quads"]["stone_top"]=love.graphics.newQuad(16,8,8,8,textures["textures"]["tileset"])
  textures["quads"]["darkstone"]=love.graphics.newQuad(24,0,8,8,textures["textures"]["tileset"])
  textures["quads"]["darkstone_top"]=love.graphics.newQuad(24,8,8,8,textures["textures"]["tileset"])
  textures["quads"]["purplegrass"]=love.graphics.newQuad(32,0,8,8,textures["textures"]["tileset"])
  textures["quads"]["palestone"]=love.graphics.newQuad(40,0,8,8,textures["textures"]["tileset"])
  textures["quads"]["palestone_top"]=love.graphics.newQuad(40,8,8,8,textures["textures"]["tileset"])
   textures["quads"]["ancientstone"]=love.graphics.newQuad(48,0,8,8,textures["textures"]["tileset"])
  textures["quads"]["ancientstone_top"]=love.graphics.newQuad(48,8,8,8,textures["textures"]["tileset"])
   textures["quads"]["coldstone"]=love.graphics.newQuad(56,0,8,8,textures["textures"]["tileset"])
  textures["quads"]["coldstone_top"]=love.graphics.newQuad(56,8,8,8,textures["textures"]["tileset"])
   textures["quads"]["lightstone"]=love.graphics.newQuad(64,0,8,8,textures["textures"]["tileset"])
  textures["quads"]["lightstone_top"]=love.graphics.newQuad(64,8,8,8,textures["textures"]["tileset"])
   --textures["quads"]["hotstone"]=love.graphics.newQuad(72,0,8,8,textures["textures"]["tileset"])
  --textures["quads"]["hotstone_top"]=love.graphics.newQuad(72,8,8,8,textures["textures"]["tileset"])
  textures["quads"]["shadowgrass"]=love.graphics.newQuad(80,0,8,8,textures["textures"]["tileset"])
  textures["quads"]["wheatgrass"]=love.graphics.newQuad(88,0,8,8,textures["textures"]["tileset"])
  textures["quads"]["diamond"]=love.graphics.newQuad(96,0,8,8,textures["textures"]["tileset"])]]
end

function loadeverything()
  textures = {}
  --loadtextures()
  loadtiles()
  --loadbiomes()
end

function loadtiles()
  tiles = {}

  textures["textures"] = {}
  textures["quads"] = {}
  textures["textures"]["tiles.png"]=love.graphics.newImage("tiles.png")
 -- textures["quads"]["dirt"]=love.graphics.newQuad(0,0,8,8,textures["textures"]["tiles.png"])
  --[[tilelists={}
  tilelists["all tiles"]={}
  tilelists["stones"]={}
  newtile("air","empty","none","none",{})
  newtile("dirt","solid","tileset","dirt",{["border"]={["quad"]="dirt_top"}})
  newtile("grass","top","tileset","grass",{["border type"]="non-solid"})
  newtile("purplegrass","top","tileset","purplegrass",{["border type"]="non-solid"})
  newtile("shadowgrass","top","tileset","shadowgrass",{["border type"]="non-solid"})
  newtile("wheatgrass","top","tileset","wheatgrass",{["border type"]="non-solid"})

  newtile("diamond","top","tileset","diamond",{["border type"]="normal"})
  newtile("stone","solid","tileset","stone",{["border"]={["quad"]="stone_top"},["isastone"]=true})
  newtile("darkstone","solid","tileset","darkstone",{["border"]={["quad"]="darkstone_top"},["isastone"]=true})
  newtile("palestone","solid","tileset","palestone",{["border"]={["quad"]="palestone_top"},["isastone"]=true})
  newtile("ancientstone","solid","tileset","ancientstone",{["border"]={["quad"]="ancientstone_top"},["isastone"]=true})
  newtile("coldstone","solid","tileset","coldstone",{["border"]={["quad"]="coldstone_top"},["isastone"]=true})
  newtile("lightstone","solid","tileset","lightstone",{["border"]={["quad"]="lightstone_top"},["isastone"]=true})
  newtile("hotstone","solid","tileset","hotstone",{["new quad"]={9,0,1,1,8},["border"]={["quad"]="hotstone_top",["new quad"]={9,1,1,1,8}},["isastone"]=true})

  newtile("dirt_wall","wall","tileset","dirt",{["border"]={["quad"]="dirt_top2"},["color"]={0.5,0.5,0.5,1}})
  newtile("stone_wall","wall","tileset","stone",{["border"]={["quad"]="stone_top"},["color"]={0.5,0.5,0.5,1},["isastone"]=true})
  newtile("hotstone_wall","wall","tileset","hotstone",{["border"]={["quad"]="hotstone_top"},["color"]={0.5,0.5,0.5,1},["isastone"]=true})
  newtile("coldstone_wall","wall","tileset","coldstone",{["border"]={["quad"]="coldstone_top"},["color"]={0.5,0.5,0.5,1},["isastone"]=true})
  ]]

  tilelists["stones"] = {
        "stone", "darkstone", "palestone", "ancientstone",
        "coldstone", "lightstone", "hotstone"
  }
  tilelists["all tiles"] = {
        "none", "dirt", "grass", "purplegrass", "shadowgrass",
        "wheatgrass", "diamond", "stone", "darkstone", "palestone",
        "ancientstone", "coldstone", "lightstone", "hotstone",
        "dirt_wall", "stone_wall", "hotstone_wall", "coldstone_wall"
    }
  tiles["none"]         = Tile("none")
  
  tiles["dirt"]         = Tile("dirt", "solid", "tiles.png", "dirt",
    {
      ["newQuad"] = { 0, 0, 1, 1, 8, },
      ["border"] = {
        ["quad"] = "dirt_top",
        ["newQuad"] = { 0, 1, 1, 1, 8 }
      }
    })

  tiles["grass"]        = Tile("grass", "top", "tiles.png", "grass",
    {
      ["newQuad"] = { 1, 0, 1, 1, 8 },
      ["border type"] = "non-solid"
    })

  tiles["purplegrass"]  = Tile("purplegrass", "top", "tiles.png", "purplegrass",
    {
      ["newQuad"] = { 4, 0, 1, 1, 8 },
      ["border type"] = "non-solid"
    })

  tiles["shadowgrass"]  = Tile("shadowgrass", "top", "tiles.png", "shadowgrass",
    {
      ["newQuad"] = { 10, 0, 1, 1, 8 },
      ["border type"] = "non-solid"
    })

  tiles["wheatgrass"]   = Tile("wheatgrass", "top", "tiles.png", "wheatgrass",
    {
      ["newQuad"] = { 11, 0, 1, 1, 8 },
      ["border type"] = "non-solid"
    })

  tiles["diamond"]      = Tile("diamond", "top", "tiles.png", "diamond",
    {
      ["newQuad"] = { 12, 0, 1, 1, 8 },
      ["border type"] = "normal"
    })

  tiles["stone"]        = Tile("stone", "solid", "tiles.png", "stone", {
    ["newQuad"] = { 2, 0, 1, 1, 8 },
    ["border"] = {
      ["quad"] = "stone_top",
      ["newQuad"] = { 2, 1, 1, 1, 8 }
    },
    ["isastone"] = true
  })

  tiles["darkstone"]    = Tile("darkstone", "solid", "tiles.png", "darkstone",
    {
      ["newQuad"] = { 3, 0, 1, 1, 8 },
      ["border"] = {
        ["quad"] = "darkstone_top",
        ["newQuad"] = { 3, 1, 1, 1, 8 }
      },
      ["isastone"] = true
    })

  tiles["palestone"]    = Tile("palestone", "solid", "tiles.png", "palestone",
    {
      ["newQuad"] = { 3, 0, 1, 1, 8 },
      ["border"] = {
        ["quad"] = "palestone_top",
        ["newQuad"] = { 5, 1, 1, 1, 8 }
      },
      ["isastone"] = true
    })
  tiles["ancientstone"] = Tile("ancientstone", "solid", "tiles.png", "ancientstone",
    {
      ["newQuad"] = { 6, 0, 1, 1, 8 },
      ["border"] = {
        ["quad"] = "ancientstone_top",
        ["newQuad"] = { 6, 1, 1, 1, 8 }
      },
      ["isastone"] = true
    })

  tiles["coldstone"]    = Tile("coldstone", "solid", "tiles.png", "coldstone",
    {
      ["newQuad"] = { 7, 0, 1, 1, 8 },
      ["border"] = {
        ["quad"] = "coldstone_top",
        ["newQuad"] = { 7, 1, 1, 1, 8 }
      },
      ["isastone"] = true
    })

  tiles["lightstone"]   = Tile("lightstone", "solid", "tiles.png", "lightstone",
    {
      ["newQuad"] = { 8, 0, 1, 1, 8 },
      ["border"] = {
        ["quad"] = "lightstone_top",
        ["newQuad"] = { 8, 1, 1, 1, 8 }
      },
      ["isastone"] = true
    })

  tiles["hotstone"] = Tile("hotstone", "solid", "tiles.png", "hotstone",
    {
      ["newQuad"] = { 9, 0, 1, 1, 8 },
      ["border"] = {
        ["quad"] = "hotstone_top",
        ["newQuad"] = { 9, 1, 1, 1, 8 }
      },
      ["isastone"] = true
    })
end

--[[function gettileinfo(tilename,info)
  if tiles[tileindexes[tilename] ]~=nil then
    if tiles[tileindexes[tilename] ][info]==nil then
      return nil
    else

    return tiles[tileindexes[tilename] ][info]
    end
  else
    return nil
  end
end]]
--[[function newtile(tilename,tiletype,texture,quad,flags)
  if tilename==nil then return end
  t={}
  t["name"]=tilename
  t["type"]=tiletype
  if t["type"]==nil then t["type"]="empty" end
  t["texture"]=texture
  if t["texture"]==nil then t["texture"]="none" end
  t["quad"]=quad
  if t["quad"]==nil then t["quad"]="none" end
  t["flags"]=flags
  if t["flags"]==nil then t["flags"]={} end
  if t["flags"]["new quad"]~=nil then textures["quads"][t["quad"] ]=love.graphics.newQuad(t["flags"]["new quad"][1]*t["flags"]["new quad"][5],t["flags"]["new quad"][2]*t["flags"]["new quad"][5],t["flags"]["new quad"][3]*t["flags"]["new quad"][5],t["flags"]["new quad"][4]*t["flags"]["new quad"][5],textures["textures"][t["texture"] ]) end
  if t["flags"]["border"]==nil then t["flags"]["border"]={} end
  if t["flags"]["border"]["quad"]==nil then t["flags"]["border"]["quad"]="none" end

  if t["flags"]["border"]["new quad"]~=nil then textures["quads"][t["flags"]["border"]["quad"] ]=love.graphics.newQuad(t["flags"]["border"]["new quad"][1]*t["flags"]["border"]["new quad"][5],t["flags"]["border"]["new quad"][2]*t["flags"]["border"]["new quad"][5],t["flags"]["border"]["new quad"][3]*t["flags"]["border"]["new quad"][5],t["flags"]["border"]["new quad"][4]*t["flags"]["border"]["new quad"][5],textures["textures"][t["texture"] ]) end

  if t["flags"]["border type"]==nil then t["flags"]["border type"]="non-solid" end
  if t["flags"]["isastone"]==nil then t["flags"]["isastone"]=false end
  if t["flags"]["hideback"]==nil then t["flags"]["hideback"]=t["type"]=="empty" end
  if t["flags"]["color"]==nil then t["flags"]["color"]={1,1,1,1} end

  tileindexes[t["name"] ]=(#tiles+1)
  table.insert(tiles,t)
  table.insert(tilelists["all tiles"],t["name"])
  if t["flags"]["isastone"] then table.insert(tilelists["stones"],t["name"]) end

end
function loadbiomes()

  biomelist={}
  --newbiome("normalland")
  newbiome("none",0.5,0.5,-1,3,5,1)
  newbiome("coldland",0.2,0.4,2,8,3,1)
  newbiome("hotland",0.8,0.6,3.5,99999,1,1)
  --newbiome("coldland",0.5,0.5,1,5,3,2)
  --newbiome("hotland",0.5,0.5,1,5,6,2.5)
end
function newbiome(biomename,temperature,wetness,deepnessmin,deepnessmax,deepnesssmooth,likeness)
  b={}
  b["name"]=biomename
  b["option1"]=temperature
  b["option2"]=wetness
  b["deepnessmin"]=deepnessmin
  b["deepnessmax"]=deepnessmax
  b["likeness"]=likeness
  b["deepnesssmooth"]=deepnesssmooth


  table.insert(biomelist,b)
end
function loadentities()
  entitiesdefenition={}


end
function newentity(name)
  ne={}


  table.insert(entitiesdefenition,ne)
end]]
