require "class/superClass"
Interface = SuperClass:extend()
Interface.className = "Interface"


---@param style '"bland"'|'"invisible"'|'"line"'
function Interface:init(name,x,y,sizeX,sizeY,style,color,textColor,flags)
    self.name = name or "none"
    self.flags = flags or {}

    self.x = x or 0.5
    self.y = y or 0.25
    self.sizeX = sizeX or 0.5
    self.sizeY = sizeY or 0.5

    self.style = style or "bland"

    self.color = color or {0.3,0.3,0.6,1}
    self.textColor = textColor or {0.9,0.9,0.9,1}
    self.textSize = self.flags.textSize or 0.003
    self.buttonHoverStyle = self.flags.buttonHoverStyle or "bright"
    self.gaps = self.flags.gaps or 0.1
    self.corners = self.flags.corners or 5
    self.lineWidth = self.flags.lineWidth or 5
    self.title = self.flags.title or "none"

    self.UISize = self.flags.UISize or UISize

    self.showTitle = self.flags.showTitle or false
    self.titleSizeX = self.flags.titleSizeX or 0.8
    self.titleSizeY = self.flags.titleSizeY or 0.07
    self.titleTextSize = self.flags.titleTextSize or self.textSize * 1.2

    self.elementsStayInBound = self.flags.elementsStayInBound or true

    self.scroll = 0
    self.scrollG = 0
    self.scrollMargin = self.flags.scrollMargin or 0.2
    self.scrollable = self.flags.scrollable or (self.scrollMargin ~= 0)

    if self.UISize ~= 1 then
        self.textSize = self.textSize * self.UISize
        self.titleTextSize = self.titleTextSize * self.UISize
        self.lineWidth = self.lineWidth * self.UISize
    end


    self.elements = {}

end

---@param elementType '"text"'|'"space"'|'"button"'|'"checkbox"'|'"slider"'|'"options"'|'"gameSaveBox"'
function Interface:addElement(name,elementType,sizeX,sizeY,textContent,contents,parameters,color,textColor)
    local newElement = {}

    newElement.name = name or "none"
    newElement.type = elementType or "none"
    newElement.sizeX = sizeX or 0.8
    newElement.sizeY = sizeY or 0.2
    newElement.textContent = textContent or ""
    newElement.contents = contents or {}
    --newElement.parameters = parameters or {}
    newElement.color = color or CopyAll(self.color)
    newElement.textColor = textColor or CopyAll(self.textColor)
    newElement.parameters = CopyAll(parameters) or {}

    newElement.textSize = newElement.parameters.textSize or self.textSize
    newElement.relativeTextSize = newElement.parameters.relativeTextSize or true
    newElement.textAlign = newElement.parameters.textAlign or "center"
    newElement.scaleWithText = newElement.parameters.scaleWithText or false
    newElement.textYOffset = newElement.parameters.textYOffset or (sizeY*0.25)
    newElement.default = newElement.parameters.default or nil

    newElement.holdTime = 0
    

    newElement.data = nil

    if newElement.type == "checkbox" then
        newElement.data = newElement.default
    end

    if newElement.type == "options" then
        newElement.data = newElement.default
    end

    if newElement.type == "slider" then
        newElement.data = newElement.default

        newElement.round = newElement.contents.round or 1
        newElement.min = newElement.contents.min or 0
        newElement.max = newElement.contents.max or 10
        newElement.displayMultiplication = newElement.contents.displayMultiplication or 1
        newElement.displayAddition = newElement.contents.displayAddition or 0
    end

    if self.UISize ~= 1 then
        newElement.textSize = newElement.textSize * self.UISize
        --newElement.sizeX = newElement.sizeX * self.UISize
        newElement.sizeY = newElement.sizeY * self.UISize
    end


    table.insert(self.elements,newElement)
end

