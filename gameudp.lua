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