local grid_size = 4
local tile_size = 85
local gap = 10
local empty_tile = { x = grid_size, y = grid_size }
local grid = {}
local started = false
local beforeStart = true

local titleFont = love.graphics.newFont(130)
local instructionFont = love.graphics.newFont(40)

local colors = {
    { bg = { 0.416, 0.675, 0.263, 0.8 }, fg = { 0.717, 0.847, 0.869 } },
    { bg = { 0.717, 0.847, 0.869, 0.8 }, fg = { 0.914, 0.486, 0.192 } },
    { bg = { 0.020, 0.717, 0.906, 0.8 }, fg = { 0.647, 0.823, 0.949 } },
    { bg = { 0.020, 0.4, 0.69, 0.8 }, fg = { 0.662, 0.741, 0.929 } },
    { bg = { 0.820, 0.271, 0.225, 0.8 }, fg = { 0.839, 0.737, 0.878 } },
}

local sounds = {
    move = love.audio.newSource("assets/sounds/sound-1-167181.mp3", "static"),
    shuffle = love.audio.newSource("assets/sounds/142_secuelasvidrios2-98596.mp3", "static"),
    win = love.audio.newSource("assets/sounds/075667_two-kazoo-fanfarewav-83382.mp3", "static"),
    start = love.audio.newSource("assets/sounds/ready-set-go-sound-268353.mp3", "static")
}

local bgImage
local timer = 0
local moveCount = 0
local font
local blackBarHeight = 50

function createGrid()
    grid = {}
    for i = 1, grid_size * grid_size - 1 do
        grid[i] = { value = i, x = (i - 1) % grid_size + 1, y = math.floor((i - 1) / grid_size) + 1 }
    end
    grid[grid_size * grid_size] = { value = nil, x = grid_size, y = grid_size }
end

function love.load()
    --love.window.setMode(grid_size * (tile_size + gap), grid_size * (tile_size + gap) + blackBarHeight)
    love.window.setMode(640, 480, { fullscreen = false, resizable = true, borderless = false })
    math.randomseed(os.time())
    bgImage = love.graphics.newImage("assets/images/bg.png")
end

function drawShadow(x, y, width, height)
    love.graphics.setColor(0, 0, 0, 0.2)
    love.graphics.setLineWidth(0)
    love.graphics.rectangle("fill", x + 6, y + 6, width, height, 10)
end

function draw3DBlock(x, y, width, height, bgColor, fgColor)
    drawShadow(x, y, width, height)
    love.graphics.setColor(bgColor)
    love.graphics.setLineWidth(0)
    love.graphics.rectangle("fill", x, y, width, height, 10)
    love.graphics.setColor(fgColor)
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", x, y, width, height, 10)
end

