local _oldPrint = print
setmetatable(_G, {
    __newindex = function(t, k, v)
        local info = debug.getinfo(2, "Sl")
        local source = info.short_src or "unknow"
        local line = info.currentline or 0
        _oldPrint("Check global variable: " .. "\t" .. k .. " " .. source .. ":" .. line)
        rawset(t, k, v)
    end
})
-- 定义print ---------------------------------
function print(...)
    local info = debug.getinfo(2, "Sl")
    local source = info.short_src
    local line = info.currentline
    _oldPrint(string.format("[%s:%d]", source, line), ...)
end

-- love.run -----------------------------------
function love.run()
    if love.load then love.load(love.arg.parseGameArguments(arg)) end
    if love.timer then love.timer.step() end

    local dt = 0
    local target_fps = 60
    local tick_rate = 1 / target_fps

    return function()
        local start_time = love.timer.getTime()

        if love.event then
            love.event.pump()
            for name, a, b, c, d, e, f in love.event.poll() do
                if name == "quit" then
                    if not love.quit or not love.quit() then
                        return a or 0
                    end
                end
                love.handlers[name](a, b, c, d, e, f)
            end
        end

        if love.timer then dt = love.timer.step() end
        if love.update then love.update(dt) end

        if love.graphics and love.graphics.isActive() then
            love.graphics.origin()
            love.graphics.clear(love.graphics.getBackgroundColor())
            if love.draw then love.draw() end
            love.graphics.present()
        end

        local cur_time = love.timer.getTime()
        local frame_time = cur_time - start_time
        if frame_time < tick_rate then
            love.timer.sleep(tick_rate - frame_time)
        end
    end
end

--variable------------------------------------
local square_model = require("ui.square")
local Button = require("ui.Button")
local ProcessBar = require("ui.ProcessBar")
local GroupBox = require("ui.GroupBox")
local Text = require("ui.Text")
local Container = require("ui.Container")
local Choice = require("ui.Choice")
local RecordKey = require("ui.RecordKey")

local square
local btn_1
local con_1
local gb1, gb2, gb3, gb4

local canvas

--main func------------------------------------
function love.load()
    canvas = love.graphics.newCanvas(800, 600)
    square = square_model:new({ radius = 10, style = "round" })
    love.graphics.setLineWidth(2)

    love.graphics.setFont(love.graphics.newFont(30))

    btn_1 = Button:new({ text = "btn_1" })
    gb1 = GroupBox:new(Text:new({ text = "Volume1", }), ProcessBar:new({}), { ratio = { 2, 3 }, width = 500 })
    gb2 = GroupBox:new(Text:new({ text = "Volume2" }), ProcessBar:new({}), { ratio = { 2, 3 }, width = 500 })
    gb3 = GroupBox:new(Text:new({ text = "Resolution" }),
        Choice:new({ choices = { "1920 x 1080", "1920 x 1200", "2560 x 1440", "3840 x 2560", "test1" } }),
        { ratio = { 2, 3 }, width = 500 })
    gb4 = GroupBox:new(Text:new({ text = "UP Key" }), RecordKey:new({}), { width = 500, ratio = { 2, 3 } })
    con_1 = Container:new(btn_1, gb1, gb2, gb3, gb4,
        { x = 100, y = 100, width = 600, height = 300, col = 1, square = square, autoFormat = true })
end

function love.update(dt)
    square:update(dt)
    con_1:update(dt)
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(34 / 255, 38 / 255, 42 / 255)
    square:draw()
    con_1:draw()
    love.graphics.setCanvas()
    love.graphics.draw(canvas)
    love.graphics.print(love.timer.getFPS())
end

function love.keypressed(key)
    square:keypressed(key)
    con_1:keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    if key == "f1" then
        love.event.quit("restart")
    end
end

function love.mousepressed(x, y, btn)
    square:mousepressed(x, y, btn)
end

function love.keyreleased(key, scancode)
end
