local mbut = require('/ui/mixButton')
local pbut = require('/ui/panelButton')
local ibut = require('/ui/iconButton')
local lg = require('love.graphics')
local tween = require('tween')
local reg = require('animRegister')
local aa = require('attackAnim')

local font = lg.newFont('/assets/Quattrocento-Regular.ttf',20)

local trans = {}

function trans.new()
    local state = {}
    
    state.ui = uicon.new(state,font)
    state.from = nil
    state.interacted = false
    local mainbut = {x=lg.getWidth()/5,y=lg.getHeight()/20,w=lg.getWidth()*.6,h=lg.getHeight()*.5}
    
    local remainH = lg.getHeight()-mainbut.y-mainbut.h
    local bh = remainH/5
    local bw = lg.getWidth()/20*8
    local br1 = {y=bh+mainbut.h+mainbut.y}
    local br2 = {y=(bh*3)+mainbut.h+mainbut.y}
    local bc1 = {x=lg.getWidth()/20}
    local bc2 = {x=lg.getWidth()/20*11}
    
    
    local but = pbut.new(mainbut.x,mainbut.y,state.ui,img.broadstories,true,mainbut.w,mainbut.h,true)
    but.click = function() trans.play(state) end
    local but1 = mbut.new(bc2.x,br1.y,state.ui,img.cog,"Setup Modloader",true,bw,bh,true)
    but1.click = function() trans.setupMods(state) end
    local but15 = mbut.new(bc2.x,br1.y,state.ui,img.disk,"Import Mods",true,bw,bh,true)
    but15.click = function() trans.loadMods(state) end
    but15.active = false
    local but2 = mbut.new(bc1.x,br1.y,state.ui,img.teleport,"Visit Broadstories",true,bw,bh,true)
    but2.click = function() love.system.openURL('http://www.broadstories.com/') end
    local but3 = mbut.new(bc1.x,br2.y,state.ui,img.bglogo,"Get Prototypes",true,bw,bh,true)
    but3.click = function() love.system.openURL('http://prototype.binarygambit.com/') end
    local but4 = mbut.new(bc2.x,br2.y,state.ui,img.retreat,"Quit",true,bw,bh,true)
    but4.click = function() trans.quit(state) end
    
    local but5 = ibut.new(lg.getWidth()-80,0,state.ui,img.facebook,true,80,48)
    local but6 = ibut.new(lg.getWidth()-80,56,state.ui,img.twitter,true,80,48)
    but5.click = function() love.system.openURL('http://www.facebook.com/Broadstories') end
    but6.click = function() love.system.openURL('http://twitter.com/gladers') end
    
    state.ui:addElement(but)
    state.ui:addElement(but1)
    state.ui:addElement(but15)
    state.ui:addElement(but2)
    state.ui:addElement(but3)
    state.ui:addElement(but4)
    state.ui:addElement(but5)
    state.ui:addElement(but6)
    
    state.animReg = reg.new(false)
    
    state.alpha = 0
    state.tween = tween.new(1,state,{alpha=255},'inQuad')
    
    state.draw = trans.draw
    state.update = trans.update
    state.enter = trans.enter
    state.mousereleased = trans.mousereleased
    state.mousepressed = trans.mousepressed
    state.keypressed = trans.keypressed
    
    
    return state
end

function trans.setupMods(self)
    local text = "Setup happened"
    self.animReg:addToRegister(aa.new({aa.newToasterCome(text)}))
    self.animReg:addToRegister(aa.new({aa.newToasterWait(text,1)}))
    self.animReg:addToRegister(aa.new({aa.newToasterGo(text)}))
    self.ui.elements[2].active = false
    self.ui.elements[3].active = true
end

function trans.loadMods(self)
    local newUnits,changedUnits = modloader.loadUnits(unitTypes)
    local levels = modloader.loadLevels(levels)
    
    local text = ""
    if newUnits then text = text .. tostring(newUnits) .. " new units " end
    if changedUnits then text = text .. tostring(newUnits) .. " units changed " end
    if levels then text = text .. tostring(newUnits) .. " levels " end
    text = text .. "added"
    if newUnits == 0 and changedUnits == 0 and levels == 0 then text = "Nothing loaded" end
    
    self.animReg:addToRegister(aa.new({aa.newToasterCome(text,font)}))
    self.animReg:addToRegister(aa.new({aa.newToasterWait(text,1,font)}))
    self.animReg:addToRegister(aa.new({aa.newToasterGo(text,font)}))
    
end

function trans.quit(self)
    love.event.quit()
end

function trans.play(self)
    if levelProg == 0 then
        levelProg = 1
    end
    
    buildNextLevel()
end

function trans:draw()
    self.ui:draw(self.alpha)
    self.animReg:draw()
end

function trans:update(dt)
    self.ui:update(dt)
    self.tween:update(dt)
    self.animReg:update(dt)
end

function trans:keypressed(key)
    self.animReg:keypressed()
    if key == "escape" then love.event.quit() end
end

function trans:mousereleased(x,y,button)
    if self.interacted then
        if button == 'l' then
            self.ui:click(x,y)
        end
        self.animReg:mousepressed()
    end
    self.interacted = false
end

function trans:mousepressed()
    self.interacted = true
end

function trans:enter(from)
    self.from = from
end


return trans
