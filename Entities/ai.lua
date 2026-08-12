function Entity:setupAI()
    if self.aiInfo == nil then
        self.aiInfo = {}
    end
    if self.aiInfo.attentionTime == nil then self.aiInfo.attentionTime = 10 end
    if self.aiInfo.sightRange == nil then self.aiInfo.sightRange = 12 end
    if self.aiInfo.alertTime == nil then self.aiInfo.alertTime = 0.8 end
    if self.aiInfo.newPositionTargetTime == nil then self.aiInfo.newPositionTargetTime = 10 end
    if self.aiInfo.state == nil then self.aiInfo.state = "idle" end -- idle | attack

    if self.aiInfo.jumpBlocks == nil then self.aiInfo.jumpBlocks = 3 end
    if self.aiInfo.movePositionTargetDistanceMax == nil then self.aiInfo.movePositionTargetDistanceMax = 18 end
    if self.aiInfo.targetHoldTime == nil then self.aiInfo.targetHoldTime = 1.2 end
    if self.aiInfo.targetHoldTimer == nil then self.aiInfo.targetHoldTimer = 0 end
    if self.aiInfo.jumpInterval == nil then self.aiInfo.jumpInterval = 1.6 end
    if self.aiInfo.jumpTimer == nil then self.aiInfo.jumpTimer = math.random(0.4, self.aiInfo.jumpInterval) end

    if self.aiInfo.targetId == nil then self.aiInfo.targetId = nil end
    if self.aiInfo.positionTarget == nil then self.aiInfo.positionTarget = nil end
    if self.aiInfo.aimTarget == nil then self.aiInfo.aimTarget = nil end
    if self.seclusionTime == nil then self.seclusionTime = 0 end

    if self.aiInfo.attentionTimer == nil then self.aiInfo.attentionTimer = 0 end
    if self.aiInfo.alertTimer == nil then self.aiInfo.alertTimer = 0 end
    if self.aiInfo.jumpTimer == nil then self.aiInfo.jumpTimer = 0 end
    if self.aiInfo.newPositionTargetTimer == nil then self.aiInfo.newPositionTargetTimer = 0 end
end

--regular
--ranger (keeps distance)
--follower (has a secondary 'owner' target, and follows him when not attacking)
--fleer (runs away)
function Entity:aiUpdate(dt)
    self:setupAI()
    if self.ai == "regular" then
        self:aiTargetUpdate(dt)
        self:aiUpdateRegular(dt)
    end
end

function Entity:aiUpdateRegular(dt)
    self:updatePositionTarget(dt)
    self.controls.left = false
    self.controls.right = false
    self.controls.down = false
    self.controls.up = false
    self.controls.jump = false

    self.controls.mine = false
    self.controls.space = false
    self.controls.leftClick = false
    self.controls.rightClick = false

    if self.aiInfo.targetId ~= nil then
        local target = self:getTarget(self.aiInfo.targetId)
        if target ~= nil then
            self.aiInfo.aimTarget = target.position
            if world:canLineGoThrough(self.position, target.position, 2) then
                self.controls.leftClick = true
                self.controls.rightClick = true
                self.seclusionTime = 0
            else
                self.seclusionTime = self.seclusionTime + dt
                if self.seclusionTime > 1.5 then
                    --self.controls.mine = true
                    self.controls.space = true
                end
                --self.controls.mine = true
                --self.controls.space = true
            end
            
        end
    end

    if self.aiInfo.positionTarget ~= nil then
        local horizontalDelta = self.aiInfo.positionTarget.x - self.position.x
        local verticalDelta = self.aiInfo.positionTarget.y - self.position.y
        local desiredDir = 0

        if horizontalDelta < -0.4 then
            desiredDir = -1
        elseif horizontalDelta > 0.4 then
            desiredDir = 1
        end

        if desiredDir ~= 0 then
            local checkX = math.floor(self.position.x + 0.5 + desiredDir)
            local checkY = math.floor(self.position.y + 0.5)
            if not world:getColision(checkX, checkY) then
                if desiredDir < 0 then
                    self.controls.left = true
                else
                    self.controls.right = true
                end
            end
        end

        self.aiInfo.jumpTimer = (self.aiInfo.jumpTimer or self.aiInfo.jumpInterval) - dt
        if self:shouldJumpTowardsTarget(self.aiInfo.positionTarget) then
            self.controls.jump = true
        elseif self:canJump() and self.aiInfo.jumpTimer <= 0 then
            self.controls.jump = true
            self.aiInfo.jumpTimer = self.aiInfo.jumpInterval + math.random() * 0.6
        end

        if verticalDelta < -0.4 and self:canJump() and self:hasSafeLanding(self.position.x, self.position.y, self.aiInfo.positionTarget.x, self.aiInfo.positionTarget.y) then
            self.controls.up = true
            self.controls.jump = true
        elseif verticalDelta > 0.4 then
            self.controls.down = true
        end
    end
