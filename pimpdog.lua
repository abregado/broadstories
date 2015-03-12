pd = {}

function pd.new(map)
    o={}
    o.map = map
    o.units = {}
    
    o.update = pd.update
    
    return o
end

function pd.addUnit(self,cell)
    local newDude = dude.new(self)
    if grid.placeObject(self.map,cell,newDude) then
        table.insert(self.units,newDude)
        newDude:arrive(cell,self.map)
        newDude:update()
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
        unit:arrive(cell,self.map)
        pd.checkAttackers(self)
        pd.checkDamage(self)
        return true
    end
    return false
end

function pd.update(self,dt)
    
    
    pd.applyDamage(self)
    
    for i,v in ipairs(self.units) do
        if v.npc then
            --[[local target = pd.findAttackSquare(self,v)
            if target then
                pd.moveUnit(self,v,target)
            end]]
            local tcell = v:ai()
            print(tcell)
            if tcell then
                pd.moveUnit(self,v,tcell)
                print("moved AI character")
            end
        end
    end
    
    for i,v in ipairs(self.units) do
        v:update(dt)
    end

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
    print("checking for attackers")
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
    print("checking for damage")
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

function pd.applyDamage(self)
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
