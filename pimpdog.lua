pd = {}

function pd.new(map)
    o={}
    o.map = map
    o.units = {}
    
    o.addUnit = d.addUnit
    o.update = d.update
    
    return o
end

function pd.addUnit(self,cell)
    local newDude = dude.new()
    newDude:arrive(cell,self.map)
    table.insert(self.units,newDude)
    cell.obj = newDude
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
