--[[
# KeyPressing 模块
1. 用于处理按键“单次触发 + 长按连发”的输入逻辑。
2. 通过 api_isTriggered 获取触发信号
]]
local KeyPressing = {}
KeyPressing.__index = KeyPressing


---@param params table|nil
---@param params.keys string[]            @监听的键位列表
---@param params.timer_1 number|nil       @长按触发前的延迟时间（秒）
---@param params.timer_2 number|nil       @连发间隔时间（秒）
---@return KeyPressing
function KeyPressing:new(params)
    local self = setmetatable({}, KeyPressing)
    self.params = params or {}

    self.keys_ls = self.params.keys or {}
    self.keys = {}
    for _, k in ipairs(self.keys_ls) do
        self.keys[k] = true
    end

    self.is_pressed = false
    self.value = false

    self.timer_1_limit = self.params.timer_1 or 0.5
    self.timer_2_limit = self.params.timer_2 or 0.2
    self.timer_1 = 0
    self.timer_2 = 0
    self.just_down = false
    return self
end

function KeyPressing:update(dt)
    self.value = false
    if self.just_down then
        self.value = true
        self.just_down = false
    else
        if love.keyboard.isDown(unpack(self.keys_ls)) then
            self.timer_1 = self.timer_1 + dt
            if self.timer_1 >= self.timer_1_limit then
                self.timer_2 = self.timer_2 + dt
                if self.timer_2 >= self.timer_2_limit then
                    self.value = true
                    self.timer_2 = 0
                end
            end
        else
            self.timer_1 = 0
            self.timer_2 = 0
        end
    end
end

function KeyPressing:draw()
end

function KeyPressing:keypressed(key)
    if self.keys[key] then
        self.just_down = true
    end
end

function KeyPressing:api_getValue()
    return self.value
end

return KeyPressing
