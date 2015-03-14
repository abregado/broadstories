DEBUG_MODE = true
if DEBUG_MODE then require ('lovedebug') end
gs = require('hump-master/gamestate') 

lg = love.graphics
lm = love.mouse
tut = require('tutorial')
td = tut.td
game = require('state_game')
vl= require('hump-master/vector-light')
grid = require('grid')
pimp = require('pimpdog')
dude = require('dude')
a8 = require('anim8')
tween = require('tween')
aa = require('attackAnim')


img = {}
img.fighter = lg.newImage('/assets/pdn4.png')
img.beastmaster = lg.newImage('/assets/smr4.png')
img.warlock = lg.newImage('/assets/npc5.png')
img.ranger = lg.newImage('/assets/ftr3.png')
img.demon = lg.newImage('/assets/dvl1.png')
img.mage = lg.newImage('/assets/amg2.png')
img.hellknight = lg.newImage('/assets/npc3.png')
img.goatlord = lg.newImage('/assets/npc6.png')
img.thief1 = lg.newImage('/assets/thf1.png')
img.thief2 = lg.newImage('/assets/thf2.png')
img.thief3 = lg.newImage('/assets/thf3.png')
img.thief4 = lg.newImage('/assets/thf4.png')
img.boy = lg.newImage('/assets/ybo1.png')
img.girl = lg.newImage('/assets/ygr1.png')
img.skelly = lg.newImage('/assets/skl1.png')

img.heart = lg.newImage('/assets/heart_0.png')
img.attack = lg.newImage('/assets/attack.png')
img.damage = lg.newImage('/assets/damage.png')
img.skull = lg.newImage('/assets/skull.png')
img.blueicon = lg.newImage('/assets/blueicon.png')
img.orangeicon = lg.newImage('/assets/orangeicon.png')
img.shield = lg.newImage('/assets/icon_12.png')
img.hit = lg.newImage('/assets/icon_82.png')

sheet = {}
sheet.sample = a8.newGrid(32,32,img.fighter:getWidth(),img.fighter:getHeight())

anims = {}
anims.stand = a8.newAnimation(sheet.sample(3,1),1)
anims.walk = a8.newAnimation(sheet.sample('3-4',1),0.3)

local font = lg.newFont()

local map = grid.newGridArea(lg:getWidth()*.75,lg:getHeight()*.75,64,lg:getWidth()/8,lg:getHeight()/8)
local control = pimp.new(map)

--[[
#############TODOS###############

dt based phasing control

attack animations
    new attack animation object to get added to animRegister
    new function which adds attack anims based on damage
        this function must keep a list of attackers
        collect animation data from attackers (different attack types)
        show who is being attacked AND who is attacking
    new function which adds damage anims based on attacks
        floating -1 hearts
    new function which adds death anims based on kills
        floating skull and unit fadeout

win/lose flyups
    Move current level to new gamestate
    master gamestate for level generation
        stats first level
    to/from temporary gamestates with Win/lose flyups
    constructors for these temporary gamestates
    reason text passed to new gamestates

win/lose conditions
    Win, all enemies defeated
    Win, enemies cannot defeat you
    Lose, all heros destroyed
    Lose, heros cannot defeat enemies
    after win/lose, return to main gamestate and get a new level
    

]]
local px,py = 1,1
local collected = nil

inputAccepted = true

--local shape = grid.newStar(5)
local shape = grid.newShapeFromGrid({{1,1,1,1,1},{1,1,1,1,1},{1,1,1,1,1},{1,1,1,1,1},{1,1,1,1,1}})

