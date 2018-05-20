sw1 = 1
gpio.mode(sw1, gpio.INT, gpio.PULLUP)

-----------------
function handle_mqtt_error(client, reason)
  print("failed reason: "..reason)
end

function mqtt_connected(client)
  print("nodemcu success connected .. mosquito Broker")
  client:subscribe("ch/2", 0, ch2_handler)
end

function ch2_handler(client)
  print("nodemcu success subscribed .. topic ch/2")
  client:on("message", msg_handler)
end

function msg_handler(client, topic, message)
  _G.channel = message
  dofile("geolocation.lua")
end
-------------

wificonf = {
  ssid = "minhaRede",
  pwd = "minhaSenha",
  got_ip_cb = function (iptable) print ("ip: ".. iptable.IP) end,
  save = false
}

retriesCounter = 0

function checker() 
  if wifi.sta.getip() == nil then
    print("Conectando ao AP...")
    retriesCounter = retriesCounter + 1
  else
    retriesCounter = 0
    ip,mask,gw = wifi.sta.getip()
    print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
    print("Resumo da conexao:")
    print("IP     : ",ip)
    print("Mascara: ",mask)
    print("Gateway: ",gw)
    print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
    tmr.stop(0)
    _G.client = mqtt.Client("nodemcu-mqtt", 120)
    _G.client:connect("test.mosquitto.org", 1883, 0, mqtt_connected, handle_mqtt_error)
  end
end
 
function configMyWiFi()
  wifi.setmode(wifi.STATION)
	wifi.sta.config(wificonf)
  tmr.alarm(0, 1000, 1, checker)
end

local function getLocation(level, timestamp)
  print("Geting location .. wait .. wait")
  _G.channel = "ch/1"
  dofile("geolocation.lua")
end

gpio.trig(sw1, "down", getLocation)
configMyWiFi()