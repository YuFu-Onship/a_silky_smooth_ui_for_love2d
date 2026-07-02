local RecordKey = {}
RecordKey.__index = RecordKey
function RecordKey:new(params)
    local self = setmetatable({}, RecordKey)
    self.params = params or {}

    self.font = self.params.font or love.graphics.getFont()
    self.textHeight = self.font:getHeight()

    self.borderX = self.params.x or 0
    self.borderY = self.params.y or 0
    self.borderWidth = self.params.width or 100
    self.borderHeight = self.params.height or 30

    self.color1 = { 1, 1, 1, 1 }
    self.color2 = { 0.2, 0.2, 0.2, 1 }
    self.currentColor = self.color1

    self.states = { "idle", "hover", "active" }
    self.currentState = "idle"
    self.isRecord = false

    self.isDrawBorder = false
    self:KeyTable_init()

    self.keyTable = {}

    self.aniTest = self.ani_trigonometricCurve(0.2)
    self.aniValue = 0

    return self
end

function RecordKey:update(dt)
    if self.currentState == "idle" then
        self.currentColor = self.color1
    else
        self.currentColor = self.color2
    end
    if self.currentState == "active" then
    end

    self:KeyTable_update(dt)
    self.aniValue = self.aniTest.update(dt)
end

function RecordKey:draw()
    self:__drawBorder()
    love.graphics.setColor(self.currentColor)
    if self.currentState == "active" then
    end
    self:KeyTable_draw()
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.circle("line", 0, self.aniValue * 100 + 100, 10)
end

function RecordKey:keypressed(key)
    if self.currentState == "active" then
        if key == "tab" then
            self.keyTable = {}
            self:keyTable__formatKey()
        elseif key == "return" then
            self.currentState = "hover"
        else
            self:KeyTable_keypressed(key)
            if self.container then self.container:api_releaseFocus() end
        end
    end
end

-- api --------------------------------------
function RecordKey:api_setPos(x, y)
    self.borderX, self.borderY = x, y
    self:KeyTable_api_setPos(x, y)
end

function RecordKey:api_setSize(w, h)
    self.borderWidth, self.borderHeight = w, h
end

function RecordKey:api_getPos()
    return self.borderX, self.borderY
end

function RecordKey:api_getSize()
    return self.borderWidth, self.borderHeight
end

function RecordKey:api_getCenterPos()
    return self.borderX + self.borderWidth * 0.5, self.borderY + self.borderHeight * 0.5
end

function RecordKey:api_setState(state)
    self.currentState = state
end

function RecordKey:api_getState()
    return self.currentState
end

function RecordKey:api_showBorder(r, g, b, a)
    self.isDrawBorder = r and true or false
    if self.isDrawBorder then
        self.borderColor = { r, g, b, a }
    end
end

function RecordKey:api_setContainer(container)
    self.container = container
end

-- internal func ----------------------------
function RecordKey:__drawBorder()
    if self.isDrawBorder then
        love.graphics.setColor(self.borderColor)
        love.graphics.rectangle("line", self.borderX, self.borderY, self.borderWidth, self.borderHeight)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function RecordKey:__rotate(x, y, cx, cy, angle)
    local vx, vy = x - cx, y - cy
    local nx = cx + (vx * math.cos(angle) - vy * math.sin(angle))
    local ny = cy + (vx * math.sin(angle) + vy * math.cos(angle))
    return nx, ny
end

function RecordKey:__easeOutBack(t)
    local s = 1.70158
    t = t - 1
    return (t * t * ((s + 1) * t + s) + 1)
end

-- keyTable
function RecordKey:KeyTable_init()
    self.keyTable = {}
    self.waitBox = self.WaitBox:new(self)
    self.keyTableWidth = 0
    self.distance = 5
    self:keyTable__formatKey()
    local waitBoxWidth, waitBoxHeight = self.waitBox:api_getSize()
    local waitBoxX = self.borderX + self.borderWidth - self.distance - self.distance - waitBoxWidth
    local waitBoxY = self.borderY + self.borderHeight * 0.5 - waitBoxHeight * 0.5
    self.waitBox:api_setPos(waitBoxX, waitBoxY)
end

function RecordKey:KeyTable_update(dt)
    self.waitBox:update(dt)
    for i, e in ipairs(self.keyTable) do
        if self.currentState == "active" then
            e:update(dt)
        end
    end
    if #self.keyTable >= 3 then
    end
end

function RecordKey:KeyTable_draw()
    if self.currentState == "active" then
        self.waitBox:draw()
    end
    for i, e in ipairs(self.keyTable) do
        e:draw()
    end
end

