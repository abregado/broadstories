local pimp = require('pimpdog')
local lg = love.graphics


d = {}

function d.new(controller,class,team)
    local o = {}
    o.map = controller.map
    o.cell = nil
    o.control = controller
    o.map = controller.map
    o.color = {math.random(0,255),math.random(0,255),math.random(0,255)}
    o.isDead = false
    
    o.x,o.y = 0,0
    o.moveTween = tween.new(1,o,{x=0,y=0})
    
    o.moveShape = grid.newCross(1)
    o.moves = {}
    o.moved = false
    
    o.attackShape = grid.newCross(1)
    o.attacking = false
    
    
    o.class = "Generic NPC"
    o.stats = {}
    o.stats.hp = 1
    o.stats.armor = 1
    o.stats.str = 1
    
    o.damage = 0
    o.attackers = {}
        
    o.img = 1
    o.team = team or -1
    o.ai = function(self) return d.avoidEnemy(self) end
    o.npc = true
    if PLAYERTEAM and team == PLAYERTEAM then o.npc = false end
    
    d.setClass(o,class or nil)
    
    
    o.draw = d.draw
    o.arrive = d.arrive
    o.endTurn = d.endTurn
    o.updateMovement = d.updateMovement
    o.hurt = d.hurt
    o.kill = d.kill
    o.setDest = d.setDest
    
    return o
end


function d.newDeathAnim(corpse)
    local o = {}
    o.draw = function(self)
        local px,py = corpse.x,corpse.y
        
        
        
        local r = corpse.map.ts/2.5
        local offset = (corpse.map.ts/2)
        local scale = corpse.map.ts/unitImg[1]:getHeight()*0.75
        
        lg.setColor(0,0,0,125)
        --lg.circle("fill",x or px,y or py,r/scale,20)
        lg.setColor(255,255,255,255-(self.off*2))
        local aoff = unitImg[1]:getHeight()/2*scale
        anims.stand:draw(unitImg[1],px-aoff,py-(aoff*1.8),0,scale,scale)
        
        lg.setColor(255,255,255,255-(self.off*2))
        offset = img.skull:getWidth()/2
        lg.draw(img.skull,px-offset,py-self.off-offset)

        
    end
    o.off = 0
    o.x = x
    o.y = y
    o.tween = tween.new(2,o,{off=128},'outQuad')
    
    return o
end


function d.hurt(self)
    self.stats.hp = self.stats.hp -1
    
    if self.stats.hp <= 0 then
        self:kill()
        return true
    end
    
    return false
    
end

function d.kill(self)
    self.isDead = true
    self.control:addToRegister(aa.new({d.newDeathAnim(self)}))
    self.img = 1
end

function d.setClass(o,class)
    if o.control.unitTypes[class] then
        local classData = o.control.unitTypes[class]
    
        o.class = tostring(classData.class)
        o.moveShape = classData.moveShape()
        o.attackShape = classData.attackShape()
        o.img = tonumber(classData.img)
        o.color = classData.color
        o.stats.hp = tonumber(classData.stats.hp)
        o.stats.armor = tonumber(classData.stats.armor)
        o.stats.str = tonumber(classData.stats.str)
        o.ai = classData.ai
    end
end

function d.endTurn(self)       
    
    if self.cell then   
        self.moves = grid.removeEnemyCells(grid.displaceList(self.map,self.moveShape,self.cell.pos.x or 0,self.cell.pos.y or 0),self)
    end
    if not self.npc then self.moved = false end
    
end

function d.updateMovement(self,dt)
    --update actual position toward target cell
    local complete = self.moveTween and self.moveTween:update(dt)
    if complete then self:arrive() end
    return complete
end

function  d.setDest(self,cell)
    self.cell = cell
    local x,y = grid.getCenter(self.map,cell)
    self.moveTween = tween.new(0.25,self,{x=x,y=y})
    self.control:addToRegister(self)
end

function d.arrive(self)
    self.moved = true
end

function d.setCell(self,cell)
    --immediatley jump to cell
    self.cell = cell
    local x,y = grid.getCenter(self.map,cell)
    self.x,self.y = x,y
    self.moveTween = nil
    
