require "class/superClass"

Vector2 = SuperClass:extend()
Vector2.className = "Vector2"

function Vector2:init(x,y)
    self.x = x or 0
    self.y = y or 0
end

function Vector2:getX()
    return self.x
end

function Vector2:getY()
    return self.y
end

function Vector2:setX(x)
    self.x = x
end

function Vector2:setY(y)
    self.y = y
end

function Vector2:__add(b)
    return Vector2:new(self:getX() + b:getX(), self:getY() + b:getY())
end

function Vector2:__sub(b)
    return Vector2:new(self:getX() - b:getX(), self:getY() - b:getY())
end

function Vector2:__mul(b)
    if type(self) == "number" then
        return Vector2:new(self * b.x, self * b.y)
    end
    if type(b) == "number" then
        return Vector2:new(self.x * b, self.y * b)
    end
    return Vector2:new(self.x * b.x, self.y * b.y)
end

function Vector2:length()
    return math.sqrt(self.x * self.x + self.y * self.y)
end

function Vector2:normalize()
    local len = self:length()
    return Vector2:new(self.x / len, self.y / len)
end

function Vector2:copy(rounded)
    if rounded == nil then rounded = false end
    if rounded then
         return Vector2(round(self.x),round(self.y))
    end
    return Vector2(self.x,self.y)
end

function Vector2:distance(other)
    return (self - other):length()
end

function Vector2:dist(other)
    return self:distance(other)
end

function Vector2:move(direction360,length)
    self.x = self.x + length * math.cos((direction360*math.pi)/180)
    self.y = self.y + length * math.sin((direction360*math.pi)/180)
end

function Vector2:moveTowards(other,length)
    local direction360 = self:getDirection360Towards(other)
    self.x = self.x + length * math.cos((direction360*math.pi)/180)
    self.y = self.y + length * math.sin((direction360*math.pi)/180)
end

function Vector2:movePredict(direction360,length)
    local x = self.x + length * math.cos((direction360*math.pi)/180)
    local y = self.y + length * math.sin((direction360*math.pi)/180)
    return Vector2(x,y)
end

function Vector2:moveTowardsPredict(other,length)
    local direction360 = self:getDirection360Towards(other)
    local x = self.x + length * math.cos((direction360*math.pi)/180)
    local y = self.y + length * math.sin((direction360*math.pi)/180)
    return Vector2(x,y)
end

function Vector2:getDirection360Towards(other)
    return (math.atan2(other.y-self.y,other.x-self.x)*180)/math.pi
end

function Vector2:__tostring()
    return "X: ".. tostring(self.x).. " Y: " ..tostring(self.y)
end

