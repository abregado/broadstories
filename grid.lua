require ('lovedebug')
local lg = love.graphics
local vl = require('hump-master/vector-light')

local g = {}

function g.newGridArea(width,height,tilesize,ox,oy)
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
    o.drawObjects = g.drawObjects
    return o
end

function g.newGrid(width,height,tilesize,ox,oy)
    o = {}
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
    return o
end

function g.setDrawLocation(self,x,y)
    self.x, self.y = x,y
end

function g.generateTiles(o,w,h,ts)
    for x=0,w-1 do
        o.tileset[x] = {}
        for y=0,h-1 do
            local newCell = {pos={x=x,y=y},obj=nil}
            table.insert(o.tilelist,newCell)
            o.tileset[x][y] = newCell
        end
    end
end


function g.draw(self)
    for i,v in ipairs(self.tilelist) do
        lg.setColor(255,255,255)
        local x,y = g.getOrigin(self,v)
        lg.rectangle("line",x,y,self.ts,self.ts)
    end
    lg.setColor(0,255,0)
    lg.rectangle("line",self.x,self.y,self.w,self.h)
end

function g.drawObjects(self)
    for i,v in ipairs(self.tilelist) do 
        if v.obj then
            --lg.setColor(v.obj.color)
            --lg.rectangle("fill",v.x+self.x,v.y+self.y,self.ts,self.ts)
            v.obj:draw()
        end
    end
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
        print("out of bounds")
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
    return ((tile.pos.x+0.5)*self.ts)+self.x, ((tile.pos.y+0.5)*self.ts)+self.y
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
    
    --remove duplicates
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

return g