function RecordKey:KeyTable_keypressed(key)
    if not key then return end

    local count = #self.keyTable
    local lastBox = self.keyTable[count]

    if lastBox and lastBox.key == key then
    else
        local textBox = self.TextBox:new(self, { key = key })
        table.insert(self.keyTable, textBox)
    end

    if #self.keyTable > 2 then
        table.remove(self.keyTable, 1)
    end

    self:keyTable__formatKey()
end

function RecordKey:KeyTable_api_setPos(x, y)
    self:keyTable__formatKey()
end

function RecordKey:KeyTable_api_getPos()
end

function RecordKey:KeyTable_api_setSize(w, h)

end

function RecordKey:KeyTable_api_getSize()
    local width = 0
    local height = self.textHeight
    for i, e in ipairs(self.keyTable) do
        width = width + e:api_getSize()
    end
    return width, height
end

function RecordKey:keyTable__formatKey()
    local width = self.distance
    for i, e in ipairs(self.keyTable) do
        local boxWidth, boxHeight = e:api_getSize()
        width = width + boxWidth + self.distance
        local x = self.borderX + self.borderWidth - width
        local y = self.borderY + self.borderHeight * 0.5 - boxHeight * 0.5
        e:api_setPos(x, y)
    end
    local waitBoxWidth, waitBoxHeight = self.waitBox:api_getSize()
    local waitBoxX = self.borderX + self.borderWidth - width - self.distance - waitBoxWidth
    local waitBoxY = self.borderY + self.borderHeight * 0.5 - waitBoxHeight * 0.5
    self.waitBox:api_setPos(waitBoxX, waitBoxY)
end

-- internal class ----------------------------
-- WaitBox -----------------------------------
RecordKey.WaitBox = {}
RecordKey.WaitBox.__index = RecordKey.WaitBox
function RecordKey.WaitBox:new(parent)
    local self = setmetatable({}, RecordKey.WaitBox)
    self.parent = parent
    self.boxX = 0
    self.boxY = 0

    self.textHeight = self.parent.textHeight
    self.boxWidth = self.parent.textHeight or 45
    self.boxHeight = self.boxWidth
    self.boxRadius = 10

    self:__waitAnimationLoad()
    return self
end

function RecordKey.WaitBox:update(dt)
    self:__waitAnimationUpdate(dt)
end

function RecordKey.WaitBox:draw()
    self:__waitAnimationDraw()
    love.graphics.rectangle("line", self.boxX, self.boxY, self.boxWidth, self.boxHeight, self.boxRadius)
end

function RecordKey.WaitBox:__waitAnimationLoad()
    self:__waitAnimationFormat()
    self.timer = 0
    self.duration = 1.5
    self.startAngle = 0
    self.targetAngle = math.pi * 2
    self.currentAngle = 0
    self.pointRadius = self.textHeight * 0.1
    self.pointBaseDistance = self.textHeight * 0.15
    self.pointMaxDistance = self.textHeight * 0.3

    self.newPoint2X = self.point1X
    self.newPoint2Y = self.point1Y
    self.newPoint3X = self.point1X
    self.newPoint3Y = self.point1Y
end

function RecordKey.WaitBox:__waitAnimationFormat()
    self.point1X = self.boxX + self.boxWidth * 0.5
    self.point1Y = self.boxY + self.boxHeight * 0.5
    self.point2X = self.point1X - 5
    self.point2Y = self.point1Y
    self.point3X = self.point1X + 5
    self.point3Y = self.point1Y
end

function RecordKey.WaitBox:__waitAnimationUpdate(dt)
    if self.timer < self.duration then
        self.timer = self.timer + dt

        local progress = math.min(self.timer / self.duration, 1)
        self.timer = progress >= 1 and 0 or self.timer

        local easedProgress = self.parent:__easeOutBack(progress)
        self.currentAngle = self.startAngle + (self.targetAngle - self.startAngle) * easedProgress
    end

    local angleSpeed = math.abs((self.currentAngle - (self.lastAngle or 0)) / dt)
    local distance = self.pointBaseDistance +
        (self.pointMaxDistance - self.pointBaseDistance) * math.min(angleSpeed * 0.05, 1)
    self.lastAngle = self.currentAngle

    self.point2X = self.point1X - distance
    self.point2Y = self.point1Y
    self.point3X = self.point1X + distance
    self.point3Y = self.point1Y

    self.newPoint2X, self.newPoint2Y = self.parent:__rotate(self.point2X, self.point2Y, self.point1X, self.point1Y,
        self.currentAngle)
    self.newPoint3X, self.newPoint3Y = self.parent:__rotate(self.point3X, self.point3Y, self.point1X, self.point1Y,
        self.currentAngle)
end

