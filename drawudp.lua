function drawgame()
  local drawdistanceX=math.ceil(szx/camv/2)
  local drawdistanceY=math.ceil(szx/camv/2)
  world:drawTiles(camx, camy, drawdistanceX, drawdistanceY, {})
 -- world:drawTiles(camx, camy, drawdistanceX, drawdistanceY, {["showBiomes"]=true})


  --[[love.graphics.print(#tiles,0,0)
  love.graphics.print(camv,50,0)
  love.graphics.print((getchunkloadstep(mxworldpos/chunksize,myworldpos/chunksize)),300,0)
  if neighborchunksloadcheck(mxworldpos/chunksize,myworldpos/chunksize,"stone") then love.graphics.print("true",300,12) end
  if neighborchunksloadcheck(mxworldpos/chunksize,myworldpos/chunksize,"grass") then love.graphics.print("true",300,24) end
  for i=1,#tiles do
    love.graphics.setColor(1,1,1,1)
    love.graphics.print(tiles[i]["name"],0,12*i)
    
    
  end
  drawdistance=math.ceil(szx/camv/2)
  layers=3]]
  --[[if debugseebiome then layers=4 end
  for il=1,layers do
  for ixt=-drawdistance,drawdistance do
  for iyt=-drawdistance,drawdistance do
    t1=gettile(camx+ixt,camy+iyt) --getinfofromworldtile
    if not t1["outofbounds"] then
      if il==2 then
        if gettileinfo(t1["tile"],"texture")~="none" then
        if gettileinfo(t1["tile"],"quad")~="none" then
          drawtile(round(camx+ixt),round(camy+iyt))
          
          
          
        end
        end
      end
      if il==3 then
        if t1["top"]~="none" then
          if gettileinfo(t1["top"],"texture")~="none" then
          if gettileinfo(t1["top"],"quad")~="none" then
            drawtop(round(camx+ixt),round(camy+iyt))
          end
          end
        end
      end
      if il==4 then
        tilename=nil
        biome=getbiome(round(camx+ixt),round(camy+iyt))
        if biome=="none" then tilename="stone" end
        if biome=="hotland" then tilename="hotstone" end
        if biome=="coldland" then tilename="coldstone" end
        if tilename~=nil then
          drawspecifictile(round(camx+ixt),round(camy+iyt),tilename,{1,1,1,1})
        end
      end
      if il==1 then
        if t1["back"]~="none" then
          if gettileinfo(t1["back"],"texture")~="none" then
          if gettileinfo(t1["back"],"quad")~="none" then
          if not gettileinfo(t1["tile"],"hideback") then
            drawback(round(camx+ixt),round(camy+iyt))
          end
          end
          end
        end
      end
    end
  end
  end
  end]]
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
