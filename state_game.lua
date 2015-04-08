local game = {}

local font = lg.newFont()

inputAccepted = true

function game.new(map,control,tutorial)
    local state = {}
    
    if map then
        state.map = map
    else
        local mw = math.random(10,18)
        local mh = math.random(8,13)
        local tw,xo,yo = grid.getGridDims(mw,mh)
        state.map = grid.newGrid(mw,mh,tw,xo,yo)
    end
    
    if control then
        state.control = control
    else
        state.control = pimp.new(state.map,unitTypes,unitImg)
    end
    
    state.lastTouch = {x=0,y=0}
    
    state.ui = uicon.new(state)
    
    --init UI buttons. move to separate class later
    local buttonHeight = lg:getHeight()-state.map.h-4
    if buttonHeight > 72 then buttonHeight = 72 end

    
    local etbut = ibut.new(lg:getWidth()-(buttonHeight*1.5),0,state.ui,img.endturn,true,buttonHeight*1.5,buttonHeight)
    local sbut = ibut.new(4+(buttonHeight*1.5),0,state.ui,img.book,true,buttonHeight*1.5,buttonHeight)
    local rbut = ibut.new(0,0,state.ui,img.flag,true,buttonHeight*1.5,buttonHeight)

    rbut.click = function() state:triggerRestart() end
    etbut.click = function() state:startNextPhase() end
    sbut.click = function() state:triggerSkip() end
    state.ui:addElement(etbut)
    state.ui:addElement(rbut)
    
    if DEBUG_MODE then
        local dbut = ibut.new(4+(buttonHeight*3),0,state.ui,img.cog,true,buttonHeight*1.5,buttonHeight)
        dbut.click = function() print("clicked debug button") bugger.drawOverlay = not bugger.drawOverlay end
        state.ui:addElement(dbut)
    end
    
    if control and map then 
        state.ui:addElement(sbut)
    end
    
    state.collected = nil
    
    state.phase = 0
    
    state.update = game.update
    state.startNextPhase = game.startNextPhase
    state.checkVictory = game.checkVictory
    state.triggerVictory = game.triggerVictory
    state.checkRetreat = game.checkRetreat
    state.triggerRetreat = game.triggerRetreat
    state.triggerRestart = game.triggerRestart
    state.triggerSkip = game.triggerSkip
    
    if sys == "Android" then
        state.touchpressed = game.touchpressed
        state.touchreleased = game.touchreleased
        state.touchmoved = game.touchmoved
        state.draw = game.drawAndroid
    else
        state.keypressed = game.keypressed
        state.mousepressed = game.mousepressed
        state.mousereleased = game.mousereleased
        state.draw = game.draw
    end
    
    if not control then
        lgen.generate(state.control,4,threatLevel)
        print('populated by default')
    end
    
    
    
    inputAccepted = true
    
    tut.clearTuts()
    if levelProg < 7 then
        game.setupTuts[levelProg](state.control.units[1],etbut,sbut,rbut)
    elseif levelProg == #levels+1 then
        game.setupTuts[7](state.control.units[1],etbut,sbut,rbut)
    end
    
    return state
end

game.setupTuts = {}

