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
