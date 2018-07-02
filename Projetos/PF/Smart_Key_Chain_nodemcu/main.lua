-----------------------------------------------------------------------------------------
--
-- main.lua
--
-- Autores: Leandro Morgado
--          Caio Feiertag
--
-- Data da ultima modificacao: 01/julho/2018
-- 
-- INF1805: Sistema Reativos. PUC-Rio
-- 
-----------------------------------------------------------------------------------------

local wifipoints = require 'wifipoints'

local led1 = 3
local led2 = 6
local sw1 = 1
local sw2 = 2

local ledstate = false

-- Verificar conexao a rede e ao servidor mqtt
local online = false

gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)
gpio.write(led1, gpio.LOW)
gpio.write(led2, gpio.LOW)
gpio.mode(sw1, gpio.INT, gpio.PULLUP)
gpio.mode(sw2, gpio.INT, gpio.PULLUP)

---- Piscar led
function blink(led)
  ledstate = not ledstate
  if ledstate then
    gpio.write(led, gpio.HIGH)
  else
    gpio.write(led, gpio.LOW)
  end
end

---- Apagar led
function stopBlink(led) 
  tmr.stop(led)
  gpio.write(led, gpio.LOW)
end

-- Callback erro nao conseguiu conexao ao servidor
function mqtt_error(client, reason)
  -- nova tentativa de conexao apos 1 segundo
  tmr.alarm(1, 1 * 1000, 0, do_mqtt_connect)
end

---- Callback sucesso node conectado ao servidor
function mqtt_connected(client)
  online = true
  stopBlink(led1)
  tmr.alarm(led2, 500, 1, function() blink(led2) end)
  -- publicar pontos de wifi no canal 1 (posicao inicial do chaveiro)
  wifipoints.publish_on_channel(client, "ch1/origin-position")
  client:subscribe("ch2/where-is-the-key-chain?", 0, ch2_subscribed)
end

---- Callback sucesso node subscreveu o canal 2
function ch2_subscribed(client)
  client:on("message", ch2_msg_handler)
end

---- Callback sucesso node recebeu mensagem no canal 2
function ch2_msg_handler(client, topic, message)
  -- publicar pontos de wifi no canal 3 (posicao final do chaveiro)
  wifipoints.publish_on_channel(client, "ch3/destination-position")
end

wificonf = {
  ssid = "network",
  pwd = "login",
  save = false
}

---- Conectar o nodemcu ao servidor mqtt
function do_mqtt_connect()
  _client:connect("iot.eclipse.org", 1883, 0, mqtt_connected, mqtt_error)
end

---- Checar a conexao a rede wifi
function checker()
  if wifi.sta.getip() ~= nil then
    tmr.stop(0)
    -- criar cliente mqtt para o node (ou chaveiro)
    _client = mqtt.Client("smart-key-chain-nodemcu", 120)
    -- tentar conexao ao servidor "broker" mqtt
    do_mqtt_connect()
  end
end

---- Callback ao pressionar o botao 1 ligar/resetar o chaveiro
function turnOn(level, timestamp)
  if not online then
    tmr.alarm(led1, 100, 1, function() blink(led1) end)
    wifi.setmode(wifi.STATION)
    wifi.sta.config(wificonf)
    tmr.alarm(0, 1000, 1, checker)
  else
    -- publicar nova posicao inicial no canal 1
    wifipoints.publish_on_channel(_client, "ch1/origin-position")
  end
end

---- Callback ao pressionar o botao 2 desligar o chaveiro
function turnOff(level, timestamp)  
  running, mode = tmr.state(led1)  
  if online then
    _client:close()
    stopBlink(led2)
  elseif running then
    stopBlink(led1)
  end
  wifi.sta.disconnect()
  online = false
end

gpio.trig(sw1, "down", turnOn)
gpio.trig(sw2, "down", turnOff)