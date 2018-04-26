-- criar retangulo encapsulado
function retangulo(x, y, w, h)  
  local originalx, originaly, rx, ry, rw, rh = x, y, x, y, w, h; 
  -- verifica se o mouse esta sobre o retangulo
  local naimagem =  function(mx, my, x, y) 
                      return (mx > x) and (mx < x + w) and (my > y) and (my < y + h)
                    end
    return {
      -- desenha retangulo
      draw =  function()
        love.graphics.rectangle("line", rx, ry, rw, rh)
      end,
      -- verifica tecla pressionada 
      keypressed = function(key)
        local mx, my = love.mouse.getPosition()
        if naimagem(mx, my, rx, ry) then
          if key == 'b' then
            rx = originalx
            ry = originaly
          elseif key == 'down' then
            ry = ry + 10
          elseif key == 'up' then
            ry = ry - 10
          elseif key == 'right' then
            rx = rx + 10
          elseif key == 'left' then
            rx = rx - 10
          end
        end
      end,
      -- atualiza o retangulo
      update = function(dt)
        -- body
      end   
    }
end

function love.load()
  -- vetor de retangulos
  rets = {}
  for i = 1, 4, 1 do
    local ret = retangulo(50 + 150 * i, 100 * i, 50, 50)
    table.insert(rets, ret)
  end
end

function love.keypressed(key)
  -- percorre o vetor + verifica tecla pressionada
  for i, ret in pairs(rets) do
    ret.keypressed(key)
  end 
end

function love.update(dt)
  -- percorre o vetor + atualiza os retangulos
  for i, ret in pairs(rets) do
    ret.update(dt)
  end 
end

function love.draw()
  -- percorre o vetor + desenha os retangulos
  for i, ret in pairs(rets) do
    ret.draw()
  end 
end