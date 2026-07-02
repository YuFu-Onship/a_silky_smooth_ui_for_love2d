local Container = {}
Container.__index = Container
function Container:new(...)
    local self = setmetatable({}, Container)

    self.elements = { ... }
    self.params = type(self.elements[#self.elements]) == "table" and self.elements[#self.elements] or {}
    table.remove(self.elements, #self.elements)

    for _, e in ipairs(self.elements) do
        if e.api_setContainer then
            e:api_setContainer(self)
        end
    end

    self.col = self.params.col or 1
    self.row = self.params.row or math.ceil((#self.elements / self.col))

    self.borderX = self.params.x or 0
    self.borderY = self.params.y or 0
    self.borderWidth = self.params.width or 100
    self.borderHeight = self.params.height or 100

    self.autoFormat = self.params.autoFormat or false

    self.square = self.params.square or nil

    self.index = 1
    self.elements[self.index]:api_setState("hover")

    self:__apply_size()
    self:__MoveKeyLoad()
    self.isDrawBorder = false

    self.isMove = true
    self.isEnterDown = false
    return self
end

function Container:update(dt)
    if self.isMove then self:__MoveKeyUpdate(dt) end
    for i, e in ipairs(self.elements) do
        local _ = e.update and e:update(dt)
        if i == self.index then
            e:api_setState(self.isMove and "hover" or "active")
        else
            e:api_setState("idle")
        end
    end
end

function Container:draw()
    for _, e in ipairs(self.elements) do
        local _ = e.draw and e:draw()
    end
end

function Container:keypressed(key)
    if key == "return" then
        self.elements[self.index]:api_setState("active")
        if self.elements[self.index]:api_getState() == "active" then
            self.isMove = not self.isMove
        else
            self.isMove = true
        end
    end
    if self.isMove then self:__MoveKeyPressed(key) end

    if self.elements[self.index].keypressed then
        self.elements[self.index]:keypressed(key)
    end
end

function Container:keyreleased(key)

end

-- internal func -------------------------------------------------
function Container:__apply_size()
    local width = self.borderWidth / self.col
    local height = self.borderHeight / self.row
    for index, e in ipairs(self.elements) do
        local zeroBased = index - 1
        local colIndex = zeroBased % self.col
        local rowIndex = math.floor(zeroBased / self.col)
        local xPos = self.borderX + colIndex * width
        local yPos = self.borderY + rowIndex * height
        local oriangleWidth, oriangleHeight = e:api_getSize()

        local targetWidth = self.autoFormat and width or oriangleWidth
        e:api_setSize(targetWidth, height)
        e:api_setPos(xPos, yPos)
    end
end

function Container:__MoveKeyLoad()
    local KeyPressing = require("key.KeyPressing")

    self.upMoveKey = KeyPressing:new({ keys = { "up" } })
    self.downMoveKey = KeyPressing:new({ keys = { "down" } })
    self.leftMoveKey = KeyPressing:new({ keys = { "left" } })
    self.rightMoveKey = KeyPressing:new({ keys = { "right" } })
end

function Container:__MoveKeyUpdate(dt)
    if not self.isMove then return end

    self.upMoveKey:update(dt)
    self.downMoveKey:update(dt)
    self.leftMoveKey:update(dt)
    self.rightMoveKey:update(dt)

    self.index =
        (self.upMoveKey:api_getValue() and self.index - self.col) or
        (self.downMoveKey:api_getValue() and self.index + self.col) or
        self.index

    if self.col > 1 then
        self.index =
            (self.leftMoveKey:api_getValue() and self.index - 1) or
            (self.rightMoveKey:api_getValue() and self.index + 1) or
            self.index
    end
    self.index = math.min(math.max(1, self.index), #self.elements)

    if self.square then
        local squareX, squareY = self.elements[self.index]:api_getPos()
        local squareWidth, squareHeight = self.elements[self.index]:api_getSize()
        self.square:api_setValue(squareX, squareY, squareWidth, squareHeight)
    end
end

function Container:__MoveKeyPressed(key)
    self.upMoveKey:keypressed(key)
    self.downMoveKey:keypressed(key)
    self.leftMoveKey:keypressed(key)
    self.rightMoveKey:keypressed(key)
end

-- api --------------------------------------------------------------------
function Container:api_showBorder(r, g, b, a)
    if r == false then
        self.isDrawBorder = false
        for i, n in ipairs(self.elements) do
            n:api_showBorder(1, 1, 1, 0)
        end
    else
        local value = r and true or false
        r = r or 1
        g = g or 0
        b = b or 0
        a = a or 1
        self.isDrawBorder = value
        for i, n in ipairs(self.elements) do
            n:api_showBorder(r, g, b, a)
        end
    end
end

function Container:api_setCurrentElementState(state)
    self.elements[self.index]:api_setState(state)
end

function Container:api_releaseFocus()
    self.elements[self.index]:api_setState("hover")
    self.isMove = true
end

return Container