game.setupTuts[1] = function (hero,etbutton,sbutton,rbutton)
    td = tut.td
    
    local intro = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5*1.1,"center","Welcome to the Broadstories Prototype. Please play through this short tutorial to learn how to play the game.",nil,false)
    local intro2 = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","You can skip any tutorial level by clicking this button.",nil,false)
    local intro3 = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","You can give up and retry any level by pressing this button.",nil,false)
    local selectDude = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","Click on your Fighter Hero with the left mouse button.",nil,false)
    local moveDude = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","Click on one of the blue circles with the left mouse button to move your Fighter Hero.",nil,false)
    local endTurn = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","Now, end your turn by pressing this button.",nil,false)
    local shapes = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5*1.1,"center","The red area shows where your Fighter Hero can attack. Try placing the Hero so the red shape overlaps the Thief's position.",nil,false)
    local attack = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","Good! Now end the turn and your Fighter Hero will attack automatically.",nil,false)
    local deselect = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","Tap anywhere else to deselect your Hero.",nil,true)
    
    
    if sys == "Android" then
        intro2 = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","You can skip any tutorial level by tapping this button.",nil,true)
        intro3 = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","You can give up and retry any level by tapping this button.",nil,true)
        selectDude = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","Tap on your Fighter Hero to move it.",nil,true)
        moveDude = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","Select one of the blue circles to move your Fighter Hero.",nil,true)
    end
    
    tut.addSlide("intro","intro2","Introduction Slide",true,function() lg.draw(intro,lg.getWidth()/6,lg.getHeight()/4*3) end)
    tut.addSlide("intro2","intro3","Introduction Slide",true,function() 
        lg.draw(intro2,sbutton.x+(sbutton.w/2),(sbutton.y+sbutton.h)*1.1) 
        lg.setLineWidth(3) lg.setColor(200,50,0) lg.rectangle("line",sbutton.x,sbutton.y,sbutton.w,sbutton.h) lg.setLineWidth(1) lg.setColor(255,255,255) end)
    tut.addSlide("intro3","select","Introduction Slide",true,function()
        lg.draw(intro3,rbutton.x+(rbutton.w/2),(rbutton.y+rbutton.h)*1.1) 
        lg.setLineWidth(3) lg.setColor(200,50,0) lg.rectangle("line",rbutton.x,rbutton.y,rbutton.w,rbutton.h) lg.setLineWidth(1) lg.setColor(255,255,255) end)
    tut.addSlide("select","move","Select a Dude Slide",true,function() lg.draw(selectDude,lg.getWidth()/6,lg.getHeight()/4*3) end)
    
    if sys == "Android" then
        tut.addSlide("move","deselect","Move a Dude Slide",true,function() lg.draw(moveDude,lg.getWidth()/6,lg.getHeight()/4*3) end)
        tut.addSlide("deselect","endturn","Move a Dude Slide",true,function() lg.draw(deselect,lg.getWidth()/6,lg.getHeight()/4*3) end)
    else
        tut.addSlide("move","endturn","Move a Dude Slide",true,function() lg.draw(moveDude,lg.getWidth()/6,lg.getHeight()/4*3) end)
    end
    
    tut.addSlide("endturn","shapes","End your turn",true,function() 
        lg.draw(endTurn,etbutton.x+(etbutton.w/2)-(endTurn:getWidth()),(sbutton.y+sbutton.h)*1.1) 
        lg.setLineWidth(3) lg.setColor(200,50,0) lg.rectangle("line",etbutton.x,etbutton.y,etbutton.w,etbutton.h) lg.setLineWidth(1) lg.setColor(255,255,255) end)
    tut.addSlide("shapes","attack","Attackshapes",false,function() lg.draw(shapes,lg.getWidth()/6,lg.getHeight()/4*3) end)
    tut.addSlide("attack",nil,"End your turn",true,function() 
        lg.draw(attack,etbutton.x+(etbutton.w/2)-(lg.getWidth()/3*2),(sbutton.y+sbutton.h)*1.1)
        lg.setLineWidth(3) lg.setColor(200,50,0) lg.rectangle("line",etbutton.x,etbutton.y,etbutton.w,etbutton.h) lg.setLineWidth(1) lg.setColor(255,255,255) end)
    
    
    tut.prepare("intro")
end

game.setupTuts[2] = function (hero,etbutton,sbutton,rbutton)
    td = tut.td
    local intro = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","Meet the Ranger Hero. This Hero has a long range attack but is not very effective at close range.",nil,true)
    local intro2 = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","The enemy on this level is tougher. Victory will require both your Heroes to work together.",nil,true)
    local ydanger = td.drawBubble(5,lg.getWidth()/5*3*1.5,lg.getHeight()/5*1.2,"center","The yellow circle around the enemy's feet shows that it is under attack but its armor will negate the damage. Move a second Hero to an attack position.",nil,true)
    local rdanger = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","Good! The circle has changed to red. Now end your turn and let your Heroes attack.",nil,true)
   
    tut.addSlide("intro","intro2","Ranger Intro",true,function() lg.draw(intro,lg.getWidth()/6,lg.getHeight()/4*3) end)
    tut.addSlide("intro2","ydanger","Toughguy",true,function() lg.draw(intro2,lg.getWidth()/6,lg.getHeight()/4) end)
    tut.addSlide("ydanger","rdanger","yellow danger",false,function() lg.draw(ydanger,10,lg.getHeight()/2) end)
    tut.addSlide("rdanger",nil,"red danger",false,function() lg.draw(rdanger,etbutton.x+(etbutton.w/2)-(lg.getWidth()/3*2),(sbutton.y+sbutton.h)*1.1) lg.setLineWidth(3) lg.setColor(200,50,0) lg.rectangle("line",etbutton.x,etbutton.y,etbutton.w,etbutton.h) lg.setLineWidth(1) lg.setColor(255,255,255) end)
  
    tut.prepare("intro")
