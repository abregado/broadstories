DEBUG_MODE = true
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
sd = require('ui/shapeDraw')
modloader = require('modloader')

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
unitImg[14] = lg.newImage('/assets/wmn1.png') --pyromancer

attackImg = {}
attackImg[1] = lg.newImage('assets/icon_78.png') --thrown dagger
attackImg[2] = lg.newImage('assets/icon_94.png') --ice spear
attackImg[3] = lg.newImage('assets/icon_95.png') --fire spear
attackImg[4] = lg.newImage('assets/icon_93.png') --arrow
attackImg[5] = lg.newImage('assets/icon_100.png') --sword
attackImg[6] = lg.newImage('assets/icon_101.png') --bow
attackImg[7] = lg.newImage('assets/icon_61.png') --magic
attackImg[8] = lg.newImage('assets/fireball.png') --fireball
attackImg[9] = lg.newImage('assets/firespear.png') --firespear
attackImg[10] = lg.newImage('assets/icon_08.png') --staff

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
img.flag = lg.newImage('/assets/flag2.png')
img.book = lg.newImage('/assets/book.png')


levels = {}
levels[1] = require('levels/broadstories_introLevel')
levels[2] = require('levels/broadstories_archerIntro')
levels[3] = require('levels/broadstories_MageIntro')
levels[4] = require('levels/broadstories_l1')
levels[5] = require('levels/broadstories_l2')
levels[6] = require('levels/gameboy1')
levels[7] = require('levels/fantasy1')

--img.tileset = lg.newImage(levels.demo.tilesets[1].image)

sheet = {}
sheet.sample = a8.newGrid(32,32,unitImg[1]:getWidth(),unitImg[1]:getHeight())
--sheet.terrain = a8.newGrid(levels.demo.tilewidth,levels.demo.tileheight,img.tileset:getWidth(),img.tileset:getHeight())

anims = {}
anims.stand = a8.newAnimation(sheet.sample(3,1),1)
anims.walk = a8.newAnimation(sheet.sample('3-4',1),0.3)

threatLevel = 0
levelProg = 1
wins = 0
losses = 0


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



function love.load(args)
    local FSmodes = love.window.getFullscreenModes(1)
    local highMode = FSmodes[1]
    local lowMode = FSmodes[#FSmodes]
    love.window.setMode(lowMode.width,lowMode.height,{fullscreen=false}) 
    
    if args then
        for i,v in ipairs(args) do
            print (v)
            
            if v == "--fs" or v == "--fullscreen" then toggleFullscreen() end 
        end
    end
    lg.setDefaultFilter('nearest','nearest')
    gs.registerEvents()
    buildNextLevel()
    
    --tweening values
    globTweens = {}
    globTweens.jiggle = {tween=nil,val=0.8,low=0.8,high=1}
    globTweens.grow = {tween=nil,val=1,low=1,high=1.2}
    
    setupTweens()
    
    modloader.checkStructure()
end

function toggleFullscreen()
    local FSmodes = love.window.getFullscreenModes(1)
    local highMode = FSmodes[1]
    local lowMode = FSmodes[#FSmodes]
    local fs = love.window.getFullscreen()
    if fs then
        love.window.setMode(lowMode.width,lowMode.height,{fullscreen=false}) 
    else
        love.window.setMode(highMode.width,highMode.height,{fullscreen=true}) 
    end
    buildNextLevel()
end

function love.keypressed(key)
    if key == "s" then
        -- To open a file or folder, "file://" must be prepended to the path.
        love.system.openURL("file://"..love.filesystem.getSaveDirectory())
    elseif key == "l" then
        modloader.loadUnits(unitTypes)
    elseif key == 'f7' then
        toggleFullscreen()
    end
end

function setupTweens()
    for i,v in pairs(globTweens) do
        v.val = v.low
        v.tween = tween.new(0.5,v,{val=v.high},'linear')
    end
end

function love.update(dt)
    for i,v in pairs(globTweens) do
        local complete = v.tween:update(dt)
        if complete and v.val == v.low then
            v.tween = tween.new(0.5,v,{val=v.high},'linear')
        elseif complete and v.val == v.high then
            v.tween = tween.new(0.5,v,{val=v.low},'linear')
        end
    end
end

function love.quit()
end

function buildNextLevel()
    if levels[levelProg] then
        gs.switch(importer.import(levels[levelProg],unitTypes,unitImg))
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
