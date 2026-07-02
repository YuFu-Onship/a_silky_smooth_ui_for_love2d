local Choice = {}
Choice.__index = Choice
function Choice:new(params)
    local self = setmetatable({}, Choice)
    self.params = params or {}

    self.choices = self.params.choices or { "none" }
    self.index = 1
    self.lastIndex = self.index
    self.choicesNum = #self.choices

    self.font = self.params.font or love.graphics.getFont()
    self.borderX = self.params.x or 100
    self.borderY = self.params.y or 100
    self.borderWidth = self.params.width or 100
    self.borderHeight = self.params.height or 100

    self:__initText()

    self.states = { "idle", "hover", "active" }
    self.currentState = "idle"

    self.color1 = { 1, 1, 1, 1 }
    self.color2 = { 0.2, 0.2, 0.2, 1 }
    self.currentColor = self.color1

    local KeyPressing = require("key.KeyPressing")
    self.rightKey = KeyPressing:new({ keys = { "right" } })
    self.leftKey = KeyPressing:new({ keys = { "left" } })


    self:__initChoiceArrow()

    self.test = self:rebound()
    self.testY = 0
    self.textAnimation = self:ani_printText()

    self.is_drawBorder = false
    return self
end

function Choice:update(dt)
    -- 操作逻辑
    self.leftKey:update(dt)
    self.rightKey:update(dt)

    if self.currentState ~= "idle" then
        if self.leftKey:api_getValue() then
            self.index = self.index - 1
        elseif self.rightKey:api_getValue() then
            self.index = self.index + 1
        end
    end
    self.index = math.max(1, math.min(self.index, #self.choices))

    if self.leftKey:api_getValue() or self.rightKey:api_getValue() then
        if self.index ~= self.lastIndex then
            self.isTextPrint = true
            self.lastIndex = self.index
        end
        self.isMoveLeftArrow = true
    end

    -- 颜色逻辑
    self.currentColor = self.currentState == "idle" and self.color1 or self.color2
    -- 文本逻辑
    self:__formatText()
    self.textAnimation(dt)
    -- 左右侧箭头逻辑
    self:__updateChoiceArrow(dt)
end

function Choice:draw()
    love.graphics.setColor(self.currentColor)
    love.graphics.print(self.text, self.textX, self.textY)
    if self.currentState ~= "idle" then
        if self.isShowLeftArrow then
            self:__drawChoiceArrowFill(self.leftArrowX, self.leftArrowY)
        end
        if self.isShowRightArrow then
            self:__drawChoiceArrowFill(self.rightArrowX, self.rightArrowY)
        end

        self:__drawChoiceArrowLine(self.leftArrowX, self.leftArrowY)
        self:__drawChoiceArrowLine(self.rightArrowX, self.rightArrowY)
    end
    if self.is_drawBorder then
        self:__drawBorder()
    end
end

function Choice:keypressed(key)
    self.leftKey:keypressed(key)
    self.rightKey:keypressed(key)
end

-- api ------------------------------------------
function Choice:api_setState(state)
    self.currentState = state
end

function Choice:api_setPos(x, y)
    self.borderX = x
    self.borderY = y
    self:__initChoiceArrow()
end

function Choice:api_setSize(w, h)
    self.borderWidth = w
    self.borderHeight = h
    self:__initChoiceArrow()
end

function Choice:api_getPos()
    return self.borderX, self.borderY
end

function Choice:api_getSize()
    return self.borderWidth, self.borderHeight
end

function Choice:api_getCenterPos()
    return self.borderX + self.borderWidth * 0.5, self.borderY + self.borderHeight * 0.5
end

function Choice:api_showBorder(r, g, b, a)
    local value = r and true or false
    self.is_drawBorder = value
    if self.is_drawBorder then
        self.borderColor = { r, g, b, a }
    end
end

function Choice:api_setIndex(index)
    self.index = index
    self.lastIndex = self.index
end

function Choice:api_getIndex()
    return self.index
end

-- internal func --------------------------------
function Choice:__drawBorder()
    if self.is_drawBorder then
        love.graphics.setColor(self.borderColor)
        love.graphics.rectangle("line", self.borderX, self.borderY, self.borderWidth, self.borderHeight)
    end
end

function Choice:__initChoiceArrow()
    self.signCoefficient = 0.4
    self.isShowArrow = true
    self.isShowLeftArrow = true
    self.isShowRightArrow = true

    self:__formatChoiceArrow()

    self.leftArrowAnimation = self:rebound()
    self.rightArrowAnimation = self:rebound()
end

function Choice:__formatChoiceArrow()
    self.leftArrowX = self.borderX + 10
    self.leftArrowY = self.borderY + (self.borderHeight - self.textHeight * self.signCoefficient) * 0.5
    self.rightArrowX = self.borderX + self.borderWidth - self.textHeight * self.signCoefficient - 10
    self.rightArrowY = self.borderY + self.borderHeight * 0.5 - self.textHeight * self.signCoefficient * 0.5
end

function Choice:__updateChoiceArrow(dt)
    if self.currentState == "idle" then
        self.isShowLeftArrow, self.isShowRightArrow = false, false
    else
        self.isShowLeftArrow, self.isShowRightArrow = true, true
        if self.index == 1 then self.isShowLeftArrow = false end
        if self.index == self.choicesNum then self.isShowRightArrow = false end
    end
    if self.leftKey:api_getValue() then
        self.leftArrowAnimation.state.isStart = true
    end
    if self.rightKey:api_getValue() then
        self.rightArrowAnimation.state.isStart = true
    end

    local leftArrowDelta = self.leftArrowAnimation.update(dt)
    local rightArrowDelta = self.rightArrowAnimation.update(dt)

    self.leftArrowX = self.borderX + 20 - leftArrowDelta
    self.rightArrowX = self.borderX + self.borderWidth - self.textHeight * self.signCoefficient - 20 + rightArrowDelta
end

function Choice:__drawChoiceArrowLine(x, y)
    love.graphics.rectangle("line",
        x, y,
        self.textHeight * self.signCoefficient, self.textHeight * self.signCoefficient, 3)
end

function Choice:__drawChoiceArrowFill(x, y)
    love.graphics.rectangle("fill",
        x, y,
        self.textHeight * self.signCoefficient, self.textHeight * self.signCoefficient, 3)
end

function Choice:__initText()
    self.text = self.choices[self.index]
    self.isTextPrint = false
    self:__formatText()
end

function Choice:__formatText()
    self.textWidth = self.font:getWidth(self.choices[self.index])
    self.textHeight = self.font:getHeight()
    self.textX = self.borderX + self.borderWidth * 0.5 - self.textWidth * 0.5
    self.textY = self.borderY + self.borderHeight * 0.5 - self.textHeight * 0.5
end

function Choice:__updateText(dt)
    self.text = self.choices[self.index]:sub(1, 2)
end

-- animation -----------------------------------------
function Choice:rebound(limit_time, limit_distance)
    limit_time = limit_time or 0.2
    limit_distance = limit_distance or 10
    local timer = 0
    local acceleration = 2 * limit_distance / (limit_time * limit_time * 0.25)
    local velocity = acceleration * limit_time * 0.5
    local value = 0
    local state = { isStart = false }
    return {
        state = state,
        update = function(dt)
            if state.isStart then
                timer = timer + dt
                value = velocity * timer - 0.5 * acceleration * timer * timer
                if value < 0 then
                    state.isStart = false
                end
                value = math.min(math.max(0, value), limit_distance)
            else
                timer = 0
                value = 0
            end
            return value
        end
    }
end

Choice.ReboundAnimation = {}
Choice.ReboundAnimation.__index = Choice.ReboundAnimation
function Choice.ReboundAnimation:new()
    local self = setmetatable({}, Choice.ReboundAnimation)
    self.isStart = false
    self.timer = 0
    self.value = 0
    self.velocity = 100
    self.acceleration = 1000
    self.limit = 10
    return self
end

function Choice.ReboundAnimation:update(dt)
    if self.isStart then
        self.timer = self.timer + dt
        self.value = self.velocity * timer - self.acceleration * self.timer * self.timer * 0.5
        if self.value < 0 then
            self.isStart = false
        end
        self.value = math.min(math.max(0, self.value), self.limit)
    else
        self.timer = 0
        self.value = 0
    end
end

function Choice:ani_printText()
    local timer = 0
    local textIndex = 1
    local timer_limit = 0.1
    return function(dt)
        local textLength = #self.choices[self.index]
        if self.isTextPrint then
            timer = timer + dt
            if timer >= timer_limit / textLength then
                timer = 0
                textIndex = textIndex + 1
            end
            textIndex = math.min(math.max(1, textIndex), textLength)
            self.text = self.choices[self.index]:sub(1, textIndex)
        end
        if textIndex == #self.choices[self.index] then
            self.isTextPrint = false
            timer = 0
            textIndex = 1
        end
    end
end

return Choice