function shuffle()
    local moves = {"up", "down", "left", "right"}
    for i = 1, 100 do
        local move = moves[math.random(#moves)]
        if move == "up" then moveTile(0, 1)
        elseif move == "down" then moveTile(0, -1)
        elseif move == "left" then moveTile(1, 0)
        elseif move == "right" then moveTile(-1, 0) end
    end
    sounds.shuffle:play()
    started = true
    timer = 0
    moveCount = 0
end

function love.keypressed(key)
    if not beforeStart then
        if key == "up" then moveTile(0, 1)
        elseif key == "down" then moveTile(0, -1)
        elseif key == "left" then moveTile(1, 0)
        elseif key == "right" then moveTile(-1, 0)
        elseif key == "space" then shuffle() end
        sounds.move:stop()
        sounds.move:play()

        if started then
            checkWin()
        end
    else
        if key == "space" then
            beforeStart = false
                sounds.start:play()
                createGrid()
                font = love.graphics.newFont(50)
                shuffle()
                shuffle()
                shuffle()
                shuffle()
                shuffle()
                shuffle()
        end
    end
end

function moveTile(dx, dy)
    local empty = findEmptyTile()
    local target = { x = empty.x + dx, y = empty.y + dy }
    if target.x >= 1 and target.x <= grid_size and target.y >= 1 and target.y <= grid_size then
        for i = 1, #grid do
            local tile = grid[i]
            if tile.x == target.x and tile.y == target.y then
                tile.x, empty.x = empty.x, tile.x
                tile.y, empty.y = empty.y, tile.y
                break
            end
        end
        moveCount = moveCount + 1
    end
end

function findEmptyTile()
    for i = 1, #grid do
        if not grid[i].value then
            return grid[i]
        end
    end
end

function love.draw()
        local screenWidth = love.graphics.getWidth()
        local screenHeight = love.graphics.getHeight()
        local totalWidth = grid_size * (tile_size + gap) - gap
        local totalHeight = grid_size * (tile_size + gap) - gap
        local xOffset = (screenWidth - totalWidth) / 2
        local yOffset = (screenHeight - totalHeight - blackBarHeight) / 2 + blackBarHeight
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(bgImage, (love.graphics.getWidth() - bgImage:getWidth()) / 2, (love.graphics.getHeight() - bgImage:getHeight()) / 2)

    if beforeStart then
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

        local textTitle = "FunTag"
        local textInstruction = "Start/Shuffle/Reset = A"

        love.graphics.setFont(titleFont)

        local titleWidth = titleFont:getWidth(textTitle)
        local titleHeight = titleFont:getHeight()
        local titleX = (love.graphics.getWidth() - titleWidth) / 2
        local titleY = (love.graphics.getHeight() - titleHeight) / 2 - 30

        -- Разные цвета для каждой буквы
        local colors = {
            { 0.416, 0.675, 0.263 }, -- F
            { 0.020, 0.717, 0.906 }, -- u
            { 0.717, 0.847, 0.869 }, -- n
            { 0.820, 0.271, 0.225 }, -- T
            { 0.020, 0.4, 0.69 },    -- a
            { 0.416, 0.675, 0.263 }, -- g
        }

        local letterX = titleX
        for i = 1, #textTitle do
            local letter = textTitle:sub(i, i)
            love.graphics.setColor(colors[i])
            love.graphics.print(letter, letterX, titleY)
            letterX = letterX + titleFont:getWidth(letter)
        end

        -- Отрисовка инструкции
        love.graphics.setFont(instructionFont)
        love.graphics.setColor(1, 1, 1)
        local instructionWidth = instructionFont:getWidth(textInstruction)
        local instructionX = (love.graphics.getWidth() - instructionWidth) / 2
        local instructionY = titleY + titleHeight + 20
        love.graphics.print(textInstruction, instructionX, instructionY)
    else
        for i = 1, #grid do
            local tile = grid[i]
            if tile.value then
                local group = (tile.value - 1) % 5 + 1
                local bg_color = colors[group].bg
                local fg_color = colors[group].fg

                draw3DBlock(xOffset + (tile.x - 1) * (tile_size + gap), yOffset + (tile.y - 1) * (tile_size + gap), tile_size, tile_size, bg_color, fg_color)

                love.graphics.setColor(fg_color)
                love.graphics.setFont(font)
                local text = tostring(tile.value)
                local text_width = love.graphics.getFont():getWidth(text)
                local text_height = love.graphics.getFont():getHeight()
                love.graphics.print(text, xOffset + (tile.x - 1) * (tile_size + gap) + (tile_size - text_width) / 2, yOffset + (tile.y - 1) * (tile_size + gap) + (tile_size - text_height) / 2)
            end
        end

        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, screenWidth, blackBarHeight)

        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(20))

        local hours = math.floor(timer / 3600)
        local minutes = math.floor((timer % 3600) / 60)
        local seconds = math.floor(timer % 60)
        local formattedTime = string.format("%02d:%02d:%02d", hours, minutes, seconds)
        love.graphics.print("Time: " .. formattedTime, 10, 10)

        love.graphics.print("Moves: " .. moveCount, screenWidth - 150, 10)
    end
end

function checkWin()
    for i = 1, grid_size * grid_size - 1 do
        local tile = grid[i]
        local expected_value = (tile.y - 1) * grid_size + tile.x

        if tile.value ~= expected_value then
            return false
        end
    end

    if empty_tile.x ~= grid_size or empty_tile.y ~= grid_size then
        return false
    end

    started = false
    sounds.win:play()
    return true
end

function love.update(dt)
    if started then
        timer = timer + dt
    end
end