end

function Entity:updatePositionTarget(dt)
    if self.aiInfo.state == "idle" then
        self.aiInfo.newPositionTargetTimer = self.aiInfo.newPositionTargetTimer + dt
        self.aiInfo.targetHoldTimer = self.aiInfo.targetHoldTimer + dt

        if self.aiInfo.positionTarget ~= nil and not self:isValidPositionTarget(self.aiInfo.positionTarget) then
            self.aiInfo.positionTarget = nil
            self.aiInfo.targetHoldTimer = 0
        end

        if self.aiInfo.positionTarget == nil then
            self.aiInfo.newPositionTargetTimer = 0
            self.aiInfo.targetHoldTimer = 0
            local tries = 60
            for i = 1, tries do
                if self:findNewPositionTarget() then
                    break
                end
            end
        else
            local reachedTarget = self.aiInfo.positionTarget:dist(self.position) < 1.5
            local targetTimedOut = self.aiInfo.targetHoldTimer > self.aiInfo.targetHoldTime
            local targetExpired = self.aiInfo.newPositionTargetTimer > self.aiInfo.newPositionTargetTime

            if reachedTarget or targetTimedOut or targetExpired then
                self.aiInfo.newPositionTargetTimer = 0
                self.aiInfo.targetHoldTimer = 0
                local tries = 60
                for i = 1, tries do
                    if self:findNewPositionTarget() then
                        break
                    end
                end
            end
        end
    end
end

function Entity:getBlockHeightFromGround(x,y)
    local height = 0
    for i = 1, 10 do
        if world:getColision(x,y-i) then
            height = height + 1
        else
            break
        end
    end
    return height
end

function Entity:isValidPositionTarget(target)
    if target == nil then
        return false
    end

    local targetX = math.floor(target.x + 0.5)
    local targetY = math.floor(target.y + 0.5)
    local currentX = math.floor(self.position.x + 0.5)
    local currentY = math.floor(self.position.y + 0.5)

    if math.abs(targetX - currentX) < 2 and math.abs(targetY - currentY) < 1 then
        return false
    end

    if math.abs(targetY - currentY) > 3 then
        return false
    end

    if world:getColision(targetX, targetY) then
        return false
    end

    if world:getColision(targetX, targetY - 1) then
        return true
    end

    if self:canJump() then
        return self:hasSafeLanding(currentX, currentY, targetX, targetY)
    end

    return false
end

function Entity:hasSafeLanding(startX, startY, endX, endY)
    local xDir = 0
    if endX > startX then
        xDir = 1
    elseif endX < startX then
        xDir = -1
    end

    local steps = math.max(2, math.abs(endX - startX) + math.abs(endY - startY))
    for i = 1, steps do
        local t = i / steps
        local px = startX + (endX - startX) * t
        local py = startY + (endY - startY) * t
        local tx = math.floor(px + 0.5)
        local ty = math.floor(py + 0.5)

        if world:getColision(tx, ty) then
            return false
        end

        if not world:getColision(tx, ty - 1) then
            if xDir ~= 0 then
                local sideX = tx + xDir
                local sideY = ty
                if world:getColision(sideX, sideY) and world:getColision(sideX, sideY - 1) then
                    return true
                end
            end
            return false
        end
    end

    return true
end

function Entity:shouldJumpTowardsTarget(target)
    if target == nil or not self:canJump() then
        return false
    end

    local dir = 1
    if target.x < self.position.x then
        dir = -1
    end

    if math.abs(target.x - self.position.x) < 1.2 then
        return false
    end

    local startX = math.floor(self.position.x + 0.5)
    local startY = math.floor(self.position.y + 0.5)
    local targetX = math.floor(target.x + 0.5)
    local targetY = math.floor(target.y + 0.5)

    local testX = startX + dir
    local testY = startY
    if world:getColision(testX, testY) and not world:getColision(testX + dir, testY) and world:getColision(testX + dir, testY - 1) then
        return true
    end

    if math.abs(targetX - startX) <= 1 then
        return false
    end

    for offset = 1, self.aiInfo.jumpBlocks do
        local tileX = startX + (dir * offset)
        local tileY = startY
        if world:getColision(tileX, tileY) and not world:getColision(tileX + dir, tileY) and world:getColision(tileX + dir, tileY - 1) then
            return true
        end
    end

    return false
end

