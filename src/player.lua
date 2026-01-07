local Player = {}

function Player.create(player, board)
    -- Random starting position
    player.pos.x = love.math.random(1, board.dimensions.w)
    player.pos.y = love.math.random(1, board.dimensions.h)
    board.grid[player.pos.y][player.pos.x] = 0 -- Player starts on an empty spot
    player.score = 0
    player.upgradeThreshold = 50
    player.mulls.count = 4
    player.canUpgrade = false
    player.mulls.active = false
end

function checkUpgrade(player)
    if player.score >= player.upgradeThreshold then
        player.canUpgrade = true

	player.upgradeThreshold = player.upgradeThreshold + (player.upgradeThreshold * 1.5)
    end
end

function addQUpgrade(player)
   player.canUpgrade = false
end

function addWUpgrade(player)
   player.canUpgrade = false
end

function addEUpgrade(player)
   player.canUpgrade = false
end

function checkGameOver(player, board)
    -- for all cells adjacent to player.pos
    for dy = -1, 1 do
        for dx = -1, 1 do
	    -- if cells are not already eaten
            if not (dx == 0 and dy == 0) then
                local tx, ty = player.pos.x + dx, player.pos.y + dy
		-- if adjacent space is uneaten and within bounds
                if tx >= 1 and tx <= board.dimensions.w and ty >= 1 and ty <= board.dimensions.h then
                    local steps = board.grid[ty][tx]
                    if steps > 0 and countSteps(player, board, steps, dx, dy) then
                        return -- Move exists
                    end
                end
            end
        end
    end
    gameOver = true
end

function Player.mulligan(player, board, dx, dy)
-- goes into a "mulligan" state where the player.pos highlights adjacent squares. 
-- E.G pressing s then w changes the w number
    
    -- if 0,0 then toggle player.mulls.active
    if dx == 0 and dy == 0 then 
        player.mulls.active = not player.mulls.active 
    elseif player.mulls.count > 0 then
        -- get cell on board
        local tx, ty = player.pos.x, player.pos.y
        tx = tx + dx
        ty = ty + dy
        -- re-roll cell
        board.grid[ty][tx] = love.math.random(1, 9)
        player.mulls.count = player.mulls.count - 1
    end
end
-- Execute movement logic
function Player.execute(player, board, dx, dy)
    local targetX, targetY = player.pos.x + dx, player.pos.y + dy
    if targetX < 1 or targetX > board.dimensions.w or targetY < 1 or targetY > board.dimensions.h then return end
    
    local steps = board.grid[targetY][targetX]
    if steps > 0 and countSteps(player, board, steps, dx, dy) then
        player.score = player.score + steps
        for i = 1, steps do
            player.pos.x = player.pos.x + dx
            player.pos.y = player.pos.y + dy
            board.grid[player.pos.y][player.pos.x] = 0
        end
        checkGameOver(player, board)
	    checkUpgrade(player)
    end
end

-- Check if a move is valid
function countSteps(player, board, steps, dx, dy)
    local tx, ty = player.pos.x, player.pos.y
    -- look at each step along the delta
    for i = 1, steps do
	-- increment along x
        tx = tx + dx
	-- increment along y
        ty = ty + dy
        -- Bounds check and check if spot is already eaten (0)
        if tx < 1 or tx > board.dimensions.w or ty < 1 or ty > board.dimensions.h or board.grid[ty][tx] == 0 then
            return false
        end
    end
    return true
end


function Player.draw(player, board)
    -- Draw Player
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("@", player.pos.x * board.cellSize, player.pos.y * board.cellSize)

    -- Draw Movement Star
       -- cells in star have white square, and number is black
    if player.mulls.active == false then
        -- for all cells adjacent to player.pos
        for dy = -1, 1 do
            for dx = -1, 1 do
    	        -- if cells are not already eaten
                if not (dx == 0 and dy == 0) then
                    local tx, ty = player.pos.x + dx, player.pos.y + dy
    		        -- if adjacent space is uneaten and within bounds
                    if tx >= 1 and tx <= board.dimensions.w and ty >= 1 and ty <= board.dimensions.h then
                        local steps = board.grid[ty][tx]
                        if steps > 0 and countSteps(player, board, steps, dx, dy) then
                            drawMovementStar(player, board, steps, dx, dy)
                        end
                    end
                end
            end
        end
    end

    if player.mulls.active == true then
        for dy = -1, 1 do
            for dx = -1, 1 do
    	        -- if cells are not already eaten
                if not (dx == 0 and dy == 0) then
                    local tx, ty = player.pos.x + dx, player.pos.y + dy
    		        -- if adjacent space is uneaten and within bounds
                    if tx >= 1 and tx <= board.dimensions.w and ty >= 1 and ty <= board.dimensions.h then
                        local steps = board.grid[ty][tx]
                        if steps > 0 then
                            drawMulliganSquare(player, board, dx, dy)
                        end
                    end
                end
            end
        end
    end
end

function drawMovementStar(player, board, steps, dx, dy)
    local tx,ty = player.pos.x, player.pos.y 
    for i = 1, steps do
	-- increment along x
        tx = tx + dx
	-- increment along y
        ty = ty + dy
        local val = board.grid[ty][tx]
        -- draw rectangle outline
        love.graphics.rectangle("line", tx * board.cellSize, ty * board.cellSize, board.cellSize, board.cellSize)
        love.graphics.print(val, tx * board.cellSize, ty * board.cellSize)
    end
end

function drawMulliganSquare(player, board, dx, dy)
    local tx,ty = player.pos.x, player.pos.y 
    
    tx = tx + dx
    ty = ty + dy
    local val = board.grid[ty][tx]
    -- draw rectangle outline
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("line", tx * board.cellSize, ty * board.cellSize, board.cellSize, board.cellSize)
    love.graphics.print(val, tx * board.cellSize, ty * board.cellSize)
end

return Player
