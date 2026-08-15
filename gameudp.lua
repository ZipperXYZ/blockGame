function gameupdate(dt)
  gametime = gametime + dt
  debugtimelog("misc","update")
  --debugtimeclear("update")
  generateworldupdate(dt) debugtimelog("generateworldupdate","update")
  --debugtimeclear("update")

  local udpDistanceX = math.ceil(szx / camv / 2)
  local udpDistanceY = math.ceil(szy / camv / 2)

  world:updateTiles(dt, camx, camy, udpDistanceX, udpDistanceY, {}) debugtimelog("updateTiles","update")
  DirectorUpdate(dt) debugtimelog("directorUpdate","update")
  world:updateDirectors(dt) debugtimelog("updateDirectors","update")
  world:updateEntities(dt) --debugtimelog("updateEntities","update")
  DungeonParticleUpdate(dt) debugtimelog("DungeonParticleUpdate","update")
  RemoveDistantEnemies(60)
  world:projectileUpdate(dt) debugtimelog("projectileUpdate","update")
  world:updateParticles(dt) debugtimelog("updateParticles","update")
  world:groundItemsUpdate(dt) debugtimelog("groundItemsUpdate","update")
  world:fogUpdate(dt) debugtimelog("fogUpdate","update")
  world.time = world.time + dt
  --entityupdate(dt)
  --playerupdate(dt)
  --updatelight(dt)
  GameEndUpdate(dt) debugtimelog("GameEndUpdate","update")

  if IsAPlayerAlive() then
    love.graphics.setColor(1,0,0,1)
    love.graphics.print("alaal",0,0)
  end
  
end

function DungeonParticleUpdate(dt)
  local count = math.ceil(dt * 60 * 5)
  local found, closestStructure, closestDistance, StructurePosition = world:getClosestMainStructure("dungeon", camx, camy)
  local localPos = Vector2(camx,camy)
  --print(round(closestDistance))
  if found and closestDistance < 400 then
    for i = 1, count do
      local particlePosition = StructurePosition:copy()
      particlePosition:move(math.random()*360,(math.random()^2)*400)
      if particlePosition:dist(localPos) < 35 and particlePosition:dist(StructurePosition) > 37 and StructurePosition.y < particlePosition.y+70  then
        world:spawnParticles(1,"evil",particlePosition,0,{1,0,0,0.6}, {0.05,0.7,0.05,0.1}, 5, 3,"floating", 1.1, particlePosition:angle(StructurePosition), 0, {lightColor = {1,0.5,0,0.3}})
      end
    end
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

function RemoveDistantEnemies(maxDistance) 
  if #entities >0 then
    for i = #entities, 1, -1 do
      if entities[i].disappearFarFromPlayer then
        local playerDistance = 999999
        if #entities > 0 then
          for j = 1, #entities do
            if entities[j].isPlayer then
              local distance = entities[i].position:getDistance(entities[j].position)
              if distance < playerDistance then
                playerDistance = distance
              end
            end
          end
        end

        if playerDistance > maxDistance then
          entities[i].state = "dead"
          table.remove(entities,i)
        end
      end

    end
  end
end

