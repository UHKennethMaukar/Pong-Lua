--[[push is a library that will allow us to draw our game at a virtual resolution, 
    instead of however large our window is; used to provide a more retro aesthetic
    https://github.com/Ulydev/push
]]
push = require 'push'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- virtual resolution to be fitted within the actual window above
-- grants magnified visual effect
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- speed of paddle movement; multiplied by dt in update
PADDLE_SPEED = 200

--[[
    Runs when the game first starts up, only once; used to initialize the game.
]]
function love.load() --Initializes game state upon program execution
    -- use nearest-neighbor filtering on upscaling and downscaling to prevent blurring of text 
    -- and graphics; try removing this function to see the difference.
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- initialize our virtual resolution, which will be rendered within our
    -- actual window no matter its dimensions; replaces our love.window.setMode call
    -- from the last example
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    -- paddle positions on the Y axis (only moves up or down)
    player1Y = 30
    player2Y = VIRTUAL_HEIGHT - 50

    -- initialize score variables, to be rendered on screen
    player1Score = 0
    player2Score = 0

    -- velocity and position variables for our ball when play starts
    ballX = VIRTUAL_WIDTH / 2 - 2
    ballY = VIRTUAL_HEIGHT / 2 - 2

    -- math.random returns a random value between min, max (inclusive)
    ballDX = math.random(2) == 1 and 100 or -100
    ballDY = math.random(-50, 50)

    -- game state variable used to transition between different parts of the game
    -- (used for beginning, menus, main game, high score list, etc.)
    -- we will use this to determine behavior during render and update
    gameState = 'start'
end

--[[
    Runs every frame, with "dt" passed in, our delta in seconds, a.k.a deltaTime
    since the last frame, which LÖVE2D supplies us.
]]
function love.update(dt)
    -- player 1 movement
    if love.keyboard.isDown('w') then
        -- add negative paddle speed to current Y scaled by dt
        player1Y = math.max(0, player1Y + -PADDLE_SPEED * dt)
    elseif love.keyboard.isDown('s') then
        -- add positive paddle speed. Note isDown is a boolean used instead of keypressed
        -- math.min returns the lesser of two values; bottom of the egde minus paddle height
        player1Y = math.min(VIRTUAL_HEIGHT - 20, player1Y + PADDLE_SPEED * dt) -- clamps y axis movement to not exceed bounds
    end

    -- player 2 movement
    if love.keyboard.isDown('up') then
        player2Y = math.max(0, player2Y + -PADDLE_SPEED * dt)
    elseif love.keyboard.isDown('down') then
        player2Y = math.min(VIRTUAL_HEIGHT - 20, player2Y + PADDLE_SPEED * dt)
    end

    -- update our ball based on its DX and DY only if we're in play state;
    -- scale the velocity by dt so movement is framerate-independent
    if gameState == 'play' then
        ballX = ballX + ballDX * dt
        ballY = ballY + ballDY * dt
    end
end

--[[
    Keyboard handling, called by LÖVE2D each frame; 
    passes in the key we pressed so we can access.
]]
function love.keypressed(key)
    -- keys can be accessed by string name
    if key == 'escape' then
        -- function LÖVE gives us to terminate application
        love.event.quit()

    -- Press enter to initiate 'play' mode
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'play'
        else
            gameState = 'start'
            
            -- Sets starting ball's position to the centre
            ballX = VIRTUAL_WIDTH / 2 - 2
            ballY = VIRTUAL_HEIGHT / 2 - 2

            -- ball's x and y velocity a random starting value
            ballDX = math.random(2) == 1 and 100 or -100 --ternary operation using and/or
            ballDY = math.random(-50, 50) * 1.5
        end
    end
end

--[[
    Called after update by LÖVE2D, used to draw anything to the screen, updated or otherwise. 
    Note X/Y coordinates in Lua goes from top left to bottom right.
]]
function love.draw()
    -- begin rendering at virtual resolution
    push:apply('start')

    -- clear the screen with a specific color; in this case, a color similar
    -- to some versions of the original Pong
    love.graphics.clear(40/255, 45/255, 52/255, 255/255) -- r, g, b, alpha(transparency)

    if gameState == 'start' then
        love.graphics.printf('Hello Start State!', 0, 20, VIRTUAL_WIDTH, 'center')
    else
        love.graphics.printf('Hello Play State!', 0, 20, VIRTUAL_WIDTH, 'center')
    end
    
    --[[
    love.graphics.printf('Hello Pong!', 0, 20, VIRTUAL_WIDTH, 'center') -- string, x, y, # of pixels to center within, alignment
    ]]

    -- draw score on the left and right center of the screen
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, 
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)
    
    -- render first paddle (left side), using the players' Y variable
    love.graphics.rectangle('fill', 10, player1Y, 5, 20) -- mode, x, y, width, height

    -- render second paddle (right side)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH - 10, player2Y, 5, 20)

    -- render ball (center)
    love.graphics.rectangle('fill', ballX, ballY, 4, 4)

    -- end rendering at virtual resolution
    push:apply('end')
end
