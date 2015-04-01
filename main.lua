DEBUG_MODE = false
if DEBUG_MODE then require ('lovedebug') end
gs = require('hump-master/gamestate') 

lg = love.graphics
lm = love.mouse
tut = require('tutorial')
td = tut.td
game = require('state_game')
trans = require('state_trans')
lgen = require('levgen')
vl= require('hump-master/vector-light')
grid = require('grid')
pimp = require('pimpdog')
unitTypes = require('unitTypes')
dude = require('dude')
a8 = require('anim8')
tween = require('tween')
aa = require('attackAnim')
uicon = require('UIcontroller')
ibut = require('ui/iconButton')
importer = require('importer')

PLAYERTEAM = 1
ENEMYTEAM = 2


unitImg = {}
unitImg[1] = lg.newImage('/assets/skl1.png') --skelly
unitImg[2] = lg.newImage('/assets/ybo1.png') --generic boy
unitImg[3] = lg.newImage('/assets/pdn4.png') --fighter
unitImg[4] = lg.newImage('/assets/ftr3.png') --ranger
unitImg[5] = lg.newImage('/assets/amg2.png') --mage
unitImg[6] = lg.newImage('/assets/smr4.png') --beastmaster
unitImg[7] = lg.newImage('/assets/thf1.png')
unitImg[8] = lg.newImage('/assets/thf2.png')
unitImg[9] = lg.newImage('/assets/thf3.png')
unitImg[10] = lg.newImage('/assets/thf4.png') 
unitImg[11] = lg.newImage('/assets/npc6.png') --goatlord
unitImg[12] = lg.newImage('/assets/npc5.png') --warlock
unitImg[13] = lg.newImage('/assets/dvl1.png') --demon



img = {}
img.heart = lg.newImage('/assets/heart_0.png')
img.attack = lg.newImage('/assets/attack.png')
img.damage = lg.newImage('/assets/damage.png')
img.skull = lg.newImage('/assets/skull.png')
img.blueicon = lg.newImage('/assets/blueicon.png')
img.orangeicon = lg.newImage('/assets/orangeicon.png')
img.shield = lg.newImage('/assets/icon_12.png')
img.hit = lg.newImage('/assets/icon_82.png')
img.endturn = lg.newImage('/assets/endturn.png')
img.retreat = lg.newImage('/assets/retreat.png')
img.cog = lg.newImage('/assets/settings.png')

levels = {}
levels[1] = require('levels/broadstories_introLevel')
levels[2] = require('levels/broadstories_archerIntro')
levels[3] = require('levels/broadstories_MageIntro')
levels[4] = require('levels/broadstories_l1')
levels[5] = require('levels/broadstories_l2')

--img.tileset = lg.newImage(levels.demo.tilesets[1].image)

sheet = {}
sheet.sample = a8.newGrid(32,32,unitImg[1]:getWidth(),unitImg[1]:getHeight())
--sheet.terrain = a8.newGrid(levels.demo.tilewidth,levels.demo.tileheight,img.tileset:getWidth(),img.tileset:getHeight())

anims = {}
anims.stand = a8.newAnimation(sheet.sample(3,1),1)
anims.walk = a8.newAnimation(sheet.sample('3-4',1),0.3)

threatLevel = 4
levelProg = 1

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
    buildNextLevel()
end

function love.quit()
end

function buildNextLevel()
    if levels[levelProg] then
        gs.switch(importer.import(levels[levelProg],{10},unitTypes,unitImg))
    else
        gs.switch(game.new())
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