end

game.setupTuts[3] = function (hero,button)
    td = tut.td
    local intro = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5*1.1,"center","Meet the Mage Hero, another long range Hero. The Mage is also the weakest Hero so keep it protected. In the final game the Mage will have a host of support abilities.",nil,true)
    local intro2 = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5*1.1,"center","and... the Beastmaster Hero. The other close range Hero. In the final game, the Beastmaster will be responsible for capturing wild beasts and training them to fight for you.",nil,true)
    local intro3 = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","Defeat the enemy on this level.",nil,true)
   
    tut.addSlide("intro","intro2","Mage Introduction",true,function() lg.draw(intro,lg.getWidth()/6,lg.getHeight()/4*3) end)
    tut.addSlide("intro2","intro3","BM Introduction",true,function() lg.draw(intro2,lg.getWidth()/6,lg.getHeight()/6) end)
    tut.addSlide("intro3",nil,"goal",true,function() lg.draw(intro3,lg.getWidth()/6,lg.getHeight()/2) end)
  
    tut.prepare("intro")
end

game.setupTuts[4] = function (hero,button)
    td = tut.td
    local intro = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","Fights will end if you dont have enough Heroes to kill the enemies.",nil,true)
    local intro2 = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","From now on it is possible that you can fail.",nil,true)
   
    tut.addSlide("intro","intro2","Losing",true,function() lg.draw(intro,lg.getWidth()/6,lg.getHeight()/4*3) end)
    tut.addSlide("intro2",nil,"Losing2",true,function() lg.draw(intro2,lg.getWidth()/6,lg.getHeight()/4*3) end)
  
    tut.prepare("intro")
end

game.setupTuts[5] = function (hero,button)
    td = tut.td
    local intro = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","These enemies are very strong. You will need to use three Heroes to defeat them.",nil,true)
    local intro2 = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5*1.2,"center","You will fail if you have less than three Heroes remaining because these enemies require three attacks to damage them.",nil,true)
   
    tut.addSlide("intro","intro2","Losing",true,function() lg.draw(intro,lg.getWidth()/6,lg.getHeight()/4) end)
    tut.addSlide("intro2",nil,"Losing2",true,function() lg.draw(intro2,lg.getWidth()/6,lg.getHeight()/4*3) end)
  
    tut.prepare("intro")
end

game.setupTuts[6] = function (hero,button)
    td = tut.td
    local intro = td.drawBubble(5,lg.getWidth()/2*1.5,lg.getHeight()/2,"center","Levels can be built using the Tiled Editor and imported into this prototype.",nil,true)
    local intro2 = td.drawBubble(5,lg.getWidth()/2*1.5,lg.getHeight()/2,"center","You can also import new tileset graphics to use in your levels. Read the documentation to find out how.",nil,true)
   
    tut.addSlide("intro","intro2","LevelEditing",true,function() lg.draw(intro,10,lg.getHeight()/2-10) end)
    tut.addSlide("intro2",nil,"TilesetImport",true,function() lg.draw(intro2,10,10) end)
  
    tut.prepare("intro")
end

