local GroupBox = {}
GroupBox.__index = GroupBox
function GroupBox:new(...)
    local self = setmetatable({}, GroupBox)
    self.args = { ... }
    self.params = self.args[#self.args]
    table.remove(self.args, #self.args)
    self.argsNum = #self.args

    self.borderX = self.params.x or 0
    self.borderY = self.params.y or 0
    self.borderWidth = self.params.width
    self.borderHeight = self.params.height or 30
    self:__initRatio()

    if self.params.width then
        self:__setElementSize()
    end


    self.states = { "idle", "hover", "active" }
    self.currentState = "idle"

    self.color1 = { 1, 1, 1, 1 }
    self.color2 = { .2, .2, .2, 1 }
    self.currentColor = self.color1

    self.isDrawBorder = false

    return self
end

function GroupBox:update(dt)
    for i, e in ipairs(self.args) do
        if e.update then
            e:update(dt)
        end
    end
end

function GroupBox:draw()
    for i, e in ipairs(self.args) do
        if e.draw then
            e:draw()
        end
    end
end

function GroupBox:keypressed(key)
    for i, e in ipairs(self.args) do
        if e.keypressed then
            e:keypressed(key)
        end
    end
end

-- api -------------------------------------------
function GroupBox:api_setPos(x, y)
    self.borderX, self.borderY = x, y
    self:__setElementPos()
end

function GroupBox:api_setSize(w, h)
    self.borderWidth, self.borderHeight = w, h
    self:__setElementSize()
end

function GroupBox:api_getPos()
    return self.borderX, self.borderY
end

function GroupBox:api_getSize()
    local sumWidth = 0
    for i = 1, #self.ratio do
        local width = self.args[i]:api_getSize()
        sumWidth = sumWidth + width
    end
    return sumWidth, self.borderHeight
end

function GroupBox:api_getCenterPos()
    return self.borderX + self.borderWidth * 0.5, self.borderY + self.borderHeight * 0.5
end

function GroupBox:api_setState(state)
    self.currentState = state
    for i = 1, self.argsNum do
        self.args[i]:api_setState(state)
    end
end

function GroupBox:api_getState()
    local allIdle = true
    local allHover = true
    for i = 1, self.argsNum do
        if self.args[i].api_getState then
            local state = self.args[i]:api_getState()
            if state == "active" then
                return "active"
            end
            if state ~= "idle" then allIdle = false end
            if state ~= "hover" then allHover = false end
        end
    end

    if allHover then return "hover" end
    if allIdle then return "idle" end
end

function GroupBox:api_showBorder(r, g, b, a)
    local value = r and true or false
    self.isDrawBorder = value
    for i, n in ipairs(self.args) do
        if n.api_showBorder then
            n:api_showBorder(r, g, b, a)
        end
    end
end

-- internal func -----------------------------------

-- 初始化组内元素的宽度或高度比例
function GroupBox:__initRatio()
    self.ratio = self.params.ratio or {}
    if #self.ratio == 0 then
        for i = 1, self.argsNum do
            table.insert(self.ratio, 1)
        end
    end
    self.ratioSum = 0
    for _, n in ipairs(self.ratio) do
        self.ratioSum = self.ratioSum + n
    end
end

function GroupBox:__setElementPos()
    local x = self.borderX
    local y = self.borderY
    local width = 0
    for i = 1, self.argsNum do
        if i > 1 then
            width = self.ratio[i - 1] / self.ratioSum * self.borderWidth
        end
        x = x + width
        self.args[i]:api_setPos(x, y)
    end
end

function GroupBox:__setElementSize()
    for i = 1, self.argsNum do
        local l = self.ratio[i]
        local width = self.ratio[i] / self.ratioSum * self.borderWidth
        local height = self.borderHeight
        self.args[i]:api_setSize(width, height)
    end
end

function GroupBox:__setElementState(state)
    for i = 1, self.argsNum do
        self.args[i]:api_setState(state)
    end
end

function GroupBox:__getSumWidth()
    local sumWidth = 0
    for i = 1, #self.ratio do
        local width = self.args[i]:api_getSize()
        sumWidth = sumWidth + width
    end
    return sumWidth
end

function GroupBox:api_setContainer(container)
    for i, e in ipairs(self.args) do
        if e.api_setContainer then
            e:api_setContainer(container)
        end
    end
end

return GroupBox
