require "class/superClass"
Bar = SuperClass:extend()
Bar.className = "Bar"

---@param type '"unisection"'|'"multisection"'
function Bar:init(name,lossColor,gainColor,type)

    self.name = name
    --self.sectionTypes = sectionTypes or "glued"
    self.lossColor = lossColor or {1,1,1,1}
    self.gainColor = gainColor or {1,1,1,1}
    self.type = type or "unisection"
    self.sections = {}
    self.damagePreviews = {}

    --table.insert(world.barList)
end

function Bar:addSection(sectionName,color,max,baseRegen,timeRegenDisabledWhenLowered,overflow,overflowToOtherSections,sectionnedOff)
    local section = {}

    section.name = sectionName
    section.color = color
    section.max = max
    section.v = max

    section.baseRegen = baseRegen or 0
    section.timeRegenDisabledBase = timeRegenDisabledWhenLowered or 1
    section.overflow = overflow or false
    section.overflowToOtherSections = overflowToOtherSections or false
    section.sectionnedOff = sectionnedOff or false

    section.timeRegenDisabled = 0
    section.gainTime = 0
    section.vFloat = section.v
    section.vGainFloat = section.v

    table.insert(self.sections,section)
end

function Bar:update(dt)
    if #self.sections > 0 then
        for i = 1, #self.sections do
            self:updateSection(self.sections[i],dt)
        end
    end
    if #self.damagePreviews > 0 then
        for i = #self.damagePreviews, 1, -1 do
            self.damagePreviews[i].time = self.damagePreviews[i].time - dt
            if self.damagePreviews[i].time <= 0 then
                table.remove(self.damagePreviews, i)
            end
        end
    end
end

function Bar:updateSection(section,dt)
    local overflow = 0
    local downflow = 0

    if section.timeRegenDisabled > 0 then
        section.timeRegenDisabled = section.timeRegenDisabled - dt
    else
        section.v = section.v + dt * section.baseRegen
        if section.v > section.max then
            overflow = section.v - section.max
        end
    end


    if (not section.overflow) and section.v > section.max then
        section.v = section.max
    end

    if section.v < 0 then
        downflow = math.abs(section.v)
    end


    if section.gainTime > 0 then
        section.gainTime = section.gainTime - dt
    else
        section.vGainFloat = section.vFloat
    end

    section.vFloat = k(section.vFloat,section.v,maximum(dt*2,1))


    return overflow,downflow
end

function Bar:getSectionIndex(sectionName)
    local index = -1
    
    if #self.sections > 0 then
        for i = 1, #self.sections do
           if self.sections[i].name == sectionName then
            index = i
           end
        end
    end

    return index
end

function Bar:getSectionName(index)
    local sectionName = nil

    if #self.sections > 0 then
        if index > 0 and index <= #self.sections then
            sectionName = self.sections[round(index)].name 
        end
    end

    return sectionName
end

function Bar:increase(value,sectionName,overflowToOtherSections)
    local overflow = 0
    local downflow = 0

    if value < 0 then
        return self:decrease(-value,sectionName,overflowToOtherSections)
    end

    local overflowToOtherSections = overflowToOtherSections or false


    if sectionName == nil or sectionName == "any" or sectionName == "all" then
        local index = 1
        if #self.sections > 0 then
            overflow, downflow = self:increase(value,self:getSectionName(index),overflowToOtherSections)
        end
    else
        local index = self:getSectionIndex(sectionName)
        if index > 0 then
            
            self.sections[index].v = self.sections[index].v + value
            
            self.sections[index].gainTime = 1


            if self.sections[index].v > self.sections[index].max then

                value = self.sections[index].v - self.sections[index].max

                overflow = value

                if overflowToOtherSections and self.sections[index].overflowToOtherSections then
                    local nextSection = self:getSectionName(index+1)

                    if nextSection ~= nil then
                        overflow, downflow = self:increase(value,nextSection,overflowToOtherSections)
                    end

                end

                if not self.sections[index].overflow then
                    self.sections[index].v = self.sections[index].max
                end

            end

        end
    end


    return overflow, downflow
