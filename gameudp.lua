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
  GameEndUpdate(dt)

  if IsAPlayerAlive() then
    love.graphics.setColor(1,0,0,1)
    love.graphics.print("alaal",0,0)
  end
  
end

function GameEndUpdate(dt)
  NoPlayersAlive = false
  if (EndGameWhenNoPlayer) and (not IsAPlayerAlive()) then
    NoPlayersAlive = true
  end
  if NoPlayersAlive then
    DeathAnimation = DeathAnimation + dt/5
    camv = math.sqrt(szy * szx) / 30
      camv = camv * (1 - (DeathAnimation^0.3)*0.3)
      --camv = round(camv,1)

      if camv <= 8 then camv = 8 end
      if camv >= 128 then camv = 128 end
    if DeathAnimation > 1 then
      DeathAnimation = 1
    end
  else
    DeathAnimation = 0
  end
end

function IsAPlayerAlive()
  local alive = false

  if #entities >0 then
    for i = 1, #entities do
      if entities[i].state ~= "dead" and entities[i].isPlayer then
        alive = true
      end
    end
  end

  return alive
end

function StartGame(changeGameState,parameters)
  if parameters == nil then parameters = {} end
  if parameters.wh == nil then parameters.wh = 1500 end
  if parameters.ww == nil then parameters.ww = 450 end
  if parameters.biomeSize == nil then parameters.biomeSize = 150 end
  if parameters.freeCam == nil then parameters.freeCam = false end
  if parameters.flyCheat == nil then parameters.flyCheat = false end

  camEntityFollow = 0
  camx = 0
  camy = 0
  DeathAnimation = 0
  entities = {}
  local worldParameters = {}
  EndGameWhenNoPlayer = true
  worldParameters.borderX = parameters.ww
  worldParameters.borderY = parameters.wh * 1.2
  world = World(math.random() * 1000000, 10, parameters.wh/5, parameters.biomeSize, {}, GlobalWorldGenStepList, worldParameters)
  --local spawnX, spawnY = world:getSpawn()
  generateBaseBiomes()

  --debugseebiome = true
  --CheatMode = true

  --lightreach = 6        --light distance
  --chunkloaddistance = 20 --
  --MaxChunkLoadedPerFrame = 3  --
  if parameters.freeCam then
    spectator = true
    EndGameWhenNoPlayer = false
  else
    world:spawnEntity("player", 0, 0)
    if parameters.flyCheat then
      entities[1].flyCheat = true
    end
  end

  if changeGameState then gamestate = "game" end
end