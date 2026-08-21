function drawgame()
  nop = world:getPlayerAmount()


  if nop <=1 then
    drawPlayerScreen(1,1)
    love.graphics.origin()
    love.graphics.setScissor()
  else
    for i = 1, nop do
      drawPlayerScreen(i,nop)
      love.graphics.origin()
      love.graphics.setScissor()
    end
  end

  resizeScreen(0,0)

  if nop == 3 then
    cx = szx * 0.15
    cy = szy * 0.775
    local centerX = camx
    local centerY = camy
    if (Cameras[1] ~= nil) and (Cameras[2] ~= nil) and (Cameras[3] ~= nil) then
      centerX = (Cameras[1].x + Cameras[2].x + Cameras[3].x) / 3
      centerY = (Cameras[1].y + Cameras[2].y + Cameras[3].y) / 3
    end
    drawWorldMap(0, szy * 0.55, szx * 0.3, szy * 0.45, 1, centerX, centerY)
  end

  resizeScreen(0,0)
  --[[
  local drawdistanceX = math.ceil(szx / camv / 2)
  local drawdistanceY = math.ceil(szy / camv / 2)
  if false and (love.keyboard.isDown("n") or love.keyboard.isDown("b")) then
    drawBiomeMap() debugtimelog("drawBiomeMap","draw")
  else
    if true and love.keyboard.isDown("m") then
      drawWorldMap() debugtimelog("drawWorldMap","draw")
    else
      world:drawTiles(camx, camy, drawdistanceX, drawdistanceY, {}) debugtimelog("drawTiles","draw")
      world:DrawEntities() debugtimelog("DrawEntities","draw")
      world:drawParticles() debugtimelog("drawParticles","draw")
      world:drawGroundItems() debugtimelog("drawGroundItems","draw")
      world:drawProjectiles() debugtimelog("drawProjectiles","draw")
      world:drawTextParticles() debugtimelog("drawTextParticles","draw")
      world:drawEntitiesHealthBars() debugtimelog("drawEntitiesHealthBars","draw")
      if world.fogActivated then
        world:drawFog(camx, camy, drawdistanceX, drawdistanceY, {}) debugtimelog("drawFog","draw")
      end 
      world:DrawUi() debugtimelog("DrawUi","draw")
      --world.globalDirector:print() 
      --¶¶
      if #world.directors > 0 then
        for i, director in ipairs(world.directors) do
          director:print()
        end
      end
      --
    end
  end--]]

  GameEndUpdate(delta) debugtimelog("GameEndUpdate","update")

  if not IsAPlayerAlive() then
    love.graphics.setColor(1,0,0,1)
    --love.graphics.print("alaal",0,0)
    PauseUpdate()
  end

end

function resizeScreen(playerNumber, playerNumberMax)

    szx, szy = love.window.getMode()

    -- Reset the graphics transform
    love.graphics.origin()

    -- Reset viewport offset
    currentViewportX = 0
    currentViewportY = 0

    -- =====================================================
    -- 1 PLAYER
    -- =====================================================

    if playerNumberMax <= 1 then

        love.graphics.setScissor()

    end


    -- =====================================================
    -- 2 PLAYERS
    -- =====================================================

    if playerNumberMax == 2 then

        -- Player 1
        if playerNumber == 1 then

            currentViewportX = 0
            currentViewportY = 0

            love.graphics.setScissor(
                0,
                0,
                szx / 2,
                szy
            )

        end

        -- Player 2
        if playerNumber == 2 then

            currentViewportX = szx / 2
            currentViewportY = 0

            love.graphics.translate(
                currentViewportX,
                currentViewportY
            )

            love.graphics.setScissor(
                currentViewportX,
                currentViewportY,
                szx / 2,
                szy
            )

        end

    end


    -- =====================================================
    -- 3 PLAYERS
    -- =====================================================

    if playerNumberMax == 3 then

        -- Player 1
        if playerNumber == 1 then

            currentViewportX = 0
            currentViewportY = 0

            love.graphics.setScissor(
                0,
                0,
                szx / 2,
                szy * 0.55
            )

        end

        -- Player 2
        if playerNumber == 2 then

            currentViewportX = szx / 2
            currentViewportY = 0

            love.graphics.translate(
                currentViewportX,
                currentViewportY
            )

            love.graphics.setScissor(
                currentViewportX,
                currentViewportY,
                szx / 2,
                szy * 0.55
            )

        end

        -- Player 3
        if playerNumber == 3 then

            currentViewportX = szx * 0.3
            currentViewportY = szy * 0.55

            love.graphics.translate(
                currentViewportX,
                currentViewportY
            )

            love.graphics.setScissor(
                currentViewportX,
                currentViewportY,
                szx * 0.7,
                szy * 0.45
            )

        end

    end


    -- =====================================================
    -- 4 PLAYERS
    -- =====================================================

    if playerNumberMax == 4 then

        -- Player 1
        if playerNumber == 1 then

            currentViewportX = 0
            currentViewportY = 0

            love.graphics.setScissor(
                0,
                0,
                szx / 2,
                szy / 2
            )

        end

        -- Player 2
        if playerNumber == 2 then

            currentViewportX = szx / 2
            currentViewportY = 0

            love.graphics.translate(
                currentViewportX,
                currentViewportY
            )

            love.graphics.setScissor(
                currentViewportX,
                currentViewportY,
                szx / 2,
                szy / 2
            )

        end

        -- Player 3
        if playerNumber == 3 then

            currentViewportX = 0
            currentViewportY = szy / 2

            love.graphics.translate(
                currentViewportX,
                currentViewportY
            )

            love.graphics.setScissor(
                currentViewportX,
                currentViewportY,
                szx / 2,
                szy / 2
            )

        end

        -- Player 4
        if playerNumber == 4 then

            currentViewportX = szx / 2
            currentViewportY = szy / 2

            love.graphics.translate(
                currentViewportX,
                currentViewportY
            )

            love.graphics.setScissor(
                currentViewportX,
                currentViewportY,
                szx / 2,
                szy / 2
            )

        end

    end


    -- =====================================================
    -- SEND VIEWPORT POSITION TO THE SHADER
    -- =====================================================

    if textures["textures"]["fraetile"] then
      textures["textures"]["fraetile"]:send(
          "viewportOffset",
          {
              currentViewportX,
              currentViewportY
          }
      )
  end


    -- =====================================================
    -- SET PLAYER SCREEN SIZE
    -- =====================================================

    setScreenSize(
        playerNumber,
        playerNumberMax
    )

