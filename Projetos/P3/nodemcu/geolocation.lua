function tableToString(t)     
  
  str = '{ "wifiPoints" : [ '      
  
  for i , obj in pairs(t) do        
    str = str .. '{'      

    for j , macNum in pairs(obj) do
      str = str .. '"' .. j .. '"' .. ' : ' .. '"' .. macNum .. '"'       
    end       
    
    str = str .. ' }'    
    
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
    this_m = {}
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
end

wifi.sta.getap(1, listap)