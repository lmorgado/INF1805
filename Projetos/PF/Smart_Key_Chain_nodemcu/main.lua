local wifipoints = require 'wifipoints'

led1 = 3
led2 = 6
sw1 = 1
sw2 = 2
ledstate = false
online = false

gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)
gpio.write(led1, gpio.LOW)
gpio.write(led2, gpio.LOW)
gpio.mode(sw1, gpio.INT, gpio.PULLUP)
gpio.mode(sw2, gpio.INT, gpio.PULLUP)

function blink(led)
  ledstate = not ledstate
  if ledstate then
    gpio.write(led, gpio.HIGH)
  else
    gpio.write(led, gpio.LOW)
  end
end

function stopBlink(led) 
  tmr.stop(led)
  gpio.write(led, gpio.LOW)
end

function mqtt_error(client, reason)
  tmr.alarm(1, 10 * 1000, 0, do_mqtt_connect)
end

function mqtt_connected(client)
  online = true
  stopBlink(led1)
  tmr.alarm(led2, 500, 1, function() blink(led2) end)
  wifipoints.publish_on_channel(client, "ch1/origin-position")
  client:subscribe("ch2/where-is-the-key-chain?", 0, ch2_subscribe_handler)
end

function ch2_subscribe_handler(client)
  client:on("message", ch2_recieved_msg_handler)
end

function ch2_recieved_msg_handler(client, topic, message)
  wifipoints.publish_on_channel(client, "ch3/destination-position")
end

wificonf = {
  ssid = "network",
  pwd = "login",
  save = false
}

function do_mqtt_connect()
  _client:connect("iot.eclipse.org", 1883, 0, mqtt_connected, mqtt_error)
end

function checker()
  if wifi.sta.getip() ~= nil then
    tmr.stop(0)
    _client = mqtt.Client("smart-key-chain-nodemcu", 120)
    do_mqtt_connect()
  end
end

function turnOn(level, timestamp)
  if not online then
    tmr.alarm(led1, 100, 1, function() blink(led1) end)
    wifi.setmode(wifi.STATION)
    wifi.sta.config(wificonf)
    tmr.alarm(0, 1000, 1, checker)
  else
    wifipoints.publish_on_channel(_client, "ch1/origin-position")
  end
end

function turnOff(level, timestamp)  
  running, mode = tmr.state(led1)
  
  if online then
    while not _client:close() do end
    stopBlink(led2)
  elseif running then
    stopBlink(led1)
  end
  wifi.sta.disconnect()
  online = false
end

gpio.trig(sw1, "down", turnOn)
gpio.trig(sw2, "down", turnOff)