end

function getMousePosition(playerNumber, playerNumberMax)
  aszx, aszy = love.window.getMode()
  local mx, my = love.mouse.getPosition()
  if playerNumberMax <= 1 then
    return mx, my
  end
  if playerNumberMax == 2 then
    if playerNumber == 1 then
      return mx, my
    end
    if playerNumber == 2 then
      return mx - aszx / 2, my
    end
  end
  if playerNumberMax == 3 then
    if playerNumber == 1 then
      return mx, my
    end
    if playerNumber == 2 then
      return mx - aszx / 2, my
    end
    if playerNumber == 3 then
      return mx - aszx * 0.3, my - aszy * 0.55
    end
  end
  if playerNumberMax == 4 then
    if playerNumber == 1 then
      return mx, my
    end
    if playerNumber == 2 then
      return mx - aszx / 2, my
    end
    if playerNumber == 3 then
      return mx, my - aszy / 2
    end
    if playerNumber == 4 then
      return mx - aszx / 2, my - aszy / 2
    end
  end
  return mx, my
end

function getMouseWorldPosition(playerNumber, playerNumberMax)
  local mx, my = getMousePosition(playerNumber, playerNumberMax)
  --mx, my = screentoposition(self.controls.mx, self.controls.my)
   setScreenSize(playerNumber,playerNumberMax)
   if Cameras[playerNumber] ~= nil then
    mx=((mx-cx)/Cameras[playerNumber].v)+Cameras[playerNumber].x
  my=(((cy-my))/Cameras[playerNumber].v)+Cameras[playerNumber].y
   end
  
  return mx, my
end

function setScreenSize(playerNumber,playerNumberMax)
  szx, szy = love.window.getMode()

  if playerNumberMax <= 1 then

  end
  if playerNumberMax == 2 then
    if playerNumber == 1 then
      szx = szx / 2
    end
    if playerNumber == 2 then
      szx = szx / 2
    end
  end
  if playerNumberMax == 3 then
    if playerNumber == 1 then
      szx = szx / 2
      szy = szy * 0.55
    end
    if playerNumber == 2 then
      szx = szx / 2
      szy = szy * 0.55
    end
    if playerNumber == 3 then
      szx = szx *0.7
      szy = szy * 0.45
    end
  end
  if playerNumberMax == 4 then
    szx = szx / 2
    szy = szy / 2
  end
  cx = szx / 2
  cy = szy / 2
end

