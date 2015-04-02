
local lg = love.graphics
local vl = require('hump-master/vector-light')

local cellColor = {80,80,80}
local walkableColor = {101,153,51}
local objColor = {101,190,51}
local gridColor = {37,76,0}

local g = {}

function g.newGridArea(width,height,tilesize,ox,oy)
print("building new grid of w/h pixels")
    o = {}
    o.tilelist = {}
    o.tileset = {}
    o.x, o.y = ox or 0,oy or 0
    o.ts = tilesize
    o.tw = math.floor(width/tilesize)
    o.th = math.floor(height/tilesize)
    o.w = o.ts*o.tw
    o.h = o.ts*o.th
    g.generateTiles(o,o.tw,o.th,o.ts)
    o.draw = g.draw
    o.getCenter = g.getCenter
    o.getOrigin = g.getOrigin
    o.drawObjects = g.drawObjects
    --print(o.tw,o.th,"mapsize")
    return o
end

function g.newGrid(width,height,tilesize,ox,oy)
    print("building new grid of w/h tiles")
    local o = {}
    o.tilelist = {}
    o.tileset = {}
    o.x, o.y = ox or 0,oy or 0
    o.ts = tilesize
    o.tw = width
    o.th = height
    o.w = o.ts*o.tw
    o.h = o.ts*o.th
    g.generateTiles(o,o.tw,o.th,o.ts)
    o.draw = g.draw
    o.getCenter = g.getCenter
    o.drawObjects = g.drawObjects
    --print(o.tw,o.th,"mapsize")
    return o
end

function g.placeObject(map,cell,obj)
    if cell.obj == nil and cell.walkable and cell.active then
        cell.obj = obj
        return true
    else
        return false
    end
end

function g.takeObject(map,cell)
    if cell.obj == nil then
        return nil
    else
        local obj = cell.obj
        cell.obj = nil
        return obj
    end
end

function g.setDrawLocation(self,x,y)
    self.x, self.y = x,y
end

function g.newCell(x,y)
    local o = {}
    o.pos = {x=x,y=y}
    o.active = true
    o.walkable = true
    o.obj = nil
    return o
end

function g.generateTiles(o,w,h,ts)
    for x=0,w-1 do
        o.tileset[x] = {}
        for y=0,h-1 do
            local newCell = g.newCell(x,y)
            table.insert(o.tilelist,newCell)
            o.tileset[x][y] = newCell
        end
    end
end


function g.draw(self)
    for i,v in ipairs(self.tilelist) do
        if v.active then
            local x,y = g.getOrigin(self,v)
            if v.obj then
                lg.setColor(objColor)
            elseif v.walkable then
                lg.setColor(walkableColor)
            elseif v.active then
                lg.setColor(cellColor)
            else
                lg.setColor(0,0,0)
            end
            lg.rectangle("fill",x,y,self.ts,self.ts)
            lg.setColor(gridColor)
            lg.rectangle("line",x,y,self.ts,self.ts)
        end
    end
    --lg.setColor(0,255,0)
    --lg.rectangle("line",self.x,self.y,self.w,self.h)
end

function g.drawObjects(self)
    --[[for i,v in ipairs(self.tilelist) do 
        if v.obj then
            --lg.setColor(v.obj.color)
            --lg.rectangle("fill",v.x+self.x,v.y+self.y,self.ts,self.ts)
            v.obj:draw()
        end
    end]]
end


function g.findTileAtPos(self,x,y)
    local result = nil
    if self.tileset[x] and self.tileset[x][y] then result = self.tileset[x][y] end
    return result
end

function g.findTileAtCoord(self,x,y)
    local result = {c=nil,d=9999}
    if (x > self.x+self.w) or (x < self.x) or (y > self.y+self.h) or (y < self.y) then
        --no nothing
        --print("out of bounds")
    else
        x = x-self.x
        y = y-self.y
        for i,v in ipairs(self.tilelist) do
            local dist = vl.dist((v.pos.x+0.5)*self.ts,(v.pos.y+0.5)*self.ts,x,y)
            if dist<result.d then result = {c=v,d=dist} end
        end
    end
    return result.c
end

function g.getCenter(self,tile)
    local x = tile.pos.x or 1
    local y = tile.pos.y or 1
    return ((x+0.5)*self.ts)+self.x, ((y+0.5)*self.ts)+self.y
end

function g.getOrigin(self,tile)
    return (tile.pos.x*self.ts)+self.x, (tile.pos.y*self.ts)+self.y
end

function g.stepDistance(self,c1,c2)
    return vl.dist(c1.pos.x,c1.pos.y,c2.pos.x,c2.pos.y)
end

function g.pixelDistance(self,c1,c2)
    return vl.dist(c1.x,c1.y,c2.x,c2.y)
end

function g.findInRadius(self,c1,d)
    local result = {}
    for i,v in ipairs(self.tilelist) do
        local dist = vl.dist(v.pos.x,v.pos.y,c1.pos.x,c1.pos.y)
        if dist <= d then
            table.insert(result,v)
        end
    end
    return result
end

function g.findInRing(self,c1,d1,d2)
    local result = {}
    if d1 > d2 then 
        d1,d2 = d2,d1
    end
    for i,v in ipairs(self.tilelist) do
        local dist = vl.dist(v.pos.x,v.pos.y,c1.pos.x,c1.pos.y)
        if dist <= d2 and dist >= d1 then
            table.insert(result,v)
        end
    end
    return result
end

function g.checkCellInList(cell,list)
    local result = false
    for i,v in ipairs(list) do
        if v == cell then
            result = true
        end
    end
    return result
