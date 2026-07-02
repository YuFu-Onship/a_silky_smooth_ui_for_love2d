local ProcessBar = {}
ProcessBar.__index = ProcessBar
-- main --------------------------------------------
function ProcessBar:new(params)
    local self = setmetatable({}, ProcessBar)
    local KeyPressing = require "key.KeyPressing"
    self.leftKey = KeyPressing:new({ keys = { "left" }, timer_2 = 0.02 })
    self.rightKey = KeyPressing:new({ keys = { "right" }, timer_2 = 0.02 })
    self.params = params or {}

    self.text = self.params.text or "ProcessBar"
    self.font = self.params.font or love.graphics.getFont()
    self.textHeight = self.font:getHeight()

    self.borderWidth = self.params.width or 100
    self.borderHeight = self.params.height or 30
    self.borderX = self.params.x or 0
    self.borderY = self.params.y or 0
    self.oriangleBorderWidth = self.borderWidth
    self:__initBar()

    self.color1 = { 1, 1, 1, 1 }
    self.color2 = { 0.2, 0.2, 0.2, 1 }
    self.currentColor = self.color1

    self.states = { "idle", "hover", "actice" }
    self.currentState = "idle"

    self.value = 30
    self.innerValue = 30 * 0.01

    self.isDrawBorder = false
    return self
end

function ProcessBar:update(dt)
    self.borderWidth = self.oriangleBorderWidth
    self.leftKey:update(dt)
    self.rightKey:update(dt)
    if self.currentState ~= "idle" then
        if self.leftKey:api_getValue() then
            self.value = self.value - 1
        elseif self.rightKey:api_getValue() then
            self.value = self.value + 1
        end
    end
    self.value = math.max(0, math.min(self.value, 100))
    self.innerValue = self.value * 0.01
    self.currentColor = self.currentState == "idle" and self.color1 or self.color2
    self:__updateBar(dt)
end

function ProcessBar:draw()
    love.graphics.setColor(self.currentColor)
    self:__drawBar()
    if self.currentState ~= "idle" then
        love.graphics.print(self.innerValue * 100, self.borderX + self.borderWidth,
            self.borderY + self.borderHeight * 0.5 - self.textHeight * 0.5)
        self.borderWidth = self.borderWidth + self.font:getWidth(tostring(self.innerValue * 100)) + 10
    end
    self:__drawBorder()
    love.graphics.setColor(1, 1, 1, 1)
end

function ProcessBar:keypressed(key)
    self.leftKey:keypressed(key)
    self.rightKey:keypressed(key)
end

-- api ---------------------------------------
function ProcessBar:api_setPos(x, y)
    self.borderX, self.borderY = x, y
    self:__formatBar()
end

function ProcessBar:api_setSize(w, h)
    self.borderWidth, self.borderHeight = w, h
    self.oriangleBorderWidth = self.borderWidth
    self:__formatBar()
end

function ProcessBar:api_getPos()
    return self.borderX, self.borderY
end

function ProcessBar:api_getSize()
    return self.borderWidth, self.borderHeight
end

function ProcessBar:api_getCenterPos()
    return self.borderX + self.borderWidth * 0.5, self.borderY + self.borderHeight * 0.5
end

function ProcessBar:api_setState(state)
    if state == "active" then state = "hover" end
    self.currentState = state
end

function ProcessBar:api_showBorder(r, g, b, a)
    self.isDrawBorder = r and true or false
    if self.isDrawBorder then
        self.borderColor = { r, g, b, a }
    end
end

function ProcessBar:api_setValue(value)
    self.value = value
    self.innerValue = self.value * 0.01
end

function ProcessBar:api_getValue()
    return self.value
end

-- internal func -----------------------------------------
function ProcessBar:__drawBorder()
    if self.isDrawBorder then
        love.graphics.setColor(self.borderColor)
        love.graphics.rectangle("line", self.borderX, self.borderY, self.borderWidth, self.borderHeight)
    end
end

function ProcessBar:__initBar()
    self.barHeightDistance = 10
    self.barWidthDistance = 10
    self.innerDistance = 5
    self.isDrawInner = true
    if self.innerValue == 0 then
        self.isDrawInner = false
    end
    self:__formatBar()
end

function ProcessBar:__formatBar()
    self.barX = self.borderX + self.barWidthDistance
    self.barY = self.borderY + self.barHeightDistance
    self.barWidth = self.borderWidth - self.barWidthDistance * 2
    self.barHeight = self.textHeight
    self.barY = self.borderY + self.borderHeight * 0.5 - self.textHeight * 0.5
    self.barRadius = 10
    self.barRadius = math.min(self.barHeight * 0.5, self.barRadius)
    self.barDiatsnce = 10
end

function ProcessBar:__updateBar(dt)
    self.innerWidth = (self.barWidth - self.innerDistance * 2) * self.innerValue
    self.innerHeight = self.barHeight - self.innerDistance * 2
    self.innerRadius = self.barRadius - self.innerDistance
    self.isDrawInner = self.value > 0 and true or false
    local innerWidthPercent = (self.innerWidth * 0.5 + self.innerDistance) / self.barRadius
    if innerWidthPercent <= 1 then
        self.innerHeight = (self.barHeight - self.innerDistance * 2) * innerWidthPercent
        self.innerRadius = math.min(self.innerWidth, self.innerHeight) * 0.5
    end
    self.innerHeight = math.max(self.barHeight - self.barRadius * 2 - self.innerDistance * 2, self.innerHeight)

    self.innerX = self.barX + self.innerDistance
    self.innerY = self.barY + self.barHeight * 0.5 - self.innerHeight * 0.5
end

function ProcessBar:__drawBar()
    love.graphics.rectangle("line", self.barX, self.barY, self.barWidth, self.barHeight, self.barRadius)
    if self.isDrawInner then
        love.graphics.rectangle("fill", self.innerX, self.innerY, self.innerWidth, self.innerHeight, self.innerRadius)
        love.graphics.rectangle("line", self.innerX, self.innerY, self.innerWidth, self.innerHeight, self.innerRadius)
    end
end

return ProcessBar