function drawPlayerScreen(playerNumber,playerNumberMax)

  resizeScreen(playerNumber,playerNumberMax)

  if Cameras[playerNumber] == nil then
    Cameras[playerNumber] = {x = camx, y = camy, v = camv, entityFollow = camEntityFollow, backgroundcolorBottom = CopyAll(backgroundcolorBottom), backgroundcolorTop = CopyAll(backgroundcolorTop)}
  end

  camx = Cameras[playerNumber].x
  camy = Cameras[playerNumber].y
  camv = Cameras[playerNumber].v
  camEntityFollow = Cameras[playerNumber].entityFollow
  backgroundcolorBottom = CopyAll(Cameras[playerNumber].backgroundcolorBottom)
  backgroundcolorTop = CopyAll(Cameras[playerNumber].backgroundcolorTop)

  updateBackground(delta,camx,camy)

  Cameras[playerNumber].backgroundcolorTop = CopyAll(backgroundcolorTop)
  Cameras[playerNumber].backgroundcolorBottom = CopyAll(backgroundcolorBottom)
  

  local drawdistanceX = math.ceil(szx / camv / 2)
  local drawdistanceY = math.ceil(szy / camv / 2)

      world:drawTiles(camx, camy, drawdistanceX, drawdistanceY, {}) debugtimelog("drawTiles","draw")
      world:DrawEntities() debugtimelog("DrawEntities","draw")
      world:drawParticles() debugtimelog("drawParticles","draw")
      world:drawGroundItems() debugtimelog("drawGroundItems","draw")
      world:drawProjectiles() debugtimelog("drawProjectiles","draw")
      world:drawTextParticles() debugtimelog("drawTextParticles","draw")
      world:drawEntitiesHealthBars() debugtimelog("drawEntitiesHealthBars","draw")
      if world.fogActivated then
        world:drawFog(camx, camy, drawdistanceX, drawdistanceY, {}) debugtimelog("drawFog","draw")
      end 
      world:DrawUi(playerNumber) debugtimelog("DrawUi","draw")
      --[[
      if #world.directors > 0 then
        for i, director in ipairs(world.directors) do
          director:print()
        end
      end]]
      
end

function drawWorldMap(x, y, w, h, zoom, centerX, centerY)
  love.graphics.setColor(0, 0, 0, 0.6)
  love.graphics.rectangle("fill", x, y, w, h)
  local screenCenterX = x + w / 2
  local screenCenterY = y + h / 2
  local mapSizePerPixel = 5
  local zoom  = zoom or 1
  local centerX = centerX or camx
  local centerY = centerY or camy
  zoom = zoom/MapZoom
  local colorScheme = "tiles" --tiles | biomes
  for ix = round2(x, mapSizePerPixel), round2(x + w, mapSizePerPixel), mapSizePerPixel do
    for iy = round2(y, mapSizePerPixel), round2(y + h, mapSizePerPixel), mapSizePerPixel do
      local wx = centerX + ((ix - screenCenterX) * (1)) * zoom
      local wy = centerY + ((screenCenterY - iy) * (1)) * zoom
      local t1 = world:getRawTile(wx, wy, "tiles")
      if t1 ~= "none" then
        if colorScheme == "biomes" then
          b1, c1 = world:getBiome(wx, wy)
          love.graphics.setColor(0.8, 0.8, 0.8, 1)
          if b1 == "none" then love.graphics.setColor(0.5, 0.5, 0.5, 1) end
          if b1 == "essenceLand" then love.graphics.setColor(0, 0.3, 0.8, 1) end
          if b1 == "coldland" then love.graphics.setColor(0.3, 0.8, 0.8, 1) end
          if b1 == "hotland" then love.graphics.setColor(0.8, 0.4, 0.1, 1) end
          if b1 == "darkland" then love.graphics.setColor(0.5, 0.2, 0.5, 1) end
          if b1 == "ancientland" then love.graphics.setColor(0.6, 0.8, 0.6, 1) end
          if b1 == "duneland" then love.graphics.setColor(0.8, 0.8, 0.6, 1) end
          if b1 == "edgeLands" then love.graphics.setColor(0.3, 0.22, 0, 1) end
        end
        if colorScheme == "tiles" then
          love.graphics.setColor(tiles[t1].mapColor)
        end
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
    gamestate = "worldCreation"
  end
  if results["settingsButton"] then
    gamestate = "settings"
  end
  if results["load"] then
    SaveName = results["loadSaveName"]
    if SaveName == "" then
      SaveName = "save"
    end
    if LoadGame(SaveName) then
      gamestate = "game"
    end
  end
  if results["quitButton"] then
    love.event.quit()
  end
  --title size : 192 x 64 
  love.graphics.setColor(1, 1, 1, 1)
  local screenSize = math.min(szx, szy)
  local size = screenSize / 200
  love.graphics.draw(textures["textures"]["title.png"], szx / 2, szy*0.2 + math.sin(realtime/1.5)*szy*0.01, 0, size, size, 192 / 2, 64 / 2)
end

function PauseUpdate()

  local results = interfaces["pause"]:updateAndDraw()
  
  if results["returnButton"] then
    gamestate = "game"
  end

  if results["retryButton"] then
    InstantStartGame(true) --StartGame(true)
  end

  if results["save"] then
    SaveGame(SaveName)
  end

  if results["leaveGameButton"] then
    gamestate = "mainMenu"
  end

