local grid = require('grid')
local lgen = {}


local dudeTypes = {
    {class="Thief",cost=1},
    {class="Thief",cost=1},
    {class="Thief",cost=1},
    {class="Thief",cost=1},
    {class="Thief",cost=1},
    {class="Thief",cost=1},
    {class="Thief",cost=1},
    {class="Demon",cost=3},
    {class="Warlock",cost=4},
    {class="ThiefArcher",cost=2},
    {class="Tough",cost=4}
    }
    
local heroTypes = {"Fighter","Mage","Beastmaster","Ranger"}
    

function lgen.generate(threat,width,height,heroes)
    local entList = {}
    local takenPlaces = {}
    local breakout = 0
    local points = threat
    
    for i=0, threat do
        local randType = math.random(1,#dudeTypes)
        local choice = dudeTypes[randType]
        --place randomly in bottom half
        local rx = math.floor(math.random(1,width-1))
        local ry = math.floor(math.random(1,height/2)+(height/2)-1)
        if checkPosFree(entList,rx,ry) and points >= choice.cost then
            table.insert(entList,{class=choice.class,x=rx,y=ry})
            points = points - choice.cost
        end
    end
    
    
    for i=1,heroes do
        local choice = "Fighter"
        if i <= # heroTypes then
            choice = heroTypes[i]
        end
        --place randomly in top quarter
        local rx = math.floor(math.random(1,width))
        local ry = math.floor(math.random(1,3))
        if checkPosFree(entList,rx,ry) then
            table.insert(entList,{class=choice,x=rx,y=ry})
        end
    end
    
    return entList    
end

function lgen.spawn(entList,controller)
    for i,v in ipairs(entList) do
        local tileLoc = grid.findTileAtPos(controller.map,v.x,v.y)
        --print(v.x,v.y,tileLoc,v.class)
        controller:addUnit(tileLoc,v.class)
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
