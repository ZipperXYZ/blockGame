require "classTest/superClass"
childClass = superClass:extend()

function childClass:init(var, name, var3,var4)
    self.test = var or self.test
    self.name = name or self.name

    superClass.init(self, var3, var4)

    print("Child class initialized with test: " .. self.test .. " and name: " .. self.name .. " and testName: " .. self.testName .. " and test variable: " .. self.testVariable)
end