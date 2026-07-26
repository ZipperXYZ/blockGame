function gameupdate(dt)
  gametime = gametime + dt
  generateworldupdate(dt)

  local udpDistanceX = math.ceil(szx / camv / 2)
  local udpDistanceY = math.ceil(szy / camv / 2)

  world:updateTiles(dt, camx, camy, udpDistanceX, udpDistanceY, {})
  world:updateEntities(dt)
  world:updateParticles(dt)
  world:groundItemsUpdate(dt)
  --entityupdate(dt)
  --playerupdate(dt)
  --updatelight(dt)
end

function StartGame(changeGameState,parameters)
  if parameters == nil then parameters = {} end
  if parameters.wh == nil then parameters.wh = 1500 end
  if parameters.ww == nil then parameters.ww = 450 end
  if parameters.freeCam == nil then parameters.freeCam = false end
  if parameters.flyCheat == nil then parameters.flyCheat = false end

  camEntityFollow = 0
  camx = 0
  camy = 0
  entities = {}
  local worldParameters = {}
  worldParameters.borderX = parameters.ww
  worldParameters.borderY = parameters.wh * 1.2
  world = World(math.random() * 1000000, 10, parameters.wh/5, 150, {}, GlobalWorldGenStepList, worldParameters)
  --local spawnX, spawnY = world:getSpawn()
  generateBaseBiomes()

  --debugseebiome = true
  --CheatMode = true

  --lightreach = 6        --light distance
  --chunkloaddistance = 20 --
  --MaxChunkLoadedPerFrame = 3  --
  if parameters.freeCam then
    spectator = true
  else
    world:spawnEntity("player", 0, 0)
    if parameters.flyCheat then
      entities[1].flyCheat = true
    end
  end

  if changeGameState then gamestate = "game" end
end