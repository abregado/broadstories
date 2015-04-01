local grid = require('grid')
local lgen = {}

function lgen.generate(control,heroes,threat)
    lgen.generateEnemies(control,threat)
    lgen.generateHeroes(control,heroes)
end

function lgen.generateHeroes(control,num)
    local map = control.map
    
    local tileList = grid.joinLists(grid.findAllAtY(map,0),grid.findAllAtY(map,1))
    tileList = grid.returnWalkable(tileList)
    
    for i=1,num do
        local randTile = math.random(1,#tileList)
        local cell = table.remove(tileList,randTile)
        control:addUnit(cell,i,PLAYERTEAM or 1)
    end
end

function lgen.generateEnemies(control,threat)
    local map = control.map
    local tileList = grid.joinLists(grid.findAllAtY(map,map.th-1),grid.findAllAtY(map,map.th-2))
    tileList = grid.returnWalkable(tileList)
    local enemyList = {}
    local rand = math.random(1,2)
    
    for i,v in pairs(control.unitTypes) do
        if v.weight > 0 then
            v.id = i
            for i=1,v.weight do
                table.insert(enemyList,v)
            end
        end
    end
    print(#tileList,#enemyList)
    
    local spent = 0
    for i=1,10 do
        lgen.trimListToCost(enemyList,threat-spent)
        if threat > spent and #enemyList > 1 and #tileList > 1 then
            rand = math.random(1,#tileList)
            local cell = table.remove(tileList,rand)
            rand = math.random(1,#enemyList)
            local dude = enemyList[rand]
            control:addUnit(cell,dude.id,ENEMYTEAM or 2)
            spent = spent + dude.cost
        end
    end
end

function lgen.trimListToCost(list,cost)
    for i,v in ipairs(list) do
        if v.cost > cost then
            table.remove(list,i)
        end
    end
end

function checkPosFree(list,x,y)
    for i,v in ipairs(list) do
        if v.x == x and v.y == y then
            return false
        end
    end
    return true
end

return lgen
