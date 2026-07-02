local Layout = {}
Layout.__index = Layout
function Layout:new(...)
    local self = setmetatable({}, { __index = Layout })
    self.args = { ... }
    self.params = type(self.args[#self.args]) == "table" and self.args[#self.args] or {}
    table.remove(self.args, #self.args)
    self.index = 1
    return self
end

function Layout:update(dt)
    for _, ele in ipairs(self.args) do
        local _ = ele.update and ele:update(dt)
    end
end

function Layout:draw()
    for _, ele in ipairs(self.args) do
        local _ = ele.draw and ele:draw()
    end
end

function Layout:keypressed(key)

end

return Layout
