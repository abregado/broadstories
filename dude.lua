local lg = love.graphics

d = {}

function d.new()
    o = {}
    o.map = nil
    o.cell = nil
    o.color = {math.random(0,255),math.random(0,255),math.random(0,255)}
    o.isDead = false
    o.speed = math.random(1,4)
    o.moves = {}
    
    o.draw = d.draw
    o.arrive = d.arrive
    
    
    print("dude created")
    return o
end

function d.arrive(self,cell,map)
    self.cell = cell
    self.map = map
    cell.obj = self
    self.moves = grid.findInRadius(map,cell,self.speed)
end

function d.draw(self,x,y)
    --x and y parameters are optional. omitting them will draw the object at its exact location
    local px,py = self.map:getCenter(self.cell)
    local r = (self.map.ts/2.5)
    local offset = (self.map.ts/2)
    
    lg.setColor(self.color)
    lg.circle("fill",x or px,y or py,r,20)
end

return d
