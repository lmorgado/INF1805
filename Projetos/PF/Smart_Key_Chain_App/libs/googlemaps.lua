-----------------------------------------------------------------------------------------
--
-- googlemaps.lua
--
-- Adaptada e estendia para o sdk Corona
-- 
-- * Referencia 1: https://github.com/ludc/googlemaps
-- 
-- * Referencia 2: https://developers.google.com/maps/documentation/
--
-- Autores: Ludovic Denoyer (modulo original) - University Pierre et Marie Curie
--          Leandro Morgado
--          Caio Feiertag
-- 
-- Ultima modificacao: 01/julho/2018
-- 
-- INF1805: Sistema Reativos. PUC-Rio
-- 
-----------------------------------------------------------------------------------------

require 'plugin.openssl'
local https = require 'plugin_luasec_https'
local bit = require 'plugin.bit'
local ltn12 = require 'ltn12'
local json = require 'json'

local googlemaps = {}


---- Get location: (latitude, longitude)
--@params request_body string with the wifi points
--@params key the google api key
function googlemaps.geolocation(request_body, key)
  
  url = "https://www.googleapis.com/geolocation/v1/geolocate?key="
  url = url..key

  local response_body = {}

  local r, c, h, s = https.request {                                                                                                                                                                            
    url = url,                                                                                                                                     
    method = 'POST',                                                                                                                                                           
    headers = {                                                                                                                                                       
      ['Content-Type'] = 'application/json; application/x-www-form-urlencoded',                                                                                                                               
      ['Content-Length'] = string.len(request_body)                                                                                                                           
    },                                                                                                                                                                      
    source = ltn12.source.string(request_body),
    sink = ltn12.sink.table(response_body)
  }

  local answer = ""
  for _, v in ipairs(response_body) do
    answer = answer..v
  end

  local resp_table = json.decode(answer)
  return resp_table
end

---- Get location adress
function googlemaps.address(latitude, longitude, key)
  
  local url = "https://maps.googleapis.com/maps/api/geocode/json?"
  url = url.."latlng="..latitude..","..longitude.."&key="..key

  local response_body = { }
   
  local r, c, h, status = https.request {
    url = url,
    sink = ltn12.sink.table(response_body),
    protocol = "tlsv1"
  }
  
  assert(string.match(status, "OK"), "Problem while querying Google Maps API: "..status)
  
  local answer = ""
  for _, v in ipairs(response_body) do
    answer = answer..v
  end

  local resp_table = json.decode(answer)
  return resp_table
end

---- Get info about timezone
function googlemaps.timezone(latitude, longitude, timestamp, key)
  
  local url = "https://maps.googleapis.com/maps/api/timezone/json?"
  url = url.."location="..latitude..","..longitude.."&timestamp="..timestamp.."&key="..key

  local response_body = {}
   
  local r, c, h, status = https.request {
    url = url,
    sink = ltn12.sink.table(response_body),
    protocol = "tlsv1"
  }
  
  assert(string.match(status, "OK"), "Problem while querying Google Maps API: "..status)
  
  local answer = ""
  for _, v in ipairs(response_body) do
    answer = answer..v
  end

  local resp_table = json.decode(answer)  
  return resp_table
end

 --- This function returns the json corresponding to a direction from 'origin' to 'destination' using the google directions API
 --@params origin the start point (lat,long as a string, or an address)
 --@params destination the final point (lat,long as a string, or an address)
 --@params mode the mode (e.g "driving")
 --@params key the google api key
 --@return the corresponding json
function googlemaps.direction(origin, destination, mode, key)
   
  local url = "https://maps.googleapis.com/maps/api/directions/json?"
  url = url.."origin="..origin.."&destination="..destination.."&mode="..mode.."&key="..key

  local resp = {}
   
  local result, content, h, statuscode = https.request {
    url = url,
    sink = ltn12.sink.table(resp),
    protocol = "tlsv1"
  }
  
  assert(string.match(statuscode, "OK"), "Problem while querying Google Maps API: "..statuscode)
  
  local answer = ""
  for _, v in ipairs(resp) do
    answer = answer..v
  end
  
  local j = json.decode(answer)
  return(j)
end

