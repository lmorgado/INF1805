wificonf = {
  ssid = "iPhone de Leandro",
  pwd = "teste123",
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
    dofile("geolocation.lua")
  end
end
 
function configMyWiFi()
  wifi.setmode(wifi.STATION)
	wifi.sta.config(wificonf)
  tmr.alarm(0, 1000, 1, checker)
end    
 
configMyWiFi()