function love.load()
    lg.setDefaultFilter('nearest','nearest')
    gs.registerEvents()
    gs.switch(game)
    pimp.addUnit(control,grid.findTileAtPos(map,3,1),"Fighter")
    pimp.addUnit(control,grid.findTileAtPos(map,4,1),"Mage")
    pimp.addUnit(control,grid.findTileAtPos(map,5,1),"Beastmaster")
    pimp.addUnit(control,grid.findTileAtPos(map,6,1),"Ranger")
    pimp.addUnit(control,grid.findTileAtPos(map,math.floor(map.tw/2),map.th-2),"Thief")
    pimp.addUnit(control,grid.findTileAtPos(map,math.floor(map.tw/2)-2,map.th-2),"Thief")
    pimp.addUnit(control,grid.findTileAtPos(map,math.floor(map.tw/2)-4,map.th-2),"Thief")
    pimp.addUnit(control,grid.findTileAtPos(map,math.floor(map.tw/2)-6,map.th-2),"Thief")
    pimp.addUnit(control,grid.findTileAtPos(map,math.floor(map.tw/2)+2,map.th-2),"Thief")
    pimp.addUnit(control,grid.findTileAtPos(map,math.floor(map.tw/2)+4,map.th-2),"Thief")
    pimp.addUnit(control,grid.findTileAtPos(map,math.floor(map.tw/2),map.th-3),"Thief")
    pimp.addUnit(control,grid.findTileAtPos(map,math.floor(map.tw/2)-2,map.th-3),"Thief")
    pimp.addUnit(control,grid.findTileAtPos(map,math.floor(map.tw/2)-4,map.th-3),"Thief")
    pimp.addUnit(control,grid.findTileAtPos(map,math.floor(map.tw/2)-6,map.th-3),"Thief")
    pimp.addUnit(control,grid.findTileAtPos(map,math.floor(map.tw/2)+2,map.th-3),"Thief")
    pimp.addUnit(control,grid.findTileAtPos(map,math.floor(map.tw/2)+4,map.th-3),"Thief")

    print("shape length: "..#shape)
    
    --control:endTurn()
end

function love.quit()
end


function love.update(dt)
    tut.update(dt)
    anims.stand:update(dt)
    anims.walk:update(dt)
    inputAccepted = control:update(dt)
        
    
end

function love.mousepressed(x,y,button)
    if inputAccepted then
        local tile = grid.findTileAtCoord(map,x,y)
        if tile and collected then
            if tile.obj == nil and grid.checkCellInList(tile,collected.moves) then
                pimp.placeUnit(control,tile,collected)
                collected = nil
            end
        elseif tile and tile.obj and not collected and not tile.obj.npc then
            collected = pimp.takeUnit(control,tile)
        end
    end
end

function love.draw()
    local hoverCell = nill
    --[[local scale = 1.5
    local step = 0
    for i,v in pairs(img) do
        anims.walk:draw(v,0,step*scale*32,0,scale,scale)
        step = step + 1
    end]]
    local mx,my = lm.getPosition()
    lg.setFont(font)
    map:draw()
    
    control:draw()
    --map:drawObjects()
    if collected then
        collected:draw(mx,my,true)
        local ox,oy = grid.getCenter(map,collected.cell)
        lg.line(mx,my,ox,oy)
        for i,v in ipairs(collected.moves) do
            lg.setColor(0,0,255,90)
            local x,y = grid.getOrigin(map,v)
            lg.rectangle("fill",x,y,map.ts,map.ts)
        end
        hoverCell = grid.findTileAtCoord(map,mx,my)
        if hoverCell then
            local attackArea = grid.displaceList(map,collected.attackShape,hoverCell.pos.x,hoverCell.pos.y)
            for i,v in ipairs(attackArea) do
                    lg.setColor(255,0,0,30)
                    local x,y = grid.getOrigin(map,v)
                    lg.rectangle("fill",x,y,map.ts,map.ts)
            end
        end
    else
        hoverCell = grid.findTileAtCoord(map,mx,my)
        
        if hoverCell and hoverCell.obj then
            local ox,oy = grid.getCenter(map,hoverCell.obj.cell)
            lg.line(mx,my,ox,oy)
            for i,v in ipairs(hoverCell.obj.moves) do
                lg.setColor(0,0,255,30)
                local x,y = grid.getOrigin(map,v)
                lg.rectangle("fill",x,y,map.ts,map.ts)
            end
        
            local attackArea = grid.displaceList(map,hoverCell.obj.attackShape,hoverCell.pos.x,hoverCell.pos.y)
            for i,v in ipairs(attackArea) do
                    lg.setColor(255,0,0,90)
                    local x,y = grid.getOrigin(map,v)
                    lg.rectangle("fill",x,y,map.ts,map.ts)
            end
            hoverCell.obj:draw(nil,nil,true)
        end
    end
    
    if not inputAccepted then
        lg.setColor(255,0,0)
        lg.setLineWidth(5)
        lg.rectangle("line",map.x-1,map.y-1,map.w+2,map.h+2)
        lg.setLineWidth(1)
    end
    
    tut.draw()
end

function love.keypressed(key)
    if inputAccepted then
        if key == "escape" then love.event.quit() 
        elseif key == " " then control:endTurn() end
        
    end
end

function love.graphics.ellipse(mode, x, y, a, b, phi, points)
  phi = phi or 0
  points = points or 10
  if points <= 0 then points = 1 end

  local two_pi = math.pi*2
  local angle_shift = two_pi/points
  local theta = 0
  local sin_phi = math.sin(phi)
  local cos_phi = math.cos(phi)

  local coords = {}
  for i = 1, points do
    theta = theta + angle_shift
    coords[2*i-1] = x + a * math.cos(theta) * cos_phi 
                      - b * math.sin(theta) * sin_phi
    coords[2*i] = y + a * math.cos(theta) * sin_phi 
                    + b * math.sin(theta) * cos_phi
  end

  coords[2*points+1] = coords[1]
  coords[2*points+2] = coords[2]

  love.graphics.polygon(mode, coords)
end


function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end
