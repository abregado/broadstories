pd = {}

function pd.new(map)
    o={}
    o.map = map
    o.units = {}
    
    o.animRegister = {}
    o.injuryRegister = {}
    
    o.endTurn = pd.endTurn
    o.update = pd.update
    o.draw = pd.draw
    o.addToRegister = pd.addToRegister
    
    return o
end

function pd.addToRegister(self,unit,force)
    if force then
        table.insert(self.animRegister,1,unit)
    else
        table.insert(self.animRegister,unit)
    end
end

function pd.draw(self)
    
    
    for i,v in ipairs(self.units) do
        v:draw()
    end
    
    if self.animRegister[1] and self.animRegister[1].isAnim then
        self.animRegister[1]:draw()
    end
end

function pd.update(self,dt)
    if self.animRegister[1] then
        local complete = self.animRegister[1]:updateMovement(dt)
        if complete then 
            if self.injuryRegister[1] and self.animRegister[1] == self.injuryRegister[1].anim then
                local death = self.injuryRegister[1].victim:hurt()
                table.remove(self.injuryRegister,1)
                if death then complete = false end
            end
            table.remove(self.animRegister,1) 
            
        end
    end
    return #self.animRegister == 0 
end

function pd.addUnit(self,cell,class)
    local newDude = dude.new(self,class)
    if grid.placeObject(self.map,cell,newDude) then
        table.insert(self.units,newDude)
        dude.setCell(newDude,cell)
        newDude:endTurn()
        print("new dude added")
    else
        print("failed to add new dude: location blocked")
    end
end


function pd.moveUnit(self,unit,cell)
    local prevCell = unit.cell
    if pd.takeUnit(self,unit.cell) then
        if pd.placeUnit(self,cell,unit) then
            return prevCell
        else
            pd.placeUnit(self,prevCell,unit)
        end
    end
    return nil
end

function pd.takeUnit(self,cell)
    local obj = grid.takeObject(map,cell)
    return obj
end

function pd.placeUnit(self,cell,unit)
    if grid.placeObject(self.map,cell,unit) then
        unit:setDest(cell)
        --pd.checkAttackers(self)
        --just for player units so the UI updates
        if unit.team == 1 then pd.checkDamage(self) end
        return true
    end
    return false
end

function pd.doTeamAI(self,team)
    for i,v in ipairs(self.units) do
        if v.npc and v.team == team then
            local tcell = v:ai()
            if tcell then
                pd.moveUnit(self,v,tcell)
            end
        end
    end
end

function pd.endTurn(self,dt)
   --[[    
    pd.applyDamage(self,1)
    pd.doTeamAI(self,2)
    pd.applyDamage(self,2)
    
    
    --remove dead guys
    for i,v in ipairs(self.units) do
        if v.isDead then
            grid.takeObject(self.map,v.cell)
            table.remove(self.units,i)
            print("one dude died") 
        end
    end
    
    for i,v in ipairs(self.units) do
        v:endTurn(dt)
    end
    pd.checkDamage(self)
    ]]
end

function pd.updateTeamMoves(self,team)
    for i,v in ipairs(self.units) do
        if v.team == team then v:endTurn(dt) end
    end
end

function pd.cleanDead(self)
    --remove dead guys
    for i,v in ipairs(self.units) do
        if v.isDead then
            grid.takeObject(self.map,v.cell)
            table.remove(self.units,i)
            print("one dude died") 
        end
    end
end

function pd.checkAttackers(self)
    for i,v in ipairs(self.units) do
        local attackSquares = grid.displaceList(self.map,v.attackShape,v.cell.pos.x,v.cell.pos.y)
        local result = false
        for j,k in ipairs(attackSquares) do
            local enemy = k.obj
            if enemy and not (enemy.team == v.team) then
                result = true
            end
        end
        v.attacking = result
    end
end

function pd.checkDamage(self)
    --reset damage counters
    for i,v in ipairs(self.units) do
        v.damage = 0
    end
    --calculate current damage
    for i,v in ipairs(self.units) do
        local attackSquares = grid.displaceList(self.map,v.attackShape,v.cell.pos.x,v.cell.pos.y)
        for j,k in ipairs(attackSquares) do
            local enemy = k.obj
            if enemy and not (enemy.team == v.team) then
                enemy.damage = enemy.damage + 1
            end
        end
    end
