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
        tw,xo,yo = grid.getGridDims(mw,mh)
        state.map = grid.newGrid(mw,mh,tw,xo,yo)
    end
    
    if control then
        state.control = control
    else
        state.control = pimp.new(state.map,unitTypes,unitImg)
    end
    
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
    
    if control and map then 
        state.ui:addElement(sbut)
    end
    
    state.collected = nil
    
    state.phase = 0
    
    state.draw = game.draw
    state.update = game.update
    state.keypressed = game.keypressed
    state.mousepressed = game.mousepressed
    state.startNextPhase = game.startNextPhase
    state.checkVictory = game.checkVictory
    state.triggerVictory = game.triggerVictory
    state.checkRetreat = game.checkRetreat
    state.triggerRetreat = game.triggerRetreat
    state.triggerRestart = game.triggerRestart
    state.triggerSkip = game.triggerSkip
    
    if not control then
        lgen.generate(state.control,4,threatLevel)
        print('populated by default')
    end
    
    
    
    inputAccepted = true
    
    tut.clearTuts()
    if levelProg < 4 then
        game.setupTuts[levelProg](state.control.units[1],etbut,sbut,rbut)
    end
    
    return state
end

game.setupTuts = {}

game.setupTuts[1] = function (hero,etbutton,sbutton,rbutton)
    td = tut.td
    local intro = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","Welcome to the Broadstories Prototype. Please play through this short tutorial to learn how to play the game.",nil,true)
    local intro2 = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","You can skip any tutorial level by clicking this button.",nil,true)
    local intro3 = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","You can give up and retry any level by pressing this button.",nil,true)
    local selectDude = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","Click on your Fighter Hero with the left mouse button.",nil,true)
    local moveDude = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","Click on one of the blue circles with the left mouse button to move your Fighter Hero.",nil,true)
    local endTurn = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","Now, end your turn by pressing this button.",nil,true)
    local shapes = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","The red area shows where your Fighter Hero can attack. Try placing the Hero so the red shape overlaps the Thief's position.",nil,true)
    local attack = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","Good! Now end the turn and your Fighter Hero will attack automatically.",nil,true)
    
    
    tut.addSlide("intro","intro2","Introduction Slide",true,function() lg.draw(intro,lg.getWidth()/6,lg.getHeight()/4*3) end)
    tut.addSlide("intro2","intro3","Introduction Slide",true,function() 
        lg.draw(intro2,sbutton.x+(sbutton.w/2),(sbutton.y+sbutton.h)*1.1) 
        lg.setLineWidth(3) lg.setColor(200,50,0) lg.rectangle("line",sbutton.x,sbutton.y,sbutton.w,sbutton.h) lg.setLineWidth(1) lg.setColor(255,255,255) end)
    tut.addSlide("intro3","select","Introduction Slide",true,function()
        lg.draw(intro3,rbutton.x+(rbutton.w/2),(rbutton.y+rbutton.h)*1.1) 
        lg.setLineWidth(3) lg.setColor(200,50,0) lg.rectangle("line",rbutton.x,rbutton.y,rbutton.w,rbutton.h) lg.setLineWidth(1) lg.setColor(255,255,255) end)
    tut.addSlide("select","move","Select a Dude Slide",true,function() lg.draw(selectDude,lg.getWidth()/6,lg.getHeight()/4*3) end)
    tut.addSlide("move","endturn","Move a Dude Slide",true,function() lg.draw(moveDude,lg.getWidth()/6,lg.getHeight()/4*3) end)
    tut.addSlide("endturn","shapes","End your turn",true,function() 
        lg.draw(endTurn,etbutton.x+(etbutton.w/2)-(lg.getWidth()/3*2),(sbutton.y+sbutton.h)*1.1) 
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
    local ydanger = td.drawBubble(5,lg.getWidth()/5*3,lg.getHeight()/5,"center","The yellow circle around the enemy's feet shows that it is under attack but its armor will negate the damage. Move a second Hero to an attack position.",nil,true)
    local rdanger = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","Good! The circle has changed to red. Now end your turn and let your Heroes attack.",nil,true)
   
    tut.addSlide("intro","intro2","Ranger Intro",true,function() lg.draw(intro,lg.getWidth()/6,lg.getHeight()/4*3) end)
    tut.addSlide("intro2","ydanger","Toughguy",true,function() lg.draw(intro2,lg.getWidth()/6,lg.getHeight()/4) end)
    tut.addSlide("ydanger","rdanger","yellow danger",false,function() lg.draw(ydanger,10,lg.getHeight()/4*3) end)
    tut.addSlide("rdanger",nil,"red danger",false,function() lg.draw(rdanger,etbutton.x+(etbutton.w/2)-(lg.getWidth()/3*2),(sbutton.y+sbutton.h)*1.1) lg.setLineWidth(3) lg.setColor(200,50,0) lg.rectangle("line",etbutton.x,etbutton.y,etbutton.w,etbutton.h) lg.setLineWidth(1) lg.setColor(255,255,255) end)
  
    tut.prepare("intro")
end

game.setupTuts[3] = function (hero,button)
    td = tut.td
    local intro = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","Meet the Mage Hero, another long range Hero. The Mage is also the weakest Hero so keep it protected. In the final game the Mage will have a host of support abilities.",nil,true)
    local intro2 = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","and.. The Beastmaster Hero. The other close range Hero. In the final game, the Beastmaster will be responsible for capturing wild beasts and training them to fight for you.",nil,true)
    local intro3 = td.drawBubble(5,lg.getWidth()/3*2,lg.getHeight()/5,"center","Defeat the enemy on this level.",nil,true)
   
    tut.addSlide("intro","intro2","Mage Introduction",true,function() lg.draw(intro,lg.getWidth()/6,lg.getHeight()/4*3) end)
    tut.addSlide("intro2","intro3","BM Introduction",true,function() lg.draw(intro2,lg.getWidth()/6,lg.getHeight()/6) end)
    tut.addSlide("intro3",nil,"goal",true,function() lg.draw(intro3,lg.getWidth()/6,lg.getHeight()/2) end)
  
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

function game:keypressed(key)
    if inputAccepted then
        if key == "escape" then love.event.quit() 
        elseif key == " " then self:startNextPhase()
        elseif key == "r" and DEBUG_MODE then self:triggerVictory() 
        elseif key == "k" and DEBUG_MODE then pimp.killTeam(self.control,2) 
        end
    end
    tut.complete("intro3")
    tut.complete("intro2")
    tut.complete("intro")
end

function game:draw(noUI)
    local hoverCell = nil

    local mx,my = lm.getPosition()
    lg.setFont(font)
    self.map:draw()
    
    --[[if not inputAccepted then
        lg.setColor(255,0,0)
        lg.setLineWidth(5)
        lg.rectangle("line",self.map.x-1,self.map.y-1,self.map.w+2,self.map.h+2)
        lg.setLineWidth(1)
    end]]
    
    
    
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
                lg.line(mx,my,ox,oy) -- draw a line to 
                
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
    
    self.control:draw(hoverCell)
    
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
