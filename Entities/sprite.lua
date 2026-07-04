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
    self.type = self.flags.type or "multipleAnimations"
    self.baseColor = self.flags["color"] or {1,1,1,1}
    self.spriteData = spriteData or {["parts"]={}}
    self.quads = {}
    self.parts = self.spriteData["parts"] or {}
    self.setupItem = self.flags["setupItem"] or false


    if self.type == "singleImage" then
        

        if self.spriteData ~= nil then
            if self.spriteData["gridMultiplication"] == nil then self.spriteData["gridMultiplication"] = 8 end
            if self.spriteData["spriteSize"] == nil then self.spriteData["spriteSize"] = {1,1} end
            if self.spriteData["spriteCenter"] == nil then self.spriteData["spriteCenter"] = {0.5,0.5} end
            if self.spriteData["quads"] == nil then self.spriteData["quads"] = {} end
            self.quads = love.graphics.newQuad(
                (self.spriteData["quads"][1]*self.spriteData["gridMultiplication"]),
                (self.spriteData["quads"][2]*self.spriteData["gridMultiplication"]),
                (self.spriteData["spriteSize"][1]*self.spriteData["gridMultiplication"]),
                (self.spriteData["spriteSize"][2]*self.spriteData["gridMultiplication"]),
                self.texture
            )
        end


    end


    if self.type == "singleAnimation" then
        

        if self.spriteData ~= nil then
            if self.spriteData["type"] == nil then self.spriteData["type"] = "repeat" end
            if self.spriteData["timePerFrame"] == nil then self.spriteData["timePerFrame"] = 0.25 end
            if self.spriteData["gridMultiplication"] == nil then self.spriteData["gridMultiplication"] = 8 end
            if self.spriteData["spriteSize"] == nil then self.spriteData["spriteSize"] = {1,1} end
            if self.spriteData["spriteCenter"] == nil then self.spriteData["spriteCenter"] = {0.5,0.5} end
            if self.spriteData["quads"] == nil then self.spriteData["quads"] = {} end
            if #self.spriteData["quads"]>0 then
                for i2=1,#self.spriteData["quads"] do
                    self.quads[i2] = love.graphics.newQuad(
                        (self.spriteData["quads"][i2][1]*self.spriteData["gridMultiplication"]),
                        (self.spriteData["quads"][i2][2]*self.spriteData["gridMultiplication"]),
                        (self.spriteData["spriteSize"][1]*self.spriteData["gridMultiplication"]),
                        (self.spriteData["spriteSize"][2]*self.spriteData["gridMultiplication"]),
                        self.texture
                    )
                end
            end
        end


    end


    if self.type == "multipleAnimations" then
            
        
        if self.setupItem then
            self.itemQuadrant = self.flags["itemQuadrant"] or {0,0}
            if checkifinlist("small",self.parts) then
                self.spriteData["small"] ={
                    ["type"] = "still",
                    ["timePerFrame"] = 1,
                    ["gridMultiplication"] = 8,
                    ["spriteSize"] = {1,1},
                    ["spriteCenter"] = {0.5,0.5},
                    ["quads"] = {{self.itemQuadrant[1],self.itemQuadrant[2]}}
                    }
            end
            if checkifinlist("medium",self.parts) then
                self.spriteData["medium"] ={
                    ["type"] = "still",
                    ["timePerFrame"] = 1,
                    ["gridMultiplication"] = 8,
                    ["spriteSize"] = {2,2},
                    ["spriteCenter"] = {1,1},
                    ["quads"] = {{self.itemQuadrant[1]+1,self.itemQuadrant[2]}}
                    }
            end
            if checkifinlist("large",self.parts) then
                self.spriteData["large"] ={
                    ["type"] = "still",
                    ["timePerFrame"] = 1,
                    ["gridMultiplication"] = 8,
                    ["spriteSize"] = {4,4},
                    ["spriteCenter"] = {2,2},
                    ["quads"] = {{self.itemQuadrant[1]+3,self.itemQuadrant[2]}}
                    }
            end
        end

        --print("spritecreate : "..self.name)
        --print("spritecreate #parts : "..#self.spriteData["parts"])
        if #self.spriteData["parts"]>0 then 
            for i=1,#self.spriteData["parts"] do
                --print("spritecreate1".." part : "..i..self.spriteData["parts"][i])
                if self.spriteData[self.spriteData["parts"][i]] ~= nil then
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

function Sprite:doesAnimationExist(animation)
    return self.spriteData[animation] ~= nil
end

function Sprite:draw(animation,animationTime,direction,x,y,sx,sy,color)
    --return textures["sprites"][self.quadName]

    if self.type == "multipleAnimations" then
        self:drawMA(animation,animationTime,direction,x,y,sx,sy,color)
    end

    if self.type == "singleAnimation" then
        self:drawSA(animationTime,direction,x,y,sx,sy,color)
    end

    if self.type == "singleImage" then
        self:drawSI(direction,x,y,sx,sy,color)
    end

end

function Sprite:drawMA(animation,animationTime,direction,x,y,sx,sy,color)

if color == nil then color = {1,1,1,1} end
    if self.baseColor == nil then self.baseColor = {1,1,1,1} end
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

function Sprite:drawSA(animationTime,direction,x,y,sx,sy,color)

    if color == nil then color = {1,1,1,1} end
    if self.baseColor == nil then self.baseColor = {1,1,1,1} end
    if direction == nil then color = "right" end
    if not self.mirrorable then direction = "right" end
    --print("draw2")

    love.graphics.setColor(color[1]*self.baseColor[1],color[2]*self.baseColor[2],color[3]*self.baseColor[3],color[4]*self.baseColor[4])

    if self.spriteData ~= nil then
        --print("draw3")
        local frameNumber = math.ceil(animationTime/self.spriteData["timePerFrame"])
        local maxFrame = #self.spriteData["quads"]
        if self.spriteData["type"] == "still" then frameNumber = 1 end
        if self.spriteData["type"] == "hold" and frameNumber>maxFrame then frameNumber = maxFrame end
        if (self.spriteData["type"] == "repeat" 
            or self.spriteData["type"] == "repeat&needsToEnd") 
                and frameNumber>maxFrame then 
            frameNumber = ((frameNumber-1) % maxFrame)+1
        end
        if frameNumber>maxFrame then frameNumber=maxFrame end
        if frameNumber<1 then frameNumber=1 end

        if direction == "right" then
            
        love.graphics.draw(self.texture
            ,self.quads[frameNumber]
            ,x
            ,y
            ,0
            ,sx
            ,sy
            ,self.spriteData["spriteCenter"][1] * self.spriteData["gridMultiplication"]
            ,self.spriteData["spriteCenter"][2] * self.spriteData["gridMultiplication"] 
            )
        else

            love.graphics.draw(self.texture
            ,self.quads[frameNumber]
            ,x
            ,y
            ,0
            ,-sx
            ,sy
            ,self.spriteData["spriteCenter"][1] * self.spriteData["gridMultiplication"]
            ,self.spriteData["spriteCenter"][2] * self.spriteData["gridMultiplication"] 
            )
        end

    end
end

function Sprite:drawSI(direction,x,y,sx,sy,color)

    if color == nil then color = {1,1,1,1} end
    if self.baseColor == nil then self.baseColor = {1,1,1,1} end
    if direction == nil then color = "right" end
    if not self.mirrorable then direction = "right" end
    --print("draw2")

    love.graphics.setColor(color[1]*self.baseColor[1],color[2]*self.baseColor[2],color[3]*self.baseColor[3],color[4]*self.baseColor[4])

    if self.spriteData ~= nil then
        --print("draw3")

        if direction == "right" then
            
        love.graphics.draw(self.texture
            ,self.quads
            ,x
            ,y
            ,0
            ,sx
            ,sy
            ,self.spriteData["spriteCenter"][1] * self.spriteData["gridMultiplication"]
            ,self.spriteData["spriteCenter"][2] * self.spriteData["gridMultiplication"] 
            )
        else

            love.graphics.draw(self.texture
            ,self.quads
            ,x
            ,y
            ,0
            ,-sx
            ,sy
            ,self.spriteData["spriteCenter"][1] * self.spriteData["gridMultiplication"]
            ,self.spriteData["spriteCenter"][2] * self.spriteData["gridMultiplication"] 
            )
        end

    end
end