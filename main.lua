-- Débogueur Visual Studio Code tomblind.local-lua-debugger-vscode
if pcall(require, "lldebugger") then
    require("lldebugger").start()
end

-- Cette ligne permet d'afficher des traces dans la console pendant l'éxécution
io.stdout:setvbuf("no")

-- Improved print function to print centered text
function drawCenteredText(rectX, rectY, rectWidth, rectHeight, text, scaleX, scaleY)
	local font       = love.graphics.getFont()
	local textWidth  = font:getWidth(text) --* scaleX
	local textHeight = font:getHeight() --* scaleY
	love.graphics.print(text, rectX+rectWidth/2, rectY+rectHeight/2, 0, scaleX, scaleY, textWidth/2, textHeight/2)
end

-- Improved draw function to draw centered images
function drawCenteredIcon(rectX, rectY, rectWidth, rectHeight, Icon, scaleX, scaleY)
	local icon       = Icon
	local iconWidth  = icon:getWidth() --* scaleX
	local iconHeight = icon:getHeight() --* scaleY
	love.graphics.draw(icon, rectX+rectWidth/2, rectY+rectHeight/2, 0, scaleX, scaleY, iconWidth/2, iconHeight/2)
end


chess = {}
chess.map = {}

-- Map of the chess grid
chess.map.grid = {{1,0,1,0,1,0,1,0},
                  {0,1,0,1,0,1,0,1},
                  {1,0,1,0,1,0,1,0},
                  {0,1,0,1,0,1,0,1},
                  {1,0,1,0,1,0,1,0},
                  {0,1,0,1,0,1,0,1},
                  {1,0,1,0,1,0,1,0},
                  {0,1,0,1,0,1,0,1},
}

-- Original position of the pieces
chess.map.pieces = {{"tour_noir","cavalier_noir","fou_noir","reine_noir","roi_noir","fou_noir","cavalier_noir","tour_noir"},
                    {"pion_noir","pion_noir","pion_noir","pion_noir","pion_noir","pion_noir","pion_noir","pion_noir"},
                    {nil,nil,nil,nil,nil,nil,nil,nil},
                    {nil,nil,nil,nil,nil,nil,nil,nil},
                    {nil,nil,nil,nil,nil,nil,nil,nil},
                    {nil,nil,nil,nil,nil,nil,nil,nil},
                    {"pion_blanc","pion_blanc","pion_blanc","pion_blanc","pion_blanc","pion_blanc","pion_blanc","pion_blanc"},
                    {"tour_blanc","cavalier_blanc","fou_blanc","reine_blanc","roi_blanc","fou_blanc","cavalier_blanc","tour_blanc"},
}

chess.images = {tour_noir,cavalier_noir,fou_noir,reine_noir,roi_noir,pion_noir,tour_blanc,cavalier_blanc,fou_blanc,reine_blanc,roi_blanc,pion_blanc}
chess.images.name = {"tour_noir","cavalier_noir","fou_noir","reine_noir","roi_noir","pion_noir","tour_blanc","cavalier_blanc","fou_blanc","reine_blanc","roi_blanc","pion_blanc"}
chess.images.icon = {}

imgMouse = {}
pieceInHands = false

-- Loading the images of all the pieces
local n
for n = 1, 12 do
    local myIcon = love.graphics.newImage("images/"..chess.images.name[n]..".png")
    table.insert(chess.images.icon, myIcon)
end

-- Labelling of lines and columns
chess.map.lineNames = {"8","7","6","5","4","3","2","1"}
chess.map.columnNames = {"A","B","C","D","E","F","G","H"}

-- Setting of colors and tile size
chess.map.TILE_SIZE = 70
chess.map.color1 = {r=0.8,g=0.8,b=0.8}
chess.map.color1hover = {r=1,g=0.8,b=0.8}
chess.map.color2 = {r=0.5,g=0.5,b=0.3}
chess.map.color2hover = {r=0.7,g=0.8,b=0.8}

-- Adapt window size in function of tile size
love.window.setMode(chess.map.TILE_SIZE*8,chess.map.TILE_SIZE*8)

function love.load()

    -- Adapt window size in function of tile size
    love.window.setMode(chess.map.TILE_SIZE*8,chess.map.TILE_SIZE*8)
