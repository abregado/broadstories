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
    o.attacking = false
    
    
    o.stats = {}
    o.stats.hp = 3
    o.stats.armor = 2
    o.damage = 0
    
    d.setClassDefault(o)
    
    o.draw = d.draw
    o.arrive = d.arrive
    o.update = d.update
    o.hurt = d.hurt
    o.kill = d.kill
    
    print("dude created")
    return o
end

function d.hurt(self)
    self.stats.hp = self.stats.hp -1
    if self.stats.hp <= 0 then
        self:kill()
    end
end

function d.kill(self)
    self.isDead = true
end

function d.setClassDefault(o)
    o.moveShape = grid.newCircle(5)
    o.attackShape = grid.newCross(1)
    o.class = "Fighter"
    o.img = img.fighter
    o.color = {100,100,255}
    o.npc = false
    o.team = 1
    d.update(o)
end

function d.setClassRanger(o)
    o.moveShape = grid.newCircle(3)
    o.attackShape = grid.newStar(10)
    o.class = "Ranger"
    o.img = img.ranger
    o.color = {203,178,151}
    o.npc = false
    o.team = 1
    d.update(o)
end

function d.setClassMage(o)
    o.moveShape = grid.joinLists(grid.newCircle(1),grid.newRing(10,11))
    o.attackShape = grid.newCross(10)
    o.class = "Mage"
    o.img = img.mage
    o.color = {192,20,169}
    o.npc = false
    o.team = 1
    d.update(o)
end

function d.setClassWarlock(o)
    o.moveShape = grid.joinLists(grid.newCircle(1),grid.newRing(10,11))
    o.attackShape = grid.newCross(8)
    o.class = "Warlock"
    o.img = img.warlock
    o.color = {192,20,169}
    o.npc = true
    o.moved = true
    o.team = 2
    d.update(o)
end

function d.setClassDemon(o)
    o.moveShape = grid.newCircle(5)
    o.attackShape = grid.newCross(1)
    o.class = "Demon"
    o.img = img.demon
    o.color = {225,125,125}
    o.npc = true
    o.moved = true
    o.team = 2
    d.update(o)
end

function d.setClassBeastmaster(o)
    o.moveShape = grid.joinLists(grid.newCircle(2),grid.newCross(3))
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
    o.npc = false
    o.team = 1
    d.update(o)
end

function d.update(self)
    if self.cell then   
        self.moves = grid.displaceList(self.map,self.moveShape,self.cell.pos.x or 0,self.cell.pos.y or 0)
    end
    if not self.npc then self.moved = false end
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
    
    lg.setColor(self.color)
    lg.circle("fill",x or px,y or py,r,20)
    lg.setColor(0,0,0)
    lg.circle("line",x or px,y or py,r,20)
    lg.setColor(255,255,255)
    local scale = self.map.ts/self.img:getHeight()
    local aoff = self.img:getHeight()/2*scale
    if self.moved then
        anims.stand:draw(self.img,x or px-aoff,y or py-(aoff*1.6),0,scale,scale)
    else
        anims.walk:draw(self.img,x or px-aoff,y or py-(aoff*1.6),0,scale,scale)
    end
    
    if self.attacking and not x and not y then
        --draw attacking marker
        lg.setColor(255,255,255)
        lg.draw(img.attack,px-aoff,py-(aoff*3.6),0,scale,scale)
    end
    
    d.drawStats(self)
    
end


function d.drawStats(self)
    local px,py = self.map:getCenter(self.cell)
    local r = (self.map.ts/2.5)
    local offset = (self.map.ts/2)
    local scale = self.map.ts/self.img:getHeight()
    local aoff = self.img:getHeight()/2*scale
    --draw health ui
    lg.setColor(255,255,255)
    local heartW = img.heart:getWidth()*0.25*scale
    for i=1,self.stats.hp do
        lg.draw(img.heart,px-(aoff/2)-(self.stats.hp*heartW/2)+(i*heartW),py - (aoff*1.6)-heartW,0,0.25*scale,0.25*scale)
    end
    --draw armor ui
    lg.setColor(255,255,255)
    local iconW = img.blueicon:getWidth()*0.25*scale
    for i=1,self.stats.armor do
        lg.draw(img.blueicon,px-(aoff/2)-(self.stats.armor*iconW/2)+(i*iconW),py - (aoff*1.6)-(iconW*2),0,0.25*scale,0.25*scale)
    end
    --draw damage ui
    lg.setColor(255,255,255)
    local iconW = img.orangeicon:getWidth()*0.25*scale
    for i=1,self.damage do
        lg.draw(img.orangeicon,px-(aoff/2)-(self.damage*iconW/2)+(i*iconW),py - (aoff*1.6)-(iconW*3),0,0.25*scale,0.25*scale)
    end
end

return d
