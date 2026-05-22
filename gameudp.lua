function gameupdate(dt)
  generateworldupdate(dt)
  world:updateEntities(dt)
  --entityupdate(dt)
  --playerupdate(dt)
  --updatelight(dt)
end