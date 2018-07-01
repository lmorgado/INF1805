local wifipoints = {}

-- Número máximo de pontos de wi-fi
local _maxOfWifiPonts = 5

-- Info p/ nodemcu mqtt-client
local _client = nil
local _channel = ""
local _data = ""

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

local function _listap(t) 
  body = {}
  body["wifiAccessPoints"] = {}   
  
  for bssid, v in pairs(t) do
    this_m = {}
    this_m.macAddress = bssid
    table.insert(body.wifiAccessPoints, this_m)
  end
  
  if table.getn(body["wifiAccessPoints"]) > 0 then
    _data = _tableToString(body["wifiAccessPoints"])
    _client:publish(_channel, _data, 0, 0)
  else
    wifi.sta.getap(1, _listap)
  end 
end

function wifipoints.publish_on_channel(client, channel)
  _client = client
  _channel = channel
  wifi.sta.getap(1, _listap)
end

return wifipoints