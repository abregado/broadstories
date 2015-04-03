local vl = require('hump-master/vector-light')

aa = {}

function aa.new(animGroup)
    local o = {}
    
    o.animObjs = {}
    
    for i,v in ipairs(animGroup or {}) do
        aa.addAnimObj(o,v)
    end
    
    o.isAnim = true
    
    o.updateMovement = aa.updateAnim
    o.draw = aa.draw
    
    return o
end

function aa.addAnimObj(self,ao)
    table.insert(self.animObjs,ao)
end



function aa.newAnimObj(x,y)
    local o = {}
    o.draw = function(self)
        lg.setColor(255,255,255,255-(self.off*2))
        local offset = img.skull:getWidth()/2
        lg.draw(img.skull,x-offset,y-self.off-offset)
    end
    o.off = 0
    o.x = x
    o.y = y
    o.tween = tween.new(0.8,o,{off=128},'inQuad')
    
    return o
end

function aa.newHitAnim(x,y)
    local o = {}
    o.draw = function(self)
        lg.setColor(255,255,255,255-(self.off*2))
        local offset = img.hit:getWidth()/2
        lg.draw(img.hit,x-offset,y-self.off-offset)
    end
    o.off = 0
    o.x = x
    o.y = y
    o.tween = tween.new(0.8,o,{off=128},'inQuad')
    
    return o
end

function aa.newShootAnim(x,y,tx,ty,icon)
    local o = {}
    o.draw = function(self)
        lg.setLineWidth(3)
        lg.setColor(255,255,255)
        lg.circle("fill",self.x,self.y,10,10)
        lg.line(self.x,self.y,self.tx,self.ty)
        lg.setLineWidth(1)
    end
    o.perc = 0
    o.x = x
    o.y = y
    o.tx = tx
    o.ty = ty
    o.tween = tween.new(0.5,o,{x=tx,y=ty},'linear')
    
    return o
end

function aa.newIconShootAnim(x,y,tx,ty,icon)
    local o = {}
    o.draw = function(self)
        lg.setColor(255,255,255)
        local ox,oy = self.icon:getWidth()/2,self.icon:getHeight()/2
        lg.draw(self.icon,self.x,self.y,self.angle,1.5,1.5,ox,oy)
    end
    o.perc = 0
    o.icon = icon
    o.x = x
    o.y = y
    o.tx = tx
    o.ty = ty
    o.angle = vl.angleTo(x-tx,y-ty)-(math.pi/4)
    o.tween = tween.new(0.5,o,{x=tx,y=ty},'linear')
    
    return o
end

function aa.newIconThrowAnim(x,y,tx,ty,icon)
    local o = {}
    o.draw = function(self)
        lg.setColor(255,255,255)
        local ox,oy = self.icon:getWidth()/2,self.icon:getHeight()/2
        lg.draw(self.icon,self.x,self.y,self.angle,1.5,1.5,ox,oy)
    end
    o.perc = 0
    o.icon = icon
    o.x = x
    o.y = y
    o.tx = tx
    o.ty = ty
    o.angle = 0
    o.tween = tween.new(1,o,{x=tx,y=ty,angle=math.pi*4},'linear')
    
    return o
end

function aa.newHurtAnim(x,y)
    local o = {}
    o.draw = function(self)
        lg.setColor(255,255,255,255-(self.off*2))
        local offset = img.heart:getWidth()/2
        lg.draw(img.heart,x-offset,y-self.off-offset)
    end
    o.off = 0
    o.x = x
    o.y = y
    o.tween = tween.new(0.8,o,{off=128},'inQuad')
    
    return o
end

function aa.newRisingIconAnim(x,y,float,icon)
    local o = {}
    o.draw = function(self)
        lg.setColor(255,255,255,255-(self.off*2))
        local offset = icon:getWidth()/2
        lg.draw(icon,x-offset,y-self.off-offset)
    end
    o.off = 0
    o.x = x
    o.y = y
    o.tween = tween.new(0.8,o,{off=float},'inQuad')
    
    return o
end

function aa.updateAnim(self,dt)
    local complete = true
    for i,v in ipairs(self.animObjs) do
        if not v.tween:update(dt) then complete = false end
    end
    return complete
end

function aa.draw(self)
    for i,v in ipairs(self.animObjs) do
        v:draw()
    end
end

return aa
