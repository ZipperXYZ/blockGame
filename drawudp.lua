function drawgame()
  local drawdistanceX = math.ceil(szx / camv / 2)
  local drawdistanceY = math.ceil(szy / camv / 2)
  if love.keyboard.isDown("n") or love.keyboard.isDown("b") then
    drawBiomeMap()
  else
    if love.keyboard.isDown("m") then
      drawWorldMap()
    else
      world:drawTiles(camx, camy, drawdistanceX, drawdistanceY, {})
      world:drawParticles()
      world:DrawEntities()
      world:drawGroundItems()
      world:DrawUi()
    end
  end
end

function drawWorldMap()
  local mapSizePerPixel = 5
  for ix = 0, round2(szx, mapSizePerPixel), mapSizePerPixel do
    for iy = 0, round2(szy, mapSizePerPixel), mapSizePerPixel do
      local wx = camx + ((ix - szx / 2) * (128 / camv))
      local wy = camy + (20 - (iy - szy / 2) * (128 / camv))
      local t1 = world:getRawTile(wx, wy, "tiles")
      if t1 ~= "none" then
        b1, c1 = world:getBiome(wx, wy)
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
        if b1 == "none" then love.graphics.setColor(0.5, 0.5, 0.5, 1) end
        if b1 == "coldland" then love.graphics.setColor(0.3, 0.8, 0.8, 1) end
        if b1 == "hotland" then love.graphics.setColor(0.8, 0.4, 0.1, 1) end
        if b1 == "darkland" then love.graphics.setColor(0.5, 0.2, 0.5, 1) end
        if b1 == "ancientland" then love.graphics.setColor(0.6, 0.8, 0.6, 1) end
        if b1 == "duneland" then love.graphics.setColor(0.8, 0.8, 0.6, 1) end
        love.graphics.rectangle("fill", ix, iy, mapSizePerPixel, mapSizePerPixel)
      end
    end
  end
end

function drawBiomeMap()
  local mapSizePerPixel = 2
  for ix = 0, round2(szx, mapSizePerPixel), mapSizePerPixel do
    for iy = 0, round2(szy, mapSizePerPixel), mapSizePerPixel do
      local wx = camx + ((ix - szx / 2) * (128 / camv))
      local wy = camy + (20 - (iy - szy / 8) * (128 / camv))
      local t1 = "dirt"
      if love.keyboard.isDown("b") then
        t1 = world:generateTerrainTile(wx, wy)
      end
      b1, c1 = world:getBiome(wx, wy)
      if (love.keyboard.isDown("n")) or (t1 == "dirt" and love.keyboard.isDown("b")) then
        love.graphics.setColor(1, 1, 1, 1)

        if b1 == "none" then love.graphics.setColor(0.5, 0.5, 0.5, 1) end
        if b1 == "coldland" then love.graphics.setColor(0.3, 0.8, 0.8, 1) end
        if b1 == "hotland" then love.graphics.setColor(0.8, 0.4, 0.1, 1) end
        if b1 == "darkland" then love.graphics.setColor(0.5, 0.2, 0.5, 1) end
        if b1 == "ancientland" then love.graphics.setColor(0.6, 0.8, 0.6, 1) end
        if b1 == "duneland" then love.graphics.setColor(0.8, 0.8, 0.6, 1) end

        love.graphics.rectangle("fill", ix, iy, mapSizePerPixel, mapSizePerPixel)
      end
    end
  end
end

function MainMenuUpdate()
  local results = interfaces["mainMenu"]:updateAndDraw()

  if results["playButton"] then
    StartGame(true)
  end
  if results["settingsButton"] then
    gamestate = "settings"
  end
  if results["quitButton"] then
    love.event.quit()
  end
end

function SettingsUpdate()
  local results = interfaces["settings"]:updateAndDraw()

  local results = interfaces["back"]:updateAndDraw()
end