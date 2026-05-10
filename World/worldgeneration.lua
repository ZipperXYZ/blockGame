function resetworld()
  --[[world={}
  entities={}
  camx=0
  camy=0
  realcamy=0
  realcamx=0
  worldseed=math.random()*100000]]
end
function generateworldupdate(dt)
  local totalChunkLoadDistanceX=(chunkloaddistance+(math.ceil(szx/camv/2/chunksize)))
  local totalChunkLoadDistanceY=(chunkloaddistance+(math.ceil(szy/camv/2/chunksize)))
  local centerX=(camx/chunksize)
  local centerY=(camy/chunksize)
  world:generate(centerX, centerY, totalChunkLoadDistanceX, totalChunkLoadDistanceY, false, nil)
  --[[totalchunkloaddistance=(chunkloaddistance+(math.ceil(szx/camv/2/chunksize)))
  --totalchunkloaddistance=(math.ceil(szx/camv/2/chunksize))-1
  if totalchunkloaddistance<1 then totalchunkloaddistance=1 end
  for ixload=-(totalchunkloaddistance), totalchunkloaddistance do
    for iyload=-(totalchunkloaddistance), totalchunkloaddistance do
      if not checkifchunkloaded((camx/chunksize)+ixload,(camy/chunksize)+iyload) then
        loadchunk((camx/chunksize)+ixload,(camy/chunksize)+iyload,"first")
      else
        loadchunk((camx/chunksize)+ixload,(camy/chunksize)+iyload,getchunkloadstep((camx/chunksize)+ixload,(camy/chunksize)+iyload))
      end
    end
  end]]
