-- Constants
local WID, HEI = 30, 30
local NCOUNT = WID * HEI
local CELL_SIZE = 15 -- Adjust for screen scale
-- lua arrays start at 1, so I can just write RGBA values in slots 1 to 9
-- DEFAULT config
-- 1 = brown
-- 2 = maroon
-- 3 = dark green
-- 4 = cobalt
-- 5 = purple
-- 6 = yellow
-- 7 = muted pink
-- 8 = lime green
-- 9 = cyan
local COLORS = {
	{ 90,  30,   0,  255},  
	{150,   0,   0,  255},
	{  0, 100,   0,  255},
	{  0, 100, 170,  255},
	{100,   0, 100,  255},
	{210, 210,   0,  255},
	{255,   0, 100,  255},
	{100, 255,   0,  255},
	{  0, 255, 200,  255}
}

-- Game State
local board = {}
local cursor = { x = 1, y = 1 }
local score = 0
local mulls = 0
local upgradeThreshold = 0
local upgrades = {}

local gameOver = false
local canUpgrade = false
local mulliganMode = false

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
    upgradeThreshold = 50
    mulls = 4
    gameOver = false
    canUpgrade = false
    mulliganMode = false
end

-- Check if a move is valid
function countSteps(steps, dx, dy)
    local tx, ty = cursor.x, cursor.y
    -- look at each step along the delta
    for i = 1, steps do
	-- increment along x
        tx = tx + dx
	-- increment along y
        ty = ty + dy
        -- Bounds check and check if spot is already eaten (0)
        if tx < 1 or tx > WID or ty < 1 or ty > HEI or board[ty][tx] == 0 then
            return false
        end
    end
    return true
end

-- Swap adjacent numbers
function mulligan(dx, dy)
-- goes into a "mulligan" state where the cursor highlights adjacent squares. 
-- E.G pressing s then w changes the w number
    
    -- if 0,0 then toggle mulliganMode
    if dx == 0 and dy == 0 then 
        mulliganMode = not mulliganMode 
    elseif mulls > 0 then
        -- get cell on board
        local tx, ty = cursor.x, cursor.y
        tx = tx + dx
        ty = ty + dy
        -- re-roll cell
        board[ty][tx] = love.math.random(1, 9)
        mulls = mulls - 1
    end
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
	checkUpgrade()
    end
end

function checkUpgrade()
    if score >= upgradeThreshold then
--        canUpgrade = true
	upgradeThreshold = upgradeThreshold + (upgradeThreshold * 1.5)
    end
end

function addQUpgrade()
   canUpgrade = false
end

function addWUpgrade()
   canUpgrade = false
end

function addEUpgrade()
   canUpgrade = false
end

function checkGameOver()
    -- for all cells adjacent to cursor
    for dy = -1, 1 do
        for dx = -1, 1 do
	    -- if cells are not already eaten
            if not (dx == 0 and dy == 0) then
                local tx, ty = cursor.x + dx, cursor.y + dy
		-- if adjacent space is uneaten and within bounds
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

    if canUpgrade then
        if key == 'q' then addQUpgrade()
        elseif key == 'w' then addWUpgrade() 
	    elseif key == 'e' then addEUpgrade()
	    elseif key == 'escape' then love.event.quit() end
        return
    elseif mulliganMode then
            if key == 'q' then mulligan(-1, -1)
        elseif key == 'w' then mulligan(0, -1)
        elseif key == 'e' then mulligan(1, -1)
        elseif key == 'a' then mulligan(-1, 0)
        elseif key == 's' then mulligan(0, 0)
        elseif key == 'd' then mulligan(1, 0)
        elseif key == 'z' then mulligan(-1, 1)
        elseif key == 'x' then mulligan(0, 1)
        elseif key == 'c' then mulligan(1, 1)
	    end
    else
        -- Key Mapping (Matching your QWE/A D/YXC layout)
            if key == 'q' then execute(-1, -1)
        elseif key == 'w' then execute(0, -1)
        elseif key == 'e' then execute(1, -1)
        elseif key == 'a' then execute(-1, 0)
        elseif key == 's' then mulligan(0, 0)
        elseif key == 'd' then execute(1, 0)
        elseif key == 'z' then execute(-1, 1)
        elseif key == 'x' then execute(0, 1)
        elseif key == 'c' then execute(1, 1)
        elseif key == "escape" then love.event.quit()
        end
    end
end

function love.draw()
    -- Draw Board
    for y = 1, HEI do
        for x = 1, WID do
            local val = board[y][x]
            if val > 0 then
		color = COLORS[val]
                love.graphics.setColor(love.math.colorFromBytes(color[1], color[2], color[3], color[4]))
                love.graphics.print(val, x * CELL_SIZE, y * CELL_SIZE)
	    end    
	    if val == 0 and (x ~= cursor.x or y ~= cursor.y) then
                love.graphics.setColor(love.math.colorFromBytes(255, 0, 0, 255))
        	love.graphics.rectangle("fill", x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
        	love.graphics.print(val, x * CELL_SIZE, y * CELL_SIZE)
	    end
        end
    end

    -- Draw Player
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("@", cursor.x * CELL_SIZE, cursor.y * CELL_SIZE)

    -- Draw Movement Star
       -- cells in star have white square, and number is black
    if mulliganMode == false then
        -- for all cells adjacent to cursor
        for dy = -1, 1 do
            for dx = -1, 1 do
    	        -- if cells are not already eaten
                if not (dx == 0 and dy == 0) then
                    local tx, ty = cursor.x + dx, cursor.y + dy
    		        -- if adjacent space is uneaten and within bounds
                    if tx >= 1 and tx <= WID and ty >= 1 and ty <= HEI then
                        local steps = board[ty][tx]
                        if steps > 0 and countSteps(steps, dx, dy) then
                            drawMovementStar(steps, dx, dy)
                        end
                    end
                end
            end
        end
    end

    if mulliganMode == true then
        for dy = -1, 1 do
            for dx = -1, 1 do
    	        -- if cells are not already eaten
                if not (dx == 0 and dy == 0) then
                    local tx, ty = cursor.x + dx, cursor.y + dy
    		        -- if adjacent space is uneaten and within bounds
                    if tx >= 1 and tx <= WID and ty >= 1 and ty <= HEI then
                        local steps = board[ty][tx]
                        if steps > 0 then
                            drawMulliganSquare(dx, dy)
                        end
                    end
                end
            end
        end
    end

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

    -- Upgrade Overlay
    if canUpgrade then
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 200, 100, 400, 200)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("UPGRADES", 200, 120, 400, "center")
    end
end

function drawMovementStar(steps, dx, dy)
    local tx,ty = cursor.x, cursor.y 
    for i = 1, steps do
	-- increment along x
        tx = tx + dx
	-- increment along y
        ty = ty + dy
        local val = board[ty][tx]
        -- draw rectangle outline
        love.graphics.rectangle("line", tx * CELL_SIZE, ty * CELL_SIZE, CELL_SIZE, CELL_SIZE)
        love.graphics.print(val, tx * CELL_SIZE, ty * CELL_SIZE)
    end
end

function drawMulliganSquare(dx, dy)
    local tx,ty = cursor.x, cursor.y 
    
    tx = tx + dx
    ty = ty + dy
    local val = board[ty][tx]
    -- draw rectangle outline
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("line", tx * CELL_SIZE, ty * CELL_SIZE, CELL_SIZE, CELL_SIZE)
    love.graphics.print(val, tx * CELL_SIZE, ty * CELL_SIZE)
end
