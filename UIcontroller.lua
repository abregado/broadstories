local uic = {}

function uic.new(state)
    local o = {}
    
    o.state = state
    o.elements = {}
    o.mouseDown = false
    
    o.draw = uic.draw
    o.update = uic.update
    o.click = uic.click
    o.addElement = uic.addElement
    
    return o
end

function uic:addElement(element)
    table.insert(self.elements,element)
    
end

function uic:draw()
    for i,v in ipairs(self.elements) do
        v:draw()
    end
end

function uic:update(dt)
    for i,v in ipairs(self.elements) do
        v:update(dt)
    end
end

function uic:click(x,y,button)
    for i,v in ipairs(self.elements) do
        if v:check(x,y) then v:click() end
    end
end


return uic
