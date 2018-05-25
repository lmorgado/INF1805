--Caio Gonçalves Feiertag 1510590
--Leandro Morgado 1212042

-- Botão 1 do nodemcu
sw1 = 1
gpio.mode(sw1, gpio.INT, gpio.PULLUP)

-- Callback erro ao conectar ao servidor mqtt 
function handle_mqtt_error(client, reason)
  print("failed for reason: ", reason)
  print("@ Reconecting NodeMCU to Mosquito server .. .. ..")
  -- nova tentativa de conexão o servidor mqtt
  tmr.alarm(1, 10 * 1000, 0, do_mqtt_connect)
end

-- Callback sucesso ao conectar ao servidor mqtt
function mqtt_connected(client)
  print("@ NodeMCU connected to MQTT server")
  -- Cliente nodemcu assina o canal "ch/2"
  client:subscribe("ch/2", 0, ch2_handler)
end

-- Cliente nodemcu escutando no tópico "ch/2"
function ch2_handler(client)
  print("@ NodeMCU listens on topic \"ch/2\"")
  print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
  -- Registrar função para receber a mensagem (string com info)
  client:on("message", msg_handler)
end

-- Função para gerenciar mensagem recebida
function msg_handler(client, topic, message)
  -- Canal onde o outro cliente quer receber a geolocalização
  _G.channel = message
  -- Buscar geolocalização
  dofile("geolocation.lua")
end

-- Configuração da rede de wi-fi
wificonf = {
  ssid = "Kelvin",
  pwd = "23101988",
  save = false
}

-- Tempo que o nodemcu levará para se conectar à rede wi-fi
timeWifiConnection = 0

-- Função para conectar o nodemcu ao servidor mqtt "broker"
function do_mqtt_connect()
  _G.client:connect("iot.eclipse.org", 1883, 0, mqtt_connected, handle_mqtt_error)
end

-- Função (alarme, loop infinito) para conectar o nodemcu à rede wi-fi.
-- Cria o nodemcu mqtt cliente e o conecta ao servidor mqtt.
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
    -- nodemcu cliente
    _G.client = mqtt.Client("nodemcu-mqtt", 120)
    -- conectar o nodemcu ao mqtt
    do_mqtt_connect()
  end
end

-- Início: conectar o nodemcu à rede e ao servidor mqtt
function configMyWiFi()
  wifi.setmode(wifi.STATION)
	wifi.sta.config(wificonf)
  -- alarme "id=0" até criar todas as conexões necessárias
  tmr.alarm(0, 1000, 1, checker)
end

-- Controla o clique do botão, impedindo o "hold"
_G.clicked = false

-- Requisitar latitude e longitude
-- Callback acionada no clique do botão 1
local function getLocation(level, timestamp)
  if not _G.clicked then
    -- tópico "ch/1", escutado pela interface love
    _G.channel = "ch/1"
    -- requisitar coordenadas
    dofile("geolocation.lua")
    _G.clicked = true
  end
end

gpio.trig(sw1, "down", getLocation)
configMyWiFi()