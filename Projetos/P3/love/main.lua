local mqtt = require("mqtt_library")
require "button"
require "label"
json = require "json"

function response(topic, message)
  table = json.decode(message)
  if(table["location"]["lat"] or table["location"]["lng"]) then
    if(topic == 'ch/1') then
      vError["info"].name = 'Cliente enviou erro'
    else
      vError["info"].name = 'Informacao pedida retornou erro'
    end
    deactivate(vInfo)
    activate(vError)
  else
    vInfo["latitude"]:change_name("Latitude: " .. table["location"]["lat"])
    vInfo["longitude"]:change_name("Longitude: " .. table["location"]["lng"])
  end
end
function request(args)
  if(mqtt_client.connected) then
    mqtt_client:publish(args[1],args[2])
  end
end
function connect()
  vInfo["client"]:change_name("Client: " .. vConnect["text"].name)
  mqtt_client:connect(vInfo["client"].name)
  if(mqtt_client.connected) then
    mqtt_client:subscribe({"ch/1"})
    mqtt_client:subscribe({"ch/3"})
    activate(vInfo)
    deactivate(vConnect)
  else
    connect()
  end
end
function disconnect()
  mqtt_client:disconnect()
  activate(vConnect)
  deactivate(vInfo)
  vInfo["client"].name = "Client: nil"
end
function errorClose()
  deactivate(vError)
  activate(vInfo)
end
function love.keypressed(key)
  vConnect["text"]:update(key)
  if(key == '1') then
    mqtt_client:publish('ch/1',"error")
  end
  if(key == '3') then
    mqtt_client:publish('ch/3',"error")
  end
end
function love.mousepressed( x, y, button, istouch )
  for _ , b in pairs(vButton) do
    b:mousepressed( x, y)
  end
end
function love.mousereleased( x, y, button, istouch )
  for _ , b in pairs(vButton) do
    b:mousereleased( )
  end
end
function love.load()
  width , heigth = love.graphics.getDimensions()
  mqtt_client = mqtt.client.create("iot.eclipse.org", 1883, response)
  vConnect = {}
  vButton = {}
  vConnect["connect"]=Button:create(width/2+20, heigth/3, 62, 30, "conectar",connect)
  vButton["connect"] = vConnect["connect"]
  vConnect["text"] = Label:create(width/4, heigth/3, 30, 200, "love-client")
  activate(vConnect)
  vInfo = {}
  vInfo["client"] = Label:create(width/2, 7*heigth/12, 30, 165, "Client: nil")
  vInfo["latitude"] = Label:create(width/2, 8*heigth/12, 30, 165, "Latitude: nil")
  vInfo["longitude"] = Label:create(width/2, 9*heigth/12, 30, 165, "Longitude: nil")
  vInfo["request"] = Button:create(width/4, 7*heigth/12, 120, 30, "pedir coordenada",request,{"ch/2", "ch/3"})
  vInfo["disconnect"] = Button:create(width/4, 9*heigth/12, 120, 30, "desconectar",disconnect)
  vButton["request"] = vInfo["request"]
  vButton["disconnect"] = vInfo["disconnect"]
  vError = {}
  vError["info"] = Label:create(width/2 - 105, heigth/2 - 50, 30, 210, "nil")
  vError["close"] = Button:create(width/2 - 25, heigth/2 + 50, 50, 30, "close",errorClose)
  vButton["close"] = vError["close"]
  
end

function love.draw()
  for _ , c in pairs(vConnect) do
    c:draw()
  end
  for _ , i in pairs(vInfo) do
    i:draw()
  end
  for _ , e in pairs(vError) do
    e:draw()
  end
end

function love.update(dt)
  if(mqtt_client.connected) then
    mqtt_client:handler()
  end
end
function activate(table)
  for _ , t in pairs(table) do
    t.active = true
  end
end
function deactivate(table)
  for _ , t in pairs(table) do
    t.active = false
  end
end