end

function g.findAllAtX(self,x)
    local result = {}
    for i,v in ipairs(self.tilelist) do
        if v.pos.x == x then
            table.insert(result,v)
        end
    end
    return result
end

function g.findAllAtY(self,y)
    local result = {}
    for i,v in ipairs(self.tilelist) do
        if v.pos.y == y then
            table.insert(result,v)
        end
    end
    return result
end



function g.findIntersection(list1,list2)
    local result = {}
    for i,v in ipairs(list1) do
        for j,k in ipairs(list2) do
            if v == k then
                table.insert(result,v)
            end
        end
    end
    return result
end

function g.joinLists(list1,list2)
    local result = {}
    for i,v in ipairs(list1) do
        table.insert(result,v)
    end
    
    for i,v in ipairs(list2) do
        table.insert(result,v)
    end
    
    --remove duplicates THANKS SOURCEFORGE
    -- make unique keys
    local hash = {}
    for _,v in ipairs(result) do
        hash[v] = true
    end

    -- transform keys back into values
    local res = {}
    for k,_ in pairs(hash) do
        res[#res+1] = k
    end

    result = res
    
    return result
end

function g.displaceList(self,list,x,y,ignoreWalkable)
    local result = {}
    for i,v in ipairs(list) do
        local newCell = g.findTileAtPos(self,v.pos.x+x,v.pos.y+y)
        if newCell and newCell.active and (ignoreWalkable or newCell.walkable) then table.insert(result,newCell) end
    end
    return result
end

function g.getFurthestFromList(list,x,y)
    local result = nil
    local d = -1
    for i,v in ipairs(list) do
        local dist = vl.dist(x,y,v.pos.x,v.pos.y)
        if dist > d then
            d = dist
            result = v
        end
    end
    return result
end

function g.getClosestFromList(list,x,y)
    local result = nil
    local d = 999999999999
    for i,v in ipairs(list) do
        local dist = vl.dist(x,y,v.pos.x,v.pos.y)
        if dist < d then
            d = dist
            result = v
        end
    end
    return result
end

function g.removeFullCells(list)
    local result = {}
    for i,v in ipairs(list) do
        if v.obj == nil or v.obj.isDead then
            table.insert(result,v)
        end
    end
    return result
end

function g.removeEnemyCells(list,unit)
    local result = {}
    for i,v in ipairs(list) do
        if v.obj == nil or v.obj.team == unit.team then
            table.insert(result,v)
        end
    end
    return result
end

function g.returnWalkable(list)
    local result = {}
    for i,v in ipairs(list) do
        if v.walkable then
            table.insert(result,v)
        end
    end
    return result
end

function g.pickRandomCell(list)
    if #list == 0 then
        return nil
    elseif #list == 1 then
        return list[1]
    else
        local r = math.random(1,#list)
        return list[r]
    end
    return nil
end

function g.findCompliment(list1,list2)
    local result = {}
    for i,v in ipairs(list1) do
        local isInList2 = false
        for j,k in ipairs(list2) do
            if v.pos.x == k.pos.x and v.pos.y == k.pos.y then
                isInList2 = true
            end
        end
        if not isInList2 then table.insert(result,v) end
    end
    return result
end

--##########  SHAPE GENERATOR ############--

function g.newBox(r)
    local result = {}
    for x=-r,r do
        for y=-r,r do
            local newCell = g.newCell(x,y)
            table.insert(result,newCell)
        end
    end
    return result
end

function g.newCircle(r)
    local box = g.newBox(r+1)
    local result = {}
    for i,v in ipairs(box) do
        local d = vl.dist(v.pos.x,v.pos.y,0,0)
        if d <= r then
            table.insert(result,v)
        end
    end
    return result
end

function g.newRing(r1,r2)
    local result = {}
    if r1 > r2 then 
        r1,r2 = r2,r1
    end
    
    local box = g.newBox(r2+1)
    for i,v in ipairs(box) do
        local d = vl.dist(v.pos.x,v.pos.y,0,0)
        if d <= r2 and d>=r1 then
            table.insert(result,v)
        end
    end
    return result
end

function g.newCross(r)
    result = {}
    for x=-r,r do
        local newCell = g.newCell(x,0)
        table.insert(result, newCell)
    end
    for y=-r,r do
        local newCell = g.newCell(0,y)
        table.insert(result, newCell)
    end
    return result
end

function g.newStar(r)
    result = {}
    for x=-r,r do
        for y=-r,r do
            if x == y or -x == y or x==-y then
                local newCell = g.newCell(x,y)
                table.insert(result,newCell)
            end
        end
    end
    return result
end

function g.newShapeFromGrid(grid)
    --grid must be 2d array of 1's and 0's
    local result = {}
    local offset = math.floor(#grid[1]/2)
    for x,j in ipairs(grid) do
        for y,k in ipairs(j) do
            if k == 1 then
                local newCell = g.newCell(x-offset-1,y-offset-1)
                table.insert(result,newCell)
            end
        end
    end
    return result
end

function g.getGridDims(w,h)
    local uibarsize = 0.13 --percent of screen height

    --calculate space available for map
    local s = {w=lg:getWidth(),h=lg:getHeight()*(1-uibarsize)}
    local tw = 64
    
    --if not enough space exists, shrink the tiles
    while s.w/tw < w or s.h/tw < h do
        tw = tw - 1
    end    
    
    print ("tilesize after resize"..tw)
    
    local xo = (s.w-(tw*w))/2
    local yo = ((s.h-(tw*h))/2)+(lg:getHeight()*uibarsize)
    
    return tw,xo,yo
end

return g
