local grid = require('grid')
local pimp = require('pimpdog')
local lgen = require('levgen')
local a8 = require('anim8')

imp = {}

function imp.import(levelLua,blockTileList,unitTypes,spriteList)
    
    --generate map from tiled dimensions (normal grid)
    local w,h = levelLua.width,levelLua.height
    local tw,xo,yo = grid.getGridDims(w,h)
    local map = grid.newGrid(w,h,tw,xo,yo)
    --modify grid object to handle:
        --import tileset data, store in grid object
        imp.importTileset(map,levelLua)
        --assign tileset values to cells
        imp.assignTilesetData(map,levelLua)
        --block tiles from the blockTileList
        imp.blockCells(map,blockTileList)
        
        --update cell draw
    
    --generate entity controller
    local control = pimp.new(map,unitTypes,spriteList)
      
    --add ents from level data
    imp.importEnts(map,control,levelLua,unitTypes)
    --check if there are any units on team 1 (otherwise generate new ones)
    --check if there are any units on team 2 (otherwise generate new ones)
    
    --generate new gamestate providing grid and control objects
    --return new gamestate
    return game.new(map,control)
end

function imp.importEnts(map,control,levelLua,unitTypes)
    print("starting ent import")
    if levelLua.layers[2] then
        local importData = levelLua.layers[2].data
        
        for i,v in ipairs(importData) do
            if v > 0 then
                local y = math.ceil(i/map.tw)
                local x = math.floor(i-((y-1)*map.tw))
                local cell = grid.findTileAtPos(map,x-1,y-1)
                local team = ENEMYTEAM or -1
                if unitTypes[v] and unitTypes[v].hero then team = PLAYERTEAM or 1 end
                control:addUnit(cell,v,team)
            end
        end
    end
            
end

function imp.importTileset(map,levelLua)
    --import tileset file from location
    
    local path = string.sub(levelLua.tilesets[1].image,3)
    
    print("importing tileset graphics from",path)
    map.spriteSheet = lg.newImage(path)
    print("done.")
    --generates a list of quads
    map.tileQuads = a8.newGrid(levelLua.tilewidth,levelLua.tileheight,map.spriteSheet:getWidth(),map.spriteSheet:getHeight())
end

function imp.assignTilesetData(map,levelLua)
    print("assigning tile data")
    --moves through cells and assigns a graphical tile number
    local importData = levelLua.layers[1].data
    for i,v in ipairs(map.tilelist) do
        local i = ((v.pos.y)*(map.tw))+v.pos.x+1
        v.imgNum = importData[i]
    end
    
end

function imp.blockCells(map,blockTileList)
    print("blocking cells")
    --disables all cells which have been assigned a graphical tile number that is listed in the blockTileList
    for i,v in ipairs(map.tilelist) do
        local walkable = true
        for j,k in ipairs(blockTileList) do
            if k == v.imgNum then walkable = false end
        end
        v.walkable = walkable
        --deactivate all cells with graphic tile 0
        if v.imgNum == 0 then v.active = false v.walkable = false end
    end            
end

function imp.updateFunctions(map)
    --replace the grid draw with the new one in this class
end

function imp.newDraw(self)
    for i,v in ipairs(self.tilelist) do
        local x,y = g.getOrigin(self,v)
        if v.obj then
            lg.setColor(objColor)
        else
            lg.setColor(cellColor)
        end
        lg.rectangle("fill",x,y,self.ts,self.ts)
        lg.setColor(gridColor)
        lg.rectangle("line",x,y,self.ts,self.ts)
    end
    lg.setColor(0,255,0)
    lg.rectangle("line",self.x,self.y,self.w,self.h)
end

return imp
