# AvariceGame
Avarice is a game that mixes the old terminal game Greed with Balatro mechanics

# Running the game
If you have love2D installed, simply type `love .` in the AvariceGame directory to run

# Movement
 q   w   e
  \  |  /
 a - @ - d
  /  |  \
 z   x   c

# TODO's

- break apart functionality into 
  - main.lua: main loop
  - data/upgrades.json: upgrades config
  - src/player.lua: player state for save games
  - src/board.lua: board logic
  - src/upgrades.lua: logic for upgrades

- add upgrade logic
  - use tiny-ecs (https://love2d.org/wiki/tiny-ecs)
- add a bunch of upgrades

- add music and sfx
- add shaders
