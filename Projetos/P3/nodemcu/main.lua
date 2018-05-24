sw1 = 1
gpio.mode(sw1, gpio.INT, gpio.PULLUP)

function handle_mqtt_error(client, reason)
  print("failed for reason: ", reason)
  print("@ Reconecting NodeMCU to Mosquito server .. .. ..")
  tmr.alarm(1, 10 * 1000, 0, do_mqtt_connect)
end

function mqtt_connected(client)
  print("@ NodeMCU connected to MQTT server")
  client:subscribe("ch/2", 0, ch2_handler)
end

function ch2_handler(client)
  print("@ NodeMCU listens on topic \"ch/2\"")
  print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
  client:on("message", msg_handler)
end

function msg_handler(client, topic, message)
  _G.channel = message
  dofile("geolocation.lua")
end

wificonf = {
  ssid = "Kelvin",
  pwd = "23101988",
  save = false
}

timeWifiConnection = 0

function do_mqtt_connect()
  _G.client:connect("iot.eclipse.org", 1883, 0, mqtt_connected, handle_mqtt_error)
end

function checker()
  if wifi.sta.getip() == nil then
    timeWifiConnection = timeWifiConnection + 1
  else
    ip,mask,gw = wifi.sta.getip()
    print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
    print("@ NodeMCU connected to Wifi. Resume: ")
    print("Time: " .. timeWifiConnection .. 's')
    print("IP     : ", ip)
    print("Mask: ", mask)
    print("Gateway: ", gw)
    print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
    tmr.stop(0)
    _G.client = mqtt.Client("nodemcu-mqtt", 120)
    do_mqtt_connect()
  end
end

function configMyWiFi()
  wifi.setmode(wifi.STATION)
	wifi.sta.config(wificonf)
  tmr.alarm(0, 1000, 1, checker)
end

_G.clicked = false

local function getLocation(level, timestamp)
  if not _G.clicked then
    _G.channel = "ch/1"
    dofile("geolocation.lua")
    _G.clicked = true
  end
end

gpio.trig(sw1, "down", getLocation)
configMyWiFi()