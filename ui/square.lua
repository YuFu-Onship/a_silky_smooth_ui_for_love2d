--Square-------------------------------------------
local Square = {}
Square.__index = Square
function Square:new(params)
    params = params or {}
    local self = setmetatable({}, Square)

    self.x = params.x or 0
    self.y = params.y or 0
    self.w = params.w or 100
    self.h = params.h or 100
    self.r = params.radius or 10

    -- 中心点
    self.currentX = self.x
    self.currentY = self.y
    self.targetX = self.x
    self.targetY = self.y
    self.targetW = self.w
    self.targetH = self.h

    self.slowCoefficient = 0.5
    self.fastCoefficient = 0.8

    self.style = params.style or "round"
    self.state = { "round", "square" }
    self.currentState = self.style

    if self.currentState == "square" then
        self:squareLoad()
    elseif self.currentState == "round" then
        self:roundLoad()
    end

    return self
end

function Square:update(dt)
    if self.currentState == "square" then
        self:squareUpdate(dt)
    elseif self.currentState == "round" then
        self:roundUpdate(dt)
    end
end

function Square:draw()
    if self.currentState == "square" then
        self:squareDraw()
    elseif self.currentState == "round" then
        self:roundDraw()
    end
end

function Square:keypressed(key)

end

function Square:mousepressed(x, y, btn)
    if btn == 1 then
        self.targetX = x
        self.targetY = y
    end
end

-- 初始化 --------------------------------------------------------------------
function Square:squareLoad()
    -- 四个顶点
    self.squareVertex_cur = self:buildSquareVertex(self.currentX, self.currentY)
    self.sqaureVertex_tar = self:buildSquareVertex(self.targetX, self.targetY)
    self.square = self:buildSquare(self.w, self.h, self.r)
end

function Square:squareUpdate(dt)
    local tx, ty = self.targetX, self.targetY
    local target_vertices = {
        tl = { x = tx - self.w * 0.5, y = ty - self.h * 0.5 },
        tr = { x = tx + self.w * 0.5, y = ty - self.h * 0.5 },
        bl = { x = tx - self.w * 0.5, y = ty + self.h * 0.5 },
        br = { x = tx + self.w * 0.5, y = ty + self.h * 0.5 }
    }

    local dx = tx - self.currentX
    local dy = ty - self.currentY

    for key, v_cur in pairs(self.squareVertex_cur) do
        local v_tar = target_vertices[key]

        local coefX = self.slowCoefficient
        local coefY = self.slowCoefficient

        if (dx > 0 and (key == "tr" or key == "br")) or
            (dx < 0 and (key == "tl" or key == "bl")) then
            coefX = self.fastCoefficient
        end

        if (dy > 0 and (key == "bl" or key == "br")) or
            (dy < 0 and (key == "tl" or key == "tr")) then
            coefY = self.fastCoefficient
        end

        v_cur.x = self:__slowClose(dt, v_cur.x, v_tar.x, coefX)
        v_cur.y = self:__slowClose(dt, v_cur.y, v_tar.y, coefY)
    end

    self.currentX = (self.squareVertex_cur.tl.x + self.squareVertex_cur.br.x) / 2
    self.currentY = (self.squareVertex_cur.tl.y + self.squareVertex_cur.br.y) / 2

    local mesh_vertex = self:buildSquareMeshVertexInUpdate()
    self.square = love.graphics.newMesh(mesh_vertex, "triangles", "dynamic")
    self.square:setTexture(self.canvas)
end

function Square:squareDraw()
    love.graphics.draw(self.square)
end

function Square:roundLoad()
    self.roundCurrentVertex = self:buildSquareVertex(self.currentX, self.currentY)
    self.roundTargetVertex = self:buildSquareVertex(self.currentX, self.currentY)
    self.roundX = self.roundCurrentVertex.tl.x
    self.roundY = self.roundCurrentVertex.tl.y
    self.roundW = self.roundCurrentVertex.br.x - self.roundCurrentVertex.tl.x
    self.roundH = self.roundCurrentVertex.br.y - self.roundCurrentVertex.tl.y
end