end

function Bar:decrease(value,sectionName,overflowToOtherSections)
    local overflow = 0
    local downflow = 0

    if value < 0 then
        return self:increase(-value,sectionName,overflowToOtherSections)
    end

    local overflowToOtherSections = overflowToOtherSections or true


    if sectionName == nil or sectionName == "any" or sectionName == "all" then
        local index = #self.sections
        if index > 0 then
            overflow, downflow = self:decrease(value,self:getSectionName(index),overflowToOtherSections)
        end
    else
        local index = self:getSectionIndex(sectionName)
        if index > 0 then
            
            self.sections[index].v = self.sections[index].v - value

            self.sections[index].timeRegenDisabled = self.sections[index].timeRegenDisabledBase


            if self.sections[index].v < 0 then

                value = math.abs(self.sections[index].v) 

                downflow = value

                if overflowToOtherSections and (not self.sections[index].sectionnedOff) then
                    local nextSection = self:getSectionName(index-1)

                    if nextSection ~= nil then
                        overflow, downflow = self:decrease(value,nextSection,overflowToOtherSections)
                    end

                end

                --if not self.sections[index].overflow then
                --    self.sections[index].v = self.sections[index].max
                --end

                self.sections[index].v = 0

            end

        end
    end


    return overflow, downflow
end

function Bar:setBaseRegen(value,sectionName)
    if sectionName == nil or sectionName == "any" or sectionName == "all" then
        if #self.sections > 0 then
            for i = 1, #self.sections do
                self.sections[i].baseRegen = value
            end
        end
    else
        local index = self:getSectionIndex(sectionName)
        if index > 0 then
            self.sections[index].baseRegen = value
        end
    end
end

function Bar:setRegenOffTimer(value,sectionName)
    if sectionName == nil or sectionName == "any" or sectionName == "all" then
        if #self.sections > 0 then
            for i = 1, #self.sections do
                self.sections[i].timeRegenDisabled = value
            end
        end
    else
        local index = self:getSectionIndex(sectionName)
        if index > 0 then
            self.sections[index].timeRegenDisabled = value
        end
    end
end

function Bar:setValue(value,sectionName)
    if sectionName == nil or sectionName == "any" or sectionName == "all" then
        if #self.sections > 0 then
            for i = 1, #self.sections do
                self:setValue(value,self:getSectionName(i))
            end
        end
    else
        local index = self:getSectionIndex(sectionName)
        if index > 0 then
            if value > self.sections[index].v then
                self.sections[index].v = value
                self.sections[index].timeRegenDisabled = self.sections[index].timeRegenDisabledBase
            end
            if value < self.sections[index].v then
                self.sections[index].v = value
                self.sections[index].gainTime = 1
            end
        end
    end
end

function Bar:setMax(value,sectionName)
    if sectionName == nil or sectionName == "any" or sectionName == "all" then
        if #self.sections > 0 then
            for i = 1, #self.sections do
                self.sections[i].max = value
            end
        end
    else
        local index = self:getSectionIndex(sectionName)
        if index > 0 then
            self.sections[index].max = value
        end
    end
end

function Bar:isOverflowing(sectionName)
    return self:getValue(sectionName) > self:getMax(sectionName)
end

function Bar:getValue(sectionName)
    if sectionName == nil or sectionName == "any" or sectionName == "all" then
        local v = 0
        if #self.sections > 0 then
            for i = 1, #self.sections do
                v = v + self.sections[i].v
            end
        end
        return v
    else
        local index = self:getSectionIndex(sectionName)
        if index > 0 then
            return self.sections[index].v
        end
    end
    return 0
end

function Bar:getValueFloat(sectionName)
    if sectionName == nil or sectionName == "any" or sectionName == "all" then
        local v = 0
        if #self.sections > 0 then
            for i = 1, #self.sections do
                v = v + self.sections[i].vFloat
            end
        end
        return v
    else
        local index = self:getSectionIndex(sectionName)
        if index > 0 then
            return self.sections[index].vFloat
        end
    end
    return 0
end

