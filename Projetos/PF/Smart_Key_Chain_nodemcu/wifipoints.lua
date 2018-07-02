-----------------------------------------------------------------------------------------
--
-- wifipoints.lua
--
-- Autores: Leandro Morgado
--          Caio Feiertag
--
-- Data da ultima modificacao: 01/julho/2018
-- 
-- INF1805: Sistema Reativos. PUC-Rio
-- 
-----------------------------------------------------------------------------------------

local wifipoints = {}

---- Numero maximo de pontos de wi-fi
local _maxOfWifiPonts = 5

-- Converter tabela em string
local function _tableToString(t)
  str = '{"wifiPoints":['
  
  numberOfWifiPonts = math.min(_maxOfWifiPonts, #t)
  
  for i , obj in pairs(t) do
    if i > numberOfWifiPonts then
      break
    end
  
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

---- Callback sucesso recebe os pontos de wifi encontrados
local function _listap(t)
  body = {}
  body["wifiAccessPoints"] = {}   
  
  for bssid, v in pairs(t) do
    this_m = {}
    this_m.macAddress = bssid
    table.insert(body.wifiAccessPoints, this_m)
  end
  
  local data = _tableToString(body["wifiAccessPoints"])
  
  -- publica pontos de wifi em dado canal
  _client:publish(_channel, data, 0, 0)
end

---- Rastrear/publicar pontos de wifi proximos
function wifipoints.publish_on_channel(client, channel)
  _client = client
  _channel = channel
  wifi.sta.getap(1, _listap)
end

return wifipoints