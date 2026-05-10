function drawgame()
  local drawdistanceX=math.ceil(szx/camv/2)
  local drawdistanceY=math.ceil(szx/camv/2)
  if love.keyboard.isDown("n") or love.keyboard.isDown("b") then
    drawBiomeMap()
  else
    if love.keyboard.isDown("m") then
      drawWorldMap()
    else
      world:drawTiles(camx, camy, drawdistanceX, drawdistanceY, {})
    end
  end
end
function drawWorldMap()
  local mapSizePerPixel=5
  for ix=0,round2(szx,mapSizePerPixel),mapSizePerPixel do
    for iy=0,round2(szy,mapSizePerPixel),mapSizePerPixel do
      local wx = camx+((ix-szx/2)*(128/camv))
      local wy = camy+(20-(iy-szy/2)*(128/camv))
      local t1 = world:getRawTile(wx,wy,"tiles")
      if t1 ~= "none" then
        b1, c1 = world:getBiome(wx,wy)
        love.graphics.setColor(0.8,0.8,0.8,1)
        if b1=="none" then love.graphics.setColor(0.5,0.5,0.5,1) end
        if b1=="coldland" then love.graphics.setColor(0.3,0.8,0.8,1) end
        if b1=="hotland" then love.graphics.setColor(0.8,0.4,0.1,1) end
        if b1=="darkland" then love.graphics.setColor(0.5,0.2,0.5,1) end
        if b1=="ancientland" then love.graphics.setColor(0.6,0.8,0.6,1) end
        if b1=="duneland" then love.graphics.setColor(0.8,0.8,0.6,1) end
        love.graphics.rectangle("fill",ix,iy,mapSizePerPixel,mapSizePerPixel)
      end
    end
  end
end
function drawBiomeMap()
  local mapSizePerPixel=2
  for ix=0,round2(szx,mapSizePerPixel),mapSizePerPixel do
    for iy=0,round2(szy,mapSizePerPixel),mapSizePerPixel do
      local wx = camx+((ix-szx/2)*(128/camv))
      local wy = camy+(20-(iy-szy/8)*(128/camv))
      local t1 = "dirt"
      if love.keyboard.isDown("b") then
        t1 = world:generateTerrainTile(wx, wy)
      end
      b1, c1 = world:getBiome(wx,wy)
      if (love.keyboard.isDown("n")) or (t1 == "dirt" and love.keyboard.isDown("b") ) then

        love.graphics.setColor(1,1,1,1)

        if b1=="none" then love.graphics.setColor(0.5,0.5,0.5,1) end
        if b1=="coldland" then love.graphics.setColor(0.3,0.8,0.8,1) end
        if b1=="hotland" then love.graphics.setColor(0.8,0.4,0.1,1) end
        if b1=="darkland" then love.graphics.setColor(0.5,0.2,0.5,1) end
        if b1=="ancientland" then love.graphics.setColor(0.6,0.8,0.6,1) end
        if b1=="duneland" then love.graphics.setColor(0.8,0.8,0.6,1) end

        love.graphics.rectangle("fill",ix,iy,mapSizePerPixel,mapSizePerPixel)
      end
    end
  end
