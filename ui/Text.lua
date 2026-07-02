local Text = {}
Text.__index = Text
-- main func-------------------------------
function Text:new(params)
    local self = setmetatable({}, Text)
    self.params = params or {}

    self.text = self.params.text or "text"
    self.font = self.params.font or love.graphics.getFont()

    self.textWidth = self.font:getWidth(self.text)
    self.textHeight = self.font:getHeight()
    self.borderX = self.params.x or 0
    self.borderY = self.params.y or 0

    self.textX = self.borderX
    self.textY = self.borderY
    self.distance = self.params.distance or 10

    self.borderWidth = self.params.width or self.textWidth
    self.borderHeight = self.params.height or self.textHeight

    self.states = { "idle", "hover", "active" }
    self.currentState = "idle"

    self.color1 = { 1, 1, 1, 1 }
    self.color2 = { 0, 0, 0, 1 }
    self.currentColor = self.color1
    self.isDrawBorder = false
    return self
end

function Text:update(dt)
    self.currentColor = self.currentState == "idle" and self.color1 or self.color2
    self.textY = self.borderY + (self.borderHeight - self.textHeight) * 0.5
end

function Text:draw()
    love.graphics.setColor(self.currentColor)
    love.graphics.print(self.text, self.textX, self.textY)
    self:__drawBorder()
    love.graphics.setColor(self.color1)
end

-- api -------------------------------
function Text:api_setPos(x, y)
    self.borderX = x
    self.borderY = y
    self.textX = self.borderX + self.distance
    self.textY = self.borderY + (self.borderHeight - self.textHeight) * 0.5
end

function Text:api_setSize(w, h)
    self.borderWidth = w
    self.borderHeight = h
    self.textX = self.borderX + self.distance
    self.textY = self.borderY + (self.borderHeight - self.textHeight) * 0.5
end

function Text:api_getPos()
    return self.borderX, self.borderY
end

function Text:api_getSize()
    return self.borderWidth, self.borderHeight
end

function Text:api_getCenterPos()
    return self.borderX + self.borderWidth * 0.5, self.borderY + self.borderHeight * 0.5
end

function Text:api_setState(state)
    self.currentState = state
end

function Text:api_showBorder(r, g, b, a)
    self.isDrawBorder = r and true or false
    if self.isDrawBorder then
        self.borderColor = { r, g, b, a }
    end
end

-- internal func ---------------------------------
function Text:__drawBorder()
    if self.isDrawBorder then
        love.graphics.setColor(self.borderColor)
        love.graphics.rectangle("line", self.borderX, self.borderY, self.borderWidth, self.borderHeight)
    end
end

return Text
