Label = {}
Label.__index = Label

function Label:create(x, y, heigth, width, name)
	local label = {}
  setmetatable(label, Label)
	label.x = x				-- origem x, y
	label.y = y
  label.heigth = heigth
  label.width = width
  label.name = name
  return label
end

function Label:draw()
    -- desenhar label
  love.graphics.setColor(1,1,1)
  love.graphics.rectangle("fill", self.x, self.y, self.width, self.heigth)
  love.graphics.setColor(0,0,0)
  love.graphics.print(self.name, self.x+5, self.y+5)
end

function Label:update(key)
  if key == 'backspace' then
    self.name = string.sub(self.name, 1, string.len(self.name)-1)
  else
    self.name = self.name .. key
  end
end
function Label:change_name(name)
  self.name=name
end 