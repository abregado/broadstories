local tut = require('tutorial')

sd = {}

function sd.drawAttackShape(list,map)
    for i,v in ipairs(list) do
        lg.setColor(200,30,30)
        local x,y = grid.getCenter(map,v)
        local barwidth = map.ts*0.3
        local barOff = barwidth/2
        lg.rectangle("fill",x-barOff,y-barOff,barwidth,barwidth)
    end
end

function sd.drawAttackOutline(list,map,unit)
    for i,v in ipairs(list) do
        if unit and v.obj and not (v.obj.team == unit.team) then
            local x,y = grid.getCenter(map,v)
            local w = (map.ts)*globTweens.grow.val
            local ox,oy = w/2,w/2
            lg.setLineWidth(3)
            lg.setColor(200,30,30,125)
            lg.rectangle("line",x-ox,y-oy,w,w)
            lg.setColor(200,30,30,200)
            lg.rectangle("fill",x-ox,y-oy,w,w)
        else
            local x,y = grid.getOrigin(map,v)
            lg.setLineWidth(3)
            lg.setColor(200,30,30,125)
            lg.rectangle("line",x,y,map.ts,map.ts)
            lg.setColor(200,30,30,60)
            lg.rectangle("line",x+3,y+3,map.ts-6,map.ts-6)
        end
    end
    

    
    lg.setLineWidth(1)
end

function sd.drawDangerSquare(map,cell,color)
    local x,y = grid.getCenter(map,cell)
    local w = (map.ts)*globTweens.grow.val
    local ox,oy = w/2,w/2
    lg.setLineWidth(3)
    lg.setColor(color[1],color[2],color[3],60)
    lg.rectangle("line",x-ox,y-oy,w,w)
    lg.setColor(color[1],color[2],color[3],125)
    lg.rectangle("fill",x-ox,y-oy,w,w)
end

function sd.drawDangerCircle(map,cell,color)
    local x,y = grid.getCenter(map,cell)
    local w = (map.ts)*globTweens.grow.val*0.6
    lg.setLineWidth(2)
    lg.setColor(color)
    lg.circle("line",x,y,w/2,20)
    lg.setLineWidth(1)
end

function sd.drawBarAttackShape(list,map,unit)
    for i,v in ipairs(list) do
        
        lg.setColor(200,30,30)
        local x,y = grid.getCenter(map,v)
        local barwidth = map.ts*0.3
        local barOff = barwidth/2
        lg.setLineWidth(barOff/2)
        --lg.rectangle("fill",x-barOff,y-barOff,barwidth,barwidth)
        lg.circle("fill",x,y,barOff,6)
        
        for j,k in ipairs(grid.getNeighboursInList(v.pos.x,v.pos.y,list)) do
            local x2,y2 = grid.getCenter(map,k)
            lg.line(x,y,x2,y2)
        end
        
        for j,k in ipairs(grid.getDoubleDiagonallyAdjacent(v.pos.x,v.pos.y,list)) do
            local x2,y2 = grid.getCenter(map,k)
            lg.line(x,y,x2,y2)
        end
        
        if unit and v.obj and not v.obj.team == unit.team then
            local hx,hy = grid.getOrigin(map,v)
            lg.draw(img.hit,hx,hy)
        end
        
    end
    lg.setLineWidth(1)
end

function sd.drawMoveShape(list,map,jiggle)
    local alpha = 80
    if jiggle then alpha = 255 end
    for i,v in ipairs(list) do
        lg.setColor(125,125,255,alpha)
        local x,y = grid.getCenter(map,v)
        local r = map.ts*0.4
        if jiggle then r = r * globTweens.jiggle.val end
        lg.circle("fill",x,y,r,20)
        lg.setColor(30,30,255,alpha)
        lg.circle("line",x,y,r,20)
    end
end

return sd