end
--[[function drawspecifictile(tileix,tileiy,tilename,color)
  love.graphics.setColor(color)
  xp1,yp1=positiontoscreen(tileix,tileiy)
  love.graphics.draw(textures["textures"][gettileinfo(tilename,"texture")],textures["quads"][gettileinfo(tilename,"quad")],round(xp1),round(yp1),0,round2(camv/8,8),round2(camv/8,8),4,4)
end
function drawtop(tileix,tileiy)
  love.graphics.setColor(1,1,1,1)
  t1=gettile(tileix,tileiy)
           xp1,yp1=positiontoscreen(tileix,tileiy)
          name1=gettileinfo(t1["tile"],"name")
          solid1=gettileinfo(t1["tile"],"type")
          flags= gettileinfo(t1["top"],"flags")
          light=t1["light"]
          love.graphics.setColor(flags["color"])
          if solid1=="solid" then love.graphics.setColor(flags["color"][1]*light[1],flags["color"][2]*light[2],flags["color"][3]*light[3],flags["color"][4]*light[4]) end
          
  t2=gettile(tileix,tileiy+1)
            if not t2["outofbounds"] then
            if (gettileinfo(t2["tile"],"name")~=name1 and flags["border type"]=="different block") or (gettileinfo(t2["tile"],"type")~=solid1 and flags["border type"]=="non-solid") or (flags["border type"]=="normal") then
              love.graphics.draw(textures["textures"][gettileinfo(t1["top"],"texture")],textures["quads"][gettileinfo(t1["top"],"quad")],round(xp1),round(yp1),0,round2(camv/8,8),round2(camv/8,8),4,4)
            end end
            
            t2=gettile(tileix,tileiy-1)
            if not t2["outofbounds"] then
            if (gettileinfo(t2["tile"],"name")~=name1 and flags["border type"]=="different block") or (gettileinfo(t2["tile"],"type")~=solid1 and flags["border type"]=="non-solid") then
              love.graphics.draw(textures["textures"][gettileinfo(t1["top"],"texture")],textures["quads"][gettileinfo(t1["top"],"quad")],round(xp1),round(yp1),d180topi(180),round2(camv/8,8),round2(camv/8,8),4,4)
            end end
            
            t2=gettile(tileix+1,tileiy)
            if not t2["outofbounds"] then
            if (gettileinfo(t2["tile"],"name")~=name1 and flags["border type"]=="different block") or (gettileinfo(t2["tile"],"type")~=solid1 and flags["border type"]=="non-solid") then
              love.graphics.draw(textures["textures"][gettileinfo(t1["top"],"texture")],textures["quads"][gettileinfo(t1["top"],"quad")],round(xp1),round(yp1),d180topi(90),round2(camv/8,8),round2(camv/8,8),4,4)
            end end
            
            t2=gettile(tileix-1,tileiy)
            if not t2["outofbounds"] then
            if (gettileinfo(t2["tile"],"name")~=name1 and flags["border type"]=="different block") or (gettileinfo(t2["tile"],"type")~=solid1 and flags["border type"]=="non-solid") then
              love.graphics.draw(textures["textures"][gettileinfo(t1["top"],"texture")],textures["quads"][gettileinfo(t1["top"],"quad")],round(xp1),round(yp1),d180topi(-90),round2(camv/8,8),round2(camv/8,8),4,4)
            end end
end


function drawtile(tileix,tileiy)
  love.graphics.setColor(1,1,1,1)
          t1=gettile(tileix,tileiy)
          xp1,yp1=positiontoscreen(tileix,tileiy)
          --love.graphics.print(t1["type"],x1,y1)
          --love.graphics.print(gettileinfo("dirt","texture"),x1,y1+12)
          name1=gettileinfo(t1["tile"],"name")
          flags= gettileinfo(t1["tile"],"flags")
          solid1= gettileinfo(t1["tile"],"type")
          light=t1["light"]
          love.graphics.setColor(flags["color"])
          if solid1=="solid" then love.graphics.setColor(flags["color"][1]*light[1],flags["color"][2]*light[2],flags["color"][3]*light[3],flags["color"][4]*light[4]) end
          love.graphics.draw(textures["textures"][gettileinfo(t1["tile"],"texture")],textures["quads"][gettileinfo(t1["tile"],"quad")],round(xp1),round(yp1),0,round2(camv/8,8),round2(camv/8,8),4,4)
          
          
          if flags["border"]~="none" then
          
            t2=gettile(tileix,tileiy+1)
            if not t2["outofbounds"] then
            if gettileinfo(t2["tile"],"name")~=name1 then
              love.graphics.draw(textures["textures"][gettileinfo(t1["tile"],"texture")],textures["quads"][flags["border"]["quad"] ],round(xp1),round(yp1),0,round2(camv/8,8),round2(camv/8,8),4,4)
            end end
            
            t2=gettile(tileix,tileiy-1)
            if not t2["outofbounds"] then
            if gettileinfo(t2["tile"],"name")~=name1 then
              love.graphics.draw(textures["textures"][gettileinfo(t1["tile"],"texture")],textures["quads"][flags["border"]["quad"] ],round(xp1),round(yp1),d180topi(180),round2(camv/8,8),round2(camv/8,8),4,4)
            end end
            
            t2=gettile(tileix+1,tileiy)
            if not t2["outofbounds"] then
            if gettileinfo(t2["tile"],"name")~=name1 then
              love.graphics.draw(textures["textures"][gettileinfo(t1["tile"],"texture")],textures["quads"][flags["border"]["quad"] ],round(xp1),round(yp1),d180topi(90),round2(camv/8,8),round2(camv/8,8),4,4)
            end end
            
            t2=gettile(tileix-1,tileiy)
            if not t2["outofbounds"] then
            if gettileinfo(t2["tile"],"name")~=name1 then
              love.graphics.draw(textures["textures"][gettileinfo(t1["tile"],"texture")],textures["quads"][flags["border"]["quad"] ],round(xp1),round(yp1),d180topi(-90),round2(camv/8,8),round2(camv/8,8),4,4)
            end end
          
          end
end
function drawback(tileix,tileiy)
  
          t1=gettile(tileix,tileiy)
          xp1,yp1=positiontoscreen(tileix,tileiy)
          --love.graphics.print(t1["type"],x1,y1)
          --love.graphics.print(gettileinfo("dirt","texture"),x1,y1+12)
          name1=gettileinfo(t1["back"],"name")
          flags= gettileinfo(t1["back"],"flags")
          love.graphics.setColor(flags["color"])
          love.graphics.draw(textures["textures"][gettileinfo(t1["back"],"texture")],textures["quads"][gettileinfo(t1["back"],"quad")],round(xp1),round(yp1),0,round2(camv/8,8),round2(camv/8,8),4,4)
          if flags["border"]~="none" then
          
            t2=gettile(tileix,tileiy+1)
            if not t2["outofbounds"] then
            if gettileinfo(t2["back"],"name")~=name1 then
              love.graphics.draw(textures["textures"][gettileinfo(t1["back"],"texture")],textures["quads"][flags["border"]["quad"] ],round(xp1),round(yp1),0,round2(camv/8,8),round2(camv/8,8),4,4)
            end end
            
            t2=gettile(tileix,tileiy-1)
            if not t2["outofbounds"] then
            if gettileinfo(t2["back"],"name")~=name1 then
              love.graphics.draw(textures["textures"][gettileinfo(t1["back"],"texture")],textures["quads"][flags["border"]["quad"] ],round(xp1),round(yp1),d180topi(180),round2(camv/8,8),round2(camv/8,8),4,4)
            end end
            
            t2=gettile(tileix+1,tileiy)
            if not t2["outofbounds"] then
            if gettileinfo(t2["back"],"name")~=name1 then
              love.graphics.draw(textures["textures"][gettileinfo(t1["back"],"texture")],textures["quads"][flags["border"]["quad"] ],round(xp1),round(yp1),d180topi(90),round2(camv/8,8),round2(camv/8,8),4,4)
            end end
            
            t2=gettile(tileix-1,tileiy)
            if not t2["outofbounds"] then
            if gettileinfo(t2["back"],"name")~=name1 then
              love.graphics.draw(textures["textures"][gettileinfo(t1["back"],"texture")],textures["quads"][flags["border"]["quad"] ],round(xp1),round(yp1),d180topi(-90),round2(camv/8,8),round2(camv/8,8),4,4)
            end end
          
          end
end]]
