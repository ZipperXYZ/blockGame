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

    self.elementsStayInBound = self.flags.elementsStayInBound or true

    self.scroll = 0
    self.scrollMargin = self.flags.scrollMargin or 0.2
    self.scrollable = self.flags.scrollable or (self.scrollMargin ~= 0)


    self.elements = {}

end

---@param elementType '"text"'|'"space"'|'"spacebutton"'|'"checkbox"'|'"slider"'|'"options"'|'"gameSaveBox"'
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

    newElement.holdTime = 0
    



    table.insert(self.elements,newElement)
end

function Interface:updateAndDraw()
    local results = {}

    local scroll = self.gaps - self.scroll
    local x = szx * (self.x - self.sizeX /2)
    local y = szy * (self.y)
    local sizeX = szx * self.sizeX
    local sizeY = szy * self.sizeY

    local backgroundColor = CopyAll(self.color)
    love.graphics.setLineWidth(self.lineWidth)

    love.graphics.setColor({backgroundColor[1]*0.8,backgroundColor[2]*0.8,backgroundColor[3]*0.8,backgroundColor[4]*0.8})
    if self.style == "bland" then
        love.graphics.rectangle("fill",x,y,sizeX,sizeY,self.corners,self.corners)
        love.graphics.setColor({backgroundColor[1]*0.6,backgroundColor[2]*0.6,backgroundColor[3]*0.6,backgroundColor[4]*0.8})
        love.graphics.rectangle("line",x,y,sizeX,sizeY,self.corners,self.corners)
    end
    if self.style == "line" then
        love.graphics.rectangle("line",x,y,sizeX,sizeY,self.corners,self.corners)
    end


    if self.elementsStayInBound then
        love.graphics.setScissor(x,y,sizeX,sizeY)
    end

    if #self.elements > 0 then
        for e = 1,#self.elements do
            
            scroll, results = self:elementDraw(self.elements[e],results,scroll,x,y,sizeX,sizeY)
            --if r ~= nil then table.insert(results,r)

            scroll = scroll + self.gaps
        end
    end

    if self.scroll < 0 then
        self.scroll = 0
    end
    if self.scroll > scroll + self.scrollMargin then
        self.scroll = scroll + self.scrollMargin
    end

    love.graphics.setScissor()
    --local r = sef
    --if r ~= nil then table.insert(results,r)

    return results
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
        love.graphics.printf(element.textContent,elementX,elementYText,elementSizeX/textSize,element.textAlign,0,textSize,textSize)

        local click = mouseInBound and buttonFramePress["click"]
        results[element.name] = click
    end

    


    scroll = scroll + element["sizeY"]/2
    return scroll, results
end