end

function pd.calculateAttackers(self,team)
    --reset damage counters
    for i,v in ipairs(self.units) do
        v.attackers = {}
    end
    --calculate current damage
    for i,v in ipairs(self.units) do
        if v.team == team then
            local attackSquares = grid.displaceList(self.map,v.attackShape,v.cell.pos.x,v.cell.pos.y)
            for j,k in ipairs(attackSquares) do
                local enemy = k.obj
                if enemy and not (enemy.team == v.team) then
                    table.insert(enemy.attackers,v)
                end
            end
        end
    end
    
    local attacked={}
    --compile list of attacked units
    for i,v in ipairs(self.units) do
        if #v.attackers > 0 then
            table.insert(attacked,v)
        end
    end
    return attacked
end

function pd.calculateInjured(attacked)
    local result = {}
    for i,unit in ipairs(attacked) do
        local hitTotal = 0
        for j, attacker in ipairs(unit.attackers) do
            hitTotal = hitTotal + attacker.stats.str
        end
        if hitTotal >= unit.stats.armor then
            table.insert(result,unit)
        end
    end
    return result
end

function pd.addInjuryPairs(self,injured)
    for i,victim in ipairs(injured) do
        local anims = {}
        for j,attacker in ipairs(victim.attackers) do
            local newAnim = aa.newHitAnim(attacker.x,attacker.y)
            table.insert(anims,newAnim)
        end
        local attackAnim = aa.new(anims)
        local hurtAnim = aa.new({aa.newHurtAnim(victim.x,victim.y)})
        self:addToRegister(attackAnim)
        self:addToRegister(hurtAnim)
        table.insert(self.injuryRegister,{victim=victim,anim=hurtAnim})
    end
end

function pd.applyDamage(self,team)
    for i,v in ipairs(self.units) do
        if v.team == team then
            v.damage = 0
        end
    end
    
    for i,v in ipairs(self.units) do
        if v.damage >= v.stats.armor then
            v:hurt()
        end
    end
end

function pd.findFurthestEnemy(self,unit,x,y)
    local result = nil
    local d = 999999999999
    for i,v in ipairs(self.units) do
        local dist = vl.dist(x,y,v.cell.pos.x,v.cell.pos.y)
        if dist > d and not (v == unit) and not (v.team == unit.team) then
            d = dist
            result = v
        end
    end
    return result
end

function pd.findClosestEnemy(self,unit,x,y)
    local result = nil
    local d = 999999999999
    for i,v in ipairs(self.units) do
        local dist = vl.dist(x,y,v.cell.pos.x,v.cell.pos.y)
        if dist < d and not (v == unit) and not (v.team == unit.team) then
            d = dist
            result = v
        end
    end
    return result
end

function pd.findUnitAt(self,x,y)
    for i,v in ipairs(self.units) do
        if v.cell.pos.x == x and v.cell.pos.y == y then
            return v
        end
    end
    return nil
end

function pd.findAttackSquares(self, unit)
    --checks current move and returns list of cells where an attack will be possible
    local moveOptions = grid.displaceList(self.map,unit.moveShape,unit.cell.pos.x,unit.cell.pos.y)
    local options = {}
    for i,v in ipairs(moveOptions) do
        if v.obj == nil then
            local attacks = 0
            local attackShape = grid.displaceList(self.map,unit.attackShape,v.pos.x,v.pos.y)
            for j,k in ipairs(attackShape) do
                local enemy = k.obj
                if enemy and not (enemy.team == unit.team) then
                    attacks = attacks +1
                end
            end
            if attacks > 0 then
                table.insert(options,v)
            end
        end
    end
    
    --[[local sorted = {}
    for i,v in spairs(options,function(t,a,b) return t[b].attacks > t[a].attacks end) do
        table.insert(sorted,v.cell)
    end]]
    
    return options
end



return pd
