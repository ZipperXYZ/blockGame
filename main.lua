local function test1()
  print("Salut je run!!!")
end

local function test2()
  print("Wow c cool je run aussi")
end

function love.load()
  --bonjour

  require "lume"
  require "gameudp"
  require "drawudp" --là ou tout le code de dessins
  require "mathsc"  --math comprend plusieurs truc bien qui sont pas dans lua de base
  require "worldgeneration"
  require "load"
  require "entities"
  require "class/childClass"
  require "class/utility/eventEmitter"
  require "class/utility/vector2"
  love.graphics.setDefaultFilter("nearest", "nearest")

  require "tiledef"
  require "chunk"
  require "world"
  --love.filesystem.setIdentity("gamename")
  tiles = {}
  tilelists = {}
  entitiesdefenition = {}
  entities = {}
  textures = {}
  tileindexes = {}

  -- ici c'est une exemple de défénitions
  obj = ChildClass:new(98, "test", 999, "class1")


  obj2 = ChildClass:new(1, "testV2", 888, "class2")
  print(obj:getClassName())

  -- test de la fonction statique

  obj:testStaticFunc()

  -- un event emitter et les fonctions qui écoute l'event

  testEvent = EventEmitter()
  testEvent:on(test1)
  testEvent:on(test2)
  testEvent:emit()

  -- clone d'un objet
  objClone = obj:clone()

  print(objClone)

  -- ici démonstration de la classe Vector2

  -- d'ailleurs comme vous voyez il est possible de ne pas faire class:new() et de juste faire () le résultat est le même

  vec = Vector2(12, 12)
  vec2 = Vector2(98, 13)
  print(vec2:normalize())

  biomelist = {}
  world = World(math.random() * 1000000,10, 100, 150, {}, { "terrain" })
  debugseebiome = false
  lightreach = 5
  biomesize = 150
  worldseed = math.random() * 100000
  chunksize = 10
  worlddeepnessprogression = 100
  --biomesize=25 worlddeepnessprogression=15
  chunkloaddistance = 4
  entities = {}
  loadtextures()
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
  gamestate = 0
  tick = 0
  szx = 100
  szy = 100
  cx = 50
  cy = 50
  fullscreen = false
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

function love.update(dt)
  delta = dt
  realtime = realtime + dt
  mx, my = love.mouse.getPosition()
  mxworldpos, myworldpos = screentoposition(mx, my)
  szx, szy = love.window.getMode()
  cx = szx / 2
  cy = szy / 2
  math.random()
  tick = tick + 1

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

  drawgame()

  clicktick = false
  rightclicktick = false
  middleclicktick = false
end

function love.keypressed(key)
  if key == "p" then
    fullscreen = not fullscreen
    love.window.setFullscreen(fullscreen)
  end
  if key == "r" then resetworld() end
  if key == "space" then
    replacetile(round(mxworldpos), round(myworldpos),
      { ["tile"] = "stone", ["top"] = "none", ["back"] = "none", ["light"] = { 1, 1, 1, 1 } })
  end
  --if key=="e" and spectator then camv=nextinlistroll(camv,{16,24,32,40,48,56,64,72,80}) end
  --if key=="q" and spectator then camv=nextinlistrollreverse(camv,{16,24,32,40,48,56,64,72,80}) end
  if key == "e" and spectator then
    camv = camv + 8
    if camv > 96 then camv = 96 end
  end
  if key == "q" and spectator then
    camv = camv - 8
    if camv < 8 then camv = 8 end
  end
end

function love.mousepressed(x, y, b)
  if b == 1 then clicktick = true end
  if b == 3 then middleclicktick = true end
  if b == 2 then rightclicktick = "none" end
end

function love.wheelmoved(x, y)

end
