-----------------------------------------------------------------------------------------
--
-- main.lua
--
-- Autores: Leandro Morgado
--          Caio Feiertag
--          
-- Ultima modificacao: 01/julho/2018
-- 
-- INF1805: Sistema Reativos. PUC-Rio
-- 
-----------------------------------------------------------------------------------------

require 'libs.ui'
require "libs.key"

local mqtt = require "libs.mqtt_library"
local googlemaps = require "libs.googlemaps"

---- Barra de botoes inicialmente travada; ligar chaveiro para destrava-la
local _tabBarIsLocked = true

local _actual_screen = "none"


---- Mostrar mapa e trajeoria (o app procura o chaveiro)
function show_map()  
  local str_orig = _orig_lat..",".._orig_lng
  local str_dest = _dest_lat..",".._dest_lng
  local mode = "driving" -- outros modos: "walking", "bicycling" ou "transit"

  local json = googlemaps.direction(str_orig, str_dest, mode, KEY)
  local leg = json.routes[1].legs[1]
  local polylines = {}
  
  for s = 1, #leg.steps do
    local st = leg.steps[s]
    if st ~= nil then
      polylines[s] = st.polyline.points
    end
  end

  local markers = {{lat = _orig_lat, lng = _orig_lng}, {lat = _dest_lat, lng = _dest_lng}}
  local polylines_str = googlemaps.assemble_polylines(polylines) 
  local width = 0.80 * _ui.viewableScreenW
  local height = 0.60 * _ui.viewableScreenH
  local size = width.."x"..height

  googlemaps.save_map(size, polylines_str, markers, "map.png", KEY)
  
  _map_img = _ui:image(width, height, "map.png")
end

---- Mostrar informacoes como enderecos, datas, distancias etc.
function show_info()    
  local year = _orig_date.year
  local month = _orig_date.month
  local day = _orig_date.day
  local hour = _orig_date.hour
  local min = _orig_date.min
  local sec = _orig_date.sec  
  
  local str = "-- Your key chain started at ".._orig_addr
  _orig_addr_label = _ui:text(0.15 * _ui.viewableScreenW, 0.10 * _ui.viewableScreenH, str)

  str = "* Initial time: "..day.."/"..month.."/"..year
  str = str.." at "..hour..":"..min..":"..sec
  _orig_date_label = _ui:text(0.15 * _ui.viewableScreenW, 0.43 * _ui.viewableScreenH, str)

  str = "* Initial coord: ".."(".._orig_lat..", ".._orig_lng..")"
  _orig_coord_label = _ui:text(0.15 * _ui.viewableScreenW, 0.53 * _ui.viewableScreenH, str)

  _dest_date = os.date("*t")
  
  year = _dest_date.year
  month = _dest_date.month
  day = _dest_date.day
  hour = _dest_date.hour
  min = _dest_date.min
  lsec = _dest_date.sec

  str = "-- Your key chain is at ".._dest_addr
  _dest_addr_label = _ui:text(0.15 * _ui.viewableScreenW, 0.22 * _ui.viewableScreenH, str)

  str = "* Final time: "..day.."/"..month.."/"..year
  str = str.." at "..hour..":"..min..":"..sec
  _dest_date_label = _ui:text(0.15 * _ui.viewableScreenW, 0.48 * _ui.viewableScreenH, str)

  str = "* Final coord: ".."(".._dest_lat..", ".._dest_lng..")"
  _dest_coord_label = _ui:text(0.15 * _ui.viewableScreenW, 0.58 * _ui.viewableScreenH, str)

  local dist = googlemaps.distance_on_earth(_orig_lat, _orig_lng, _dest_lat, _dest_lng)
  dist = math.round(dist / 1000)
  
  str = "* Travelled distance: "..dist.." Km"
  _dist_label = _ui:text(0.15 * _ui.viewableScreenW, 0.38 * _ui.viewableScreenH, str)

  str = "-- Others informations: "
  _mark_label = _ui:text(0.15 * _ui.viewableScreenW, 0.33 * _ui.viewableScreenH, str)
end

---- Mostrar fotos "street views" de angulos diferentes
function show_photos() 
  local width = 0.80 * _ui.viewableScreenW
  local height = 0.60 * _ui.viewableScreenH
  local size = width.."x"..height

  local heading = 0 -- define o angulo da foto
  local images = {}

  for i = 1, 9 do
    local filename = "view"..heading..".png"
    googlemaps.capture_street_view(_dest_lat, _dest_lng, heading, size, filename, KEY)
    table.insert(images, filename)
    heading = heading + 45
  end

  _photos_img = _ui:slideView(images)
  _photos_img.y = -_ui.viewableScreenH / 8
