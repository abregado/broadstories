local aa = require('attackAnim')
local lg = require('love.graphics')

local flyupFont = lg.newFont("/assets/ccaps.ttf",40)
local underbarFont = lg.newFont("/assets/ccaps.ttf",20)
local barColor = {255,255,255}
local fontColor = {0,0,0}

local trans = {}

function trans.new(animations)
    local state = {}
    
    state.animRegister = {}
    state.from = nil
    
    state.draw = trans.draw
    state.update = trans.update
    state.keypressed = trans.keypressed
    state.mousepressed = trans.mousepressed
    state.enter = trans.enter
    state.addToRegister = trans.addToRegister
    
    for i,v in ipairs(animations) do
        state:addToRegister(v)
    end
    
    return state
end

function trans:addToRegister(anim,force)
    if force then
        table.insert(self.animRegister,1,anim)
    else
        table.insert(self.animRegister,anim)
    end
end

function trans:draw()
    if self.from then self.from:draw() end
    
    if self.animRegister[1] and self.animRegister[1].isAnim then
        self.animRegister[1]:draw()
    end
    
end

function trans:update(dt)
    if self.animRegister[1] then
        local complete = self.animRegister[1]:updateMovement(dt)
        if complete then 
            table.remove(self.animRegister,1) 
        end
    else
       gs.switch(game.new()) 
    end
end

function trans:keypressed()
    if self.animRegister[1] then
        table.remove(self.animRegister,1)
    end
end

function trans:mousepressed()
    if self.animRegister[1] then
        table.remove(self.animRegister,1)
    end
end

function trans:enter(from)
    self.from = from
end

function trans.newFlyup(text)
    local o = {}
    o.draw = function(self)
        
        local fontHeight = flyupFont:getHeight(self.text)
        local fontWidth = flyupFont:getWidth(self.text)
        
        lg.setColor(barColor)
        lg.rectangle("fill",0,self.y-10,lg.getWidth(),fontHeight+20)
        
        lg.setColor(fontColor)
        lg.setFont(flyupFont)
        lg.print(self.text,self.x+lg.getWidth()/2-(fontWidth/2),self.y)

        
    end
    o.text = text
    o.x = 0
    o.y = lg.getHeight()
    o.tween = tween.new(2,o,{y=-50},'outQuad')
    
    return o
end

function trans.newUnderbar(text)
    local o = {}
    o.draw = function(self)
        
        local fontHeight = underbarFont:getHeight(self.text)
        local fontWidth = underbarFont:getWidth(self.text)
        
        lg.setColor(barColor)
        lg.rectangle("fill",0,self.y-10,lg.getWidth(),fontHeight+20)
        
        lg.setColor(fontColor)
        lg.setFont(underbarFont)
        lg.print(self.text,self.x+lg.getWidth()/2-(fontWidth/2),self.y)

        
    end
    o.text = text
    o.x = 0
    o.y = lg.getHeight()+40
    o.tween = tween.new(2,o,{y=-10},'outQuad')
    
    return o
end


return trans
