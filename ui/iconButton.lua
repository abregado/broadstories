-- menu button which has an icon instead of text
local lm = love.mouse

local colors = {but={},ui={}}
colors.but.hover = {255,0,0}
colors.but.ready = {255,255,255}
colors.but.locked = {0,0,0}
colors.ui.bg = {60,60,60}
colors.ui.icon = {255,255,255}

ibutton = {}

function ibutton.new(xin,yin,control,icon,ready)
	local o = {}
	o.x = xin
	o.y = yin
	o.w = 64
	o.h = 64
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
	print('ibut generated')
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
	lg.setColor(colors.ui.bg)
	lg.rectangle("fill",self.x-1,self.y-1,66,66)
	lg.setColor(colors.ui.icon)
	lg.rectangle("fill",self.x,self.y,64,64)
	
	if self:check(lm.getX(),lm.getY()) and self.ready then -- select coloration of the icon
		lg.setColor(colors.but.hover)
	elseif self.ready then
		lg.setColor(colors.but.ready)
	else
		lg.setColor(colors.but.locked)
	end
	
	lg.draw(self.icon,self.x,self.y)

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
