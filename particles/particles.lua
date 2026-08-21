require "class/superClass"

Particle = SuperClass:extend()
Particle.className = "Particle"

--init()
function Particle:init(name,position, color,timer,motion, flags)
    self.name = name or "none"
    self.color = color or {1,0,1,1}
    self.startColor = CopyAll(self.color)
    self.colorAmount = 1
    self.timer = timer or 1
    self.timerStart = self.timer or 1
    self.motion = motion or "dust"
    self.position = position or Vector2(0,0)

    self.flags = flags or {}

    self.timeAlive = 0
    self.appearIn = 0
    if type(self.flags.appearIn) == "number" then
        self.appearIn = self.flags.appearIn
    end
    self.weight = self.flags.weight or 1
    self.hasCollisions = self.flags.hasCollisions or true
    self.hasGravity = self.flags.hasGravity or true
    self.stuck = false
    self.noCollisionsTimer = self.flags.noCollisionsTimer or 0.3
    self.velocity = self.flags.velocity or Vector2(0,0)

    self.size = self.flags.size or 0.125
    self.sizeMotion = self.flags.sizeMotion or 0

    self.appearanceType = self.flags.appearanceType or "dot"


    self.xpValue = self.flags.xpValue or 0
    self.coinValue = self.flags.coinValue or 0
    if self.flags.lightColor ~= nil then self.lightColor = self.flags.lightColor end
    if self.flags.flashColor ~= nil then self.flashColor = self.flags.flashColor end
    self.flashTime = self.flags.flashTime or 1
    
    if self.flags.color2 ~= nil then self.color2 = self.flags.color2 self.colorAmount = self.colorAmount + 1 end
    if self.flags.color3 ~= nil then self.color3 = self.flags.color3 self.colorAmount = self.colorAmount + 1 end
    if self.flags.color4 ~= nil then self.color4 = self.flags.color4 self.colorAmount = self.colorAmount + 1 end
    if self.flags.color5 ~= nil then self.color5 = self.flags.color5 self.colorAmount = self.colorAmount + 1 end

end

function Particle:update(dt)
    local die = false
    if self.appearIn > 0 then
        self.appearIn = self.appearIn - dt
        return die
    end

    self.timer = self.timer - dt
    self.timeAlive = self.timeAlive + dt
    if self.timer<0 then die = true end

    self.size = self.size + self.sizeMotion * dt

    self.noCollisionsTimer = self.noCollisionsTimer - dt

    
    if self.noCollisionsTimer <= 0 and self.hasCollisions then
        if world:getTile(self.position.x,self.position.y,"tiles").type == "solid" then
            self.stuck = true
        else
            self.stuck = false
        end
        
    end


    if self.colorAmount > 1 then
        local progression = (getk(self.timerStart,0,self.timer) * (self.colorAmount-1)) + 1
        local colorPrevious = math.floor(progression)
        local colorNext = math.ceil(progression)

        local colorPreviousName = "color"..colorPrevious
        if colorPrevious < 2 then colorPreviousName = "startColor" end
        if colorPrevious > self.colorAmount then colorPreviousName = "color"..self.colorAmount end

        local colorNextName = "color"..colorNext
        if colorNext < 2 then colorNextName = "startColor" end
        if colorNext > self.colorAmount then colorNextName = "color"..self.colorAmount end

        local localProgression = getk(math.floor(progression),math.ceil(progression),progression)

        self.color = {
            k(self[colorPreviousName][1],self[colorNextName][1],localProgression),
            k(self[colorPreviousName][2],self[colorNextName][2],localProgression),
            k(self[colorPreviousName][3],self[colorNextName][3],localProgression),
            k(self[colorPreviousName][4],self[colorNextName][4],localProgression),
        }

    end


    if self.motion == "fire" then
        self.velocity:move(90,dt*self.weight*2)

        self.velocity.x = k(self.velocity.x,0 + math.sin(gametime/3)*2*self.weight,dt*0.5*self.weight)
        self.velocity.y = k(self.velocity.y,0,dt*0.5*self.weight)

        if self.stuck then
            self.velocity.x = 0
            self.velocity.y = 0
        end
    end

    if self.motion == "dust" then

        if self.hasGravity then
            self.velocity:move(-90,dt*self.weight*10)
        end

        
            self.velocity.x = k(self.velocity.x,0,dt*0.5*self.weight)
            self.velocity.y = k(self.velocity.y,0,dt*0.5*self.weight)
        

        if self.stuck then
            self.velocity.x = 0
            self.velocity.y = 0
        end

    end

    if self.motion == "floating" then

        self.velocity.x = k(self.velocity.x,0,dt*0.15*self.weight)
        self.velocity.y = k(self.velocity.y,0,dt*0.15*self.weight)

    end


    if (self.xpValue > 0 and self.timeAlive > 1.6) or (self.coinValue > 0 and self.timeAlive > 0.8)  then
        die = self:xpUpdate(dt,die)
    end


    self.position.x = self.position.x + self.velocity.x * dt
    self.position.y = self.position.y + self.velocity.y * dt



    return die
