-- Constants
local WID, HEI = 52,22
local NCOUNT = WID * HEI
local CELL_SIZE = 15 -- Adjust for screen scale

-- Game State
local board = {}
local cursor = { x = 1, y = 1 }
local score = 0
local gameOver = false

-- Initialize the board
function createBoard()
    board = {}
    for y = 1, HEI do
        board[y] = {}
        for x = 1, WID do
            board[y][x] = love.math.random(1, 9)
        end
    end
    
    -- Random starting position
    cursor.x = love.math.random(1, WID)
    cursor.y = love.math.random(1, HEI)
    board[cursor.y][cursor.x] = 0 -- Player starts on an empty spot
    score = 0
    gameOver = false
end

-- Check if a move is valid
function countSteps(steps, dx, dy)
    local tx, ty = cursor.x, cursor.y
    for i = 1, steps do
        tx = tx + dx
        ty = ty + dy
        -- Bounds check and check if spot is already eaten (0)
        if tx < 1 or tx > WID or ty < 1 or ty > HEI or board[ty][tx] == 0 then
            return false
        end
    end
    return true
end

-- Execute movement logic
function execute(dx, dy)
    local targetX, targetY = cursor.x + dx, cursor.y + dy
    if targetX < 1 or targetX > WID or targetY < 1 or targetY > HEI then return end
    
    local steps = board[targetY][targetX]
    if steps > 0 and countSteps(steps, dx, dy) then
        score = score + steps
        for i = 1, steps do
            cursor.x = cursor.x + dx
            cursor.y = cursor.y + dy
            board[cursor.y][cursor.x] = 0
        end
        checkGameOver()
    end
end

function checkGameOver()
    for dy = -1, 1 do
        for dx = -1, 1 do
            if not (dx == 0 and dy == 0) then
                local tx, ty = cursor.x + dx, cursor.y + dy
                if tx >= 1 and tx <= WID and ty >= 1 and ty <= HEI then
                    local steps = board[ty][tx]
                    if steps > 0 and countSteps(steps, dx, dy) then
                        return -- Move exists
                    end
                end
            end
        end
    end
    gameOver = true
end

-- LÖVE Callbacks
function love.load()
    love.window.setTitle("Greed (Lua/Linux)")
    -- Set a small font to mimic console look
    local font = love.graphics.newFont(14)
    love.graphics.setFont(font)
    createBoard()
end

function love.keypressed(key)
    if gameOver then
        if key == 'y' then createBoard()
        elseif key == 'n' or key == 'escape' then love.event.quit() end
        return
    end

    -- Key Mapping (Matching your QWE/A D/YXC layout)
    if key == 'q' then execute(-1, -1)
    elseif key == 'w' then execute(0, -1)
    elseif key == 'e' then execute(1, -1)
    elseif key == 'a' then execute(-1, 0)
    elseif key == 'd' then execute(1, 0)
    elseif key == 'y' or key == 'z' then execute(-1, 1) -- 'z' for QWERTZ/QWERTY comfort
    elseif key == 'x' then execute(0, 1)
    elseif key == 'c' then execute(1, 1)
    end
end

function love.draw()
    -- Draw Board
    for y = 1, HEI do
        for x = 1, WID do
            local val = board[y][x]
            if val > 0 then
                -- Mimic the C++ color logic (6 + i)
                love.graphics.setColor(0.5, 0.4 + (val/10), 0.8)
                love.graphics.print(val, x * CELL_SIZE, y * CELL_SIZE)
            end
        end
    end

    -- Draw Player
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("@", cursor.x * CELL_SIZE, cursor.y * CELL_SIZE)

    -- Draw Score
    love.graphics.setColor(0, 1, 0)
    local percent = string.format("%.2f", (score * 100) / NCOUNT)
    love.graphics.print("SCORE: " .. score .. " : " .. percent .. "%", 10, HEI * CELL_SIZE + 20)

    -- Game Over Overlay
    if gameOver then
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 200, 100, 400, 100)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("GAME OVER\nPLAY AGAIN (Y/N)?", 200, 120, 400, "center")
    end
end
