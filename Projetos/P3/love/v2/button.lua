Button = {}
Button.__index = Button

function Button:create(x, y, width, heigth, name, func, args)
	local button = {}
  setmetatable(button, Button)
	button.x = x				-- origem x, y
	button.y = y
  button.name = name
	button.func = func
  button.args = args
  button.width = width
  button.heigth = heigth
  button.color = {["r"] = 1 , ["g"] = 0, ["b"] = 0};
  return button
end

function Button:draw()
    -- desenhar botao
  love.graphics.setColor(self.color["r"], self.color["g"], self.color["b"]);
  love.graphics.rectangle("fill", self.x , self.y, self.width, self.heigth, 5)
  love.graphics.setColor(0,0,1)
  love.graphics.rectangle("line", self.x , self.y, self.width, self.heigth, 5)
  love.graphics.print(self.name, self.x+5, self.y+5)
end

function Button:mousepressed( mx, my)
  -- checar se o clique e no botao
  if(mx>self.x and mx<self.x+self.width and my>self.y and my<self.y+self.heigth) then
    self.color["r"]=1 
    self.color["g"]=1
    self.color["b"]=1
    self.func(self.args)
  end
end 

function Button:mousereleased()
  self.color["r"]=1 
  self.color["g"]=0
  self.color["b"]=0
end