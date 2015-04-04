local grid = require('grid')
local pimp = require('pimpdog')
local lgen = require('levgen')
local a8 = require('anim8')

imp = {}

function imp.import(levelLua,unitTypes,spriteList)
    
    --generate map from tiled dimensions (normal grid)
    local w,h = levelLua.width,levelLua.height
    local tw,xo,yo = grid.getGridDims(w,h)
    local map = grid.newGrid(w,h,tw,xo,yo)
    
    --buildBlocktileList
    local blockTileList = imp.buildBlocked(levelLua)
    
    --modify grid object to handle:
        --import tileset data, store in grid object
        imp.importTileset(map,levelLua)
        --assign tileset values to cells
        imp.assignTilesetData(map,levelLua)
        --block tiles from the blockTileList
        imp.blockCells(map,blockTileList)
        
        --update cell draw
        imp.updateFunctions(map)
    
    --generate entity controller
    local control = pimp.new(map,unitTypes,spriteList)
      
    --add ents from level data
    imp.importEnts(map,control,levelLua,unitTypes)
    --check if there are any units on team 1 (otherwise generate new ones)
    if control:countTeamMembers(PLAYERTEAM or 1) == 0 then
        lgen.generateHeroes(control,4)
    end
    
    --check if there are any units on team 2 (otherwise generate new ones)
    if control:countTeamMembers(ENEMYTEAM or 2) == 0 then
        lgen.generateEnemies(control,threatLevel or 6)
    end
    
    --generate new gamestate providing grid and control objects
    --return new gamestate
    return game.new(map,control)
end

function imp.buildBlocked(levelLua)
    local list = {}
    for i,v in pairs(levelLua.tilesets[1].tiles) do
        table.insert(list,v.id+1)
    end
    return list
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
    map.tileQuads = imp.buildQuadList(levelLua.tilesets[1].tilewidth,levelLua.tilesets[1].tileheight,levelLua.tilesets[1].imagewidth,levelLua.tilesets[1].imageheight)
    map.scale = map.ts/levelLua.tilesets[1].tilewidth
end

function imp.buildQuadList(tw,th,w,h)
    local quads = {}
    for i=0,math.floor(h/th)-1 do
        for j=0,math.floor(w/tw)-1 do
            table.insert(quads,lg.newQuad(j*tw,i*th,tw,th,w,h))
        end
    end
    return quads
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
    map.draw = imp.newDraw
end

function imp.newDraw(self)
    --lg.draw(self.spriteSheet,0,0)
    for i,v in ipairs(self.tilelist) do
        if v.active then
            lg.setColor(255,255,255)
            local x,y = grid.getOrigin(self,v)
            --lg.circle("fill",x,y,5,5)
            local quad = self.tileQuads[v.imgNum] or lg.newQuad(0,0,32,32,256,320)
            lg.draw(self.spriteSheet,quad,x,y,0,self.scale,self.scale)
        end
    end
end

return imp