function Bar:getValueGain(sectionName)
    if sectionName == nil or sectionName == "any" or sectionName == "all" then
        local v = 0
        if #self.sections > 0 then
            for i = 1, #self.sections do
                v = v + self.sections[i].vGainFloat
            end
        end
        return v
    else
        local index = self:getSectionIndex(sectionName)
        if index > 0 then
            return self.sections[index].vGainFloat
        end
    end
    return 0
end

function Bar:getMax(sectionName)
    if sectionName == nil or sectionName == "any" or sectionName == "all" then
        local max = 0
        if #self.sections > 0 then
            for i = 1, #self.sections do
                max = max + self.sections[i].max
            end
        end
        return max
    else
        local index = self:getSectionIndex(sectionName)
        if index > 0 then
            return self.sections[index].max
        end
    end
    return 0
end

function Bar:getTotal()
    return self:getValue("all")
end

function Bar:getMaxTotal()
    return self:getMax("all")
end

function Bar:setDamagePreview(name,value,color,time,section)
    local time = time or 1
    local color = color or {1,1,1,1}
    local present = false
    if #self.damagePreviews > 0 then
        for i = 1, #self.damagePreviews do
            if self.damagePreviews[i].name == name then
                present = true
                self.damagePreviews[i].name = name
                self.damagePreviews[i].value = value
                self.damagePreviews[i].section = section
                self.damagePreviews[i].color = CopyAll(color)
                if self.damagePreviews[i].time < time then
                    self.damagePreviews[i].time = time
                end
            end
        end
    end
    if not present then
        local newDamagePreview = {}

        newDamagePreview.name = name
        newDamagePreview.section = section
        newDamagePreview.value = value
        newDamagePreview.time = time
        newDamagePreview.color = CopyAll(color)

        table.insert(self.damagePreviews,newDamagePreview)
    end
end

function Bar:removeDamagePreview(name)
    if #self.damagePreviews > 0 then
        for i = #self.damagePreviews, 1, -1 do
            if self.damagePreviews[i].name == name then
                table.remove(self.damagePreviews,i)
            end
        end
    end
end

