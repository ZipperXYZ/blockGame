function positiontoscreen(x,y)
  --camorientation=0
  x=cx+((x-camx))*camv
  y=cy-((y-camy))*camv
  --x,y=moveposition180(x,y,pointat180(0,0,((x-camx))*camv,((y-camy))*camv),dist(0,0,((x-camx))*camv,((y-camy))*camv))
  --xaa3=x
  --yaa3=y
  --x,y=moveposition180(0,0,pointat180(0,0,xaa3-camx,yaa3-camy)+camorientation,dist(0,0,xaa3-camx,yaa3-camy))
  --x=cx+((x))*camv
  --y=cy-((y))*camv
  --x=cx+x
  --y=cy-y
  return x,y
end
function screentoposition(x,y)
  x=((x-cx)/camv)+camx--
  y=(((cy-y))/camv)+camy--
  
  return x,y
end
function screentoposition2(x,y,camx2,camy2)
  x=((x-cx)/camv)+camx2--
  y=(((cy-y))/camv)+camy2--
  x=x-camx2
  y=y-camy2
  return x,y
end
function screentopos(x1,y1)
  x2=((x1-screenoffsetx)/tilesize)+camx--
  y2=(((screensizey-y1)-screenoffsety)/tilesize)+camy--
  
  return x2,y2
end
function roundify(x2,y2,x3,y3,distance1) --distance is probably between 0 and 1
  x1,y1=moveposition(0,0,math.random()*math.pi*2,distance1)
  x4=round(x2+(x1*x3))
  y4=round(y2+(y1*y3))
  return x4,y4
end
  function movetowards(x1,y1,x2,y2,move1)
   d1= pointatpi(x1,y1,x2,y2)
   x3,y3= movepositionpi(x1,y1,d1,move1)
    return x3,y3
    end
  function movepositionpi(x1,y1,angle1,move1)
    cos = math.cos(angle1)
    sin = math.sin(angle1)
    fx1 = x1 + move1 * cos
    fy1 = y1 + move1 * sin
    return fx1,fy1
  end
  function moveposition180(x1,y1,angle1,move1)
    angle1=(angle1*math.pi)/180
    cos = math.cos(angle1)
    sin = math.sin(angle1)
    fx1 = x1 + move1 * cos
    fy1 = y1 + move1 * sin
    return fx1,fy1
  end
  function movepositionreversex(x1,y1,angle1,move1)
    cos = math.cos(angle1)
    sin = math.sin(angle1)
    fx1 = x1 - move1 * cos
    fy1 = y1 + move1 * sin
    return fx1,fy1
  end
  function pointatpi(x1,y1,x2,y2)
   d1 =math.atan2(y2-y1,x2-x1) 
   return d1
  end
  function pointat180(x1,y1,x2,y2)
   d1 =(math.atan2(y2-y1,x2-x1)*180)/math.pi
   return d1
  end
  function limit(number,l1,l2)
  if number < l1 then number=l1 end
  if number > l2 then number=l2 end
  return number
  end
function round(x1)
  if x1-math.floor(x1)<0.5 then return math.floor(x1)
    else return math.ceil(x1) end
  end
function round2(value,precision)
  return (round(value*precision)/precision)
  end
function directionfluctuate(d,goal,amount)
  d=d%360
  goal=goal%360
  df=d
distclock=360
distanticlock=360
  if d>=goal then
  distanticlock=d-goal
  distclock=(goal+360)-d
else
  distclock=goal-d
  distanticlock=(d+360)-goal
  end
  
if distanticlock<distclock then
  df=d-distanticlock*amount
  else
  df=d+distclock*amount
  end

  return df
  end
function distancea(xi1,yi1,xi2,yi2,distance1)
  if math.sqrt(((xi1-xi2)^2)+((yi1-yi2)^2))<=distance1 then return 1 else return 0 end
    
end
function touch(xi1,yi1,xi2,yi2,distance1)
  if math.sqrt(((xi1-xi2)^2)+((yi1-yi2)^2))<=distance1 then return true else return false end
    
end
function touch2(xi1,yi1,xi2,yi2,size1,size2)
  if math.sqrt(((xi1-xi2)^2)+((yi1-yi2)^2))<=size1+size2 then return true else return false end
    
end
function touch3d2(xi1,yi1,xi2,yi2,h1,h2,size1,size2,he1,he2)
  if math.sqrt(((xi1-xi2)^2)+((yi1-yi2)^2))<=size1+size2 and ((h2>=h1 and h2<=h1+he1)or(h1>=h2 and h1<=h2+he2)) then return true else return false end
    
end
function nottouch(xi1,yi1,xi2,yi2,distance1)
  if math.sqrt(((xi1-xi2)^2)+((yi1-yi2)^2))<=distance1 then return false else return true end
    
end
function calculatedistance(xi1,yi1,xi2,yi2,distance1)
 if math.sqrt(((xi1-xi2)^2)+((yi1-yi2)^2))<=distance1 then return math.sqrt(((xi1-xi2)^2)+((yi1-yi2)^2)) end
    
end
function dist(xi1,yi1,xi2,yi2)
 return math.sqrt(((xi1-xi2)^2)+((yi1-yi2)^2))
    
end
function d180topi(d)
return d/180*math.pi
end
function circonference(r)
  return r*2*math.pi
  end