--- Encode a sequence of points to a polyline_str
--@params each point is point.lat and point.lng
function googlemaps.encode_polyline(points)
  
  local function _split_into_chunks(value)
    local chunks = {}
    local pos = 1
    while(value >= 32) do
        chunks[pos] = bit.bor(bit.band(value,31), 0x20)
        pos = pos + 1
        value = bit.rshift(value, 5)
    end
    chunks[pos] = value
    return chunks
  end
  
  local function _encode_value(value)
    if (value < 0) then
      value = bit.bnot(bit.lshift(value, 1))
    else
      value = bit.lshift(value, 1)
    end
    
    local chunks = _split_into_chunks(value)
    
    local retour = ""
    for _, v in ipairs(chunks) do
      retour = retour..string.char(v + 63)
    end
    return retour
  end
  
  local result = ""
   
  local prev_lat = 0
  local prev_lng = 0
    
    for k, p in ipairs(points) do        
        local lat = math.floor(p.lat * 1e5)
        local lng = math.floor(p.lng * 1e5)
        
        local d_lat = _encode_value(lat - prev_lat)
        local d_lng = _encode_value(lng - prev_lng)        
        
        prev_lat = lat
        prev_lng = lng
        
        result = result..d_lat
        result = result..d_lng
    end
    
    return result
end

---- Assemble multiple polylines (as string) to one single polyline (as string)
function googlemaps.assemble_polylines(tab_polylines)

  local decoded = {}  
  for k,v in ipairs(tab_polylines) do    
    decoded[k] = googlemaps.decode_polyline(v)
  end  
  
  local allpoints = {}; local idx = 1
  for k, v in ipairs(decoded) do
    for k2, v2 in ipairs(v) do      
      allpoints[idx] = v2
      idx = idx + 1
    end
  end
  
  return googlemaps.encode_polyline(allpoints)
end

---- This function save a PNG file corresponding to a map
--@params size a string corresponding to the size of the image e.g 640x480
--@params filename the name of the output file
--@params markers a set of points (each point is point.lat, point.lng
--@params polyline the string corresponding to the trajectory one wants to draw on the map. This trajectory is a string in the polyline format (not too long)
--@params key the API key
--- markers or polyline must be not nil
function googlemaps.save_map(size, polyline_str, markers, filename, key)
  
  assert((polyline_str~=nil) or (markers~=nil), "You must give at least a polyline or a set of markers")
  
  local url = "https://maps.googleapis.com/maps/api/staticmap?"
  url = url.."size="..size
  
  if (polyline_str ~= nil) then url = url.."&path=weight:3%7Ccolor:blue%7Cenc:"..polyline_str end
  
  if (markers ~= nil) then
    url = url.."&markers=color:blue%7Clabel:O%7C"
    url = url..markers[1].lat..","..markers[1].lng
    if #markers > 1 then
      url = url.."&markers=color:red%7Clabel:D%7C"
      url = url..markers[#markers].lat..","..markers[#markers].lng
    end
  end
  
  url = url.."&key="..key
  
  local resp = {}
  
  local result, content, h, statuscode = https.request {
    url = url,
    sink = ltn12.sink.table(resp),
    protocol = "tlsv1"
  }
  
  local answer = ""
  for _, v in ipairs(resp) do
    answer = answer..v
  end
  
  assert(string.match(statuscode, "OK"),"Problem while querying Google Maps: polyline is too long ?")
  
  local path = system.pathForFile(filename, system.DocumentsDirectory)
  local file, errorString = io.open(path, "wb")
  
  if not file then
    print("File error: "..errorString)
  else
    file:write(answer)
    file:close()   
  end
  
  file = nil 
end  

---- This function compute the heading (in degree between 0 and 360) given one start_position and one end_position)
function googlemaps.compute_heading(start_position_latitude,start_position_longitude,end_position_latitude,end_position_longitude)
    
    local lat1 = start_position_latitude
    local lat2 = end_position_latitude
    local long1 = start_position_longitude
    local long2 = end_position_longitude
    
    local dLon = (long2 - long1)

    local y = math.sin(dLon) * math.cos(lat2)
    local x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1)
            * math.cos(lat2) * math.cos(dLon)

    local brng = math.atan2(y, x)

    brng = math.deg(brng)
    while(brng > 360) do brng = brng - 360 end
    while(brng < 0) do brng = brng + 360 end

    return brng
end

