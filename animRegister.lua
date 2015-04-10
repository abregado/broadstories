local reg = {}

function reg.new(skippable)
    local o = {}
    
    o.skippable = skippable
    o.animRegister = {}
    o.addToRegister = reg.addToRegister
    o.draw = reg.draw
    o.update = reg.update
    o.keypressed = reg.keypressed
    o.mousepressed = reg.mousepressed
    
    return o
end


function reg:addToRegister(anim,force)
    if force then
        table.insert(self.animRegister,1,anim)
    else
        table.insert(self.animRegister,anim)
    end
end

function reg:draw()
    
    if self.animRegister[1] and self.animRegister[1].isAnim then
        self.animRegister[1]:draw()
    end
    
end

function reg:update(dt)
    if self.animRegister[1] then
        local complete = self.animRegister[1]:updateMovement(dt)
        if complete then 
            table.remove(self.animRegister,1) 
        end
    else

    end
end

function reg:keypressed()
    if self.animRegister[1]and self.skippable then
        table.remove(self.animRegister,1)
    end
end

function reg:mousepressed()
    if self.animRegister[1] and self.skippable then
        table.remove(self.animRegister,1)
    end
end


return reg
