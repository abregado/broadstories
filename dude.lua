local lg = love.graphics


d = {}

function d.new(controller,class)
    local o = {}
    o.map = controller.map
    o.cell = nil
    o.control = controller
    o.color = {math.random(0,255),math.random(0,255),math.random(0,255)}
    o.isDead = false
    o.moves = {}
    o.moved = false
    o.attacking = false
    
    
    o.stats = {}
    o.stats.hp = 3
    o.stats.armor = 2
    o.damage = 0
    
    d.setClass(o,class or nil)
    
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

function d.setClass(o,class)
    if class == "Ranger" then
        d.setClassRanger(o)
    elseif class == "Mage" then
        d.setClassMage(o)
    elseif class == "Beastmaster" then
        d.setClassBeastmaster(o)
    elseif class == "Fighter" then
        d.setClassFighter(o)
    elseif class == "Warlock" then
        d.setClassWarlock(o)
    elseif class == "Demon" then
        d.setClassDemon(o)
    elseif class == "Thief" then
        d.setClassThief(o)
    else
        d.setClassGenericNPC(o)
    end
end

function d.setClassFighter(o)
    o.moveShape = grid.newCircle(2)
    o.attackShape = grid.newCross(1)
    o.class = "Fighter"
    o.img = img.fighter
    o.color = {100,100,255}
    o.npc = false
    o.team = 1
    o.stats.hp = 4
    o.stats.armor = 3
end