end

function Particle:xpUpdate(dt,die)

    if #entities > 0 then
        for i = 1, #entities do
            local entity = entities[i]
            if self.position:distance(entity.position) < 20 then
                self.position:move(self.position:angle(entity.position),dt*9*(1-((self.position:distance(entity.position))/20))^3)
            end
            if self.position:distance(entity.position) < entity.size then
                if self.xpValue > 0 then
                    entity:giveXp(self.xpValue)
                end
                if self.coinValue > 0 then
                    entity.money = entity.money + self.coinValue
                    if self.coinValue >= 1 then
                        world:spawnTextParticle((round(self.coinValue)).."$",self.position:copy(),nil,nil,nil,{1,1,0,1},{0,0,0,1})
                    else
                        world:spawnTextParticle((round(self.coinValue*100)).."¢",self.position:copy(),nil,nil,nil,{0.6,0.6,0.65,1},{0,0,0,1})
                    end
                end
                self.xpValue = 0
                self.coinValue = 0
                die = true
            end
        end
    end

    return die
end

function Particle:draw()
    if not (self.appearIn > 0) then
        local x,y,size = world:getTileScreenPosition(round(self.position.x*8)/8,round(self.position.y*8)/8)

        love.graphics.setColor(self.color[1],self.color[2],self.color[3],self.color[4]*maximum(self.timer,1))

        if self.flags.flashColor ~= nil then
            local value = math.sin((self.timeAlive/self.flashTime)*math.pi*2)
            if value > 0 then
                love.graphics.setColor(k(self.color[1],self.flashColor[1],value),k(self.color[2],self.flashColor[2],value),k(self.color[3],self.flashColor[3],value),k(self.color[4],self.flashColor[4],value)*maximum(self.timer,1))
            end
        end


        if self.appearanceType == "dot" then

            love.graphics.rectangle("fill",x,y,size/1,size/1)

            if self.lightColor ~= nil then
                love.graphics.setColor(self.lightColor[1],self.lightColor[2],self.lightColor[3],self.lightColor[4]*maximum(self.timer,1))

                if self.flags.flashColor ~= nil then
                    local value = math.sin((self.timeAlive/self.flashTime)*math.pi*2)
                    if value > 0 then
                        love.graphics.setColor(k(self.lightColor[1],self.flashColor[1],value),k(self.lightColor[2],self.flashColor[2],value),k(self.lightColor[3],self.flashColor[3],value),k(self.lightColor[4],self.flashColor[4],value)*maximum(self.timer,1))
                    end
                end

                love.graphics.rectangle("fill",x+size,y,size/1,size/1)
                love.graphics.rectangle("fill",x-size,y,size/1,size/1)
                love.graphics.rectangle("fill",x,y+size,size/1,size/1)
                love.graphics.rectangle("fill",x,y-size,size/1,size/1)
            end
        end

        if self.appearanceType == "circle" then
            
            love.graphics.setLineWidth(size/1)
            love.graphics.circle("line",x,y,self.size*camv)
            --love.graphics.rectangle("fill",x,y,size/1,size/1)

            if self.lightColor ~= nil then
                love.graphics.setColor(self.lightColor[1],self.lightColor[2],self.lightColor[3],self.lightColor[4]*maximum(self.timer,1))

                if self.flags.flashColor ~= nil then
                    local value = math.sin((self.timeAlive/self.flashTime)*math.pi*2)
                    if value > 0 then
                        love.graphics.setColor(k(self.lightColor[1],self.flashColor[1],value),k(self.lightColor[2],self.flashColor[2],value),k(self.lightColor[3],self.flashColor[3],value),k(self.lightColor[4],self.flashColor[4],value)*maximum(self.timer,1))
                    end
                end

                love.graphics.circle("line",x+size,y,self.size*camv)
                love.graphics.circle("line",x-size,y,self.size*camv)
                love.graphics.circle("line",x,y+size,self.size*camv)
                love.graphics.circle("line",x,y-size,self.size*camv)
            end
        end

        
    end
end