function Entity:findNewPositionTarget()
    local bestTarget = nil
    local bestScore = nil

    local minDistance = math.max(4, math.floor(self.aiInfo.sightRange * 0.6))
    local maxDistance = math.max(minDistance + 3, self.aiInfo.movePositionTargetDistanceMax)

    for i = 1, 40 do
        local candidate = self.position:copy()
        local angle = math.random() * 360
        local distance = math.random(minDistance, maxDistance)
        candidate:move(angle, distance)
        candidate.x = math.floor(candidate.x + 0.5)
        candidate.y = math.floor(candidate.y + 0.5)

        if self:isValidPositionTarget(candidate) then
            local candidateDistance = candidate:dist(self.position)
            local score = candidateDistance + (math.random() * 2.5)
            if bestTarget == nil or score > bestScore then
                bestTarget = candidate
                bestScore = score
            end
        end
    end

    if bestTarget == nil then
        local fallback = self.position:copy()
        fallback:move(math.random() * 360, math.max(4, math.floor(self.aiInfo.sightRange * 0.7)))
        fallback.x = math.floor(fallback.x + 0.5)
        fallback.y = math.floor(fallback.y + 0.5)
        if self:isValidPositionTarget(fallback) then
            bestTarget = fallback
        end
    end

    if bestTarget ~= nil then
        self.aiInfo.positionTarget = bestTarget
        self:newPositionTarget(self.aiInfo.positionTarget:copy())
        return true
    end

    return false
end

function Entity:getTarget(id)
    if id == nil then return nil end
    for i = 1, #entities do
        if entities[i].id == id then
            return entities[i]
        end
    end
    return nil
end

function Entity:aiTakeDamage(sourceEntity)
    self:setupAI()
    if sourceEntity == nil then return end
    if self:canAttack(sourceEntity) then
        self.aiInfo.targetId = sourceEntity.id
        if self.aiInfo.state ~= "attack" then
            self.aiInfo.state = "attack"
            self:stateStangeParticles(self.aiInfo.state)
        end
    end
end

function Entity:aiTargetUpdate(dt)
    if self.aiInfo.targetId == nil then
        if self.aiInfo.state == "attack" then
            self.aiInfo.state = "idle"
            self:stateStangeParticles(self.aiInfo.state)
        end
        local sawEnemy = false
        for i = 1, #entities do
            if self:canAttack(entities[i]) then
                local distance = self.position:dist(entities[i].position)
                if distance < self.aiInfo.sightRange then
                    if world:canLineGoThrough(self.position, entities[i].position, 2) then
                        self.aiInfo.alertTimer = self.aiInfo.alertTimer + dt
                        if self.aiInfo.alertTimer > self.aiInfo.alertTime then
                            self.aiInfo.targetId = entities[i].id
                            self.aiInfo.state = "attack"
                            self:stateStangeParticles(self.aiInfo.state)
                            self.aiInfo.alertTimer = 0
                            sawEnemy = true
                        end
                    end
                end
            end
        end
        if not sawEnemy then
            self.aiInfo.alertTimer = math.max(0, self.aiInfo.alertTimer - dt/2)
        end
    else
        self.aiInfo.alertTimer = 0
        local target = self:getTarget(self.aiInfo.targetId)
        if target == nil then self.aiInfo.targetId = nil return end
        self.aiInfo.positionTarget = target.position:copy()
        if not world:canLineGoThrough(self.position, target.position, 2) or self.position:dist(target.position) > self.aiInfo.sightRange then
            self.aiInfo.attentionTimer = self.aiInfo.attentionTimer + dt
            if self.aiInfo.attentionTimer > self.aiInfo.attentionTime then
                self.aiInfo.targetId = nil
                self.aiInfo.positionTarget = nil
                self.aiInfo.state = "idle"
                self:stateStangeParticles(self.aiInfo.state)
                self.aiInfo.attentionTimer = 0
            end
        else
            self.aiInfo.attentionTimer = 0
        end
    end
end

function Entity:newPositionTarget(position)
    --print("new position target ",position.x," : ",position.y)
    local color = {0,0,0.8,1}
    --world:spawnParticles(10,"ai change",position:copy(),self.size,color, {0.05,0.05,0.05,0.05}, 0.5, 0.5,"fire", 0.5, 0, 360, {["weight"] = 0.15})
end

function Entity:stateStangeParticles(newState)
    local color = {0.8,0.8,0.8,1}
    if newState == "idle" then
        color = {0.2,0.8,0.2,1}
        self.greenTime = 0
    end
    if newState == "attack" then
        color = {0.8,0.2,0.2,1}
        self.redTime = 0
    end
    world:spawnParticles(12,"ai change",self.position:copy(),self.size+0.3,color, {0.05,0.05,0.05,0.05}, 1.5, 1,"fire", 0.5, 0, 360, {["weight"] = 0.15})
end