function love.load()
  --bonjour

  require "lume"
  require "gameudp"
  require "drawudp" --là ou tout le code de dessins
  require "mathsc"  --math comprend plusieurs truc bien qui sont pas dans lua de base
  require "World/worldgeneration"
  require "World/structureList"
  require "World/structure"
  require "load"
  require "Entities/entities"
  require "Entities/sprite"
  require "items/inventory"
  require "items/item"
  require "items/groundItem"
  require "class/childClass"
  require "class/utility/eventEmitter"
  require "class/utility/vector2"
  require "particles/particles"
  require "interfaces/interface"
  love.graphics.setDefaultFilter("nearest", "nearest")

  require "World/tiledef"
  require "World/chunk"
  require "World/world"
  love.filesystem.setIdentity("GAMENAMEPLEASEFINDONE")

  Fonts = {
    love.graphics.newFont("/fonts/Pixelify_Sans/PixelifySans-VariableFont_wght.ttf", 12, "light", 4),
    love.graphics.newFont("/fonts/DotGothic16/DotGothic16-Regular.ttf", 12, "light", 4),
  }
  Font = Fonts[1]
  love.graphics.setFont(Font)
  
  -- require "chunkv2"
  -- require "worldv2"
  --love.filesystem.setIdentity("gamename")
  tiles = {}
  items = {}
  MainStructureList = {}
  tilelists = {}
  ItemList = {}
  entitiesdefenition = {}
  entities = {}
  sprites = {}
  textures = {}
  interfaces = {}

  --[[
  --commandes:

  p:fullscreen
  wasd:bouger
  qe:zoomer/dézoomer

  r:reset le monde avec une nouvelle seed et des biomes normaux
  t:reset le monde avec la meme seed et une liste au hasard de biomes

  maintenir pour les commandes suivantes:

  m:afficher la carte de blocs loadés
  n:afficher la carte des biomes
  b:afficher la carte des biomes et du terrain

  k:quadrupler la distance de génération de chunks
  --]]

  --entity = Entity:new("test", "test", "test", 1, 9)

  -- entity:damage(99)
  GlobalNoisePower = calculateNoisePower(0.25)
  
  biomelist = {}
  world = World(math.random() * 1000000, 10, 100, 150, {}, { "none", "stone", "stone2", "grass", "ores", "deco", "done" })
  generateBaseBiomes()

  debugseebiome = false

  lightreach = 6       
  chunkloaddistance = 20 
  MaxChunkLoadedPerFrame = 3
  InventorySize = 1
  UISize = 1
  InventoryTextSize = 1.4
  SelectedFont = 1
  MapZoom = 2

  CheatMode = true
  CheatInventoryScroll = 0

  biomesize = 150
  worldseed = math.random() * 100000
  chunksize = 10
  worlddeepnessprogression = 100
  --biomesize=25 worlddeepnessprogression=15

  entities = {}
  --loadtextures()
  cameraPossibleZooms = {1,2,4,8,16,24,32,40,48,56,64,72,80,96,112,152,188,224,336,448}
  camEntityFollow = 0
  camx = 0
  realcamx = 0
  realcamy = 0
  mx = 0
  my = 0
  mxworldpos = 0
  myworldpos = 0
  camv = 48
  camy = 0
  gametime = 0
  realtime = 0
  gamestate = "mainMenu"
  tick = 0
  szx = 100
  szy = 100
  cx = 50
  cy = 50
  fullscreen = false
  scrollValueX = 0
  scrollValueY = 0
  buttons = {"w","e","tab","click","rclick","shiftclick","shiftrclick"}
  SelectedMouseDrag = "none"
  buttonFramePress = {}
  for ib = 1, #buttons do
    buttonFramePress[buttons[ib]] = false
  end
  clicktick = false
  rightclicktick = false
  middleclicktick = false

  spectator = true
  loadeverything()
  resetworld()
  backgroundcolor = { 0.15, 0.15, 0.2, 1 }
  love.window.setFullscreen(fullscreen)
  love.window.setMode(800, 600, { resizable = true, minwidth = 400, minheight = 300 })
end

--code totalement pas écrit par chatgpt

-- Returns a power value based on how centered the noise distribution is.
-- Uses 100000 samples.

function calculateNoisePower(targetDistance)
    local samples = 100000
    local sum = 0

    for i = 1, samples do
        local n = love.math.noise(
            love.math.random() * 100000,
            love.math.random() * 100000,
            love.math.random() * 100000,
            love.math.random() * 100000
        )

        sum = sum + math.abs(n - 0.5)
    end

    local averageDistance = sum / samples

    -- Prevent divide-by-zero
    if averageDistance <= 0 then
        return 1
    end

    return targetDistance / averageDistance
end