function Interface:updateAndDraw()
    local results = {}

    local maxScroll = 0
    local scroll = self.gaps - self.scroll
    local pageX = szx * (self.x - self.sizeX /2)
    local pageY = szy * (self.y)
    local pageSizeX = szx * self.sizeX
    local pageSizeY = szy * self.sizeY

    local backgroundColor = CopyAll(self.color)
    love.graphics.setLineWidth(self.lineWidth)

    if self.showTitle then
        local xTitle = szx * (self.x - (self.sizeX * self.titleSizeX) /2)
        local yTitle = pageY - szy * self.titleSizeY
        local sizeXTitle = szx * (self.sizeX * self.titleSizeX)
        local sizeYTitle = szy * self.titleSizeY * 1
        love.graphics.setColor({backgroundColor[1]*0.8,backgroundColor[2]*0.8,backgroundColor[3]*0.8,backgroundColor[4]*0.8})
        if self.style == "bland" then
            love.graphics.rectangle("fill",xTitle,yTitle,sizeXTitle,sizeYTitle,self.corners,self.corners)
            love.graphics.setColor({backgroundColor[1]*0.6,backgroundColor[2]*0.6,backgroundColor[3]*0.6,backgroundColor[4]*0.8})
            love.graphics.rectangle("line",xTitle,yTitle,sizeXTitle,sizeYTitle,self.corners,self.corners)
        end
        if self.style == "line" then
            love.graphics.rectangle("line",xTitle,yTitle,sizeXTitle,sizeYTitle,self.corners,self.corners)
        end

        love.graphics.setColor(CopyAll(self.textColor))
        local textSize = self.titleTextSize * szy
        --local yTitleText = yTitle + self.titleSizeY * 0.05
        local yTitleText = yTitle + ((sizeYTitle-(Font:getHeight()*textSize))/2)
        love.graphics.printf(self.title,xTitle,yTitleText,sizeXTitle/textSize,"center",0,textSize,textSize)
    end

    love.graphics.setColor({backgroundColor[1]*0.8,backgroundColor[2]*0.8,backgroundColor[3]*0.8,backgroundColor[4]*0.8})
    if self.style == "bland" then
        love.graphics.rectangle("fill",pageX,pageY,pageSizeX,pageSizeY,self.corners,self.corners)
        love.graphics.setColor({backgroundColor[1]*0.6,backgroundColor[2]*0.6,backgroundColor[3]*0.6,backgroundColor[4]*0.8})
        love.graphics.rectangle("line",pageX,pageY,pageSizeX,pageSizeY,self.corners,self.corners)
    end
    if self.style == "line" then
        love.graphics.rectangle("line",pageX,pageY,pageSizeX,pageSizeY,self.corners,self.corners)
    end


    if self.elementsStayInBound then
        love.graphics.setScissor(pageX,pageY,pageSizeX,pageSizeY)
    end

    if mx > pageX and mx < pageX + pageSizeX
    and my > pageY and my < pageY + pageSizeY then
        if self.scrollable then
            self.scrollG = self.scrollG - scrollValueY * 0.2
        end
    end

    if #self.elements > 0 then
        for e = 1,#self.elements do
            local oldScroll = scroll
            scroll, results = self:elementDraw(self.elements[e],results,scroll,pageX,pageY,pageSizeX,pageSizeY)
            maxScroll = maxScroll + scroll- oldScroll
            --if r ~= nil then table.insert(results,r)

            scroll = scroll + self.gaps
            maxScroll = maxScroll + self.gaps
        end
    end


    if self.scrollG < 0 then
        self.scrollG = 0
    end
    if self.scrollG > maxScroll + self.scrollMargin then
        self.scrollG = maxScroll + self.scrollMargin
    end
    self.scroll = k(self.scroll,self.scrollG, maximum(delta*5,1))
    
    if self.scrollable then
        local maxScrollArea = maxScroll + self.scrollMargin + (pageSizeY / szy)
        love.graphics.setColor(0,0,0,0.5)
        love.graphics.rectangle("fill",pageX + pageSizeX - 8, pageY + pageSizeY / (maxScrollArea) * self.scroll, 8, 1 / maxScrollArea * pageSizeY)
    end


    love.graphics.setScissor()
    --local r = sef
    --if r ~= nil then table.insert(results,r)

    return results
