require "class/superClass"

TextParticle = SuperClass:extend()
TextParticle.className = "TextParticle"

--init()
function TextParticle:init(text,position, time,size, height,color,outlineColor,animationColor, flags)
    self.text = text
    self.position = position:copy() or Vector2(0,0)
    self.basePosition = position or Vector2(0,0)
    self.maxTime = time or 1
    self.size = size or 0.25
    self.height = height or 1
    self.color = color or {1,1,1,1}
    self.actualColor = {1,1,1,1}
    self.outlineColor = outlineColor or {0,0,0,1}
    self.actualOutlineColor = {0,0,0,1}
    self.animationColor = animationColor or {1,1,1,1}
    self.animationTime = 0.5
    self.fadeTime = 0.5
    self.time = 0

    if self.outlineColor == nil then self.outlineColor = {0,0,0,1} end
    if self.animationColor == nil then self.animationColor = {1,1,1,1} end
    if self.color == nil then self.color = {1,1,1,1} end

    self.flags = flags or {}

end

function TextParticle:update(dt)
    local die = false

    self.time = self.time + dt

    if self.time > self.maxTime then
        die = true
    end

    
    local lifespan = self.time / self.maxTime

    self.position.x = self.basePosition.x
    self.position.y = self.basePosition.y + self.height * lifespan^0.5


    self.actualColor = {self.color[1],self.color[2],self.color[3],self.color[4]}
    self.actualOutlineColor = {self.outlineColor[1],self.outlineColor[2],self.outlineColor[3],self.outlineColor[4]}

    if self.time < self.animationTime then
        self.actualColor[1] = k(self.actualColor[1],self.animationColor[1],1-self.time / self.animationTime)
        self.actualColor[2] = k(self.actualColor[2],self.animationColor[2],1-self.time / self.animationTime)
        self.actualColor[3] = k(self.actualColor[3],self.animationColor[3],1-self.time / self.animationTime)
        self.actualColor[4] = k(self.actualColor[4],self.animationColor[4],1-self.time / self.animationTime)
        self.actualOutlineColor[1] = k(self.actualOutlineColor[1],self.animationColor[1],1-self.time / self.animationTime)
        self.actualOutlineColor[2] = k(self.actualOutlineColor[2],self.animationColor[2],1-self.time / self.animationTime)
        self.actualOutlineColor[3] = k(self.actualOutlineColor[3],self.animationColor[3],1-self.time / self.animationTime)
        self.actualOutlineColor[4] = k(self.actualOutlineColor[4],self.animationColor[4],1-self.time / self.animationTime)
    end

    if self.time > self.maxTime - self.fadeTime then
        self.actualColor[4] = self.actualColor[4] * (1 - (self.time - (self.maxTime - self.fadeTime)) / self.fadeTime)
        self.actualOutlineColor[4] = self.actualOutlineColor[4] * (1 - (self.time - (self.maxTime - self.fadeTime)) / self.fadeTime)
    end


    return die
end

function TextParticle:draw()
    local x,y,size = world:getTileScreenPosition(self.position.x,self.position.y)
    local textSize = size * self.size

    love.graphics.setColor(self.actualOutlineColor)
    love.graphics.printf(self.text,x-200+1,y,400/textSize,"center",0,textSize,textSize)
    love.graphics.printf(self.text,x-200-2,y,400/textSize,"center",0,textSize,textSize)
    love.graphics.printf(self.text,x-200,y+1,400/textSize,"center",0,textSize,textSize)
    love.graphics.printf(self.text,x-200,y-1,400/textSize,"center",0,textSize,textSize)
    love.graphics.setColor(self.actualColor)
    love.graphics.printf(self.text,x-200,y,400/textSize,"center",0,textSize,textSize)
    --love.graphics.rectangle("fill",x,y,size/1,size/1)
    
end