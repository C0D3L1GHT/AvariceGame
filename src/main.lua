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

local tiny = require("tiny")
local world = tiny.world()
local entities = require("entities")
local player = entities.player
local Player = require("player")

-- The Board Entity
local board = {
    isBoard = true,
    grid = {}, -- 2D array from your createBoard() logic
    dimensions = { w = 15, h = 15 },
    cellSize = 15
}

world:addEntity(player)
world:addEntity(board)

-- Initialize the board
function createBoard()
    board.grid = {}
    for y = 1, board.dimensions.h do
        board.grid[y] = {}
        for x = 1, board.dimensions.w do
            board.grid[y][x] = love.math.random(1, 9)
        end
    end

    Player.create(player, board)
    
    gameOver = false
end


-- LÖVE Callbacks
function love.load()
    -- love.window.setMode(board.dimensions.w * 20, board.dimensions.h * 20)
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

    if Player.canUpgrade then
        if key == 'q' then addQUpgrade()
        elseif key == 'w' then addWUpgrade() 
	    elseif key == 'e' then addEUpgrade()
	    elseif key == 'escape' then love.event.quit() end
        return
    elseif player.mulls.active then
            if key == 'q' then Player.mulligan(player, board, -1, -1)
        elseif key == 'w' then Player.mulligan(player, board, 0, -1)
        elseif key == 'e' then Player.mulligan(player, board, 1, -1)
        elseif key == 'a' then Player.mulligan(player, board, -1, 0)
        elseif key == 's' then Player.mulligan(player, board, 0, 0)
        elseif key == 'd' then Player.mulligan(player, board, 1, 0)
        elseif key == 'z' then Player.mulligan(player, board, -1, 1)
        elseif key == 'x' then Player.mulligan(player, board, 0, 1)
        elseif key == 'c' then Player.mulligan(player, board, 1, 1)
	    end
    else
        -- Key Mapping (Matching your QWE/A D/YXC layout)
            if key == 'q' then Player.execute(player, board, -1, -1)
        elseif key == 'w' then Player.execute(player, board, 0, -1)
        elseif key == 'e' then Player.execute(player, board, 1, -1)
        elseif key == 'a' then Player.execute(player, board, -1, 0)
        elseif key == 's' then Player.mulligan(player, board, 0, 0)
        elseif key == 'd' then Player.execute(player, board, 1, 0)
        elseif key == 'z' then Player.execute(player, board, -1, 1)
        elseif key == 'x' then Player.execute(player, board, 0, 1)
        elseif key == 'c' then Player.execute(player, board, 1, 1)
        elseif key == "escape" then love.event.quit()
        end
    end
end

function love.draw()
    -- Draw Board
    for y = 1, board.dimensions.h do
        for x = 1, board.dimensions.w do
            local val = board.grid[y][x]
            if val > 0 then
		        color = COLORS[val]
                love.graphics.setColor(love.math.colorFromBytes(color[1], color[2], color[3], color[4]))
                love.graphics.print(val, x * board.cellSize, y * board.cellSize)
	        end    
	        if val == 0 and (x ~= player.pos.x or y ~= player.pos.y) then
                love.graphics.setColor(love.math.colorFromBytes(255, 0, 0, 255))
        	    love.graphics.rectangle("fill", x * board.cellSize, y * board.cellSize, board.cellSize, board.cellSize)
        	    love.graphics.print(val, x * board.cellSize, y * board.cellSize)
	        end
        end
    end
    
    Player.draw(player, board)

    -- Draw Score
    love.graphics.setColor(0, 1, 0)
    local percent = string.format("%.2f", (player.score * 100) / (board.dimensions.w * board.dimensions.h))
    love.graphics.print("SCORE: " .. player.score .. " : " .. percent .. "%", 10, board.dimensions.h * board.cellSize + 20)

    -- Game Over Overlay
    if gameOver then
        love.graphics.setColor(love.math.colorFromBytes(0, 0, 0, 0.8))
        love.graphics.rectangle("fill", 200, 100, 400, 100)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("GAME OVER\nPLAY AGAIN (Y/N)?", 200, 120, 400, "center")
    end

    -- Upgrade Overlay
    if player.canUpgrade then
        love.graphics.setColor(love.math.colorFromBytes(255, 255, 255, 10))
        love.graphics.rectangle("fill", 200, 100, 400, 200)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("UPGRADES", 200, 120, 400, "center")
    end
end