function d.setClassGenericNPC(o)
    o.moveShape = grid.newCross(1)
    o.attackShape = grid.newCross(1)
    o.class = "Generic NPC"
    local skins = {img.boy,img.girl}
    local skin = math.random(1,#skins)
    o.img = skins[skin]
    o.color = {255,255,255}
    o.npc = true
    o.team = -1
    o.ai = function(self) return d.avoidEnemy(self) end
    o.stats.armor = 1
    o.stats.hp = 1
end

function d.setClassRanger(o)
    o.moveShape = grid.newBox(1)
    o.attackShape = grid.newStar(10)
    o.class = "Ranger"
    o.img = img.ranger
    o.color = {203,178,151}
    o.npc = false
    o.team = 1
    o.stats.hp = 2

end

function d.setClassMage(o)
    o.moveShape = grid.newBox(1)
    o.attackShape = grid.newCross(10)
    o.class = "Mage"
    o.img = img.mage
    o.color = {192,20,169}
    o.npc = false
    o.team = 1
    o.stats.armor = 1
    o.stats.hp = 3

end

function d.setClassWarlock(o)
    --o.moveShape = grid.joinLists(grid.newCircle(1),grid.newRing(10,11))
    o.moveShape = grid.joinLists(grid.newCircle(1),grid.newRing(10,11))
    o.attackShape = grid.newCross(8)
    o.class = "Warlock"
    o.img = img.warlock
    o.color = {192,20,169}
    o.npc = true
    o.moved = true
    o.team = 2
    o.ai = function(self) return d.pickFurthestAttack(self) or d.moveTowardEnemy(self) end

end

function d.setClassDemon(o)
    o.moveShape = grid.newCircle(2)
    o.attackShape = grid.newCross(1)
    o.class = "Demon"
    o.img = img.demon
    o.color = {225,125,125}
    o.npc = true
    o.moved = true
    o.team = 2

end

function d.setClassThief(o)
    o.moveShape = grid.newCross(1)
    o.attackShape = grid.newStar(1)
    o.class = "Thief"
    local skins = {img.thief1,img.thief2,img.thief3,img.thief4}
    local skin = math.random(1,#skins)
    o.img = skins[skin]
    o.color = {125,200,125}
    o.npc = true
    o.moved = true
    o.team = 2
    o.stats.hp = 2
    o.stats.armor = 2
    o.ai = function(self) return d.pickFurthestAttack(self) or d.moveTowardEnemy(self) end
end

function d.setClassBeastmaster(o)
    o.moveShape = grid.joinLists(grid.newBox(1),grid.newCross(2))
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
    o.stats.hp = 4
end

function d.update(self)
    if self.cell then   
        self.moves = grid.removeEnemyCells(grid.displaceList(self.map,self.moveShape,self.cell.pos.x or 0,self.cell.pos.y or 0),self)
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

function d.draw(self,x,y,showStats)
    --x and y parameters are optional. omitting them will draw the object at its exact location
    local px,py = self.map:getCenter(self.cell)
    local r = self.map.ts/2.5
    local offset = (self.map.ts/2)
    local scale = self.map.ts/self.img:getHeight()*0.75
    
    --lg.setColor(self.color)
    lg.setColor(0,0,0,125)
    lg.circle("fill",x or px,y or py,r/scale,20)
    --lg.setColor(0,0,0)
    --lg.circle("line",x or px,y or py,r/scale,20)
    lg.setColor(255,255,255)
    local aoff = self.img:getHeight()/2*scale
    if self.moved then
        anims.stand:draw(self.img,x or px-aoff,y or py-(aoff*1.8),0,scale,scale)
    else
        anims.walk:draw(self.img,x or px-aoff,y or py-(aoff*1.8),0,scale,scale)
    end
    
    --[[if self.attacking and not x and not y then
        --draw attacking marker
        lg.setColor(255,255,255)
        lg.draw(img.attack,px-aoff,py-(aoff*3.6),0,scale,scale)
    end]]
    
    if self.damage > 0 then
        d.drawArmor(self)
    end
    if showStats then
        d.drawHealth(self)
    end
    
end

function d.drawArmor(self)
    local px,py = self.map:getCenter(self.cell)
    local ox,oy = self.map:getOrigin(self.cell)
    local by = py + self.map.ts/2
    
    local scale = self.img:getHeight()/self.map.ts*1.5
    
    local sIcon = img.shield
    local dIcon = img.hit
    local iw,ih = sIcon:getWidth()*scale,sIcon:getHeight()*scale
    local two = iw*self.stats.armor/2
    
    for i=1,self.stats.armor do
        if i <= self.damage then
            lg.draw(dIcon,px+((i-1)*iw)-two,by-ih,0,scale,scale)
        else
            lg.draw(sIcon,px+((i-1)*iw)-two,by-ih,0,scale,scale)
        end
    end
end

function d.drawHealth(self)
    local px,py = self.map:getCenter(self.cell)
    local ox,oy = self.map:getOrigin(self.cell)
    local by = py + self.map.ts/2
    
    local scale = self.img:getHeight()/self.map.ts*1.5
    
    local hIcon = img.heart
    local iw,ih = hIcon:getWidth()*scale,hIcon:getHeight()*scale
    local two = iw*self.stats.hp/2
    
    for i=1,self.stats.hp do
        lg.draw(hIcon,px+((i-1)*iw)-two,by-ih,0,scale,scale)
    end
    
    --[[
    local r = (self.map.ts/2.5)
    local offset = (self.map.ts/2)
    local scale = self.map.ts/self.img:getHeight()
    local aoff = self.img:getHeight()/2*scale
    
    if self.npc then hIcon = img.skull end
    --draw health ui
    lg.setColor(255,255,255)
    local heartW = hIcon:getWidth()*0.25*scale
    for i=1,self.stats.hp do
        lg.draw(hIcon,px-(aoff/2)-(self.stats.hp*heartW/2)+(i*heartW),py - (aoff*1.6)+heartW,0,0.25*scale,0.25*scale)
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
    end]]
    
    
    
end

function d.moveTowardEnemy(self)
    local tcell
    local target = pimp.findClosestEnemy(self.control,self,self.cell.pos.x,self.cell.pos.y)
    if target then
        local options = grid.displaceList(self.map,self.moveShape,self.cell.pos.x,self.cell.pos.y)
        options = grid.removeFullCells(options)
        tcell = grid.getClosestFromList(options,target.cell.pos.x,target.cell.pos.y)
        print(tcell.pos.x,tcell.pos.y,#options)
        return tcell or nil
    end
    return nil
end

function d.avoidEnemy(self)
    local tcell
    local target = pimp.findClosestEnemy(self.control,self,self.cell.pos.x,self.cell.pos.y)
    if target then
        local options = grid.displaceList(self.map,self.moveShape,self.cell.pos.x,self.cell.pos.y)
        options = grid.removeFullCells(options)
        tcell = grid.getFurthestFromList(options,target.cell.pos.x,target.cell.pos.y)
        print(tcell.pos.x,tcell.pos.y,#options)
        return tcell or nil
    end
    return nil
    
end

function d.pickRandomAttack(self)
    local attackSquares = pimp.findAttackSquares(self.control,self)
    return grid.pickRandomCell(attackSquares)
end

function d.pickFurthestAttack(self)
    local target = pimp.findClosestEnemy(self.control,self,self.cell.pos.x,self.cell.pos.y)
    if target then
        local attackSquares = pimp.findAttackSquares(self.control,self)
        return grid.getFurthestFromList(attackSquares,target.cell.pos.x,target.cell.pos.y)
    end
    return nil
end

function d.pickClosestAttack(self)
    local target = pimp.findClosestEnemy(self.control,self,self.cell.pos.x,self.cell.pos.y)
    if target then
        local attackSquares = pimp.findAttackSquares(self.control,self)
        return grid.getClosestFromList(attackSquares,target.cell.pos.x,target.cell.pos.y)
    end
    return nil
end

return d
