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

maingame = game.new()

--[[
#############TODOS###############

attack animations
    shooting at target animation

BUG: sometimes dead guys still act!!!

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



function love.load()
    lg.setDefaultFilter('nearest','nearest')
    gs.registerEvents()
    gs.switch(maingame)

end

function love.quit()
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