function DirectorUpdate(dt)
  --world:updateDirectors(dt)
  local directorCount = -1
  if #entities > 0 then
    for i = 1, #entities do
      if entities[i].isPlayer then
        directorCount = directorCount + 1
        if directorCount == 0 then
          local depth = world:getDepth(entities[i].position.y)
          local multiplier = (1 + math.abs((depth*1.5) ^ 2))
          world.globalDirector.position = entities[i].position:copy()
          world.globalDirector.maxCredit = (100 + 30 * multiplier) * world.directorCreditMultiplier
          world.globalDirector.maxCreditBank = 40 + 30 * multiplier
          world.globalDirector.creditGain = (0.25 + 0.22 * multiplier) * world.directorCreditMultiplier
          world.globalDirector.spawnFrequency = 12 / (1 + 0.035 * multiplier) / world.directorSpawnSpeedMultiplier
          world.globalDirector.minCreditPerSpawn = -30 + (3 * multiplier)
          world.globalDirector.maxCreditPerSpawn = 50 + (10 * multiplier) * world.directorCreditMultiplier
          world.globalDirector.mobLimit = 60
          world.globalDirector.decay = world.globalDirector.decay + 10
        else
          if #world.directors < directorCount then
            local newDirector = EntitySpawnDirector(entities[i].position:copy(),50,15,25,3,12,nil,60,95,0,100,200,150,999999999,40)
            table.insert(world.directors,newDirector)
          else
            world.directors[directorCount].position = entities[i].position:copy()
            local depth = world:getDepth(entities[i].position.y)
            local multiplier = (1 + math.abs((depth*1.5) ^ 2)) 
            world.directors[directorCount].position = entities[i].position:copy()
            world.directors[directorCount].maxCredit = (100 + 30 * multiplier)* world.directorCreditMultiplier
            world.directors[directorCount].maxCreditBank = 40 + 30 * multiplier
            world.directors[directorCount].creditGain = (0.25 + 0.22 * multiplier) * world.directorCreditMultiplier
            world.directors[directorCount].spawnFrequency = 12 / (1 + 0.035 * multiplier) / world.directorSpawnSpeedMultiplier
            world.directors[directorCount].minCreditPerSpawn = -30 + (3 * multiplier)
            world.directors[directorCount].maxCreditPerSpawn = 50 + (10 * multiplier) * world.directorCreditMultiplier
            world.directors[directorCount].mobLimit = 60
            world.directors[directorCount].decay = world.directors[directorCount].decay + 10
          end
        end
      end
    end
  end
end

function StartGame(changeGameState,parameters)
  if parameters == nil then parameters = {} end
  if parameters.wh == nil then parameters.wh = 1500 end
  if parameters.ww == nil then parameters.ww = 450 end
  if parameters.biomeSize == nil then parameters.biomeSize = 150 end
  if parameters.freeCam == nil then parameters.freeCam = false end
  if parameters.flyCheat == nil then parameters.flyCheat = false end
  if parameters.worldseed == nil or parameters.worldseed == "" then parameters.worldseed = math.random() * 100000000 end
  if type(parameters.worldseed) == "string" then parameters.worldseed = tonumber(parameters.worldseed) end
  if parameters.directorCreditMultiplier == nil then parameters.directorCreditMultiplier = 1 end
  if parameters.directorSpawnSpeedMultiplier == nil then parameters.directorSpawnSpeedMultiplier = 1 end
  if parameters.terrainSize == nil then parameters.terrainSize = 1 end


  camEntityFollow = 0
  camx = 0
  camy = 0
  DeathAnimation = 0
  entities = {}
  local worldParameters = {}
  EndGameWhenNoPlayer = true
  worldParameters.caveSize = parameters.terrainSize or 1
  worldParameters.borderX = parameters.ww
  worldParameters.borderY = parameters.wh * 1.2
  worldParameters.directorCreditMultiplier = parameters.directorCreditMultiplier or 1
  worldParameters.directorSpawnSpeedMultiplier = parameters.directorSpawnSpeedMultiplier or 1
  UnfocusTextInput()
  world = World(parameters.worldseed, 10, parameters.wh/5, parameters.biomeSize, {}, GlobalWorldGenStepList, worldParameters)
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
    --world:spawnEntity("player", 0, 0)
    table.insert(entities, Entity("player", "player", "player", Vector2(0, 0), 100, 0.425, nil, "player", {}))
    --table.insert(entities, Entity("player", "player", "bigSlime", Vector2(0, 0), 100, 0.85, 0, "player", {}))
    if parameters.flyCheat then
      entities[1].flyCheat = true
    end
  end

  if changeGameState then gamestate = "game" end
end