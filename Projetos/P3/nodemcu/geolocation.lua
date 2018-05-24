local numberOfWifiPonts = 1

function tableToString(t)
  print("@ Number of visible WifiPoints: " .. #t)
  str = '{"wifiPoints":['
  for i , obj in pairs(t) do
    if i > numberOfWifiPonts then
      break
    end
    str = str .. '{'
    for j , macNum in pairs(obj) do
      str = str .. '"' .. j .. '"' .. ':' .. '"' .. macNum .. '"'   
    end
    str = str .. '}'
    if(i ~= math.min(numberOfWifiPonts, #t)) then
      str = str .. ','
    end  
  end    
  return str .. ']}'
end

json = ""

function listap(t) 
  body = {}
  body["wifiAccessPoints"] = {}   
  for bssid, v in pairs(t) do
    this_m = {}
    this_m.macAddress = bssid
    table.insert(body.wifiAccessPoints, this_m)
  end
  while table.getn(body["wifiAccessPoints"]) == 0 do
    getGeoFromWiFi()
  end
  json = tableToString(body["wifiAccessPoints"])
  print("@ The WifiPoints considered: ")
  print(json)
  print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")

  print("Calcutating geoLocation .. .. ..")
  
  tmr.alarm(1, 5 * 1000, 0, 
    function()
      http.post('https://www.googleapis.com/geolocation/v1/geolocate?key=AIzaSyBtoGhEwgnkJ0Dj5uiLv_WoEeth6QUlc0k', 'Content-Type: application/json\r\n', json,  
        function(code, data)
          if (code < 0) then 
            data = '{"location": {"lat": "error", "lng": "error"}}'      
            _G.client:publish(_G.channel, data, 0, 0,
              function(client)
                print("!! HTTP request failed.")
                print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
              end
            )
          else
            _G.client:publish(_G.channel, data, 0, 0,
              function(client)
                print("!! HTTP request success")
                print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
              end
            )
          end
        end
      )
    end
  )
  _G.clicked = false
end

function getGeoFromWiFi()
  wifi.sta.getap(1, listap)
end

getGeoFromWiFi()