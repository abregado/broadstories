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

local map = grid.newGridArea(lg.getWidth(),lg.getHeight(),64)
local control = pimp.new(map)

--[[
#############TODOS###############
grid object
  generate grid given screensize/tilesize
  generate grid of W,H of given tilesize
  stores display location (x,y)
  stores own heigh and width
  draw function to call draw of cells
  1D and 2D array lookups (store as both, modify references)
  get tile from X,Y input
  tiled input
  distance calulation
  grid object only used for reference!!! it does not modify the cell objects at all!!!

cell objects
  draw
  own color
  grid parent
  
functionality phase 1
  cell that mouse is on becomes highlighted
  click and then all cells with x range become highlighted

functionality phase 2
  click a cell with contents
  record cell
  show ghost contents with line connecting
  click elsewhere to move the contents to the new cell

functionality phase 3


]]
local px,py = 1,1

function love.load()
    gs.registerEvents()
    gs.switch(game)
    pimp.addUnit(control,grid.findTileAtPos(map,3,3))
end

function love.quit()
end


function love.update(dt)
    tut.update(dt)
    
end

function love.mousepressed(x,y,button)
    --[[local tile = grid.findTileAtCoord(map,x,y)
    if tile and tile.obj == nil then
        tile.obj = {color={255,0,0}}
    elseif tile then
        tile.obj=nil
    end
    print("mouse clicked")]]
end

function love.draw()
    lg.setFont(font)
    map:draw()
    map:drawObjects()
    tut.draw()
end

function love.keypressed(key)
   --[[if key == "up" then
        py = py -1
    elseif key == "down" then
        py = py +1
    elseif key == "left" then
        px = px -1
    elseif key == "right" then
        px = px +1
    end
    
    local tile = grid.findTileAtPos(map,px,py)
    if tile and tile.obj == nil then
        tile.obj = {color={0,255,0}}
    elseif tile then
        tile.obj=nil
    end
    ]]
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
