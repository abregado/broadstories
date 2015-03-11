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


img = {}
img.fighter = lg.newImage('/assets/pdn4.png')
img.beastmaster = lg.newImage('/assets/smr4.png')
img.warlock = lg.newImage('/assets/npc5.png')
img.ranger = lg.newImage('/assets/ftr3.png')
img.demon = lg.newImage('/assets/dvl1.png')
img.mage = lg.newImage('/assets/amg2.png')
img.hellknight = lg.newImage('/assets/npc3.png')
img.goatlord = lg.newImage('/assets/npc6.png')

sheet = {}
sheet.sample = a8.newGrid(32,32,img.fighter:getWidth(),img.fighter:getHeight())

anims = {}
anims.stand = a8.newAnimation(sheet.sample(3,1),1)
anims.walk = a8.newAnimation(sheet.sample('3-4',1),0.3)

local font = lg.newFont()

local map = grid.newGrid(20,20,math.floor(lg:getHeight()/20),(lg:getWidth()-lg:getHeight())/2,0)
local control = pimp.new(map)

--[[
#############TODOS###############

unit manager take and place

]]
local px,py = 1,1
local collected = nil

--local shape = grid.newStar(5)
local shape = grid.newShapeFromGrid({{1,1,1,1,1},{1,1,1,1,1},{1,1,1,1,1},{1,1,1,1,1},{1,1,1,1,1}})

function love.load()
    lg.setDefaultFilter('nearest','nearest')
    gs.registerEvents()
    gs.switch(game)
    pimp.addUnit(control,grid.findTileAtPos(map,3,1))
    pimp.addUnit(control,grid.findTileAtPos(map,4,1))
    pimp.addUnit(control,grid.findTileAtPos(map,5,1))
    pimp.addUnit(control,grid.findTileAtPos(map,6,1))
    dude.setClassRanger(control.units[1])
    dude.setClassMage(control.units[2])
    dude.setClassBeastmaster(control.units[3])
    print("shape length: "..#shape)
    
    control:update()
end

function love.quit()
end


function love.update(dt)
    tut.update(dt)
    anims.stand:update(dt)
    anims.walk:update(dt)
end

function love.mousepressed(x,y,button)
    
    local tile = grid.findTileAtCoord(map,x,y)
    if tile and collected then
        if tile.obj == nil and grid.checkCellInList(tile,collected.moves) then
            pimp.placeUnit(control,tile,collected)
            collected = nil
        end
    elseif tile and tile.obj and not collected then
        collected = pimp.takeUnit(control,tile)
    end
    
end

function love.draw()
    local scale = 1.5
    local step = 0
    for i,v in pairs(img) do
        anims.walk:draw(v,0,step*scale*32,0,scale,scale)
        step = step + 1
    end
    local mx,my = lm.getPosition()
    lg.setFont(font)
    map:draw()
    map:drawObjects()
    if collected then
        collected:draw(mx,my,true)
        local ox,oy = grid.getCenter(map,collected.cell)
        lg.line(mx,my,ox,oy)
        for i,v in ipairs(collected.moves) do
            lg.setColor(0,0,255,60)
            local x,y = grid.getOrigin(map,v)
            lg.rectangle("fill",x,y,map.ts,map.ts)
        end
        local hoverCell = grid.findTileAtCoord(map,mx,my)
        if hoverCell then
            local attackArea = grid.displaceList(map,collected.attackShape,hoverCell.pos.x,hoverCell.pos.y)
            for i,v in ipairs(attackArea) do
                    lg.setColor(255,0,0,60)
                    local x,y = grid.getOrigin(map,v)
                    lg.rectangle("fill",x,y,map.ts,map.ts)
            end
        end
    end
    
    
    tut.draw()
end

function love.keypressed(key)
    if key == "escape" then love.event.quit() 
    elseif key == " " then control:update() end
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