-- Pushes values toward 0 and 1 smoothly
function shapeNoise(v, power)
    local a = v ^ power
    local b = (1 - v) ^ power

    return a / (a + b)
end


-- Custom 4D noise function
-- x,y,z,w = coordinates
-- power:
--   1   = unchanged
--   >1  = stronger extremes
--   <1  = more centered

function noise(x, y, z, w)
    local n = love.math.noise(x or 0, y or 0, z or 0, w or 0)

    return shapeNoise(n, GlobalNoisePower)
end

function love.update(dt)
  if dt > 0.15 then dt = 0.15 end
  delta = dt
  realtime = realtime + dt
  mx, my = love.mouse.getPosition()
  mxworldpos, myworldpos = screentoposition(mx, my)
  szx, szy = love.window.getMode()
  cx = szx / 2
  cy = szy / 2
  math.random()
  tick = tick + 1

  if gamestate == "game" then
    GlobalGameUpdate(dt)
  end
  
end

function GlobalGameUpdate(dt)
  cameramove(dt)
  gameupdate(dt)
end

function cameramove(dt)
  if spectator then
    if love.keyboard.isDown("w") then realcamy = realcamy + 650 * dt / camv end
    if love.keyboard.isDown("s") then realcamy = realcamy - 650 * dt / camv end
    if love.keyboard.isDown("d") then realcamx = realcamx + 650 * dt / camv end
    if love.keyboard.isDown("a") then realcamx = realcamx - 650 * dt / camv end
    --if love.keyboard.isDown("q") then camv=camv*(1-1*dt) end
    --if love.keyboard.isDown("e") then camv=camv*(1+1*dt) end
  end
  camx = round2(realcamx, 8)
  camy = round2(realcamy, 8)
end

function love.draw()
  love.graphics.setBackgroundColor(backgroundcolor)

  if gamestate == "game" then
    drawgame()
  end
  if gamestate == "pause" then
    drawgame()
    PauseUpdate()
  end
  if gamestate == "mainMenu" then
    MainMenuUpdate()
  end
  if gamestate == "settings" then
    SettingsUpdate()
  end
  if gamestate == "worldCreation" then
    WorldCreationUpdate(dt)
  end


  ResetButtonTicks()
end

function ResetButtonTicks()
  if not love.mouse.isDown(1) then SelectedMouseDrag = "none" end
  clicktick = false
  rightclicktick = false
  middleclicktick = false
  scrollValueX = 0
  scrollValueY = 0

  for ib = 1, #buttons do
    buttonFramePress[buttons[ib]] = false
  end
end

function love.keypressed(key)
  if key == "p" then
    fullscreen = not fullscreen
    love.window.setFullscreen(fullscreen)
  end

  if key == "escape" then
    if gamestate == "game" then
      gamestate = "pause"
    else
      if gamestate == "pause" then
        gamestate = "game"
      end
    end
  end
  if key == "r" then
   --[[ world = World(math.random() * 1000000, 10, 100, 150, {},
      { "none", "stone", "stone2", "grass", "ores", "deco", "done" })
    generateBaseBiomes()]]
  end
  if key == "t" then
    --world:clear()
    --generateRandomBiomeList()
  end
  if key == "space" then
    --[[if #entities < 1 then
      world:spawnEntity("player", world:getMouseTile(false).x, world:getMouseTile(false).y)
    else
      world:spawnEntity("enemy", world:getMouseTile(true).x, world:getMouseTile(true).y)
    end]]
    --world:spawnEntity("player", "player", "player", "none", 100, 0, "player", { ["newQuad"] = { 15, 0, 1, 1, 8 } })
  end

  if spectator then
    if key == "e" then 
      camv = nextinlistroll(camv, cameraPossibleZooms) 
    end
    if key == "q" then 
      camv = nextinlistrollreverse(camv, cameraPossibleZooms) 
    end
  end

  if checkifinlist(key,buttons) then
    buttonFramePress[key] = true
  end
  --[[if key == "e" and spectator then
    camv = camv + 8
    if camv > 96 then camv = 96 end
  end
  if key == "q" and spectator then
    camv = camv - 8
    if camv < 8 then camv = 8 end
  end]]
end

function love.mousepressed(x, y, b)
  if b == 1 then clicktick = true end
  if b == 3 then middleclicktick = true end
  if b == 2 then rightclicktick = "none" end

  if b == 1 and not love.keyboard.isDown("lshift") then buttonFramePress["click"] = true end
  if b == 2 and not love.keyboard.isDown("lshift") then buttonFramePress["rclick"] = true end
  if b == 1 and love.keyboard.isDown("lshift") then buttonFramePress["shiftclick"] = true end
  if b == 2 and love.keyboard.isDown("lshift") then buttonFramePress["shiftrclick"] = true end
end

function love.wheelmoved(x, y)
  scrollValueX = x
  scrollValueY = y
end
