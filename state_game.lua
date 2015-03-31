local game = {}

local font = lg.newFont()


inputAccepted = true

function game.new()
    local state = {}
     
    state.map = grid.newGridArea(lg:getWidth()*.9,lg:getHeight()*.9,48,lg:getWidth()/20,lg:getHeight()/20)
    state.control = pimp.new(state.map)
    
    state.collected = nil
    
    state.phase = 0
    --phase 0: player movement
    --phase 1: player calculate attacks and generate animations, calculate teams
    --phase 2: npc team 1 move
    --phase 3: npc team 1 calculate attacks and animate 
    --if more teams goto phase 2 with next team
    --goto phase 0
    
    state.draw = game.draw
    state.update = game.update
    state.keypressed = game.keypressed
    state.mousepressed = game.mousepressed
    state.startNextPhase = game.startNextPhase
    state.checkVictory = game.checkVictory
    state.triggerVictory = game.triggerVictory
    state.checkRetreat = game.checkRetreat
    state.triggerRetreat = game.triggerRetreat
    
    game.populate(state)
    
    inputAccepted = true
    
    return state
end

function game:populate()
    math.randomseed(os.time())
    local level = lgen.generate(threatLevel,self.map.tw,self.map.th,4)
    lgen.spawn(level,self.control)
    --[[pimp.addUnit(self.control,grid.findTileAtPos(self.map,5,1),"Fighter")
    pimp.addUnit(self.control,grid.findTileAtPos(self.map,7,0),"Mage")
    pimp.addUnit(self.control,grid.findTileAtPos(self.map,9,1),"Beastmaster")
    pimp.addUnit(self.control,grid.findTileAtPos(self.map,9,0),"Ranger")
    pimp.addUnit(self.control,grid.findTileAtPos(self.map,math.floor(self.map.tw/2),self.map.th-2),"Thief")
    pimp.addUnit(self.control,grid.findTileAtPos(self.map,math.floor(self.map.tw/2)-2,self.map.th-2),"Thief")
    pimp.addUnit(self.control,grid.findTileAtPos(self.map,math.floor(self.map.tw/2)-4,self.map.th-2),"Thief")
    pimp.addUnit(self.control,grid.findTileAtPos(self.map,math.floor(self.map.tw/2)-6,self.map.th-2),"Thief")
    pimp.addUnit(self.control,grid.findTileAtPos(self.map,math.floor(self.map.tw/2)+2,self.map.th-2),"Thief")
    pimp.addUnit(self.control,grid.findTileAtPos(self.map,math.floor(self.map.tw/2)+4,self.map.th-2),"Thief")
    --pimp.addUnit(self.control,grid.findTileAtPos(self.map,math.floor(self.map.tw/2),self.map.th-3),"Thief")
    --pimp.addUnit(self.control,grid.findTileAtPos(self.map,math.floor(self.map.tw/2)-2,self.map.th-3),"Thief")
    --pimp.addUnit(self.control,grid.findTileAtPos(self.map,math.floor(self.map.tw/2)-4,self.map.th-3),"Thief")
    --pimp.addUnit(self.control,grid.findTileAtPos(self.map,math.floor(self.map.tw/2)-6,self.map.th-3),"Thief")
    --pimp.addUnit(self.control,grid.findTileAtPos(self.map,math.floor(self.map.tw/2)+2,self.map.th-3),"Thief")
    --pimp.addUnit(self.control,grid.findTileAtPos(self.map,math.floor(self.map.tw/2)+4,self.map.th-3),"Thief")]]
end

function game:mousepressed(x,y,button)
    if inputAccepted then
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

function game:keypressed(key)
    if inputAccepted then
        if key == "escape" then love.event.quit() 
        elseif key == " " then self:startNextPhase()
        elseif key == "r" then self:triggerVictory() end
    end
end

function game:draw()
    local hoverCell = nill

    local mx,my = lm.getPosition()
    lg.setFont(font)
    self.map:draw()
    
    self.control:draw()
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
    
    if not inputAccepted then
        lg.setColor(255,0,0)
        lg.setLineWidth(5)
        lg.rectangle("line",self.map.x-1,self.map.y-1,self.map.w+2,self.map.h+2)
        lg.setLineWidth(1)
    end
    
    tut.draw()
    lg.print(threatLevel,0,0)
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
    
    
end

function game:triggerVictory()
    threatLevel = threatLevel + 1
    gs.switch(trans.new({aa.new({trans.newFlyup("VICTORY!"),trans.newUnderbar("You defeated all enemies")})}))
end

function game:triggerRetreat()
    gs.switch(trans.new({aa.new({trans.newFlyup("RETREAT!"),trans.newUnderbar("You don't have enough heroes to win")})}))
end

function game:checkRetreat()
    --victory is when all enemies are destroyed
    --ask controller about enemy number
    local heroes = pimp.countTeamMembers(self.control,1)
    local highArmor = pimp.countHighestArmorInTeam(self.control,2)
    if heroes < highArmor then
        self:triggerRetreat()
    end
end

function game:checkVictory()
    --victory is when all enemies are destroyed
    --ask controller about enemy number
    local enemies = pimp.countTeamMembers(self.control,2)
    if enemies == 0 then
        self:triggerVictory()
    end
end

return game
