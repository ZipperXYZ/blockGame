require "class/superClass"
EntitySpawnCard = SuperClass:extend()
EntitySpawnCard.className = "EntitySpawnCard"

---@param cardType '"enemy"'|'"boss"'|'"specialBoss"'|'"other"'
function EntitySpawnCard:init(cardCost,cardWeight,cardType,biomes,name,sprite,ai,flags,tier)
    self.cardCost = cardCost or 1
    self.cardWeight = cardWeight or 10
    self.cardType = cardType or "enemy"
    self.type = cardType or "enemy"
    self.biomes = biomes or {"any"}
    self.name = name or "none"
    self.sprite = sprite or "none"
    self.flags = CopyAll(flags) or {}
    self.size = self.flags.size or 0.45
    self.health = self.flags.health or 20
    --self.healthPerLevel = healthPerLevel or (self.health * 0.2)
    self.healthPerLevel = (self.health * 0.3)
    self.damage = self.flags.damage or 1
    --self.damagePerlevel = damagePerlevel or (self.damage * 0.2)
    self.damagePerlevel = (self.damage * 0.25)
    self.ai = ai or "none"
    self.moveType = self.flags.movementType or "humanlike"
    
    self.elementalTier = tier or 0
end

function EntitySpawnCard:use(position,level,directorId,cost,type)
    --name, type, sprite, position, health, size, level, ia, flags
    --print("Using card: "..self.name.." at position: "..position.x..","..position.y.." with level: "..level.." and directorId: "..directorId.." and type: "..type)
    local flags = CopyAll(self.flags)
    level = math.ceil(level)
    flags.directorId = directorId
    flags.directorCost = cost
    flags.attackDamage = self.damage
    flags.baseAttackDamage = self.damage
    flags.attackDamagePerLevel = self.damagePerlevel
    flags.movementType = self.moveType
    flags.healthPerLevel = self.healthPerLevel
    table.insert(entities,
        Entity(
            self.name,
            type,
            self.sprite,
            position:copy(),
            self.health,
            self.size,
            level,
            self.ai,
            flags
        )
    )
end