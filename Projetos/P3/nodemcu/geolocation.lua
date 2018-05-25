-- Número máximo de pontos de wi-fi
local maxOfWifiPonts = 3

-- Função para converter tabela para json string
function tableToString(t)
  print("@ Number of visible WifiPoints: " .. #t)
  str = '{"wifiPoints":['
  numberOfWifiPonts = math.min(maxOfWifiPonts, #t)
  -- Formatar tabela em json string p/ Google API
  for i , obj in pairs(t) do
    if i > numberOfWifiPonts then
      break
    end
    -- só considerado macAdresses
    str = str .. '{'
    for j , value in pairs(obj) do 
      str = str .. '"' .. j .. '"' .. ':' .. '"' .. value .. '"'   
    end
    str = str .. '}'
    if(i ~= numberOfWifiPonts) then
      str = str .. ','
    end  
  end
  return str .. ']}'
end

-- Requisitar geolocalização à Google API
function getGeoFromWiFi()
  print("Requesting geoLocation .. .. ..")
  -- Requisitar a geolocalização após 2 segundos
  tmr.alarm(1, 2 * 1000, 0, 
    function()
      http.post("https://www.googleapis.com/geolocation/v1/geolocate?key=AIzaSyBtoGhEwgnkJ0Dj5uiLv_WoEeth6QUlc0k", "Content-Type: application/json\r\n", json,  
        function(code, data)
          -- Erro. Não se conseguiu a geolocalização
          if (code < 0) then 
            data = '{"location": {"lat": "error", "lng": "error"}}'      
            -- Enviar error à interface love
            _G.client:publish(_G.channel, data, 0, 0,
              function(client)
                print("!! HTTP request failed.")
                print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
              end
            )
          -- Sucesso. Geolocalização retornada.
          else
            -- Enviar Geolocalização à interface love
            _G.client:publish(_G.channel, data, 0, 0,
              function(client)
                print("!! HTTP request success.")
                print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
              end
            )
          end
          -- Reabilitar botão do nodemcu a uma nova requisição
          _G.clicked = false
        end
      )
    end
  )
end

-- Callback para a chamada "wifi.sta.getap(1, listap)"
-- Recebe uma tabela "t" com info sobre os pontos de wi-fi próximos
function listap(t) 
  body = {}
  body["wifiAccessPoints"] = {}   
  for bssid, v in pairs(t) do
    this_m = {}
    this_m.macAddress = bssid
    table.insert(body.wifiAccessPoints, this_m)
  end
  -- Tabela "t" recebida corretamente
  if table.getn(body["wifiAccessPoints"]) > 0 then
    -- Obtém o json string
    json = tableToString(body["wifiAccessPoints"])
    print("@ The " .. numberOfWifiPonts .. " WifiPoint(s) considered: ")
    print(json)
    print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
    -- Pedir geolocalização à Google API
    getGeoFromWiFi()
  -- Tabela "t" vazia, requisitar novamente os pontos de wi-fi
  else
    wifi.sta.getap(1, listap)
  end 
end

-- Obter os pontos de wi-fi próximos ao nodemcu (já conectado à rede e ao servidor!)
wifi.sta.getap(1, listap)