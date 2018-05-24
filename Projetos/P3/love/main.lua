local mqtt = require("mqtt_library")
require "button"
require "label"
json = require "json"

function response(topic, message)
  table = json.decode(message)
  vLabel["latitude"]:change_name("Latitude: " .. table["location"]["lat"])
  vLabel["longitude"]:change_name("Longitude: " .. table["location"]["lng"])
end
function request(args)
  if(mqtt_client.connected) then
    mqtt_client:publish(args[1],args[2])
  end
end
function connect()
  vLabel["client"]:change_name("Client: " .. vLabel["text"].name)
  mqtt_client:connect(vLabel["text"].name)
  if(mqtt_client.connected) then
    mqtt_client:subscribe({"ch/1"})
    mqtt_client:subscribe({"ch/3"})
  else
    connect()
  end
end
function love.keypressed(key)
  vLabel["text"]:update(key)
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
  vButton = {}
  table.insert(vButton,Button:create(width/4, 7*heigth/12, 120, 30, "pedir coordenada",request,{"ch/2", "ch/3"}))
  table.insert(vButton,Button:create(width/2+20, heigth/3, 62, 30, "conectar",connect))
  vLabel = {}
  vLabel["text"] = Label:create(width/4, heigth/3, 30, 200, "love-client")
  vLabel["client"] = Label:create(width/2, 7*heigth/12, 30, 165, "Client: nil")
  vLabel["latitude"] = Label:create(width/2, 8*heigth/12, 30, 165, "Latitude:0.0")
  vLabel["longitude"] = Label:create(width/2, 9*heigth/12, 30, 165, "Longitude:0.0")
end

function love.draw()
  for _ , b in pairs(vButton) do
    b:draw()
  end
  for _ , l in pairs(vLabel) do
    l:draw()
  end
end

function love.update(dt)
  if(mqtt_client.connected) then
    mqtt_client:handler()
  end
end