end
--[[function checkifchunkloaded(x,y)
  x=round(x)
  y=round(y)
  if world[x]== nil then return false end
  if world[x][y]== nil then return false end
  return true
end
function updatelightchunk(x,y)
  x=round(x)
  y=round(y)
  lightable=true
  if not checkifchunkloaded(x,y) then lightable=false end
  if not checkifchunkloaded(x+1,y) then lightable=false end
  if not checkifchunkloaded(x-1,y) then lightable=false end
  if not checkifchunkloaded(x,y+1) then lightable=false end
  if not checkifchunkloaded(x,y-1) then lightable=false end
  if not checkifchunkloaded(x-1,y-1) then lightable=false end
  if not checkifchunkloaded(x+1,y-1) then lightable=false end
  if not checkifchunkloaded(x+1,y+1) then lightable=false end
  if not checkifchunkloaded(x-1,y+1) then lightable=false end
  if lightable then
  for ix=1,chunksize do
    for iy=1,chunksize do
      if gettileinfo(world[x][y]["t"][ix][iy]["tile"],"type")=="solid" then
        xworldpos,yworlpos=getworldpositionchunktile(x,y,ix,iy)
        closest=getclosestnonsolidtile(xworldpos,yworlpos,lightreach)
        world[x][y]["t"][ix][iy]["light"]={1-(closest-1)/lightreach,1-(closest-1)/lightreach,1-(closest-1)/lightreach,1}
      end
    end
  end
  end
end
function getclosestnonsolidtile(x,y,max)
  closest=99
  for il=1,max do
    --t1=gettile(x+il,y) if gettileinfo(t1["tile"],"type")~="solid" then closest=il return closest end
    --t1=gettile(x-il,y) if gettileinfo(t1["tile"],"type")~="solid" then closest=il return closest end
    --t1=gettile(x,y-il) if gettileinfo(t1["tile"],"type")~="solid" then closest=il return closest end
    --t1=gettile(x,y+il) if gettileinfo(t1["tile"],"type")~="solid" then closest=il return closest end
    for il2=0,il do
      t1=gettile(x+il-il2,y-il2) if gettileinfo(t1["tile"],"type")~="solid" then closest=il return closest end  --
      t1=gettile(x-il2,y-il+il2) if gettileinfo(t1["tile"],"type")~="solid" then closest=il return closest end
      t1=gettile(x-il+il2,y+il2) if gettileinfo(t1["tile"],"type")~="solid" then closest=il return closest end
      t1=gettile(x+il2,y+il-il2) if gettileinfo(t1["tile"],"type")~="solid" then closest=il return closest end
    end
  end
  return closest
end
function getchunkloadstep(x,y)
  step="ng"--not generated
  x=round(x)
  y=round(y)
  if checkifchunkloaded(x,y) then
    step=world[x][y]["s"]
  end
  return step
end
function neighborchunksloadcheck(x,y,step1)
  loadedenough=true
  neighborchunks={}
  neighborchunks[1]={["x"]=x+1,["y"]=y+1}
  neighborchunks[2]={["x"]=x+1,["y"]=y}
  neighborchunks[3]={["x"]=x+1,["y"]=y-1}
  neighborchunks[4]={["x"]=x,["y"]=y-1}
  neighborchunks[5]={["x"]=x-1,["y"]=y-1}
  neighborchunks[6]={["x"]=x-1,["y"]=y}
  neighborchunks[7]={["x"]=x-1,["y"]=y+1}
  neighborchunks[8]={["x"]=x,["y"]=y+1}
  for ich=1,#neighborchunks do
    c1=getchunkloadstep(neighborchunks[ich]["x"],neighborchunks[ich]["y"])
    if step1=="stone" then if checkifinlist(c1,{"ng","first"}) then loadedenough=false end end
    if step1=="stone2" then if checkifinlist(c1,{"ng","first","stone"}) then loadedenough=false end end
    if step1=="grass" then if checkifinlist(c1,{"ng","first","stone","stone2"}) then loadedenough=false end end
    if step1=="ores" then if checkifinlist(c1,{"ng","first","stone","stone2","grass"}) then loadedenough=false end end
  end
  return loadedenough
end
function loadchunk(x,y,step)
  x=round(x)
  y=round(y)
  if not checkifchunkloaded(x,y) then step="first" end 
    if step=="first" then
    if world[x]== nil then world[x]={} end
    if world[x][y]== nil then world[x][y]={} world[x][y]["s"]="ng" world[x][y]["t"]={} end
    for ix=1,chunksize do
      
      world[x][y]["t"][ix]={}
      for iy=1,chunksize do
        world[x][y]["t"][ix][iy]=generateterraintile(x*chunksize+ix,y*chunksize+iy)
        
        
      end
    end
    world[x][y]["s"]="stone"
  end
  
  if step=="grass" then if neighborchunksloadcheck(x,y,"grass") then
    for ix=1,chunksize do
      for iy=1,chunksize do
        xworldpos,yworlpos=getworldpositionchunktile(x,y,ix,iy)
        t1=gettile(xworldpos,yworlpos)
        
        if checkifinlist(t1["tile"],{"dirt","stone"}) then
          if not (love.math.noise(xworldpos/20,yworlpos/20,worldseed+800)>0+(yworlpos/(worlddeepnessprogression*3))+0.85) then
            world[x][y]["t"][ix][iy]["top"]="grass"
          end
        end
        if checkifinlist(world[x][y]["t"][ix][iy]["top"],{"grass"}) then
          if (love.math.noise(xworldpos/80,yworlpos/80,worldseed-122)>0.65) then
            world[x][y]["t"][ix][iy]["top"]="wheatgrass"
          end
        end
        if checkifinlist(t1["tile"],{"dirt","stone","darkstone"}) then
          if (not (love.math.noise(xworldpos/20,yworlpos/20,worldseed+520)<0+(yworlpos/(worlddeepnessprogression*5))+0.85)) and love.math.noise(xworldpos/40,yworlpos/40,worldseed+585)<0.35 then
            world[x][y]["t"][ix][iy]["top"]="purplegrass"
          end
        end
        if checkifinlist(t1["tile"],tilelists["stones"]) then
          if (not (love.math.noise(xworldpos/20,yworlpos/20,worldseed+455)<0+(yworlpos/(worlddeepnessprogression*6))+1.2)) and love.math.noise(xworldpos/90,yworlpos/90,worldseed+588)<0.3 then
            world[x][y]["t"][ix][iy]["top"]="shadowgrass"
          end
        end
      end
    end
    world[x][y]["s"]="ores" 
  end end
  
  if step=="ores" then if neighborchunksloadcheck(x,y,"ores") then
    for ix=1,chunksize do
      for iy=1,chunksize do
        xworldpos,yworlpos=getworldpositionchunktile(x,y,ix,iy)
        t1=gettile(xworldpos,yworlpos)
        
        if checkifinlist(t1["tile"],tilelists["stones"]) then
          if (not (love.math.noise(xworldpos/20,yworlpos/20,worldseed+452)<0+(yworlpos/(worlddeepnessprogression*20)+0.75))) and love.math.noise(xworldpos/6,yworlpos/12,worldseed+588)<0.2 then
            world[x][y]["t"][ix][iy]["top"]="diamond"
          end
        end
      end
    end
    updatelightchunk(x,y)
    world[x][y]["s"]="done" 
  end end
  
  if step=="stone" then if neighborchunksloadcheck(x,y,"stone") then
    for ix=1,chunksize do
      for iy=1,chunksize do
        xworldpos,yworlpos=getworldpositionchunktile(x,y,ix,iy)
        t1=gettile(xworldpos,yworlpos)
        if love.math.noise(xworldpos/14,yworlpos/14,worldseed-608)<0.6 then
          world[x][y]["t"][ix][iy]["back"]="dirt_wall"
        end
        if love.math.noise(xworldpos/15,yworlpos/30,worldseed+100)>0+(-yworlpos/30) then
          world[x][y]["t"][ix][iy]["back"]="none"
        end
      end
    end
    for ix=1,chunksize do
      for iy=1,chunksize do
        xworldpos,yworlpos=getworldpositionchunktile(x,y,ix,iy)
        t1=gettile(xworldpos,yworlpos)
        
        if t1["back"]=="dirt_wall" then
          if love.math.noise(xworldpos/8,yworlpos/8,worldseed+600)>0+(yworlpos/(worlddeepnessprogression*3))+0.75 then
            if not (love.math.noise(xworldpos/45,yworlpos/30,worldseed+800)>0.7) then
            world[x][y]["t"][ix][iy]["back"]="stone_wall"
          end end
        end
        if t1["tile"]=="dirt" then
          if love.math.noise(xworldpos/8,yworlpos/8,worldseed+600)>0+(yworlpos/(worlddeepnessprogression*3))+0.75 then
            if not (love.math.noise(xworldpos/45,yworlpos/30,worldseed+800)>0.7) then
            world[x][y]["t"][ix][iy]["tile"]="stone"
          end end
        end
      end
    end
    
    world[x][y]["s"]="stone2" 
  end end
  
  if step=="stone2" then if neighborchunksloadcheck(x,y,"stone2") then
    for ix=1,chunksize do
      for iy=1,chunksize do
        xworldpos,yworlpos=getworldpositionchunktile(x,y,ix,iy)
        t1=gettile(xworldpos,yworlpos)
        
        
        
        if checkifinlist( t1["tile"],tilelists["stones"]) then
          --if love.math.noise(xworldpos/35,yworlpos/35,worldseed-580)>0+(yworlpos/(worlddeepnessprogression*5))+2 then if (love.math.noise(xworldpos/130,yworlpos/130,worldseed+212)>0.15) then
          if getbiome(xworldpos,yworlpos)=="hotland" then
              world[x][y]["t"][ix][iy]["tile"]="hotstone"
          end --end
        end
        if checkifinlist( t1["back"],tilelists["stones"]) then
          --if love.math.noise(xworldpos/35,yworlpos/35,worldseed-580)>0+(yworlpos/(worlddeepnessprogression*5))+2 then if (love.math.noise(xworldpos/130,yworlpos/130,worldseed+212)>0.15) then
          if getbiome(xworldpos,yworlpos)=="hotland" then
              world[x][y]["t"][ix][iy]["back"]="hotstone_wall"
          end --end
        end
        if checkifinlist( t1["tile"],tilelists["stones"]) then
          --if love.math.noise(xworldpos/35,yworlpos/35,worldseed-580)>0+(yworlpos/(worlddeepnessprogression*5))+1.4 then if (love.math.noise(xworldpos/70,yworlpos/75,worldseed+282)>0.45) or (love.math.noise(xworldpos/70,yworlpos/75,worldseed+282)<0.2) then
          if getbiome(xworldpos,yworlpos)=="coldland" then
              world[x][y]["t"][ix][iy]["tile"]="coldstone"
          end --end
        end
        if checkifinlist( t1["back"],tilelists["stones"]) then
          --if love.math.noise(xworldpos/35,yworlpos/35,worldseed-580)>0+(yworlpos/(worlddeepnessprogression*5))+1.4 then if (love.math.noise(xworldpos/70,yworlpos/75,worldseed+282)>0.45) or (love.math.noise(xworldpos/70,yworlpos/75,worldseed+282)<0.2) then
          if getbiome(xworldpos,yworlpos)=="coldland" then
              world[x][y]["t"][ix][iy]["back"]="coldstone_wall"
          end --end
        end
        if checkifinlist( t1["tile"],tilelists["stones"]) then
          if love.math.noise(xworldpos/35,yworlpos/35,worldseed-580)>0+(yworlpos/(worlddeepnessprogression*5))+1.8 then
              if (love.math.noise(xworldpos/8,yworlpos/8,worldseed+242)>0.72) or (love.math.noise(xworldpos/8,yworlpos/8,worldseed+242)<0.1) then
              world[x][y]["t"][ix][iy]["tile"]="lightstone"
          end end
        end
        
        if t1["tile"]=="stone" then
          
          if love.math.noise(xworldpos/22,yworlpos/22,worldseed+950)>0+(yworlpos/(worlddeepnessprogression*5))+0.75 then
            if (love.math.noise(xworldpos/8,yworlpos/18,worldseed+900)>0.725) or (love.math.noise(xworldpos/8,yworlpos/18,worldseed+900)<0.275) then
            world[x][y]["t"][ix][iy]["tile"]="darkstone"
          end end
          
        end
        if checkifinlist( t1["tile"],{"stone","darkstone"}) then
          if love.math.noise(xworldpos/35,yworlpos/35,worldseed+975)>0+(yworlpos/(worlddeepnessprogression*5))+1 then
              if (love.math.noise(xworldpos/35,yworlpos/12,worldseed+505)>0.75) or (love.math.noise(xworldpos/35,yworlpos/12,worldseed+505)<0.275) then
              world[x][y]["t"][ix][iy]["tile"]="palestone"
          end end
        end
        if checkifinlist( t1["tile"],tilelists["stones"]) then
          if love.math.noise(xworldpos/35,yworlpos/35,worldseed-580)>0+(yworlpos/(worlddeepnessprogression*5))+1.2 then
              if (love.math.noise(xworldpos/8,yworlpos/12,worldseed+545)>0.75) or (love.math.noise(xworldpos/8,yworlpos/12,worldseed+545)<0.2) then
              world[x][y]["t"][ix][iy]["tile"]="ancientstone"
          end end
        end
        
        
      end
    end
    world[x][y]["s"]="grass" 
  end end
end
function noise(x,y,z,w,divider)
  if z>0 or z<0 then
  if w>0 or w<0 then
    return love.math.noise(x/divider,y/divider,z/divider,w/divider)
  else
    return love.math.noise(x/divider,y/divider,z/divider)
  end
 else
    return love.math.noise(x/divider,y/divider)
  end
end
function generateterraintile(tilex,tiley)
  tile={}
  tile["tile"]="air"
  tile["top"]="none" 
  tile["back"]="none" 
  tile["light"]={1,1,1,1} 
  if love.math.noise(tilex/20,tiley/20,worldseed)<0.25 then
    tile["tile"]="air"
    else
    tile["tile"]="dirt"
  end
  if love.math.noise(tilex/40,tiley/40,worldseed-100)<0.3 then
    tile["tile"]="air"
  end
  if love.math.noise(tilex/12,tiley/12,worldseed-500)<0.35 then
    tile["tile"]="air"
  end
  if love.math.noise(tilex/5,tiley/5,worldseed-600)<0.35 and love.math.noise(tilex/15,tiley/15,worldseed+100)<0+(tiley/(worlddeepnessprogression*2))+1 then
    tile["tile"]="air"
  end
  if love.math.noise(tilex/25,tiley/90,worldseed-200)<0.4 and love.math.noise(tilex/25,tiley/90,worldseed-200)>0.36 then
    tile["tile"]="air"
  end
  if love.math.noise(tilex/15,tiley/30,worldseed+100)>0+(-tiley/20) then
    tile["tile"]="air"
    
  end
  
  --if math.random()>0.3 then tile["tile"]="dirt" end
  --if math.random()>0.8 then tile["tile"]="stone" end
  
  
  
  return tile
end
function getworldpositionchunktile(chunkx,chunky,ix,iy)
  
  xworldpos=chunkx*chunksize+ix-1 
  yworlpos=chunky*chunksize+iy-1
  
  return xworldpos,yworlpos
end
function gettileworldposition(tilex,tiley)
  tilex=round(tilex)
  tiley=round(tiley)
  chunkxpos=math.floor(tilex/chunksize)
  chunkypos=math.floor(tiley/chunksize)
  --tileposx=((tilex-1)%chunksize)+1
  tileposx=((tilex)%chunksize)+1
  --tileposy=((tiley-1)%chunksize)+1
  tileposy=((tiley)%chunksize)+1
  
  return chunkxpos,chunkypos,tileposx,tileposy
end
function replacetile(tilex,tiley,newtile)
  xc1,yc1,x1,y1=gettileworldposition(tilex,tiley)
  
  if world[xc1]==nil then
    return false
  else
    if world[xc1][yc1]==nil then
      return false
    else
      if world[xc1][yc1]==nil then
        return false
      else
        if world[xc1][yc1]["t"][x1]==nil then
          return false
        else
          if world[xc1][yc1]["t"][x1][y1]==nil then
            return false
          else
            world[xc1][yc1]["t"][x1][y1]=newtile
            updatelightchunk(xc1,yc1)
            updatelightchunk(xc1+1,yc1)
            updatelightchunk(xc1-1,yc1)
            updatelightchunk(xc1,yc1+1)
            updatelightchunk(xc1,yc1-1)
            updatelightchunk(xc1+1,yc1+1)
            updatelightchunk(xc1+1,yc1-1)
            updatelightchunk(xc1-1,yc1-1)
            updatelightchunk(xc1-1,yc1+1)
            return true
          end
        end
      end
    end
  end
end
function getinfofromworldtile()
  
  
  
end
function gettile(tilex,tiley)
  tilex=round(tilex)
  tiley=round(tiley)
  tile={}
  tile["tile"]="air"
  tile["top"]="none"
  tile["light"]={1,1,1,1}
  tile["outofbounds"]=false
  xc1,yc1,x1,y1=gettileworldposition(tilex,tiley)
  if world[xc1]==nil then
    tile["outofbounds"]=true
  else
    if world[xc1][yc1]==nil then
      tile["outofbounds"]=true
    else
      if world[xc1][yc1]==nil then
        tile["outofbounds"]=true
      else
        if world[xc1][yc1]["t"][x1]==nil then
          tile["outofbounds"]=true
        else
          if world[xc1][yc1]["t"][x1][y1]==nil then
            tile["outofbounds"]=true
          else
            tile["tile"]=world[xc1][yc1]["t"][x1][y1]["tile"]
            tile["top"]=world[xc1][yc1]["t"][x1][y1]["top"]
            tile["back"]=world[xc1][yc1]["t"][x1][y1]["back"]
            tile["light"]=world[xc1][yc1]["t"][x1][y1]["light"]
          end
        end
      end
    end
  end
  return tile
end
function getbiome(x,y)
    biome = "none"

    nearcenter = 0

    closestDist = 999999
    secondDist = 999999

    op1 = love.math.noise(
        x/biomesize,
        y/biomesize,
        worldseed-5
    )

    op2 = love.math.noise(
        x/(biomesize*1.2),
        y/(biomesize/1.2),
        worldseed-10
    )

    for ib=1,#biomelist do

        distance1 = dist(
            op1,
            op2,
            biomelist[ib]["option1"],
            biomelist[ib]["option2"]
        ) ^ biomelist[ib]["likeness"]

        depth = (-y/worlddeepnessprogression)

        minDepth = biomelist[ib]["deepnessmin"]
        maxDepth = biomelist[ib]["deepnessmax"]
        smooth = biomelist[ib]["deepnesssmooth"]

        enter = (depth - minDepth) / smooth
        exit = (maxDepth - depth) / smooth

        if enter < 0 then enter = 0 end
        if enter > 1 then enter = 1 end

        if exit < 0 then exit = 0 end
        if exit > 1 then exit = 1 end

        ymulti = math.min(enter, exit)

        if ymulti <= 0 then
            distance1 = 999999
        else
            distance1 = distance1 / ymulti
        end

        -- track 2 closest biomes
        if distance1 < closestDist then

            secondDist = closestDist

            closestDist = distance1

            biome = biomelist[ib]["name"]

        elseif distance1 < secondDist then

            secondDist = distance1

        end
    end

    -- biome dominance calculation
    -- 0 = edge
    -- 1 = center

    nearcenter = 1 - (closestDist / secondDist)

    if nearcenter < 0 then nearcenter = 0 end
    if nearcenter > 1 then nearcenter = 1 end

    return biome, nearcenter
end]]