end

function love.update(dt)

    -- Get the position of the mouse on the grid
    mouseX, mouseY = love.mouse.getPosition( )
    if mouseX ~= nil and mouseY ~= nil then
        if mouseX ~= 0 and mouseY ~= 0 and mouseX~=chess.map.TILE_SIZE*8-1 and mouseY~=chess.map.TILE_SIZE*8-1 then
            mouseL = math.floor(mouseY/chess.map.TILE_SIZE+1)
            mouseC = math.floor(mouseX/chess.map.TILE_SIZE+1)
        else
            mouseL = 0
            mouseC = 0
        end
    end
end

function love.draw()

    -- Drawing the chessboard
    local l,c,k, color
    for l=1,8 do
        for c=1,8 do -- color of the squares
            if l%2 == 0 and c%2 == 0 then
                    color = chess.map.color1 
            elseif l%2 == 0 and c%2 > 0 then
                 color = chess.map.color2 
            elseif l%2 > 0 and c%2 == 0 then
                color = chess.map.color2 
            elseif l%2 > 0 and c%2 > 0 then
                color = chess.map.color1 
            end
            
            if c == mouseC and l == mouseL then -- is the mouse over a square?
                love.graphics.setColor(color.r + 0.2, color.g, color.b, 1)
            else
                love.graphics.setColor(color.r, color.g, color.b, 1)
            end
            love.graphics.rectangle("fill",chess.map.TILE_SIZE*(c-1),chess.map.TILE_SIZE*(l-1),chess.map.TILE_SIZE,chess.map.TILE_SIZE)
            love.graphics.setColor(1,1,1,1)

            --[[ Display the lines and columns
            local font       = love.graphics.getFont()
            local textWidth  = font:getWidth("A")
            local textHeight = font:getHeight()
            if l==1 then drawCenteredText(chess.map.TILE_SIZE*(c-1),chess.map.TILE_SIZE*(l-1),chess.map.TILE_SIZE,chess.map.TILE_SIZE,chess.map.columnNames[c],3,3) end
            if c==1 then drawCenteredText(chess.map.TILE_SIZE*(c-1),chess.map.TILE_SIZE*(l-1),chess.map.TILE_SIZE,chess.map.TILE_SIZE,chess.map.lineNames[l],3,3) end
            ]]

            -- Check if we click on a square with no piece in hands
            if clicked == true and pieceInHands == false then
                for k = 1, 12 do
                    if chess.map.pieces[mouseL][mouseC] == chess.images.name[k] then
                        imgMouse.icon = chess.images.icon[k]
                        imgMouse.name = chess.images.name[k]
                    end
                end
                chess.map.pieces[mouseL][mouseC] = nil    
                clicked = false
                pieceInHands = true
            end

            -- Check if we already have a piece in hand
            if pieceInHands == true then
                if clicked == false then
                    local mouseX, mouseY = love.mouse.getPosition()
                    love.mouse.setVisible(false)
                    love.graphics.draw(imgMouse.icon, mouseX - imgMouse.icon:getWidth()/2, mouseY - imgMouse.icon:getHeight()/2, 0, 0.8, 0.8)
                else 
                    for k = 1, 12 do
                        if imgMouse.name == chess.images.name[k] then
                            chess.map.pieces[mouseL][mouseC] = chess.images.name[k]
                            pieceInHands = false
                            love.mouse.setVisible(true)
                            clicked = false
                        end
                    end
                end
            end

            -- Check where are the pieces and draw them on the grid
            for k = 1, 12 do
                if chess.map.pieces[l][c] == chess.images.name[k] then
                    drawCenteredIcon(chess.map.TILE_SIZE*(c-1),chess.map.TILE_SIZE*(l-1), chess.map.TILE_SIZE, chess.map.TILE_SIZE, chess.images.icon[k], 0.8,0.8)
                end
            end
        end
    end
end

function love.mousepressed(x, y, button, istouch)
    if button == 1 then
        local x, y = love.mouse.getPosition() -- get the position of the mouse
        print(chess.map.columnNames[math.floor(x/chess.map.TILE_SIZE+1)]..","..chess.map.lineNames[math.floor(y/chess.map.TILE_SIZE+1)])
        clicked = true
    end
end
