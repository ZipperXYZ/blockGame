function gameupdate(dt)
  generateworldupdate(dt)
  world:updateEntities(dt)
  world:groundItemsUpdate(dt)
  --entityupdate(dt)
  --playerupdate(dt)
  --updatelight(dt)
end