game.setupTuts[7] = function (hero,button)
    td = tut.td
    local intro = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","From now on the game will play in Endless Mode. New fights will be randomly generated.. FOREVER",nil,true)
    local intro2 = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","Have your say on development at www.broadstories.com",nil,true)
    local intro3 = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","Happy Hunting and thanks for playing!",nil,true)
   
    tut.addSlide("intro","intro2","LevelEditing",true,function() lg.draw(intro,lg.getWidth()/6,lg.getHeight()/4*3) end)
    tut.addSlide("intro2","intro3","TilesetImport",true,function() lg.draw(intro2,lg.getWidth()/6,lg.getHeight()/4*3) end)
    tut.addSlide("intro3",nil,"TilesetImport",true,function() lg.draw(intro3,lg.getWidth()/6,lg.getHeight()/4*3) end)
  
    tut.prepare("intro")
end



function game:mousepressed(x,y,button)
    if inputAccepted then
        if not self.ui:click(x,y,button) then
            local tile = grid.findTileAtCoord(self.map,x,y)
            if tile and self.collected then
                if tile.obj == nil and grid.checkCellInList(tile,self.collected.moves) then
                    pimp.placeUnit(self.control,tile,self.collected)
                    self.collected = nil
                    tut.complete("move")
                    tut.complete("ydanger")
                end
            elseif tile and tile.obj and not self.collected and not tile.obj.npc then
                self.collected = pimp.takeUnit(self.control,tile)
                tut.complete("select")
                tut.display("shapes")
            end
        end
    end
    tut.complete("intro3")
    tut.complete("intro2")
    tut.complete("intro")
end

function game:touchreleased(id,x,y,pressure)
    local mx,my = lg.getWidth()*x,lg.getHeight()*y
    if inputAccepted then
        if not self.ui:click(mx,my) then
            local tile = grid.findTileAtCoord(self.map,mx,my)
            if tile and self.collected then
                if tile.obj == nil and grid.checkCellInList(tile,self.collected.moves) then
                    pimp.moveUnit(self.control,self.collected,tile)
                    tut.complete("move")
                    tut.complete("ydanger")
                elseif tile.obj and tile.obj.team == PLAYERTEAM then
                    self.collected = tile.obj
                end
            elseif tile and tile.obj and not self.collected and not tile.obj.npc then
                self.collected = tile.obj
                tut.complete("select")
                tut.display("shapes")
            end
            if not tile or (tile and not tile.obj) then
                self.collected = nil
                tut.complete("deselect")
            end
        end
    end
    
end

function game:touchpressed(id,x,y,pressure)
    x,y = lg.getWidth()*x,lg.getHeight()*y
    self.lastTouch = {x=x,y=y}
    tut.complete("intro3")
    tut.complete("intro2")
    tut.complete("intro")
end

function game:touchmoved(id,x,y,pressure)
    x,y = lg.getWidth()*x,lg.getHeight()*y
    self.lastTouch = {x=x,y=y}
end

function game:mousereleased(x,y,button)

end

function game:keypressed(key)
    if inputAccepted then
        if key == "escape" then love.event.quit() 
        elseif key == " " then self:startNextPhase()
        elseif key == "r" and DEBUG_MODE then self:triggerVictory() 
        elseif key == "k" and DEBUG_MODE then pimp.killTeam(self.control,2) 
        else        
            tut.complete("intro3")
            tut.complete("intro2")
            tut.complete("intro")
        end
    end
end

