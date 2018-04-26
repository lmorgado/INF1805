led1 = 3
led2 = 6
sw1 = 1
sw2 = 2
mytimer = 1

-- pinos de leds são de saída
gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)

-- apaga os leds
gpio.write(led1, gpio.LOW);
gpio.write(led2, gpio.LOW);

-- pino de botão 1 por interrupção
-- pullup garante sinal qdo não há algum
gpio.mode(sw1, gpio.INT, gpio.PULLUP)

-- pino de botão 2 por interrupção
-- pullup garante sinal qdo não há algum
gpio.mode(sw2, gpio.INT, gpio.PULLUP)

-- estado do led
ledstate = false

-- intervalo para piscar o led
deltaT = 2000

-- funcao piscar o led 1
function blink()	
	ledstate = not ledstate
	if ledstate then
		gpio.write(led1, gpio.HIGH);
	else
		gpio.write(led1, gpio.LOW);
	end
end

-- parar o timer e acender o led 1
function stopTimer(pin)
	if gpio.read(pin) == 0 then
		tmr.stop(mytimer)
		gpio.write(led1, gpio.HIGH)
	end	
end

-- desacelear o piscar do led1
local function decelerate(level, timestamp)	
	stopTimer(sw2) -- verifica se o botao 2 esta pressionado
	deltaT = deltaT + 250
	tmr.interval(mytimer, deltaT)		
end

-- acelerar o piscar do led1
local function acelerate(level, timestamp)
	stopTimer(sw1) -- verifica se o botao 1 esta pressionado
	if deltaT > 250 then
		deltaT = deltaT - 250
		tmr.interval(mytimer, deltaT)
	end
end

-- configurar timer "mytimer" com execucoes multiplas
tmr.alarm(mytimer, deltaT, 1, function() blink() end)

-- registrar tratamento para os botoes 1 e 2
gpio.trig(sw1, "down", decelerate)
gpio.trig(sw2, "down", acelerate)
