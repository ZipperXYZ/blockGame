require "class/superClass"
require "class/interface"

-- toujours suivre cette ordre.
-- on extend la classe en premier

Raycast = SuperClass:extend()

Raycast.className = "Raycast"

function Raycast:init(startPos, direction, endPos, length)
    SuperClass.init(self)
    self.startPos = startPos
    self.direction = direction or nil
    self.endPos = endPos or nil
    self.length = length or nil

    print("Raycast created with startPos: " .. tostring(self.startPos) .. ", direction: " .. tostring(self.direction) .. ", endPos: " .. tostring(self.endPos) .. ", length: " .. tostring(self.length))
end