require "class/superClass"
require "class/interface"

-- toujours suivre cette ordre.
-- on extend la classe en premier

ChildClass = SuperClass:extend()

--ensuite on set le className car sinon superclass va override le className
ChildClass.className = "ChildClass"

-- après on implemente les interface

ChildClass:implement(InterfaceTest)

-- ici c'est comme le new d'une classe, mais on va juste setter les attributs du new.

function ChildClass:init(var, name, var3,var4)

    SuperClass.init(self)

    self.test = var or self.test
    self.name = name or self.name

end

-- ici c'est une fonction qui vien de l'interface test que on implemente.

function ChildClass:testFunc()
    print("Vous avez implementer la fonction testFunc")
end