function RecordKey.WaitBox:__waitAnimationDraw()
    love.graphics.circle("fill", self.newPoint2X, self.newPoint2Y, self.pointRadius)
    love.graphics.circle("line", self.newPoint2X, self.newPoint2Y, self.pointRadius)
    love.graphics.circle("fill", self.newPoint3X, self.newPoint3Y, self.pointRadius)
    love.graphics.circle("line", self.newPoint3X, self.newPoint3Y, self.pointRadius)
end

function RecordKey.WaitBox:api_setPos(x, y)
    self.boxX = x
    self.boxY = y
    self:__waitAnimationFormat()
end

function RecordKey.WaitBox:api_getSize()
    return self.boxWidth, self.boxHeight
end

-- TextBox -----------------------------------------
RecordKey.TextBox = {}
RecordKey.TextBox.__index = RecordKey.TextBox
function RecordKey.TextBox:new(parent, params)
    local self = setmetatable({}, RecordKey.TextBox)
    self.parent = parent
    self.params = params or {}
    self.boxX = 0
    self.boxY = 0
    self.key = self.params.key or "space"
    self.text = string.upper(self.key)
    self.textHeight = self.parent.textHeight or 45
    self.textScale = 0.8

    self.boxWidth = self.textHeight or 45
    self.boxHeight = self.boxWidth
    self.boxWidth = math.max(self.textHeight, self.boxWidth)
    self.boxRadius = 10

    self.modes = { "start", "wait", "end" }
    self.currentMode = "start"

    self:__formatBox()

    return self
end

function RecordKey.TextBox:update(dt)
end

function RecordKey.TextBox:draw()
    love.graphics.rectangle("line", self.boxX, self.boxY, self.boxWidth, self.boxHeight, self.boxRadius)
    love.graphics.print(self.text, self.textX, self.textY, 0, self.textScale)
end

function RecordKey.TextBox:api_setPos(x, y)
    self.boxX = x
    self.boxY = y
    self:__formatBox()
end

function RecordKey.TextBox:api_getPos()
    return self.boxX, self.boxY
end

function RecordKey.TextBox:api_getSize()
    return self.boxWidth, self.boxHeight
end

function RecordKey.TextBox:api_setKey(key)
    self.key = key
    self.text = string.upper(self.key)
    self:__formatBox()
end

function RecordKey.TextBox:__formatBox()
    self.boxHeight = self.parent.textHeight or 45

    self.textWidth = self.parent.font:getWidth(self.text)
    self.textHeight = self.parent.textHeight or 45
    self.textDistance = self.parent.textHeight * (1 - self.textScale) * 0.5

    self.boxWidth = self.textWidth + self.textDistance * 2

    self.textY = self.boxY + self.boxHeight * 0.5 - self.textHeight * self.textScale * 0.5
    self.textX = self.boxX + self.boxWidth * 0.5 - self.textWidth * self.textScale * 0.5
end

function RecordKey.TextBox:__initAnimation()
end

function RecordKey.TextBox:__startLoad()
    self.boxWidth = 0
    self.boxHeight = self.textHeight
    self.boxTargetWidth = self.parent.font:getWidth(self.text)
    self.deltaBoxWidth = 0
end

function RecordKey.TextBox:__startUpdate(dt)
    local distance = self.boxTargetWidth - self.boxWidth
    local delta = self.boxWidth + distance * 0.3
    local lastWidth = self.boxWidth
    self.boxWidth = self.boxWidth + delta
end

function RecordKey.TextBox:__startDraw()

end

function RecordKey.TextBox:__waitLoad()

end

function RecordKey.TextBox:__waitUpdate(dt)

end

function RecordKey.TextBox:__waitDraw()

end

function RecordKey.TextBox:__endLoad()

end

function RecordKey.TextBox:__endUpdate(dt)

end

function RecordKey.TextBox:__endDraw()

end

-- animation ------------------------------------
function RecordKey.ani_trigonometricCurve(limitTime)
    local value = 0
    local timer = 0
    local coefficient = limitTime / math.pi
    local q = math.pi * 0.5
    local status = { isStart = true, isFinish = false }
    return {
        status = status,
        update = function(dt)
            if status.isFinish then
                return 1
            else
                timer = timer + dt
                if timer >= limitTime then status.isFinish = true end
                if status.isStart then
                    value = (math.sin(timer / coefficient - q) + 1) * 0.5
                    value = math.min(math.max(0, value), 1)
                    return value
                else
                    timer = 0
                    value = 0
                end
            end
        end
    }
end

function RecordKey.ani_BezierCurve(limitTime)
    local x1 = 0
    local y1 = 0.3
    local x2 = 1
    local y2 = 0
    local timer = 0
    local status = { isStart = true }

    return
    {
        status = status,
        update = function(dt)
            timer = timer + dt
        end
    }
end

return RecordKey