end

function d.draw(self,x,y,showStats)
    --x and y parameters are optional. omitting them will draw the object at its exact location
    local px,py = self.x,self.y
    local r = self.map.ts/2.5
    local offset = (self.map.ts/2)
    local scale = self.map.ts/self.control.spriteList[self.img]:getHeight()*0.75
    
    --lg.setColor(self.color)
    lg.setColor(0,0,0,125)
    lg.circle("fill",x or px,y or py,r/scale,20)
    --lg.setColor(0,0,0)
    --lg.circle("line",x or px,y or py,r/scale,20)
    lg.setColor(255,255,255)
    local aoff = self.control.spriteList[self.img]:getHeight()/2*scale
    if self.moved then
        anims.stand:draw(self.control.spriteList[self.img],x or px-aoff,y or py-(aoff*1.8),0,scale,scale)
    else
        anims.walk:draw(self.control.spriteList[self.img],x or px-aoff,y or py-(aoff*1.8),0,scale,scale)
    end
    
    --[[if self.attacking and not x and not y then
        --draw attacking marker
        lg.setColor(255,255,255)
        lg.draw(img.attack,px-aoff,py-(aoff*3.6),0,scale,scale)
    end]]
    
    if self.damage > 0 and self.npc and inputAccepted then
        d.drawHits(self)
    end
    if showStats then
        d.drawHealth(self)
        d.drawArmor(self)
    end
end

function d.drawHits(self)
    local px,py = self.x,self.y
    local ox,oy = self.x-(self.map.ts/2),self.y-(self.map.ts/2)
    local by = py + self.map.ts/2
    
    local sIcon = img.shield
    local dIcon = img.hit
    
    local idealWidth = self.map.ts/2
    local margin = self.map.ts/6
    local scale = idealWidth/sIcon:getWidth()
    
    local iw,ih = sIcon:getWidth()*scale,sIcon:getHeight()*scale
    local two = ((margin*(self.stats.armor-1))+iw)/2
    
    for i=self.stats.armor,1,-1 do
        if i <= self.damage then
            lg.draw(dIcon,px+((i-1)*margin)-two,by-ih,0,scale,scale)
        else
            lg.draw(sIcon,px+((i-1)*margin)-two,by-ih,0,scale,scale)
        end
    end
end

function d.drawHealth(self)
    local px,py = self.x,self.y
    local ox,oy = self.x-(self.map.ts/2),self.y-(self.map.ts/2)
    local by = py + self.map.ts/2
    
    
    local hIcon = img.heart
    
    local idealWidth = self.map.ts/4
    local scale = idealWidth/hIcon:getWidth()
    
    local iw,ih = hIcon:getWidth()*scale,hIcon:getHeight()*scale
    local two = iw*self.stats.hp/2
    
    for i=1,self.stats.hp do
        lg.draw(hIcon,px+((i-1)*iw)-two,by-ih-ih,0,scale,scale)
    end
end

function d.drawArmor(self)
    local px,py = self.x,self.y
    local ox,oy = self.x-(self.map.ts/2),self.y-(self.map.ts/2)
    local by = py + self.map.ts/2
    
    
    local hIcon = img.shield
    
    local idealWidth = self.map.ts/4
    local scale = idealWidth/hIcon:getWidth()
    
    local iw,ih = hIcon:getWidth()*scale,hIcon:getHeight()*scale
    local two = iw*self.stats.armor/2
    
    for i=1,self.stats.armor do
        lg.draw(hIcon,px+((i-1)*iw)-two,by-ih,0,scale,scale)
    end
end

function d.moveTowardEnemy(self)
    local tcell
    local target = pimp.findClosestEnemy(self.control,self,self.cell.pos.x,self.cell.pos.y)
    if target then
        local options = grid.displaceList(self.map,self.moveShape,self.cell.pos.x,self.cell.pos.y)
        options = grid.removeFullCells(options)
        tcell = grid.getClosestFromList(options,target.cell.pos.x,target.cell.pos.y)

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
