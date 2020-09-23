Paddle = Class{}

function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dy = 0
end

function Paddle:update(dt)

    -- adds paddle movement to current Y scaled by dt
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    -- math.max/min used to clamp movement to not exceed screen bounds
    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end
end

    -- To be called by our main function in `love.draw`
function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end