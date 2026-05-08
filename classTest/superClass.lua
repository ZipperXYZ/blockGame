superClass = {}

superClass.__index = superClass

function superClass:new(...)
    local o = {}
    setmetatable(o, self)
    if o.init then
        o:init(...)
    end
    return o
end


function superClass:extend()
    local cls = {}
    for k, v in pairs(self) do
        if k:find("__") == 1 then
            cls[k] = v
        end
    end
    cls.__index = cls
    setmetatable(cls, self)
    return cls
end

function superClass:init(var1, var2)
    self.testVariable = var1 or 42
    self.testName = var2 or "SuperClass"
    print("Super class initialized with testVariable: " .. self.testVariable .. " and name: " .. self.testName)
end