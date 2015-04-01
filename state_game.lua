local game = {}

local font = lg.newFont()

inputAccepted = true

function game.new(map,control)
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
    --local sbut = ibut.new(4+(buttonHeight*1.5),0,state.ui,img.cog,true,buttonHeight,buttonHeight)
    local rbut = ibut.new(0,0,state.ui,img.retreat,true,buttonHeight*1.5,buttonHeight)
    rbut.click = function() state:triggerRestart() end
    etbut.click = function() state:startNextPhase() end
    state.ui:addElement(rbut)
    state.ui:addElement(etbut)
    --state.ui:addElement(sbut)
    
    
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
        --elseif key == "r" then self:triggerVictory() 
        end
    end
end

function game:draw()
    local hoverCell = nill

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
            self.collected:draw(mx,my,true)
            local ox,oy = grid.getCenter(self.map,self.collected.cell)
            lg.line(mx,my,ox,oy)
            for i,v in ipairs(self.collected.moves) do
                lg.setColor(0,0,255,90)
                local x,y = grid.getOrigin(self.map,v)
                lg.rectangle("fill",x,y,self.map.ts,self.map.ts)
            end
            hoverCell = grid.findTileAtCoord(self.map,mx,my)
            if hoverCell then
                local attackArea = grid.displaceList(self.map,self.collected.attackShape,hoverCell.pos.x,hoverCell.pos.y)
                for i,v in ipairs(attackArea) do
                        lg.setColor(255,0,0,30)
                        local x,y = grid.getOrigin(self.map,v)
                        lg.rectangle("fill",x,y,self.map.ts,self.map.ts)
                end
            end
        else
            hoverCell = grid.findTileAtCoord(self.map,mx,my)
            
            if hoverCell and hoverCell.obj then
                local ox,oy = grid.getCenter(self.map,hoverCell.obj.cell)
                lg.line(mx,my,ox,oy)
                for i,v in ipairs(hoverCell.obj.moves) do
                    lg.setColor(0,0,255,30)
                    local x,y = grid.getOrigin(self.map,v)
                    lg.rectangle("fill",x,y,self.map.ts,self.map.ts)
                end
            
                local attackArea = grid.displaceList(self.map,hoverCell.obj.attackShape,hoverCell.pos.x,hoverCell.pos.y)
                for i,v in ipairs(attackArea) do
                        lg.setColor(255,0,0,90)
                        local x,y = grid.getOrigin(self.map,v)
                        lg.rectangle("fill",x,y,self.map.ts,self.map.ts)
                end
                hoverCell.obj:draw(nil,nil,true)
            end
        end
    
    end
    
    self.control:draw()
    
    tut.draw()
    lg.print(threatLevel,0,lg:getHeight()-10)
    self.ui:draw()
    
    
end

function game:startNextPhase()
    if self.phase == 0 then --end of player movement phase
        --check for Retreat or Defeat
        self:checkRetreat()
        --calculate list of damaged targets
        local victims = pimp.calculateAttackers(self.control,1)
        local injuries = pimp.calculateInjured(victims)
        --build list of attack and damage animations (animation,target pairs)
        pimp.addInjuryPairs(self.control,injuries)
        print("Starting phase 1: victims = "..#victims..", injuries = "..#injuries)
        --set next phase
        self.phase = 1
        inputAccepted = false
    elseif self.phase == 1 then --end of player attack phase
        --clean up dead guys
        pimp.cleanDead(self.control)
        --check for victory
        self:checkVictory()
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
        self.phase = 3
    elseif self.phase == 3 then --end of npc attack phase
        --clean up dead heroes
        pimp.cleanDead(self.control)
        --calculate hero movement
        pimp.updateTeamMoves(self.control,1)
        pimp.updateTeamMoves(self.control,2)
        pimp.checkDamage(self.control)
        self.phase = 0
        inputAccepted = true
    end
end

function game:update(dt)
    tut.update(dt)
    anims.stand:update(dt)
    anims.walk:update(dt)
    
    if self.phase == 0 then
        local complete = self.control:update(dt)
        --wait for player end turn command 
    elseif self.phase == 1 then
        --work through attack animations list
        --deal damage as each animation finishes
        --splice death animations
        local complete = self.control:update(dt)
        --trigger nextPhase when done
        if complete then self:startNextPhase() end
    elseif self.phase == 2 then
        --work through enemy movement (just team 2 for now)
        local complete = self.control:update(dt)
        --trigger nextPhase when empty
        if complete then self:startNextPhase() end
    elseif self.phase == 3 then
        --work through attack animations list
        --deal damage as each animation finishes
        --splice death animations
        local complete = self.control:update(dt)
        --trigger nextPhase when done
        if complete then self:startNextPhase() end
    end
    
    self.ui:update(dt)
end

function game:triggerVictory()
    threatLevel = threatLevel + 1
    levelProg = levelProg + 1
    gs.switch(trans.new({aa.new({trans.newFlyup("VICTORY!"),trans.newUnderbar("You defeated all enemies")})}))
end

function game:triggerRetreat()
    gs.switch(trans.new({aa.new({trans.newFlyup("RETREAT!"),trans.newUnderbar("You don't have enough heroes to win",-60,true)})}))
end

function game:triggerRestart()
    gs.switch(trans.new({aa.new({trans.newFlyup("RETREAT!"),trans.newUnderbar("You gave up.",-60,true)})}))
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
