local VolumeBar = {}
VolumeBar.__index = VolumeBar
function VolumeBar:new(params)
    local self = setmetatable({}, VolumeBar)
    self.params = params or {}
    local GroupBox = require("ui.GroupBox")
    local ProcessBar = require("ui.ProcessBar")
    local Text = require("ui.Text")

    self.text = self.params.text or "VolumeBar"
    self.textElement = Text:new({ text = self.text })
    self.processBarElement = ProcessBar:new({})

    self.box = GroupBox:new(self.textElement, self.processBarElement, { ratio = { 1, 2 } })

    self.font = self.params.font or love.graphics.getFont()
    self.textWidth = self.font:getWidth(self.text)
    self.textHeight = self.font:getHeight()

    self.borderX = self.params.x or 0
    self.borderY = self.params.y or 0
    self.borderWidth = self.params.width or 100
    self.borderHeight = self.params.height or 30

    self.distance = self.params.distance or 10
    self.textX = self.borderX + self.distance
    self.textY = self.borderY + self.borderHeight * 0.5 - self.textHeight * 0.5

    self.processBarElement:api_setPos(self.borderX, self.borderY)
    self.processBarElement:api_setSize(self.borderWidth, self.borderHeight)

    return self
end

function VolumeBar:update(dt)
    self:__updateText()
    self.box:update(dt)
end

function VolumeBar:draw()
    self.box:draw()
end

function VolumeBar:keypressed(key)
    self.box:keypressed(key)
end

-- api -----------------------------------------------------------
function VolumeBar:api_setPos(x, y)
    self.borderX = x
    self.borderY = y
    self.box:api_setPos(x, y)
end

function VolumeBar:api_setSize(w, h)
    self.borderWidth = w
    self.borderHeight = h
    self.box:api_setSize(w, h)
end

function VolumeBar:api_getPos()
    return self.box:api_getPos()
end

function VolumeBar:api_getSize()
    return self.box:api_getSize()
end

function VolumeBar:api_getCenterPos()
    return self.box:api_getCenterPos()
end

function VolumeBar:api_setState(state)
    self.currentState = state
    self.box:api_setState(state)
end

function VolumeBar:api_showBorder(r, g, b, a)
    self.box:api_showBorder(r, g, b, a)
end

-- internal func ----------------------------------------------------
function VolumeBar:__setElementPos(x, y)
    self.processBarElement:api_setPos(self.borderX, self.borderY)
end

function VolumeBar:__setElementSize(w, h)
    self.processBarElement:api_setSize(self.borderWidth, self.borderHeight)
end

function VolumeBar:__updateText()
    self.textX = self.borderX + self.distance
    self.textY = self.borderY + self.borderHeight * 0.5 - self.textHeight * 0.5
end

return VolumeBar