end

function InstantStartGame(b)
  interfaces["worldCreation"]:passDataToElement("cheat",CheatMode)
  interfaces["worldCreation"]:passDataToElement("BuilderCheat",BuilderCheat)
  local results = interfaces["worldCreation"]:updateAndDraw()

    local parameters = {}
    parameters.wh = tonumber(results["worldHeigth"])
    parameters.ww = tonumber(results["worldWidth"])
    parameters.freeCam = results["freeCam"]
    parameters.flyCheat = results["flyCheat"]
    parameters.biomeSize = results["biomeSize"]
    parameters.terrainSize = results["terrainSize"]
    parameters.directorCreditMultiplier = results["directorCreditMultiplier"]
    parameters.directorSpawnSpeedMultiplier = results["directorSpawnSpeedMultiplier"]
    parameters.worldseed = results["worldseed"]
    parameters.numberOfPlayer = results["numberOfPlayer"]
    parameters.playerFogDistance = results["playerFogDistance"]
    parameters.playerFog = results["playerFog"]
    parameters.itemAttributesMultiplier = results["itemAttributesMultiplier"]

    StartGame(b,parameters)

  CheatMode = results["cheat"]
  BuilderCheat = results["BuilderCheat"]
  lightreach = results["lightReach"]
end

function WorldCreationUpdate(dt)

  interfaces["worldCreation"]:passDataToElement("cheat",CheatMode)
  interfaces["worldCreation"]:passDataToElement("BuilderCheat",BuilderCheat)
  local results = interfaces["worldCreation"]:updateAndDraw()

  if results["saveName"] ~= "" then
    SaveName = results["saveName"]
  else
    SaveName = "save"
  end
  if results["resetWorldCreation"] then
    interfaces["worldCreation"]:resetAll()
    results = interfaces["worldCreation"]:updateAndDraw()
  end

  if results["createButton"] then
    InstantStartGame(true)
  end

  CheatMode = results["cheat"]
  BuilderCheat = results["BuilderCheat"]
  lightreach = results["lightReach"]

  
  



  local results = interfaces["back"]:updateAndDraw()
  if results["back"] then
    gamestate = "mainMenu"
  end
end

function SettingsUpdate()

  --interfaces["settings"]:passDataToElement("cheat",CheatMode)

  interfaces["settings"]:passDataToElement("chunkRenderDistance",chunkloaddistance)
  interfaces["settings"]:passDataToElement("maxChunkLoadedPerFrame",MaxChunkLoadedPerFrame)
  interfaces["settings"]:passDataToElement("MapZoom",MapZoom)
  interfaces["settings"]:passDataToElement("InventorySize",InventorySize)
  interfaces["settings"]:passDataToElement("TooltipSize",TooltipSize)
  interfaces["settings"]:passDataToElement("UISize",UISize)
  interfaces["settings"]:passDataToElement("InventoryTextSize",InventoryTextSize)
  interfaces["settings"]:passDataToElement("InventoryStyle",InventoryStyle)
  interfaces["settings"]:passDataToElement("SelectedFont",SelectedFont)
  interfaces["settings"]:passDataToElement("fullscreen",fullscreen)
  interfaces["settings"]:passDataToElement("HealthBarStyle",HealthBarStyle)
  interfaces["settings"]:passDataToElement("HealthBarPosition",HealthBarPosition)
  local lastFont = SelectedFont
  local lastFullscreen = fullscreen
  
  local results = interfaces["settings"]:updateAndDraw()

  if results["resetSettings"] then
    interfaces["settings"]:resetAll()
    results = interfaces["settings"]:updateAndDraw()
  end
  --CheatMode = results["cheat"]
  --lightreach = results["lightReach"]
  chunkloaddistance = results["chunkRenderDistance"]
  MaxChunkLoadedPerFrame = results["maxChunkLoadedPerFrame"]
  
  MapZoom = results["MapZoom"]
  HealthBarStyle = results["HealthBarStyle"]
  HealthBarPosition = results["HealthBarPosition"]
  InventorySize = results["InventorySize"]
  TooltipSize = results["TooltipSize"]
  InventoryTextSize = results["InventoryTextSize"]
  SelectedFont = results["SelectedFont"]
  UISize = results["UISize"]
  InventoryStyle = results["InventoryStyle"]
  fullscreen = results["fullscreen"]

  if lastFullscreen ~= fullscreen then
    love.window.setFullscreen(fullscreen)
  end
  if lastFont ~= SelectedFont then
    Font = Fonts[SelectedFont]
    love.graphics.setFont(Font)
  end

  if results["resetUI"] then
    LoadInterfaces()
  end
  



  local results = interfaces["back"]:updateAndDraw()
  if results["back"] then
    gamestate = "mainMenu"
  end
end