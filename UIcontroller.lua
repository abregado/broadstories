local uic = {}

function uic.new(state,font)
    local o = {}
    
    o.state = state
    o.elements = {}
    o.mouseDown = false
    o.font = font
    
    o.draw = uic.draw
    o.update = uic.update
    o.click = uic.click
    o.addElement = uic.addElement
    
    return o
end

function uic:addElement(element)
    element.font = self.font
    table.insert(self.elements,element)
    
end

function uic:draw(alpha)
    for i,v in ipairs(self.elements) do
        if v.active then v:draw(alpha) end
    end
end

function uic:update(dt)
    for i,v in ipairs(self.elements) do
        if v.active then v:update(dt) end
    end
end

function uic:click(x,y)
    local clickedItem = nil
    for i,v in ipairs(self.elements) do
        if v.active and v:check(x,y) then clickedItem = v end
    end
    if clickedItem then clickedItem:click() end
    return clickedItem
end


return uic
