require "class/superClass"
EntitySpawnCard = SuperClass:extend()
EntitySpawnCard.className = "EntitySpawnCard"

---@param type '"enemy"'|'"boss"'|'"specialBoss"'|'"other"'
function EntitySpawnCard:init(cardCost,cardWeight,cardType,biomes,name,sprite,size,health,damage,flags)
    self.cardCost = cardCost or 1
    self.cardWeight = cardWeight or 10
    self.cardType = cardType or "enemy"
    self.biomes = biomes or {"any"}
    self.name = name or "none"
    self.sprite = sprite or "none"
    self.size = size or 0.45
    self.health = health or 20
    --self.healthPerLevel = healthPerLevel or (self.health * 0.2)
    self.healthPerLevel = (self.health * 0.2)
    self.damage = damage or 1
    --self.damagePerlevel = damagePerlevel or (self.damage * 0.2)
    self.damagePerlevel = (self.damage * 0.2)
    self.flags = CopyAll(flags) or {}

end

function EntitySpawnCard:use(position,level,directorId,type)
    
end