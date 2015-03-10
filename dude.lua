local lg = love.graphics

d = {}

function d.new()
    o = {}
    o.map = nil
    o.cell = nil
    o.color = {0,255,0}
    o.isDead = false
    o.draw = d.draw
    o.arrive = d.arrive
    
    print("dude created")
    return o
end

function d.arrive(self,cell,map)
    self.cell = cell
    self.map = map
end

function d.draw(self,x,y)
    --x and y parameters are optional. omitting them will draw the object at its exact location
    local r = (self.map.ts/2.5)
    local offset = (self.map.ts/2)
    if x and y then
    else
        x,y = self.cell.x+offset,self.cell.y+offset
    end
    
    lg.setColor(self.color)
    lg.circle("fill",x,y,r,20)
    print("dude drawn")
end

return d