function moytable(table1)
  sum=0
  if #table1>2 then
  for i=1,#table1 do
  sum=sum+table1[i]
end
sum=sum/#table1
end
if sum==0 then sum=0.00001 end
return sum
end
function checkarena(x,y)
  inarena=true
  if x<0 or y<0 then inarena=false end
  if x>arenasizex or y>arenasizey then inarena=false end
  return inarena
end
function moveposition3dpi(x,y,h,angleground,anglehight,dist)
x = x + math.cos(angleground) * math.cos(anglehight)*dist
y = y + math.sin(angleground) * math.cos(anglehight)*dist
h = h + math.sin(anglehight) *dist
return x,y,h
end
function k(v1,v2,f)
  v=(v1*(1-f))+(v2*f)
  return v
end
function getk(v1,v2,f)
  v=1/(v2-v1)*(f-v1)
  return v
end
function gettimeloop(duration,multiplicator,loopable)
  if loopable then
    duration=duration/2
    if (gametime%(duration*2))>duration then i=(gametime%(duration*2))-duration else i=duration-(gametime%(duration*2)) end
    i=i*multiplicator
  else
    i=(gametime%duration)*multiplicator
    end
  return i
end
function gettimeloop2(duration,multiplicator,loopable,delay1)
  if loopable then
    duration=duration/2
    if ((gametime+delay1)%(duration*2))>duration then i=((gametime+delay1)%(duration*2))-duration else i=duration-((gametime+delay1)%(duration*2)) end
    i=i*multiplicator
  else
    i=((gametime+delay1)%duration)*multiplicator
    end
  return i
end
function checkifinscreen(x1,y1,size1)
  inscreen=false
  if  dist(x1,y1,camx,camy)<(size1)+1200/camv then
  inscreen=true
  end
  return inscreen
end
function nb(number1,pos1)
  number1=round(number1*pos1)/pos1
  return number1
end
function getrandomside(sides)
  number=math.ceil(math.random(#sides))
  if number<1 then number=1 end
  if number>#sides then number=#sides end
  side=sides[number]
  
  return side
end
function nextinlistroll(value1,list1)
  posinlist=0
  nextvalue=""
  if #list1>0 then
  for g66=1,#list1 do
  if list1[g66]==value1 then posinlist=g66 end
end
if posinlist<#list1 then nextvalue=list1[posinlist+1] else
nextvalue=list1[1] 
end

end

return nextvalue
end
function nextinlistrollreverse(value1,list1)
  posinlist=0
  nextvalue=""
  list2={}
  if #list1>0 then
    for g66=#list1,1,-1 do
  table.insert(list2,list1[g66])
  
  end
  end
  if #list2>0 then
  for g66=1,#list2 do
  if list2[g66]==value1 then posinlist=g66 end
end
if posinlist<#list2 then nextvalue=list2[posinlist+1] else
nextvalue=list2[1] 
end

end

return nextvalue
end
function getbooltext(bool)
 text="false"
 if bool then text="true" end
  
  return text
end
function normalisevector(xr,yr)
  --xr2=xr
  --yr2=yr
  --lenght=dist(0,0,xr,yr)
  --love.graphics.print(lenght,0,0)
  --xf=(xr2/lenght)
  --yf=(yr2/lenght)
  
  
  xr2=xr
  yr2=yr
 lenght=(dist(0,0,xr,yr))
 if lenght>1 then xr2,yr2=moveposition180(0,0,pointat180(0,0,xr,yr),1) end
  --love.graphics.print(lenght,0,0)
  xf=(xr2)
  yf=(yr2)
  
  return xf,yf
end
function checkifinlist(value1,list1)
  inside=false
  if #list1>0 then for j6=1,#list1 do
  if list1[j6]==value1 then inside=true end
  end end
  return inside
end
function pickrandomvalued(values)
  table1={}
  for iv=1,#values do
    if values[iv][2]>1 then
  if values[iv][2]>1000 then values[iv][2]=1000 end 
  for iv2=1,math.ceil(values[iv][2]) do
  table.insert(table1,values[iv][1])
  end end
  end
  t=round(math.random(#table1))
  if t<1 then t=1 end
  if t>#table1 then t=#table1 end
  return table1[t]
end
function pickrandomvaluedtriple(values)
  table1={}
  table2={}
  for iv=1,#values do
    if values[iv][2]>1 then
  if values[iv][2]>1000 then values[iv][2]=1000 end 
  for iv2=1,math.ceil(values[iv][2]) do
  table.insert(table1,values[iv][1])
  table.insert(table2,values[iv][3])
  end end
  end
  t=round(math.random(#table1))
  if t<1 then t=1 end
  if t>#table1 then t=#table1 end
  return table1[t],table2[t]
end
function randomvaluefromlist(values)
t=round(math.random(#values))
  if t<1 then t=1 end
  if t>#values then t=#values end
  return values[t]
end
function notrandomvaluefromlist(values,number1)
t=round(number1*#values)
  if t<1 then t=1 end
  if t>#values then t=#values end
  return values[t]
end
function checkindexequal(table1,value1)
  bool=false
  if checkindex(table1) then
  bool=table1==value1
  end
  return bool
end
function checkindexbool(table1)
  bool=false
  if checkindex(table1) then
  bool=table1
  end
  return bool
end
function checkindex(table1)
  indexpresent=false
  if table1~= nil then
  indexpresent=true
end
  return indexpresent
end