local entities = {}

entities.player = {
    isPlayer = true,
    pos = { x = 1, y = 1 },
    score = 0,
    upgradeThreshold = 50,
    mulls = { count = 4, active = false },
    upgrades = {},
    canUpgrade = false
}

entities.board = {
    isBoard = true,
    grid = {},
    dimensions = { w = 15, h = 15 },
    cellSize = 15,
    colors = {
        { 90,  30,   0,  255}, {150,   0,   0,  255}, {  0, 100,   0,  255},
        {  0, 100, 170,  255}, {100,   0, 100,  255}, {210, 210,   0,  255},
        {255,   0, 100,  255}, {100, 255,   0,  255}, {  0, 255, 200,  255}
    }
}

return entities
