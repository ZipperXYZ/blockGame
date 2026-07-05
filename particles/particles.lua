require "class/superClass"

Particle = SuperClass:extend()
Particle.className = "Particle"

--init()
function Particle:init(name,position, color,timer,motion, flags)
    self.name = name or "none"
    self.color = color or {1,0,1,1}
    self.timer = timer or 1
    self.timerStart = timerStart or 1
    self.motion = motion or "dust"
    self.position = position or Vector2(0,0)

    self.flags = flags or {}

    self.weight = self.flags.weight or 1
    self.hasCollisions = self.flags.hasCollisions or true
    self.hasGravity = self.flags.hasGravity or true
    self.stuck = false
    self.noCollisionsTimer = self.flags.noCollisionsTimer or 0.3
    self.velocity = self.flags.velocity or Vector2(0,0)

    self.appearanceType = self.flags.appearanceType or "dot"



end

function Particle:update(dt)
    local die = false

    self.timer = self.timer - dt
    if self.timer<0 then die = true end

    self.noCollisionsTimer = self.noCollisionsTimer - dt

    
    if self.noCollisionsTimer <= 0 and self.hasCollisions then
        if world:getTile(self.position.x,self.position.y,"tiles").type == "solid" then
            self.stuck = true
        else
            self.stuck = false
        end
        
    end


    if self.hasGravity then
        self.velocity:move(-90,dt*self.weight*10)
    end

    if self.motion == "dust" then
        self.velocity.x = k(self.velocity.x,0,dt*0.5*self.weight)
        self.velocity.y = k(self.velocity.y,0,dt*0.5*self.weight)
    end

    if self.stuck then
        self.velocity.x = 0
        self.velocity.y = 0
    end


    self.position.x = self.position.x + self.velocity.x * dt
    self.position.y = self.position.y + self.velocity.y * dt



    return die
end

function Particle:draw()
    local x,y,size = world:getTileScreenPosition(round(self.position.x*8)/8,round(self.position.y*8)/8)

    love.graphics.setColor(self.color[1],self.color[2],self.color[3],self.color[4]*maximum(self.timer,1))
    love.graphics.rectangle("fill",x,y,size/1,size/1)
    
end