local mqtt = require("mqtt_library")
require "button"
json = require 'json'

local mqtt_client = 0
local subscribed = false

local latitude = 0
local longitude = 0

function response(topic, message)
  table = json.decode(message)
  latitude = table["location"]["lat"]
  longitude = table["location"]["lng"]
end

function request(args)
  mqtt_client:publish(args[1], args[2])
end

function love.mousepressed(x, y, button, istouch)
  button1:mousepressed(x, y)
end

function love.load()
  width , heigth = love.graphics.getDimensions()
  controle = false
  mqtt_client = mqtt.client.create("test.mosquitto.org", 1883, response)
  mqtt_client:connect("love-client")
end

function love.draw()
  button1:draw()
end

function love.update(dt)
  mqtt_client:handler()

  if not mqtt_client.connected then
    mqtt_client:connect("love-client")
  end

  if mqtt_client.connected and not subscribed then
    mqtt_client:subscribe({"ch/1"})
    mqtt_client:subscribe({"ch/3"})
    button1 = Button:create(width/2, heigth/3, "pedir coordenada", request, {"ch/2", "ch/3"})
    subscribed = not subscribed
  end
end