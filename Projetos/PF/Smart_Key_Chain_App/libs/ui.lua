-----------------------------------------------------------------------------------------
--
-- ui.lua
--
-- Autores: Leandro Morgado
--          Caio Feiertag
--
-- Data da ultima modificacao: 01/julho/2018
-- 
-- INF1805: Sistema Reativos. PUC-Rio
-- 
-----------------------------------------------------------------------------------------

local widget = require 'widget'
local slideView = require 'libs.slide_view'

Ui = {}
Ui.__index = Ui

function Ui:create()
	local ui = {}
	ui.screenW = display.contentWidth
	ui.screenH = display.contentHeight
	ui.viewableScreenW = display.viewableContentWidth
	ui.viewableScreenH = display.viewableContentHeight
   	setmetatable(ui, Ui)
   	return ui
end

---- Criar um text-label com quebra de linha (multiplas linhas)
function Ui:text(x, y, text)	
	-- extensao do texto setada
    local width = 0.9 * self.viewableScreenW
	local txt = display.newText(text, x, y, width, 0, native.systemFont, 12)
	txt:setFillColor(0, 0.5, 1)
	txt.anchorX = 0
	txt.anchorY = 0
	return txt
end

---- Criar uma barra de progresso default
function Ui:progressView(x, y, length)
	local options = {left = x, top = y, width = length, isAnimated = true}
	local progView = widget.newProgressView(options)
	return progView
end

---- Criar uma barra ("tab bar") com 3 botoes
function Ui:tabBar(handle_map, handle_street, handle_info)
	local f1 = {x = 4, y = 0, width = 24, height = 120}
	local f2 = {x = 32, y = 0, width = 40, height = 120}
	local f3 = {x = 72, y = 0, width = 40, height = 120}
	local f4 = {x = 112, y = 0, width = 40, height = 120}
	local f5 = {x = 152, y = 0, width = 72, height = 120}
	local f6 = {x = 224, y = 0, width = 72, height = 120}	
	local fs = {f1, f2, f3, f4, f5, f6}
	
    local options = {frames = fs, sheetContentWidth = 296, sheetContentHeight = 120}
	local image = graphics.newImageSheet("tab-bar.png", options)
 	
 	local button1 = { 
 		defaultFrame = 5,
        overFrame = 6,
        label = "MAP",
        id = "map",
        size = 16,
        labelYOffset = -8,
        onPress = handle_map
    }
    
    local button2 = {
        defaultFrame = 5,
        overFrame = 6,
        label = "VIEW",
        id = "view",
        size = 16,
        labelYOffset = -8,
        onPress = handle_street
    }
    
    local button3 = {
        defaultFrame = 5,
        overFrame = 6,
        label = "INFO",
        id = "info",
        selected = true,
        size = 16,
        labelYOffset = -8,
        onPress = handle_info
    }

	local buttons = {button1, button2, button3}
 
	local tabBar = widget.newTabBar({
        sheet = image,
        left = 0.0,
        top = 0.74 * self.screenH,
        width = self.screenW,
        height = 120,
        backgroundFrame = 1,
        tabSelectedLeftFrame = 2,
        tabSelectedMiddleFrame = 3,
        tabSelectedRightFrame = 4,
        tabSelectedFrameWidth = 40,
        tabSelectedFrameHeight = 120,
        buttons = buttons
    })

	return tabBar
end

---- Criar uma imagem setada no centro da tela
function Ui:image(width, height, filename)
	local image = display.newImageRect(filename, system.DocumentsDirectory, width, height)
    image.x = self.screenW / 2
    image.y = self.screenH / 2.65
    return image
end

---- Criar um carrossel de imagens
function Ui:slideView(images)
	local sldView = slideView.new(images, nil)
	return sldView
end