end

function Interface:resetAll()
    if #self.elements > 0 then
        for i = 1, #self.elements do
            if self.elements[i].default ~= nil then
                self.elements[i].data = self.elements[i].default
            end
        end
    end
end

function Interface:passDataToElement(elementName,data)
    if #self.elements > 0 then
        for i = 1, #self.elements do
            if self.elements[i].name == elementName then
                self.elements[i].data = data
            end
        end
    end
end

function Interface:elementDraw(element,results,scroll,x,y,sizeX,sizeY)
    local elementXVisual = x + sizeX * (1-(element["sizeX"]*(1+0.25*element.holdTime)))/2
    local elementSizeXVisual = sizeX * (element["sizeX"]*(1+0.25*element.holdTime))
    local elementX = x + sizeX * (1-element["sizeX"])/2
    local elementSizeX = sizeX * element["sizeX"]
    local elementY = y + (szy * scroll)
    local elementYText = y + (szy * scroll) + element.textYOffset * szy
    local elementSizeY = szy * element["sizeY"]


    local color = CopyAll(element.color)
    love.graphics.setColor(color)

    if element.type == "button" then
        local mouseInBound = mx > elementX and mx < elementX + elementSizeX 
            and my > elementY and my < elementY + elementSizeY
            and ((mx > x and mx < x + sizeX) or (not self.elementsStayInBound))
            and ((my > y and my < y + sizeY) or (not self.elementsStayInBound))

        if mouseInBound then
            element.holdTime = k(element.holdTime, 1, 0.12)
            if self.buttonHoverStyle == "bright" then
                love.graphics.setColor({color[1]*1.4,color[2]*1.4,color[3]*1.4,color[4]*1})
            end
            if self.buttonHoverStyle == "dark" then
                love.graphics.setColor({color[1]*0.4,color[2]*0.4,color[3]*0.4,color[4]*1})
            end
        else
            element.holdTime = k(element.holdTime, 0, 0.08)
        end


        love.graphics.rectangle("fill",elementXVisual,elementY,elementSizeXVisual,elementSizeY,self.corners,self.corners)
        love.graphics.setColor({color[1]*0.6,color[2]*0.6,color[3]*0.6,color[4]*1})
        love.graphics.rectangle("line",elementXVisual,elementY,elementSizeXVisual,elementSizeY,self.corners,self.corners)

        love.graphics.setColor(element.textColor)
        local textSize = element.textSize * szy
        --love.graphics.printf(element.textContent,elementX,elementYText,elementSizeX/textSize,element.textAlign,0,textSize,textSize)
        love.graphics.printf(element.textContent,elementX,elementY + ((elementSizeY-(Font:getHeight()*textSize))/2),elementSizeX/textSize,element.textAlign,0,textSize,textSize)

        local click = mouseInBound and buttonFramePress["click"]
        if click then buttonFramePress["click"] = false end
        results[element.name] = click
    end

    if element.type == "checkbox" then
        local boxSize = szy * 0.04 * self.UISize
        local boxX = elementX + elementSizeX - boxSize 
        local boxY = elementYText
        local boxSizeX = boxSize
        local boxSizeY = boxSize

        local mouseInBound = mx > boxX and mx < boxX + boxSizeX 
            and my > boxY and my < boxY + boxSizeY
            and ((mx > x and mx < x + sizeX) or (not self.elementsStayInBound))
            and ((my > y and my < y + sizeY) or (not self.elementsStayInBound))

        if mouseInBound then
            element.holdTime = k(element.holdTime, 1, 0.12)
            if self.buttonHoverStyle == "bright" then
                love.graphics.setColor({color[1]*1.4,color[2]*1.4,color[3]*1.4,color[4]*1})
            end
            if self.buttonHoverStyle == "dark" then
                love.graphics.setColor({color[1]*0.4,color[2]*0.4,color[3]*0.4,color[4]*1})
            end
        else
            element.holdTime = k(element.holdTime, 0, 0.08)
        end


        love.graphics.rectangle("fill",boxX,boxY,boxSizeX,boxSizeY,self.corners,self.corners)
        love.graphics.setColor({color[1]*0.6,color[2]*0.6,color[3]*0.6,color[4]*1})
        love.graphics.rectangle("line",boxX,boxY,boxSizeX,boxSizeY,self.corners,self.corners)

        if element.data then
             love.graphics.setColor(element.textColor)
             love.graphics.line(boxX,boxY,boxX + boxSizeX,boxY + boxSizeY)
             love.graphics.line(boxX,boxY + boxSizeY,boxX + boxSizeX,boxY)
        end

        love.graphics.setColor(element.textColor)
        local textSize = element.textSize * szy
        love.graphics.printf(element.textContent,elementX,elementYText,(elementSizeX - boxSizeX * 1.2)/textSize,element.textAlign,0,textSize,textSize)

        local click = mouseInBound and buttonFramePress["click"]
        if click then element.data = not element.data end
        if click then buttonFramePress["click"] = false end
        results[element.name] = element.data
        
    end

    

    if element.type == "slider" then
        local lineSize = szy * 0.08 * self.UISize
        local lineX = elementX
        local lineY = elementY + szy * 0.08 * self.UISize
        local lineSizeX = elementSizeX
        local lineSizeY = lineSize

        local mouseInBound = mx > lineX and mx < lineX + lineSizeX 
            and my > lineY and my < lineY + lineSizeY
            and ((mx > x and mx < x + sizeX) or (not self.elementsStayInBound))
            and ((my > y and my < y + sizeY) or (not self.elementsStayInBound))

        if mouseInBound then
            element.holdTime = k(element.holdTime, 1, 0.12)
            
        else
            element.holdTime = k(element.holdTime, 0, 0.08)
        end


        local intervals = math.ceil((element.max - element.min) / element.round)

        love.graphics.setColor(element.textColor)

        love.graphics.line( lineX, lineY + lineSizeY / 2, lineX + lineSizeX, lineY + lineSizeY / 2)

        for inter = 0, intervals do
            if (inter == 0 or inter == intervals) or (lineSizeX * 1 / intervals > 12) then
                local position = inter / intervals 
                local markSize = 0.8
                if inter == 0 or inter == intervals then markSize = 0.9 end
                love.graphics.line( lineX + lineSizeX * position, lineY + lineSizeY * (1 - markSize), lineX + lineSizeX * position, lineY + lineSizeY * markSize )
            end
        end

        love.graphics.setColor(1,1,0,1)

        local linePosition = (element.data - element.min) / (element.max - element.min)
        love.graphics.line( lineX + lineSizeX * linePosition, lineY , lineX + lineSizeX * linePosition, lineY + lineSizeY * 1 )


        --love.graphics.rectangle("fill",lineX,lineY,lineSizeX,lineSizeY,self.corners,self.corners)
        --love.graphics.setColor({color[1]*0.6,color[2]*0.6,color[3]*0.6,color[4]*1})
        --love.graphics.rectangle("line",lineX,lineY,lineSizeX,lineSizeY,self.corners,self.corners)

        --if element.data then
        --     love.graphics.setColor(element.textColor)
        --     love.graphics.line(lineX,lineY,lineX + lineSizeX,lineY + lineSizeY)
        --     love.graphics.line(lineX,lineY + lineSizeY,lineX + lineSizeX,lineY)
        --end

        love.graphics.setColor(element.textColor)
        local textSize = element.textSize * szy
        love.graphics.printf(element.textContent,elementX,elementY,(elementSizeX)/textSize,element.textAlign,0,textSize,textSize)
        love.graphics.printf((element.data + element.displayAddition) * element.displayMultiplication,elementX,elementY,(elementSizeX)/textSize,"right",0,textSize,textSize)
        --love.graphics.printf(linePosition,elementX,elementYText+20,(elementSizeX)/textSize,"right",0,textSize,textSize)

        local click = (mouseInBound and buttonFramePress["click"]) or ( SelectedMouseDrag == element.name and love.mouse.isDown(1))
        if click then 
            SelectedMouseDrag = element.name
            element.data = ((mx - lineX) / lineSizeX) * (element.max - element.min) + element.min
            element.data = round(element.data / element.round) * element.round
            if element.data < element.min then element.data = element.min end
            if element.data > element.max then element.data = element.max end
        end
        if click then buttonFramePress["click"] = false end
        results[element.name] = element.data
        
    end



    if element.type == "options" then

        local textSize = element.textSize * szy

        local xOffset = 0
        local yOffset = 0
        for option = 1, #element.contents do
            local content = element.contents[option]

            local boxSize = szy * 0.08
            local boxX = elementX + xOffset
            local boxY = elementY + szy * 0.08 + yOffset
            local boxSizeX = Font:getWidth(content) * textSize + szx * 0.02
            local boxSizeY = boxSize

            if boxSizeX + boxX > elementX + elementSizeX then
                xOffset = 0
                yOffset = yOffset + boxSizeY
                --boxSize = szy * 0.08
                boxX = elementX + xOffset
                boxY = elementY + szy * 0.08 + yOffset 
                --boxSizeX = Font:getWidth(content) * textSize + szx * 0.02
                --boxSizeY = boxSize
            end

            local mouseInBound = mx > boxX and mx < boxX + boxSizeX 
                and my > boxY and my < boxY + boxSizeY
                and ((mx > x and mx < x + sizeX) or (not self.elementsStayInBound))
                and ((my > y and my < y + sizeY) or (not self.elementsStayInBound))

            love.graphics.setColor(color)
            if element.data == content then love.graphics.setColor(element.textColor) end
            if mouseInBound then
                element.holdTime = k(element.holdTime, 1, 0.12)
                if self.buttonHoverStyle == "bright" then
                    love.graphics.setColor({color[1]*1.4,color[2]*1.4,color[3]*1.4,color[4]*1})
                end
                if self.buttonHoverStyle == "dark" then
                    love.graphics.setColor({color[1]*0.4,color[2]*0.4,color[3]*0.4,color[4]*1})
                end
            else
                element.holdTime = k(element.holdTime, 0, 0.08)
            end

            love.graphics.rectangle("fill",boxX,boxY,boxSizeX,boxSizeY,self.corners,self.corners)
            love.graphics.setColor({color[1]*0.6,color[2]*0.6,color[3]*0.6,color[4]*1})
            love.graphics.rectangle("line",boxX,boxY,boxSizeX,boxSizeY,self.corners,self.corners)

            love.graphics.setColor(element.textColor)
            if element.data == content then love.graphics.setColor(color) end
            love.graphics.printf(content,boxX,boxY + ((boxSizeY-(Font:getHeight()*textSize))/2),(boxSizeX)/textSize,"center",0,textSize,textSize)


            local click = mouseInBound and (buttonFramePress["click"])
            if click then 
                element.data = content
            end
            if click then buttonFramePress["click"] = false end


            xOffset = xOffset + boxSizeX + szx * 0.015
        end
        if yOffset > 0 then scroll = scroll + yOffset/szy end


        love.graphics.setColor(element.textColor)
        love.graphics.printf(element.textContent,elementX,elementY,(elementSizeX)/textSize,element.textAlign,0,textSize,textSize)

        results[element.name] = element.data
        
    end
    --love.graphics.printf(scroll,elementX,elementYText,(elementSizeX)/1.2,element.textAlign,0,1.2,1.2)


    scroll = scroll + element["sizeY"]/2
    return scroll, results
end