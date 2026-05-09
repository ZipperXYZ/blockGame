--[[
    SuperClass: La classe que toutes les autres classes vont hériter un jour ou l'autre
    Elle contient toutes les méthodes importantes pour que une classe normale marche bien.

    Si toutes les classes extends celle la tous va être plus facile.

--]]
SuperClass = {}

SuperClass.__index = SuperClass
SuperClass.className = "SuperClass"



-- le new que toutes les classe utilise. Au lieux de refaire un new une fois on le fait hériter, comme cela 
-- toutes les classes on new.

-- New va retourner le nouvel objet.
-- Elle va aussi exécuter la fonction init() de la classe child
-- Elle va aussi rechercher pour des interfaces que le child doit implementer... si les fonctions ne sont pas implementer.. elle va throw une erreur.
function SuperClass:new(...)
    local o = {}
    setmetatable(o, self)
    if o.init then
        o:init(...)
    end

    if self._interfaces then 
        for _, interface in pairs(self._interfaces) do
            for k, _ in pairs(interface) do
                if type(o[k]) ~= "function" and k ~= "interfaceName" then
                    error(self.className.. " doit implementer la fonction: " .. k .. " venant de l'interface: " .. interface.interfaceName)
                end
            end
        end


    end
    return o
end

-- la fonction qu'on utilise pour extend la superClass vers une class child.

function SuperClass:extend()
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

-- la fonction qu'on utilise pour implementer une interfaces.

function SuperClass:implement(interface)
    for k,v in pairs(interface) do
        if(self[k] == nil) then
            self[k] = v
        end
    end

    self._interfaces = self._interfaces or {}
    table.insert(self._interfaces, interface)

end

function SuperClass:instanceOf(class)
    local mt = getmetatable(self)

    while mt do
        if (mt == class) then return true end

        mt = getmetatable(mt)
    end

    return false
end

function SuperClass:init()

end

function SuperClass:getClassName()
    return self.className
end

function SuperClass:destroy()
    setmetatable(self, nil)
    for k in pairs(self) do
        self[k] = nil
    end
end

function SuperClass:clone()
    local copy = {}
    for k, v in pairs(self) do
        copy[k] = v
    end
    setmetatable(copy, getmetatable(self))
    return copy
end

function SuperClass.__call(cls, ...)
    return cls:new(...)
end

function SuperClass:__tostring()
    local result = self.className .. " {\n"
    for k, v in pairs(self) do
        result = result .. "  " .. k .. " = " .. tostring(v) .. "\n"
    end
    return result .. "}"
end

function SuperClass:serialize()
    local data = {}
    for k, v in pairs(self) do
        if type(v) ~= "function" then
            data[k] = v
        end
    end
    return data
end

function SuperClass:deserialize(data)
    for k, v in pairs(data) do
        self[k] = v
    end
end
