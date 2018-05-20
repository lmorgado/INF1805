Button = {}
Button.__index = Button

function Button:create(x, y, name, func, args)
	local button = {}
  setmetatable(button, Button)
	button.x = x				-- origem x, y
	button.y = y
  button.name = name
	button.func = func
  button.args = args
  return button
end

function Button:draw()
    -- desenhar botao
  love.graphics.setColor(1,1,1)
  love.graphics.rectangle("fill", self.x -60, self.y-15, 120, 30)
  love.graphics.setColor(0,0,1)
  love.graphics.print(self.name, self.x-55, self.y-7)
end

function Button:mousepressed( mx, my)
  -- checar se o clique e no botao
--  if(mx>self.x-60 and mx<self.x+60 and my>self.y-15 and my<self.y+15) then
    self.func(self.args)
--  end
end 