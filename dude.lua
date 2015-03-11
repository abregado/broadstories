local lg = love.graphics

d = {}

function d.new()
    o = {}
    o.map = nil
    o.cell = nil
    o.color = {math.random(0,255),math.random(0,255),math.random(0,255)}
    o.isDead = false
    o.minspeed = math.random(2,3)
    o.speed = math.random(1,2)+o.minspeed
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
    --self.moves = grid.findInRadius(map,cell,self.speed)
    --self.moves = grid.findInRing(map,cell,self.speed,self.minspeed)
    --self.moves = grid.findAllAtY(map,self.cell.pos.y)
    self.moves = grid.joinLists(grid.findAllAtY(map,self.cell.pos.y),grid.findAllAtX(map,self.cell.pos.x))
    --self.moves = grid.joinLists(self.moves,grid.findInRing(map,cell,self.speed,self.minspeed))
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