---@param sectionTypes '"glued"'|'"seperated"'
---@param textType '"total"'|'"sectionned"'
function Bar:draw(x,y,width,height,sectionTypes,textType,textSize,corners,draw)
    sectionTypes = sectionTypes or "glued"
    textType = textType or "total"
    corners = corners or 0
    textSize = textSize or height/30
    local yText = y + ((Font:getHeight()*textSize)/2)

    local total = self:getMaxTotal()
    
    if draw == "bars" then
        love.graphics.setColor(0,0,0,0.5)
        love.graphics.rectangle("fill",x,y,width,height,corners,corners)
    end
    
    local xo = x

    if draw == nil then
        self:draw(x,y,width,height,sectionTypes,textType,textSize,corners,"bars")
        self:draw(x,y,width,height,sectionTypes,textType,textSize,corners,"previews")
        self:draw(x,y,width,height,sectionTypes,textType,textSize,corners,"text")
    end

    if #self.sections > 0 then
        if sectionTypes == "seperated" then
            for i = 1, #self.sections do

                local b = self.sections[i]

                local proportionMax = 1/self:getMaxTotal()*self:getMax(b.name)
                local proportionValue = 1/self:getMaxTotal()*self:getValue(b.name)
                local proportionValueFloat = 1/self:getMaxTotal()*self:getValueFloat(b.name)
                local proportionValueGain = 1/self:getMaxTotal()*self:getValueGain(b.name)
                

                if draw == "bars" then
                    love.graphics.setColor(CopyAll(self.lossColor))
                    local cornerRound = maximum(corners,width*(proportionValueFloat))
                    love.graphics.rectangle("fill",xo,y,width*proportionValueFloat,height,cornerRound,cornerRound)

                    love.graphics.setColor(CopyAll(b.color))
                    local cornerRound = maximum(corners,width*(proportionValue))
                    love.graphics.rectangle("fill",xo,y,width*proportionValue,height,cornerRound,cornerRound)

                    if proportionValueGain > 0 then
                        local color = CopyAll(self.gainColor)
                        local cornerRound = maximum(corners,width*(proportionValue-proportionValueGain))
                        love.graphics.setColor({color[1],color[2],color[3],color[4]*b.gainTime})
                        love.graphics.rectangle("fill",xo+width*(proportionValueGain),y,width*(proportionValue-proportionValueGain),height,cornerRound,cornerRound)
                    end
                end

                if draw == "text" then
                    if textType == "sectionned" then
                        local value = round(b.v)
                        local max = round(b.max)
                        love.graphics.setColor(0,0,0,1)
                        love.graphics.printf(value.." / "..max,xo-100+1,yText,(width*proportionMax+200)/textSize,"center",0,textSize,textSize)
                        love.graphics.printf(value.." / "..max,xo-100-1,yText,(width*proportionMax+200)/textSize,"center",0,textSize,textSize)
                        love.graphics.printf(value.." / "..max,xo-100,yText+1,(width*proportionMax+200)/textSize,"center",0,textSize,textSize)
                        love.graphics.printf(value.." / "..max,xo-100,yText-1,(width*proportionMax+200)/textSize,"center",0,textSize,textSize)
                        love.graphics.setColor(1,1,1,1)
                        love.graphics.printf(value.." / "..max,xo-100,yText,(width*proportionMax+200)/textSize,"center",0,textSize,textSize)
                    end
                end


                xo = xo + width * proportionMax

            end
        else
            local proportionValueFloat = 1/self:getMaxTotal()*self:getValueFloat("all")
            local proportionValueGain = 1/self:getMaxTotal()*self:getValueGain("all")

            if draw == "bars" then
                local cornerRound = maximum(corners,width*(proportionValueFloat))
                love.graphics.setColor(CopyAll(self.lossColor))
                love.graphics.rectangle("fill",x,y,width*proportionValueFloat,height,cornerRound,cornerRound)
            end

            for i = 1, #self.sections do

                local b = self.sections[i]

                local proportionMax = 1/self:getMaxTotal()*self:getMax(b.name)
                local proportionValue = 1/self:getMaxTotal()*self:getValue(b.name)
                

                if draw == "bars" then
                    love.graphics.setColor(CopyAll(b.color))
                    local cornerRound = maximum(corners,width*(proportionValue))
                    love.graphics.rectangle("fill",xo,y,width*proportionValue,height,cornerRound,cornerRound)


                    if proportionValueGain > 0 then
                        local color = CopyAll(self.gainColor)
                        local cornerRound = maximum(corners,width*(proportionValue-proportionValueGain))
                        love.graphics.setColor({color[1],color[2],color[3],color[4]*b.gainTime})
                        love.graphics.rectangle("fill",xo+width*(proportionValueGain),y,width*(proportionValue-proportionValueGain),height,cornerRound,cornerRound)
                    end
                end

                if textType == "sectionned" then
                    if draw == "text" then
                        local value = round(b.v)
                        local max = round(b.max)
                        love.graphics.setColor(0,0,0,1)
                        love.graphics.printf(value.." / "..max,xo-100+1,yText,(width*proportionMax+200)/textSize,"center",0,textSize,textSize)
                        love.graphics.printf(value.." / "..max,xo-100-1,yText,(width*proportionMax+200)/textSize,"center",0,textSize,textSize)
                        love.graphics.printf(value.." / "..max,xo-100,yText+1,(width*proportionMax+200)/textSize,"center",0,textSize,textSize)
                        love.graphics.printf(value.." / "..max,xo-100,yText-1,(width*proportionMax+200)/textSize,"center",0,textSize,textSize)
                        love.graphics.setColor(1,1,1,1)
                        love.graphics.printf(value.." / "..max,xo-100,yText,(width*proportionMax+200)/textSize,"center",0,textSize,textSize)
                    end
                end


                xo = xo + width * proportionValue

            end
        end
    end
    local proportionMax = 1
    local value = round(self:getTotal())
    local max = round(self:getMaxTotal())
    if draw == "text" then
        if textType == "total" then
            love.graphics.setColor(0,0,0,1)
            love.graphics.printf(value.." / "..max,x-100+1,yText,(width*proportionMax+200)/textSize,"center",0,textSize,textSize)
            love.graphics.printf(value.." / "..max,x-100-1,yText,(width*proportionMax+200)/textSize,"center",0,textSize,textSize)
            love.graphics.printf(value.." / "..max,x-100,yText+1,(width*proportionMax+200)/textSize,"center",0,textSize,textSize)
            love.graphics.printf(value.." / "..max,x-100,yText-1,(width*proportionMax+200)/textSize,"center",0,textSize,textSize)
            love.graphics.setColor(1,1,1,1)
            love.graphics.printf(value.." / "..max,x-100,yText,(width*proportionMax+200)/textSize,"center",0,textSize,textSize)
        end
    end
    if draw == "previews" and #self.damagePreviews > 0 then
        if sectionTypes == "glued" then
            local offset = 0
            for i = 1,#self.damagePreviews do
                local d = self.damagePreviews[i]
                local value = self:getTotal()
                local max = self:getMaxTotal()
                local color = CopyAll(d.color)

                local proportionValue = 1/self:getMaxTotal()*d.value
                local proportionValueBar = 1/self:getMaxTotal()*self:getTotal()
                local proportionOffset = 1/self:getMaxTotal()*offset

                local cornerRound = maximum(corners,width*(proportionValue))

                love.graphics.setLineWidth(2)
                
                love.graphics.setColor({color[1],color[2],color[3],color[4]*0.4})
                love.graphics.rectangle("fill",x+width*(proportionValueBar-proportionValue-proportionOffset),y,width*(proportionValue),height,cornerRound,cornerRound)
                love.graphics.setColor({color[1],color[2],color[3],color[4]})
                love.graphics.rectangle("line",x+width*(proportionValueBar-proportionValue-proportionOffset),y,width*(proportionValue),height,cornerRound,cornerRound)


                offset = offset + d.value
            end
        end
        if sectionTypes == "seperated" then
            local sectionOffsets = {}
            for i = 1,#self.damagePreviews do
                local d = self.damagePreviews[i]
                local value = self:getTotal()
                local max = self:getMaxTotal()
                local color = CopyAll(d.color)
                local previewLeft = d.value
                local counterBarOffset = 1
                
                for bar = #self.sections, 1, -1 do

                    local b = self.sections[bar]
                    local proportionValueBarMax = 1/self:getMaxTotal()*b.max
                    counterBarOffset = counterBarOffset - proportionValueBarMax

                    local canUseSection = (d.section == nil or d.section == "all" or d.section == "any" or d.section == b.name)
                    if canUseSection then
                    
                    local proportionValue = 1/self:getMaxTotal()*d.value
                    local proportionValueBar = 1/self:getMaxTotal()*b.v
                    local sectionOffset = sectionOffsets[bar] or 0

                    local rightEdge = width * (counterBarOffset + proportionValueBar)
                    
                    local availableInSection = minimum(b.v - sectionOffset,0)
                    local remainingPreview = minimum(previewLeft,0)
                    local previewAmount = maximum(remainingPreview,availableInSection)
                    local widthPreview = width/max*previewAmount
                    local xPreview = rightEdge - widthPreview - width * (sectionOffset / max)
                    
                    if widthPreview > 0 then
                        local cornerRound = maximum(corners,widthPreview)

                        love.graphics.setLineWidth(2)
                        
                        love.graphics.setColor({color[1],color[2],color[3],color[4]*0.4})
                        love.graphics.rectangle("fill",x+xPreview,y,widthPreview,height,cornerRound,cornerRound)
                        love.graphics.setColor({color[1],color[2],color[3],color[4]})
                        love.graphics.rectangle("line",x+xPreview,y,widthPreview,height,cornerRound,cornerRound)
                    end
                    
                    previewLeft = previewLeft - previewAmount
                    sectionOffsets[bar] = sectionOffset + previewAmount
                    end
                    


                end
            end
        end
    end
end