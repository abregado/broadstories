local lg = love.graphics

d = {}

function d.new()
    local o = {}
    o.map = nil
    o.cell = nil
    o.color = {math.random(0,255),math.random(0,255),math.random(0,255)}
    o.isDead = false
    o.moves = {}
    o.moved = false
    
    d.setClassDefault(o)
    
    o.draw = d.draw
    o.arrive = d.arrive
    o.update = d.update
    
    print("dude created")
    return o
end

function d.setClassDefault(o)
    o.moveShape = grid.newCircle(5)
    o.attackShape = grid.newCross(1)
    o.class = "Fighter"
    o.img = img.fighter
    o.color = {100,100,255}
    d.update(o)
end

function d.setClassRanger(o)
    o.moveShape = grid.newCircle(3)
    o.attackShape = grid.newStar(10)
    o.class = "Ranger"
    o.img = img.ranger
    o.color = {203,178,151}
    d.update(o)
end

function d.setClassMage(o)
    o.moveShape = grid.newCircle(2)
    o.attackShape = grid.newCross(10)
    o.class = "Mage"
    o.img = img.mage
    o.color = {192,20,169}
    d.update(o)
end

function d.setClassBeastmaster(o)
    o.moveShape = grid.newCircle(3)
    local bmgrid = {
        {0,0,0,0,1,0,0},
        {0,0,0,0,1,0,0},
        {1,1,1,0,1,0,0},
        {0,0,0,0,0,0,0},
        {0,0,1,0,1,1,1},
        {0,0,1,0,0,0,0},
        {0,0,1,0,0,0,0}
        }
    o.attackShape = grid.newShapeFromGrid(bmgrid)
    o.class = "Beastmaster"
    o.img = img.beastmaster
    o.color = {86,188,109}
    d.update(o)
end

function d.update(self)
    if self.cell then   
        self.moves = grid.displaceList(self.map,self.moveShape,self.cell.pos.x or 0,self.cell.pos.y or 0)
    end
    self.moved = false
end

function d.arrive(self,cell,map)
    self.cell = cell
    self.map = map
    self.moved = true
    --self.moves = grid.findInRadius(map,cell,self.speed)
    --self.moves = grid.findInRing(map,cell,self.speed,self.minspeed)
    --self.moves = grid.findAllAtY(map,self.cell.pos.y)
    --self.moves = grid.joinLists(grid.findAllAtY(map,self.cell.pos.y),grid.findAllAtX(map,self.cell.pos.x))
    --self.moves = grid.joinLists(self.moves,grid.findInRing(map,cell,self.speed,self.minspeed))
    --self.moves = grid.displaceList(map,self.moveShape,cell.pos.x,cell.pos.y)
end

function d.draw(self,x,y)
    --x and y parameters are optional. omitting them will draw the object at its exact location
    local px,py = self.map:getCenter(self.cell)
    local r = (self.map.ts/2.5)
    local offset = (self.map.ts/2)
    local aoff = self.img:getHeight()/2*1.5
    
    lg.setColor(self.color)
    lg.circle("fill",x or px,y or py,r,20)
    lg.setColor(0,0,0)
    lg.circle("line",x or px,y or py,r,20)
    lg.setColor(255,255,255)
    if self.moved then
        anims.stand:draw(self.img,x or px-aoff,y or py-(aoff*1.6),0,1.5,1.5)
    else
        anims.walk:draw(self.img,x or px-aoff,y or py-(aoff*1.6),0,1.5,1.5)
    end
end

return d