---- This function computes the distance in meters between two points
function googlemaps.distance_on_earth(lat1, long1, lat2, long2)  
  
  local function distance_on_unit_sphere(lat1, long1, lat2, long2)
    degrees_to_radians = math.pi / 180.0
    local phi1 = (90.0 - lat1) * degrees_to_radians
    local phi2 = (90.0 - lat2) * degrees_to_radians
    local theta1 = long1 * degrees_to_radians
    local theta2 = long2 * degrees_to_radians
    local cos = (math.sin(phi1) * math.sin(phi2) * math.cos(theta1 - theta2) + math.cos(phi1) * math.cos(phi2))
    local arc = math.acos( cos )
    return arc
  end
  
  return distance_on_unit_sphere(lat1, long1, lat2, long2) * 6378137
end

---- This function decodes a polyline string and returns a list of points
function googlemaps.decode_polyline(polyline_str)
    
    local index, lat, lng = 1, 0, 0
    local coordinates = {}
    local pos = 1
    local changes = {}
    changes.latitude = 0
    changes.longitude = 0

    while (index <= polyline_str:len()) do
        
        do
          local shift, result = 0, 0

          while(true) do
                local byte = string.byte(polyline_str, index) - 63
                index = index + 1
                result = bit.bor(result, bit.lshift(bit.band(byte, 0x1f), shift))
                shift = shift + 5
                if (byte < 0x20) then
                    break
                end
          end

          if (bit.band(result,1) ~= 0) then
              changes.latitude = -(bit.rshift(result, 1))
          else
              changes.latitude = bit.rshift(result, 1)
          end
        end
        
        do
          local shift, result = 0, 0

          while(true) do
                local byte = string.byte(polyline_str, index) - 63
                index = index + 1
                
                local sh = bit.lshift(bit.band(byte,0x1f), shift)
                result = bit.bor(result,sh)
                shift = shift + 5
                if (byte < 0x20) then
                    break
                end
          end
          if (bit.band(result,1) ~= 0) then
              changes.longitude = -(bit.rshift(result, 1))
          else
              changes.longitude = bit.rshift(result, 1)
          end
        end
        
        lat = lat + changes.latitude
        lng = lng + changes.longitude
        
        coordinates[pos] = {}
          coordinates[pos].lat = lat / 100000.0
          coordinates[pos].lng = lng / 100000.0
        pos = pos + 1
    end
    return coordinates
  end

---- Save a google street view image
---@params lat,long = latitude and longitude of the point
---@params heading the heading
---@params size the size of the image e.g "640x480"
---@params filename the name of the ouput PNG file
---@params key the API key
function googlemaps.capture_street_view(lat, long, heading, size, filename, key)
  
  local url = "https://maps.googleapis.com/maps/api/streetview?"
  url = url.."size="..size
  url = url.."&location="..lat..","..long 
  url = url.."&heading="..heading  
  url = url.."&key="..key
  
  local resp = {}
  
  local result, content, h, statuscode = https.request {
    url = url,
    sink = ltn12.sink.table(resp),
    protocol = "tlsv1"
  }
  
  assert(string.match(statuscode, "OK"), "Problem while querying Google Maps API: "..statuscode)
  
  local answer = ""
  for _, v in ipairs(resp) do
    answer = answer..v
  end
  
  local path = system.pathForFile(filename, system.DocumentsDirectory)
  local file, errorString = io.open(path, "wb")
  
  if not file then
    print("File error: "..errorString)
  else
    file:write(answer)
    file:close()
  end
  
  file = nil 
end  

---- Returns the closest point on an existing road using the google Roads API
function googlemaps.get_point_on_road(lat, lng, key)
  
  local url = "https://roads.googleapis.com/v1/snapToRoads?path="..lat..","..lng.."&key="..key
  
   local resp = {}
   
   local result, content, h, statuscode = https.request {
    url = url,
    sink = ltn12.sink.table(resp),
    protocol = "tlsv1"
  }
  
  assert(string.match(statuscode, "OK"), "Problem while querying Google Roads API: "..statuscode)
  
  local answer = ""
  
  for _, v in ipairs(resp) do
    answer = answer..v
  end
  
  local j = json.decode(answer)
  
  local retour = {}
  
  if (j.snappedPoints == nil) then 
    retour.lat = lat 
    retour.lng = lng
    return retour
  end
  
  retour.lat = j.snappedPoints[1].location.latitude
  retour.lng = j.snappedPoints[1].location.longitude  
  
  return retour
end

return googlemaps