function Square:roundUpdate(dt)
    local tx, ty = self.targetX, self.targetY
    local target_vertices = {
        tl = { x = tx - self.w * 0.5, y = ty - self.h * 0.5 },
        tr = { x = tx + self.w * 0.5, y = ty - self.h * 0.5 },
        bl = { x = tx - self.w * 0.5, y = ty + self.h * 0.5 },
        br = { x = tx + self.w * 0.5, y = ty + self.h * 0.5 }
    }

    local dx = tx - self.currentX
    local dy = ty - self.currentY

    for key, v_cur in pairs(self.roundCurrentVertex) do
        local v_tar = target_vertices[key]

        local coefX = self.slowCoefficient
        local coefY = self.slowCoefficient

        if (dx > 0 and (key == "tr" or key == "br")) or
            (dx < 0 and (key == "tl" or key == "bl")) then
            coefX = self.fastCoefficient
        end

        if (dy > 0 and (key == "bl" or key == "br")) or
            (dy < 0 and (key == "tl" or key == "tr")) then
            coefY = self.fastCoefficient
        end

        v_cur.x = self:__slowClose(dt, v_cur.x, v_tar.x, coefX)
        v_cur.y = self:__slowClose(dt, v_cur.y, v_tar.y, coefY)
    end
    self.currentX = (self.roundCurrentVertex.tl.x + self.roundCurrentVertex.br.x) / 2
    self.currentY = (self.roundCurrentVertex.tl.y + self.roundCurrentVertex.br.y) / 2
    self.roundX = self.roundCurrentVertex.tl.x
    self.roundY = self.roundCurrentVertex.tl.y
    self.roundW = self.roundCurrentVertex.br.x - self.roundCurrentVertex.tl.x
    self.roundH = self.roundCurrentVertex.br.y - self.roundCurrentVertex.tl.y
end

function Square:roundDraw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", self.roundX, self.roundY, self.roundW, self.roundH, self.r)
    love.graphics.rectangle("line", self.roundX, self.roundY, self.roundW, self.roundH, self.r)
end

-- 生成mesh顶点
function Square:buildSquareMeshVertex(x, y, w, h, r)
    local vertices = {}
    r = r or 5
    local function addRect(x, y, w, h)
        local v = {
            { x,     y,     0, 0 },
            { x + w, y,     1, 0 },
            { x,     y + h, 0, 1 },

            { x + w, y,     1, 0 },
            { x + w, y + h, 1, 1 },
            { x,     y + h, 0, 1 },
        }
        for i = 1, 6 do table.insert(vertices, v[i]) end
    end

    addRect(r + x, 0 + y, w - 2 * r, r)
    addRect(0 + x, r + y, w, h - 2 * r)
    addRect(r + x, h - r + y, w - 2 * r, r)
    return vertices
end

-- 创建方块mesh
function Square:buildSquare(w, h, r)
    self.canvas = love.graphics.newCanvas(1, 1)
    love.graphics.setCanvas(self.canvas)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, 1, 1)
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    local vertices = self:buildSquareMeshVertex(
        self.squareVertex_cur.tl.x,
        self.squareVertex_cur.tl.y,
        self.targetW,
        self.targetH, self.r)
    local mesh = love.graphics.newMesh(vertices, "triangles", "dynamic")
    mesh:setTexture(self.canvas)
    return mesh
end

-- 缓动函数(当前值,目标值,缓动系数)
function Square:__slowClose(dt, a, b, c)
    c = c or 0.5
    local dist = b - a
    a = (math.abs(dist) < 0.1) and b or (a + dist * c * dt * 30)
    return a
end

-- 创建四个顶点的table
function Square:buildSquareVertex(x, y)
    return {
        tl = { x = x - self.w * 0.5, y = y - self.h * 0.5 },
        tr = { x = x + self.w * 0.5, y = y - self.h * 0.5 },
        bl = { x = x - self.w * 0.5, y = y + self.h * 0.5 },
        br = { x = x + self.w * 0.5, y = y + self.h * 0.5 }
    }
end

-- 创建sqaure活动过程中的mesh顶点
function Square:buildSquareMeshVertexInUpdate()
    local v = self.squareVertex_cur
    local w = v.tr.x - v.tl.x
    local h = v.br.y - v.tr.y
    return self:buildSquareMeshVertex(v.tl.x, v.tl.y, w, h, self.r)
end

-- api --------------------------------------------------------------------
function Square:api_setPos(x, y)
    self.targetX = x
    self.targetY = y
end

function Square:api_setSize(w, h)
    self.w = w
    self.h = h
end

function Square:api_setValue(x, y, w, h)
    self.w = w
    self.h = h
    self.targetX = x + self.w * 0.5
    self.targetY = y + self.h * 0.5
end

return Square