function game:draw(noUI)
    local hoverCell = nil
    local sys = love.system.getOS()
    local touches = 0

    local mx,my = lm.getPosition()

    lg.setFont(font)
    self.map:draw()   
    
    if inputAccepted then
        if self.collected then
            sd.drawMoveShape(self.collected.moves,self.map,true) -- draw selected units movement area with jiggle
            
            local ox,oy = grid.getCenter(self.map,self.collected.cell)
            hoverCell = grid.findTileAtCoord(self.map,mx,my)
            local hx,hy = grid.getCenter(self.map,hoverCell)

            if hoverCell and grid.checkCellInList(hoverCell,self.collected.moves) then
                
                local attackArea = grid.displaceList(self.map,self.collected.attackShape,hoverCell.pos.x,hoverCell.pos.y,true,true)
                sd.drawAttackOutline(attackArea,self.map,self.collected)
            end
            
            if grid.checkCellInList(hoverCell,self.collected.moves) then
                lg.setColor(30,30,255)
                lg.setLineWidth(8)
                lg.line(hx,hy,ox,oy)
                self.collected:draw(hx,hy,false)
                lg.setLineWidth(1)
            end
        else
            hoverCell = grid.findTileAtCoord(self.map,mx,my)
            
            if hoverCell and hoverCell.obj and hoverCell.obj.isDead == false then
                local ox,oy = grid.getCenter(self.map,hoverCell.obj.cell)
                --lg.line(mx,my,ox,oy) -- draw a line to 
                
                sd.drawMoveShape(hoverCell.obj.moves,self.map)
            
                local attackArea = grid.displaceList(self.map,hoverCell.obj.attackShape,hoverCell.pos.x,hoverCell.pos.y,true,true)
                sd.drawAttackOutline(attackArea,self.map,hoverCell.obj)
            end
        end
    
    end
    
    
    if not noUI then
        --draw UI and stats
        self.ui:draw()
        lg.setColor(255,255,255)
        local lastUI = self.ui.elements[#self.ui.elements]
        lg.print("Wins: "..wins,lastUI.x+lastUI.w+4,10)
        lg.print("Losses: "..losses,lastUI.x+lastUI.w+4,30)
        lg.print("Threat: "..threatLevel,lastUI.x+lastUI.w+4,50)    
        
    end
    
    self.control:draw(hoverCell,self.collected)
    
    if not noUI then
        tut.draw()
    end
    
end

function game:drawAndroid(noUI)
    --ANDROID VERSION OF DRAW: DIFFERENT HOVER STUFF
    local hoverCell = nil
    local sys = love.system.getOS()
    local touches = love.touch.getTouchCount()

    lg.setFont(font)
    self.map:draw()    
    
    if self.collected and inputAccepted then
        sd.drawMoveShape(self.collected.moves,self.map,true) -- draw selected units movement area with jiggle
        
        local ox,oy = grid.getCenter(self.map,self.collected.cell)
        hoverCell = grid.findTileAtCoord(self.map,self.lastTouch.x,self.lastTouch.y)
        local hx,hy = grid.getCenter(self.map,hoverCell)
       
        if hoverCell and grid.checkCellInList(hoverCell,self.collected.moves) then
            lg.setColor(30,30,255)
            lg.setLineWidth(8)
            lg.line(hx,hy,ox,oy)
            self.collected:draw(hx,hy,false)
            lg.setLineWidth(1)
            local attackArea = grid.displaceList(self.map,self.collected.attackShape,hoverCell.pos.x,hoverCell.pos.y,true,true)
            sd.drawAttackOutline(attackArea,self.map,self.collected)
        end
        
    elseif inputAccepted then
        if touches > 0 then
            hoverCell = pimp.findClosestUnitInPixels(self.control,self.lastTouch.x,self.lastTouch.y).cell
            
            if hoverCell and hoverCell.obj and hoverCell.obj.isDead == false then
                local ox,oy = grid.getCenter(self.map,hoverCell.obj.cell)
                --lg.line(mx,my,ox,oy) -- draw a line to 
                
                sd.drawMoveShape(hoverCell.obj.moves,self.map)
            
                local attackArea = grid.displaceList(self.map,hoverCell.obj.attackShape,hoverCell.pos.x,hoverCell.pos.y,true,true)
                sd.drawAttackOutline(attackArea,self.map,hoverCell.obj)
            end
        end
    end
    
    if DEBUG_MODE then
        lg.setColor(255,255,255,125)
        lg.circle("line",self.lastTouch.x,self.lastTouch.y,50,20)
    end
    
    if not noUI then
        --draw UI and stats
        self.ui:draw()
        lg.setColor(255,255,255)
        local lastUI = self.ui.elements[#self.ui.elements]
        lg.print("Wins: "..wins,lastUI.x+lastUI.w+4,10)
        lg.print("Losses: "..losses,lastUI.x+lastUI.w+4,30)
        lg.print("Threat: "..threatLevel,lastUI.x+lastUI.w+4,50)    
        
    end
    
    self.control:draw(hoverCell,self.collected)
    
    if not noUI then
        tut.draw()
    end
    
end

function game:startNextPhase()
    if self.collected == nil then
        tut.complete("rdanger")
        tut.complete("endturn")
        tut.complete("attack")
        if self.phase == 0 then --end of player movement phase
            --check for Retreat or Defeat
            self:checkRetreat()
            --calculate list of damaged targets
            local victims = pimp.calculateAttackers(self.control,1)
            local injuries = pimp.calculateInjured(victims)
            --build list of attack and damage animations (animation,target pairs)
            pimp.addInjuryPairs(self.control,injuries)
            print("Starting phase 1: victims = "..#victims..", injuries = "..#injuries)
            --clean up dead guys
            pimp.cleanDead(self.control)
            --set next phase
            
            self.phase = 1
            inputAccepted = false
        elseif self.phase == 1 then --end of player attack phase
            --clean up dead guys
            pimp.cleanDead(self.control)
            --check for victory
            self:checkVictory()
            pimp.newToaster(self.control,"ENEMY TURN")
            --calculate enemy movement
            pimp.updateTeamMoves(self.control,2)
            pimp.doTeamAI(self.control,2)
            self.phase = 2
        elseif self.phase == 2 then -- end of npc movement phase
            --calculate damage against team 1
            local victims = pimp.calculateAttackers(self.control,2)
            local injuries = pimp.calculateInjured(victims)
            pimp.addInjuryPairs(self.control,injuries)
            print("Starting phase 3: victims = "..#victims..", injuries = "..#injuries)
            --clean up dead guys
            pimp.cleanDead(self.control)
            self.phase = 3
        elseif self.phase == 3 then --end of npc attack phase
            --clean up dead heroes
            pimp.cleanDead(self.control)
            --calculate hero movement
            pimp.updateTeamMoves(self.control,1)
            pimp.updateTeamMoves(self.control,2)
            pimp.checkDamage(self.control)
            
            pimp.newToaster(self.control,"PLAYERS TURN")
            self.phase = 0
            inputAccepted = true
        end
    else
        self.collected = nil
    end
end

function game:update(dt)
    tut.update(dt)
    anims.stand:update(dt)
    anims.walk:update(dt)

    local complete = self.control:update(dt)
    if self.phase > 0 then
        --autocomplete phase when done
        if complete then self:startNextPhase() end 
    end
    
    self.ui:update(dt)
end

function game:triggerVictory()
    threatLevel = threatLevel + 2
    levelProg = levelProg + 1
    wins = wins + 1
    gs.switch(trans.new({
        aa.new({trans.newFlyup("VICTORY!",lg.getHeight()/2)}),
        aa.new({trans.newFadeout("VICTORY!",lg.getHeight()/2)})}
        ))
end

function game:triggerRetreat()
    losses = losses + 1
    gs.switch(trans.new({
        aa.new({trans.newFlyup("RETREAT!",lg.getHeight()/2,true)}),
        aa.new({trans.newFadeout("RETREAT!",lg.getHeight()/2,true)})}
        ))
end

function game:triggerRestart()
    losses = losses + 1
    gs.switch(trans.new({
        aa.new({trans.newFlyup("RELOADING",lg.getHeight()/2,true)}),
        aa.new({trans.newFadeout("RELOADING",lg.getHeight()/2,true)})}
        ))
end

function game:triggerSkip()
    levelProg = levelProg + 1
    threatLevel = threatLevel + 1
    gs.switch(trans.new({
        aa.new({trans.newFlyup("TUTORIAL SKIPPED",lg.getHeight()/2)}),
        aa.new({trans.newFadeout("TUTORIAL SKIPPED",lg.getHeight()/2)})}
        ))
end

function game:checkRetreat()
    --victory is when all enemies are destroyed
    --ask controller about enemy number
    local heroes = pimp.countTeamMembers(self.control,PLAYERTEAM)
    local highArmor = pimp.countHighestArmorInTeam(self.control,ENEMYTEAM)
    if heroes < highArmor then
        self:triggerRetreat()
    end
end

function game:checkVictory()
    --victory is when all enemies are destroyed
    --ask controller about enemy number
    local enemies = pimp.countTeamMembers(self.control,ENEMYTEAM)
    if enemies == 0 then
        self:triggerVictory()
    end
end

return game
