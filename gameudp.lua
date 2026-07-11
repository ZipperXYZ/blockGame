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

function StartGame(changeGameState)
  entities = {}
  world = World(math.random() * 1000000, 10, 100, 150, {}, { "none", "stone", "stone2", "grass", "ores", "deco", "done" })
  --local spawnX, spawnY = world:getSpawn()
  generateBaseBiomes()

  --debugseebiome = true
  --CheatMode = true

  --lightreach = 6        --light distance
  --chunkloaddistance = 20 --
  --MaxChunkLoadedPerFrame = 3  --


  world:spawnEntity("player", 0, 0)

  if changeGameState then gamestate = "game" end
end