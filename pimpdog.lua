pd = {}

function pd.new(map)
    o={}
    o.map = map
    o.units = {}
    
    o.update = pd.update
    
    return o
end

function pd.addUnit(self,cell)
    local newDude = dude.new()
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
        pd.placeUnit(self.map,cell,unit)
        return prevCell
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
    for i,v in ipairs(self.units) do
        v:update(dt)
    end
    
    pd.applyDamage(self)

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

return pd
