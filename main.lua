DEBUG_MODE = false
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

local font = lg.newFont()

local map = grid.newGrid(10,10,64,100,100)
local control = pimp.new(map)

--[[
#############TODOS###############

edge placement issue? 
    Either search function, draw or too many cells are being made

Setter functions for grid. Objects cant be placed directly into the grid

unit manager take and place

]]
local px,py = 1,1
local collected = nil

function love.load()
    gs.registerEvents()
    gs.switch(game)
    pimp.addUnit(control,grid.findTileAtPos(map,3,1))
    pimp.addUnit(control,grid.findTileAtPos(map,4,1))
    pimp.addUnit(control,grid.findTileAtPos(map,5,1))
    pimp.addUnit(control,grid.findTileAtPos(map,6,1))
    pimp.addUnit(control,grid.findTileAtPos(map,7,1))
end

function love.quit()
end


function love.update(dt)
    tut.update(dt)
    
end

function love.mousepressed(x,y,button)
    
    local tile = grid.findTileAtCoord(map,x,y)
    if tile and collected then
        if tile.obj == nil and grid.checkCellInList(tile,collected.moves) then
            collected:arrive(tile,map)
            collected = nil
        end
    elseif tile and tile.obj and not collected then
        collected = tile.obj
        tile.obj = nil
    end
    
    print("mouse clicked")
end

function love.draw()
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
    end
    tut.draw()
end

function love.keypressed(key)

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
