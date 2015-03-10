require ('lovedebug')
local lg = love.graphics
local vl = require('hump-master/vector-light')

local g = {}

function g.newGridArea(width,height,tilesize)
    o = {}
    o.tilelist = {}
    o.tileset = {}
    o.x, o.y = 0,0
    o.ts = tilesize
    o.tw = math.floor(width/tilesize)
    o.th = math.floor(height/tilesize)
    o.w = o.ts*o.tw
    o.h = o.ts*o.th
    g.generateTiles(o,o.tw,o.th,o.ts)
    o.draw = g.draw
    o.drawObjects = g.drawObjects
    return o
end

function g.setDrawLocation(self,x,y)
    self.x, self.y = x,y
end

function g.generateTiles(o,w,h,ts)
    for x=1,w do
        o.tileset[x] = {}
        for y=1,h do
            local newCell = {x=(x-1)*ts,y=(y-1)*ts,pos={x=x,y=y},obj=nil}
            table.insert(o.tilelist,newCell)
            o.tileset[x][y] = newCell
        end
    end
end

function g.draw(self)
    for i,v in ipairs(self.tilelist) do
        lg.setColor(255,255,255)
        lg.rectangle("line",v.x+self.x,v.y+self.y,self.ts,self.ts)
    end
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
        for i,v in ipairs(self.tilelist) do
            local dist = vl.dist(v.x+(self.ts/2),v.y+(self.ts/2),x,y)
            if dist<result.d then result = {c=v,d=dist} end
        end
    end
    return result.c
end

function g.stepDistance(self,c1,c2)
    return vl.dist(c1.pos.x,c1.pos.y,c2.pos.x,c2.pos.y)
end

function g.pixelDistance(self,c1,c2)
    return vl.dist(c1.x,c1.y,c2.x,c2.y)
end


return g
