-- menu button which has an icon instead of text
local lm = love.mouse

local colors = {but={},ui={}}
colors.but.hover = {90,90,220}
colors.but.ready = {255,255,255}
colors.but.locked = {0,0,0}
colors.ui.border = {0,0,0}
colors.ui.bg = {60,60,60}
colors.ui.bghover = {30,30,30}

ibutton = {}

function ibutton.new(xin,yin,control,icon,ready,w,h)
	local o = {}
	o.x = xin
	o.y = yin
	o.w = w or 64
	o.h = h or 64
	o.control = control
	o.hover = 18
	
	o.ready = ready or false
	o.icon = icon
	
	o.click = ibutton.click
	o.label = ibutton.label
	o.activate = ibutton.activate
	o.update = ibutton.update
	o.draw = ibutton.draw
	o.check = ibutton.check
	o.drawTip = ibutton.drawTip
	o.checkHover = ibutton.checkHover
	--print('ibut generated')
	return o
end

function ibutton:click()
	print("click")
end

function ibutton:label()
	return "Unlabeled Button"
end



function ibutton:activate()
end

function ibutton:update(dt)
	
end

function ibutton:draw()
	lg.setColor(colors.ui.border)
	lg.rectangle("fill",self.x,self.y,self.w,self.h)
    
    if self:check(lm.getX(),lm.getY()) and self.ready then -- select coloration of the icon
		lg.setColor(colors.ui.bghover)
	else
		lg.setColor(colors.ui.bg)
	end
    
    local border = 0.2 * self.h
	lg.rectangle("fill",self.x+border,self.y+border,self.w-(border*2),self.h-(border*2))
	
	if self:check(lm.getX(),lm.getY()) and self.ready then -- select coloration of the icon
		lg.setColor(colors.but.hover)
	elseif self.ready then
		lg.setColor(colors.but.ready)
	else
		lg.setColor(colors.but.locked)
	end
	
    local scale = self.h/self.icon:getHeight()
    if scale > 1 then scale = 1 end
    
    iconX = (self.w/2)-(self.icon:getWidth()/2)*scale
    iconY = (self.h/2)-(self.icon:getHeight()/2)*scale
    
	lg.draw(self.icon,self.x+iconX,self.y+iconY,0,scale,scale)

end


function ibutton:checkHover(x,y)
	return collideRect(x,y,self.x,self.y,self.w,self.h)		
end

function ibutton:drawTip(mx,my)
	if self:checkHover(mx,my) then
	local tipX = mx
	local tipY = my
	
	local text = lang.word(self.hover)
	g.setFont(fonts.sml)
	local tipW= fonts.sml:getWidth(text)
	local tipH= fonts.sml:getHeight(text)
	
	if mx > (g:getWidth()-tipW) then
		tipX = tipX-tipW-10
	else
		tipX = tipX+20
	end
	
	if my > (g:getHeight()-tipH) then
		tipY = tipY-tipH-10
	else
		tipY=tipY+10
	end
				
		g.setColor(30,30,30)
		g.rectangle("fill",tipX-4,tipY-4,tipW+8,tipH+8)
		g.setColor(255,255,255)
		g.printf(text,tipX,tipY,tipW,centre)
	end
end

function ibutton:check(mx,my)
	if mx >= self.x and mx <=self.x+self.w and my >= self.y and my <= self.y+self.h then
		return true
	else
		return false
	end
end

function collideRect(x,y,rx,ry,rw,rh)
	if x >= rx and x <= rx+rw and y >= ry and y<= ry+rh then
		return true
	end
	return false
end

return ibutton
