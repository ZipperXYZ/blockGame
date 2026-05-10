function love.load()
  --bonjour

  require "lume"
  require "gameudp"
  require "drawudp" --là ou tout le code de dessins
  require "mathsc"  --math comprend plusieurs truc bien qui sont pas dans lua de base
  require "World/worldgeneration"
  require "load"
  --  require "entities"
  require "class/childClass"
  require "class/utility/eventEmitter"
  require "class/utility/vector2"
  love.graphics.setDefaultFilter("nearest", "nearest")

  require "World/tiledef"
  require "World/chunk"
  require "World/world"
  -- require "chunkv2"
  -- require "worldv2"
  --love.filesystem.setIdentity("gamename")
  tiles = {}
  tilelists = {}
  entitiesdefenition = {}
  entities = {}
  textures = {}
  tileindexes = {}

  --entity = Entity:new("test", "test", "test", 1, 9)

  -- entity:damage(99)

  biomelist = {}
  world = World(math.random() * 1000000, 10, 100, 150, {}, { "terrain" })
  world:addBiome("none",0.5,0.5,-1,3,5,1)
  world:addBiome("coldland",0.2,0.4,2,8,3,1)
  world:addBiome("hotland",0.8,0.6,3.5,99999,1,1)
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
  if key == "r" then world = World(math.random() * 1000000, 10, 100, 150, {}, { "terrain" }) end
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
