require "class/superClass"

Sprite = SuperClass:extend()
Sprite.className = "Sprite"

--init()
function Sprite:init(name, texture, spriteData, flags)
    self.name = name or "none"
    self.texture = textures["textures"][texture]
    --self.quadName = quadName or "none"
    self.flags = flags or {}
    self.mirrorable = self.flags["mirrorable"] or true
    self.baseColor = self.flags["color"] or {1,1,1,1}
    self.spriteData = spriteData or {["parts"]={}}
    self.quads = {}
    self.parts = self.spriteData["parts"] or {}

    --print("spritecreate : "..self.name)
    --print("spritecreate #parts : "..#self.spriteData["parts"])
    if #self.spriteData["parts"]>0 then 
        for i=1,#self.spriteData["parts"] do
            --print("spritecreate1".." part : "..i..self.spriteData["parts"][i])
            if self.spriteData[self.spriteData["parts"][i]] ~= nil then
                print("1")
                local spriteName = self.spriteData["parts"][i]
                if self.spriteData[spriteName]["type"] == nil then self.spriteData[spriteName]["type"] = "repeat" end
                if self.spriteData[spriteName]["timePerFrame"] == nil then self.spriteData[spriteName]["timePerFrame"] = 0.25 end
                if self.spriteData[spriteName]["gridMultiplication"] == nil then self.spriteData[spriteName]["gridMultiplication"] = 8 end
                if self.spriteData[spriteName]["spriteSize"] == nil then self.spriteData[spriteName]["spriteSize"] = {1,1} end
                if self.spriteData[spriteName]["spriteCenter"] == nil then self.spriteData[spriteName]["spriteCenter"] = {0.5,0.5} end
                if self.spriteData[spriteName]["quads"] == nil then self.spriteData[spriteName]["quads"] = {} end
                if #self.spriteData[spriteName]["quads"]>0 then
                    for i2=1,#self.spriteData[spriteName]["quads"] do
                        self.quads[spriteName..i2] = love.graphics.newQuad(
                            (self.spriteData[spriteName]["quads"][i2][1]*self.spriteData[spriteName]["gridMultiplication"]),
                            (self.spriteData[spriteName]["quads"][i2][2]*self.spriteData[spriteName]["gridMultiplication"]),
                            (self.spriteData[spriteName]["spriteSize"][1]*self.spriteData[spriteName]["gridMultiplication"]),
                            (self.spriteData[spriteName]["spriteSize"][2]*self.spriteData[spriteName]["gridMultiplication"]),
                            self.texture
                        )
                    end
                end
            end
        end
    end

    --[[if (not textures["sprites"][self.quadName]) and self.quadName ~= "none" then
        textures["sprites"][self.quadName] = love.graphics.newQuad(
            self.flags["newQuad"][1] * self.flags["newQuad"][5]
            , self.flags["newQuad"][2] * self.flags["newQuad"][5]
            , self.flags["newQuad"][3] * self.flags["newQuad"][5]
            , self.flags["newQuad"][4] * self.flags["newQuad"][5]
            , textures["textures"][self.textureName])
    end]]
end

function Sprite:draw(animation,animationTime,direction,x,y,sx,sy,color)
    --return textures["sprites"][self.quadName]
    if color == nil then color = {1,1,1,1} end
    if direction == nil then color = "right" end
    if not self.mirrorable then direction = "right" end
    --print("draw2")

    love.graphics.setColor(color[1]*self.baseColor[1],color[2]*self.baseColor[2],color[3]*self.baseColor[3],color[4]*self.baseColor[4])
    
    if self.spriteData[animation] ~= nil then
        --print("draw3")
        local frameNumber = math.ceil(animationTime/self.spriteData[animation]["timePerFrame"])
        local maxFrame = #self.spriteData[animation]["quads"]
        if self.spriteData[animation]["type"] == "still" then frameNumber = 1 end
        if self.spriteData[animation]["type"] == "hold" and frameNumber>maxFrame then frameNumber = maxFrame end
        if (self.spriteData[animation]["type"] == "repeat" 
            or self.spriteData[animation]["type"] == "repeat&needsToEnd") 
                and frameNumber>maxFrame then 
            frameNumber = ((frameNumber-1) % maxFrame)+1
        end
        if frameNumber>maxFrame then frameNumber=maxFrame end
        if frameNumber<1 then frameNumber=1 end

        if direction == "right" then
            
        love.graphics.draw(self.texture
            ,self.quads[animation..frameNumber]
            ,x
            ,y
            ,0
            ,sx
            ,sy
            ,self.spriteData[animation]["spriteCenter"][1] * self.spriteData[animation]["gridMultiplication"]
            ,self.spriteData[animation]["spriteCenter"][2] * self.spriteData[animation]["gridMultiplication"] 
            )
        else

            love.graphics.draw(self.texture
            ,self.quads[animation..frameNumber]
            ,x
            ,y
            ,0
            ,-sx
            ,sy
            ,self.spriteData[animation]["spriteCenter"][1] * self.spriteData[animation]["gridMultiplication"]
            ,self.spriteData[animation]["spriteCenter"][2] * self.spriteData[animation]["gridMultiplication"] 
            )
        end

    end
end

