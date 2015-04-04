local game = {}

local font = lg.newFont()

inputAccepted = true

function game.new(map,control,tutorial)
    local state = {}
    
    if map then
        state.map = map
    else
        tw,xo,yo = grid.getGridDims(15,11)
        state.map = grid.newGrid(15,11,tw,xo,yo)
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
    state.ui:addElement(rbut)
    state.ui:addElement(etbut)
    
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
    
    
    
    
    return state
end




function game:mousepressed(x,y,button)
    if inputAccepted then
        if not self.ui:click(x,y,button) then
            local tile = grid.findTileAtCoord(self.map,x,y)
            if tile and self.collected then
                if tile.obj == nil and grid.checkCellInList(tile,self.collected.moves) then
                    pimp.placeUnit(self.control,tile,self.collected)
                    self.collected = nil
                end
            elseif tile and tile.obj and not self.collected and not tile.obj.npc then
                self.collected = pimp.takeUnit(self.control,tile)
            end
        end
    end
end

function game:keypressed(key)
    if inputAccepted then
        if key == "escape" then love.event.quit() 
        elseif key == " " then self:startNextPhase()
        elseif key == "r" and DEBUG_MODE then self:triggerVictory() 
        elseif key == "k" and DEBUG_MODE then pimp.killTeam(self.control,2) 
        
        end
    end
end

function game:draw()
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
    
    self.control:draw(hoverCell)
    
    tut.draw()
    self.ui:draw()
    lg.setColor(255,255,255)
    local lastUI = self.ui.elements[#self.ui.elements]
    lg.print("Wins: "..wins,lastUI.x+lastUI.w+4,10)
    lg.print("Losses: "..losses,lastUI.x+lastUI.w+4,30)
    lg.print("Threat: "..threatLevel,lastUI.x+lastUI.w+4,50)
    
end

function game:startNextPhase()
    if self.collected == nil then
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
            --check for victory
            self:checkVictory()
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
    gs.switch(trans.new({aa.new({trans.newFlyup("VICTORY!"),trans.newUnderbar("You defeated all enemies")})}))
end

function game:triggerRetreat()
    losses = losses + 1
    gs.switch(trans.new({aa.new({trans.newFlyup("RETREAT!"),trans.newUnderbar("You don't have enough heroes to win",-60,true)})}))
end

function game:triggerRestart()
    losses = losses + 1
    gs.switch(trans.new({aa.new({trans.newFlyup("RETREAT!"),trans.newUnderbar("You gave up.",-60,true)})}))
end

function game:triggerSkip()
    levelProg = levelProg + 1
    threatLevel = threatLevel + 1
    gs.switch(trans.new({aa.new({trans.newFlyup("Level Skipped"),trans.newUnderbar("You didn't need that tutorial anyway.",-60)})}))
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
