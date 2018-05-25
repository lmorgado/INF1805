--Caio Gonçalves Feiertag 1510590
--Leandro Morgado 1212042

local mqtt = require("mqtt_library")
require "button"
require "label"
json = require "json"

function response(topic, message)
  --insere a informacao recebida, em caso de erro ativa a notificacao de erro
  table = json.decode(message)
  if(table["location"]["lat"]== 'error' or table["location"]["lng"]=='error') then
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
  -- handler do botao request
  if(mqtt_client.connected) then
    mqtt_client:publish(args[1],args[2])
  end
end
function connect()
  --handler do botao connect
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
  --handler do botao disconnect
  mqtt_client:disconnect()
  activate(vConnect)
  deactivate(vInfo)
  vInfo["client"].name = "Client: nil"
  vInfo["latitude"].name = "Latitude: nil"
  vInfo["longitude"].name = "Longitude: nil"
end
function errorClose()
  --handler do pressionamento do botao para fechar o erro
  deactivate(vError)
  activate(vInfo)
end
function love.keypressed(key)
  vConnect["text"]:update(key)
end
function love.mousepressed( x, y, button, istouch )
  -- clique no botao
  for _ , b in pairs(vButton) do
    b:mousepressed( x, y)
  end
end
function love.mousereleased( x, y, button, istouch )
  --desativa animacao de clique
  for _ , b in pairs(vButton) do
    b:mousereleased( )
  end
end
function love.load()
  width , heigth = love.graphics.getDimensions()
  mqtt_client = mqtt.client.create("iot.eclipse.org", 1883, response)
  -- cria tabelas de componentes e salva a referencia para os botoes no vetor de botoes
  vComponents = {}
  vButton = {}
  --cria o vetor de componentes responsaveis por conectar o cliente
  vConnect = {}
  vConnect["connect"]=Button:create(width/2+20, heigth/3, 62, 30, "conectar",connect)
  vButton["connect"] = vConnect["connect"]
  vConnect["text"] = Label:create(width/4, heigth/3, 30, 200, "love-client")
  --cria o vetor de componentes responsaveis pela informacao apos a conexao ser bem sucedida
  vInfo = {}
  vInfo["client"] = Label:create(width/2, 7*heigth/12, 30, 165, "Client: nil")
  vInfo["latitude"] = Label:create(width/2, 8*heigth/12, 30, 165, "Latitude: nil")
  vInfo["longitude"] = Label:create(width/2, 9*heigth/12, 30, 165, "Longitude: nil")
  vInfo["request"] = Button:create(width/4, 7*heigth/12, 120, 30, "pedir coordenada",request,{"ch/2", "ch/3"})
  vInfo["disconnect"] = Button:create(width/4, 9*heigth/12, 120, 30, "desconectar",disconnect)
  vButton["request"] = vInfo["request"]
  vButton["disconnect"] = vInfo["disconnect"]
  -- cria o vetor de componentes resposaveis de informar os erros
  vError = {}
  vError["info"] = Label:create(width/2 - 105, heigth/2 - 50, 30, 210, "nil")
  vError["close"] = Button:create(width/2 - 25, heigth/2 + 50, 50, 30, "close",errorClose)
  vButton["close"] = vError["close"]
  -- guarda referencia na tabela de todos os componentes
  vComponents.info = vInfo
  vComponents.connect = vConnect
  vComponents.error = vError
  -- ativa os componentes responsaveis pela conexao
  activate(vConnect)
  
end

function love.draw()
  -- draw interface components
  for _ , components in pairs(vComponents) do
    for _ , component in pairs(components) do
      component:draw()
    end
  end
end

function love.update(dt)
  -- check new message
  if(mqtt_client.connected) then
    mqtt_client:handler()
  end
end
function activate(table)
  -- ativa uma tabela de componentes
  for _ , t in pairs(table) do
    t.active = true
  end
end
function deactivate(table)
  -- desativa uma tabela de componentes
  for _ , t in pairs(table) do
    t.active = false
  end
end
