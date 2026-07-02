local Button = {}
Button.__index = Button
-- main
function Button:new(params)
    local self = setmetatable({}, Button)
    self.params = params or {}
    self.distance = self.params.distance or 10

    -- font
    local _ = self.params.font_size and love.graphics.setNewFont(self.params.font_size)
    self.font = self.params.font or love.graphics.getFont()

    -- text
    self.text = self.params.text or "button"
    self.textWidth = self.font:getWidth(self.text)
    self.textHeight = self.font:getHeight()

    self.borderX = self.params.x or 0
    self.borderY = self.params.y or 0
    self.borderWidth = self.params.w or self.textWidth + self.distance * 2
    self.borderHeight = self.params.h or self.textHeight

    self.textX = self.borderX + self.borderWidth * 0.5 - self.textWidth * 0.5
    self.textY = self.borderY + self.borderHeight * 0.5 - self.textHeight * 0.5

    -- mode
    self.state = { "idle", "hover", "active" }
    self.currentState = "idle"
    -- color
    self.color1 = { 1, 1, 1, 1 }
    self.color2 = { .2, .2, .2, 1 }
    self.currentColor = self.color1


    self.isDrawBorder = false
    return self
end

function Button:update(dt)
    self.textX = self.borderX + self.borderWidth * 0.5 - self.textWidth * 0.5
    self.textY = self.borderY + self.borderHeight * 0.5 - self.textHeight * 0.5
    self.currentColor = self.currentState == "idle" and self.color1 or self.color2
end

function Button:draw()
    love.graphics.setColor(self.currentColor)
    love.graphics.print(self.text, self.textX, self.textY)
    self:__drawBorder()
    love.graphics.setColor(1, 1, 1, 1)
end

function Button:keypressed(key)

end

-- api ---------------------------------------------------
function Button:api_setPos(x, y)
    self.borderX = x
    self.borderY = y
end

function Button:api_setSize(w, h)
    self.borderWidth = w
    self.borderHeight = h
end

function Button:api_getPos()
    return self.borderX, self.borderY
end

function Button:api_getSize()
    return self.borderWidth, self.borderHeight
end

function Button:api_getCenterPos()
    return self.borderX + self.borderWidth * 0.5, self.borderY + self.borderHeight * 0.5
end

function Button:api_setState(state)
    if state == "active" then state = "hover" end
    self.currentState = state
end

function Button:api_showBorder(r, g, b, a)
    self.isDrawBorder = r and true or false
    if self.isDrawBorder then
        self.borderColor = { r, g, b, a }
    end
end

function Button:api_getState()
    return self.currentState
end

-- internal func ---------------------------------------
function Button:__drawBorder()
    if self.isDrawBorder then
        love.graphics.setColor(self.borderColor)
        love.graphics.rectangle("line", self.borderX, self.borderY, self.borderWidth, self.borderHeight)
    end
end

return Button
