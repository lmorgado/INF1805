function tableToString(t)     
  
  str = '{ "wifiPoints" : [ '      
  
  for i , list in pairs(t) do  
    
    str = str .. '{'      
    str = str .. '"' .. "macAddress" .. '"' .. ' : ' .. '"' .. list["macAddress"] .. '"' .. ','
    str = str .. '"' .. "signalStrength" .. '"' .. ' : ' .. list["signalStrength"] .. ','
    str = str .. '"' .. "channel" .. '"' .. ' : ' .. list["channel"]  
    str = str .. '}'  
    
    if(i ~= #t) then
      str = str .. ', '
    end    
  
  end
  
  return str .. '] }'

end

function listap(t)   
  
  body = {}
  body["wifiAccessPoints"] = {}
  
  for bssid, v in pairs(t) do   
    local ssid, rssi, authmode, channel = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]*)")
    this_m = {}
    this_m.channel = channel
    this_m.signalStrength = rssi
    this_m.macAddress = bssid
    table.insert(body.wifiAccessPoints, this_m)
  end
    
  str = tableToString(body["wifiAccessPoints"])
  
  http.post('https://www.googleapis.com/geolocation/v1/geolocate?key=AIzaSyD9a1Zz9_dger1y69XvJf_nWqnkX203Phg', 'Content-Type: application/json\r\n', str,
    function(code, data)
      if (code < 0) then
        print("HTTP request failed")
      else
        _G.client:publish(_G.channel, data, 0, 0, function(client) print("info sent!") end)
      end 
  end)

  _G.clicked = false

end

wifi.sta.getap(1, listap)