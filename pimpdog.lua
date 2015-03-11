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
        return true
    end
    return false
end

function pd.update(self,dt)
    for i,v in ipairs(self.units) do
        v:update(dt)
    end

    --remove dead guys
    for i,v in ipairs(self.units) do
        if v.isDead then
            table.remove(self.units,i)
        end
    end
end

return pd