end

---- Limpar tela e seus elementos ui view
function clean_screen(screen)

  if _origMsg ~= nil then
    display.remove(_origMsg)
    _origMsg = nil
  end

   if _progView ~= nil then
    display.remove(_progView)
    _progView = nil
  end

  if _statusMsg ~= nil then
    display.remove(_statusMsg)
    _statusMsg = nil
  end
 
  if "view" == screen then
    display.remove(_photos_img)
    _photos_img = nil
  
  elseif "map" == screen then
    display.remove(_map_img)
    _map_img = nil
  
  elseif "info" == screen then
    display.remove(_orig_addr_label)
    _orig_addr_label = nil
    
    display.remove(_dest_addr_label)
    _dest_addr_label = nil
    
    display.remove(_mark_label)
    _mark_label = nil
    
    display.remove(_dist_label)
    _dist_label = nil
    
    display.remove(_orig_date_label)
    _orig_date_label = nil
    
    display.remove(_dest_date_label)
    _dest_date_label = nil
    
    display.remove(_orig_coord_label)
    _orig_coord_label = nil
    
    display.remove(_dest_coord_label)
    _dest_coord_label = nil
  end
end

---- Listener para os 3 butoes ("map", "view" e "info")
local function handle_button(event)
  if not _tabBarIsLocked then
    _past_screen = _actual_screen -- tela a ser substituida
    _actual_screen = event.target.id -- nova tela
    _client:publish("ch2/where-is-the-key-chain?", "where are you, key-chain?")
  end
end

---- Callback sucesso recebe info no canal 1 (pt inicial) ou 3 (pt final)
local function mqtt_callback(topic, payload)
  local resp = googlemaps.geolocation(payload, KEY)
  local lat = resp["location"]["lat"]
  local lng = resp["location"]["lng"]
  local res = googlemaps.address(lat, lng, KEY)
  local addr = res["results"][1]["formatted_address"]
  
  if (topic == "ch1/origin-position") then
    _orig_lat = lat
    _orig_lng = lng
    _orig_addr = addr
   
    clean_screen(_actual_screen)
    
    local str = "Tab bar is unlocked and your key chain is at ".._orig_addr 
    if _origMsg ~= nil then
      _origMsg.text = str
    else
      _origMsg = _ui:text(0.15 * _ui.viewableScreenW, 0.15 * _ui.viewableScreenH, str)
    end
       
    _orig_date = os.date("*t")
    _tabBarIsLocked = false
  
  else   
    -- Esse e o trecho correto!
    -- _dest_lat = lat
    -- _dest_lng = lng
    -- _dest_addr = addr
    
    -- Mas pode ser dificil sairmos com o node ligado rua a fora
    -- e, portanto, a posicao final sera sempre igual a inicial;
    -- para um teste mais completo setamos uma posicao final "fake" generica
    _dest_lat = -22.988620
    _dest_lng = -43.193047
    res = googlemaps.address(_dest_lat, _dest_lng, KEY)
    _dest_addr = res["results"][1]["formatted_address"]
    
    clean_screen(_past_screen)

    if "map" == _actual_screen then
      show_map()
    
    elseif "view" == _actual_screen then
      show_photos()
    
    elseif "info" == _actual_screen then
      show_info()
    end 
  end
end

---- Iniciar o app
local function init()
  local id = "smart-key-chain-app"
  local code = math.random(1, 100)
  id = id..code -- id unico p/ cada app cliente
  
  -- criar cliente, conectar ao servidor mqtt e assinar os canais 1 e 3
  _client = mqtt.client.create("iot.eclipse.org", 1883, mqtt_callback)
  _client:connect(id)
  _client:subscribe({"ch1/origin-position", "ch3/destination-position"}) 
  
  -- iniciar a interface de usuario com seus itens iniciais
  _ui = Ui:create()
  _progView = _ui:progressView(0.15 * _ui.viewableScreenW, 0.1 * _ui.viewableScreenH, 0.4 * _ui.viewableScreenW)
  _progView:setProgress(1.0) 
  
  local str = "Please, update your key chain: press the power button!"
  _statusMsg = _ui:text(0.15 * _ui.viewableScreenW, 0.15 * _ui.viewableScreenH, str) 
  _tabBar = _ui:tabBar(handle_button, handle_button, handle_button)  
end

---- loop infinito (60 fps) p/ monitorar os canais subscritos (novas info)
local update = function(event)
  if _client ~= nil then
    _client:handler()
  end
end

init()
Runtime:addEventListener("enterFrame", update)