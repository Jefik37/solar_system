function love.load()

    --client related
    love.window.setMode(0, 0)
    screen_width = love.graphics.getWidth()
    screen_height = love.graphics.getHeight()
    love.window.setMode(screen_width, screen_height, {resizable = true})
    love.window.setFullscreen(true, "desktop")
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    rgb = love.math.colorFromBytes
    color_grid = {0.5, 0.5, 0.5}
    love.graphics.setBackgroundColor({0,0,0})

    --values

    offset_x = width/2
    offset_y = height/2
    strt_tchd_pos_x = 0
    strt_tchd_pos_y = 0
    prev_click_state = true
    paused = true

    --options 
    body_spacing = 4
    grid_on = false
    options = true

    --maths
    abs = math.abs
    floor = math.floor
    ceil = math.ceil
    sqrt = math.sqrt
    sin = math.sin
    cos = math.cos
    atan = math.atan

    --body
    preset[tonumber(2)]()
    love.mouse.setRelativeMode(true)

    lines = 0
    debug = lines

end

function love.update(dt)

    love.mouse.setPosition(width/2, height/2)

    if selected_body then
        offset_x = width/2 - selected_body.x * zoom
        offset_y = height/2 - selected_body.y * zoom
        body0.x = body0.x + selected_body.x - prev_x_selected_body
        body0.y = body0.y + selected_body.y - prev_y_selected_body

        prev_x_selected_body = selected_body.x
        prev_y_selected_body = selected_body.y
    end

    if not paused then 

        for i = 2, #body do
            body[i].ax = 0
            body[i].ay = 0
            if love.mouse.isDown(1) then
                body[i]:update_collisons(body0)
                body[i]:update_acceleration(body0)
            end
            for j = 2, #body do
                if i ~= j then
                    body[i]:update_acceleration(body[j])
                end
            end
            body[i]:update_speed_position()
        end
    end

end

function love.draw()

    if grid_on then draw_grid() end

    for i = 2, #body do --draws bodies
        love.graphics.setColor(rgb(body[i].color))
        love.graphics.circle('fill', body[i].x*zoom+offset_x, body[i].y*zoom+offset_y, body[i].radius*zoom)
    end

    if grid_on then
        for i = 2, #body do --draws bodies outline
            love.graphics.setColor(rgb(body[i].color))
            love.graphics.circle('line', body[i].x*zoom+offset_x, body[i].y*zoom+offset_y, body[i].radius*zoom*10*body_spacing)
        end
        love.graphics.setColor(rgb(body0.color)) --draws cursor outline
        love.graphics.circle('line', body0.x*zoom+offset_x, body0.y*zoom+offset_y, body0.radius*zoom*10*body_spacing)
    end

    love.graphics.setColor(rgb(body0.color)) --draws cursor
    love.graphics.circle('fill', body0.x*zoom+offset_x, body0.y*zoom+offset_y, body0.radius*zoom)

    if paused then
        love.graphics.setColor(rgb({255, 50, 50}))
        love.graphics.print('PAUSED', width-130, 20, 0, 2, 2)
    end

    if options then
        text_spacing = 20
        love.graphics.setColor(rgb({255, 255, 255}))
        for i=1, #text_menu do
            love.graphics.print(text_menu[i], 20, text_spacing*i)
        end
    end

end 

function love.mousemoved( x, y, dx, dy, istouch )

    if love.mouse.isDown(2) then
        offset_x = offset_x + dx
        offset_y = offset_y + dy
    else
        body0.x = body0.x + dx/zoom
        body0.y = body0.y + dy/zoom
    end

end

function closest_divisible(x, y)
    q = floor(x, y)
    return (q*y-y)
end

function get_closest_multiple_of_the_power(x, s)
    i = x - 1 
    while i%s ~= 0 do 
        i = i - 1 
    end 
    return i
end

function draw_grid()
    lines = 0
    love.graphics.setColor(color_grid)
    love.graphics.setLineWidth(0.5)
    scale = (floor(50/zoom)*10)
    -- makes it so it will only be a power of ten
    scale_power_of_ten = "1"
    for i = 1, #tostring(scale)-1 do
        scale_power_of_ten = scale_power_of_ten..'0'
    end

    beginning = ceil(-offset_x/zoom)
    beginning = get_closest_multiple_of_the_power(beginning, scale_power_of_ten)

    for i = beginning, (width-offset_x)/zoom, scale_power_of_ten do
        lines = lines + 1
        x = i*zoom + offset_x 
        love.graphics.line(x, 0, x, height)
        love.graphics.print(i, x+zoom/10, offset_y+zoom/10)
    end

    beginning = ceil(-offset_y/zoom)
    beginning = get_closest_multiple_of_the_power(beginning, scale_power_of_ten)

    for j = beginning, (height-offset_y)/zoom, scale_power_of_ten do
        lines = lines + 1
        y = j*zoom + offset_y 
        love.graphics.line(0, y, width, y)
        if j ~=0 then
            love.graphics.print(-j, offset_x+zoom/10, y+zoom/10)
        end
    end

    love.graphics.setLineWidth(2)
    love.graphics.line(offset_x, 0, offset_x, height)
    love.graphics.line(0, offset_y, width, offset_y)

end

function instring(char, str)
    for i = 1, #str do
        if string.sub(str, i, i) == char then
            return true
        end
    end
    return false
end

function reset_cursor()
    body0.x = (width/2-offset_x)/zoom
    body0.y = (height/2-offset_y)/zoom
end

function love.keypressed(key, scancode, isrepeat)
	if key == "f11" or (key == 'return' and love.keyboard.isDown('lalt')) then
        
        if height ~= screen_height then
            love.window.setMode(0, 0)
            screen_width = love.graphics.getWidth()
            screen_height = love.graphics.getHeight()
            love.window.setMode(width, height, {resizable = true})
            love.window.setFullscreen(true, "desktop")
        else
            love.window.setMode(800, 600, {resizable = true})
        end
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    love.graphics.setBackgroundColor(0,0,0)

        width = love.graphics.getWidth()
        height = love.graphics.getHeight()
    elseif key == 'escape' then
        -- love.event.quit() 
    elseif key == 'p' then
        paused = not paused
    elseif key == 'g' then
        grid_on = not grid_on
    elseif key == 's' then
        options = not options
    elseif key == 'r' then
        reset_cursor()
    elseif key == '1' or key == '2' or key == '3' then
        offset_x = width/2
        offset_y = height/2
        preset[tonumber(key)]()
    end
end


function love.mousereleased( x, y, button, istouch, presses )
    if button == 1 then
        body0.color = {255, 255, 255}
    end

end

function love.mousepressed( x, y, button, istouch, presses )

    if button == 1 then
        body0.color = {255, 40, 40}

    elseif button == 2 then
        --make camera stick to body
        found_body = false
        for i = #body, 2, -1 do
            if  body0.x<body[i].x+body[i].radius and
                body0.x>body[i].x-body[i].radius and
                body0.y<body[i].y+body[i].radius and
                body0.y>body[i].y-body[i].radius then
                    selected_body = body[i]
                    found_body = true
                    prev_x_selected_body = selected_body.x 
                    prev_y_selected_body = selected_body.y
                    break
            end
        end

        if not found_body and selected_body ~= nil then
            selected_body = nil
        end
        --make camera stick to body        
    end
end

function love.wheelmoved( dx, dy )

    center_x = (offset_x-width/2)/zoom
    center_y = (offset_y-height/2)/zoom
    zoom = zoom + dy * zoom/10
    if zoom <0.00001 then zoom = 0.00001 end --prevent from going negative
    offset_x = width/2+center_x*zoom
    offset_y = height/2+center_y*zoom
end

Body = {

    new = function(self, x, y, vx, vy, ax, ay, radius, mass, color)
        obj = {}
        setmetatable(obj, self)
        self.__index = self
        obj.x      = x
        obj.y      = y
        obj.vx     = vx
        obj.vy     = vy
        obj.ax     = ax
        obj.ay     = ay
        obj.radius = radius
        obj.mass   = mass
        obj.color  = color
        return obj
    end,
    
    to_str = function(self)
        return string.format("x=%f, y=%f, vx=%f, vy=%f, ax=%f, ay=%f, radius=%f, mass=%f, color=%f",
                                self.x, self.y, self.vx, self.vy, self.ax, self.ay, self.radius, self.mass, self.color)
    end,
    
    update_collisons = function(self, other)
        dx = other.x - self.x 
        dy = other.y - self.y

        d = sqrt(dx^2 + dy^2)
        theta = atan(dy/dx)
        if d<other.radius+self.radius then
            if dx>0 then
                self.x = self.x + dx-(other.radius+self.radius)*cos(theta)
            elseif dx<0 then
                self.x = self.x + dx+(other.radius+self.radius)*cos(theta)
            end
            if dy>0 then
                self.y = self.y + dy - (other.radius+self.radius)*abs(sin(theta))
            elseif dy<0 then
                self.y = self.y + dy + (other.radius+self.radius)*abs(sin(theta))
            end

            self.vx = -self.vx
            self.vy = -self.vy
        end

    end,

    update_acceleration = function(self, other)
        dx = other.x - self.x
        dy = other.y - self.y
        d = sqrt(dx^2+dy^2)

        if d<1 then d=1 end

        a = G*other.mass/d^2
        theta = atan(dy/dx)
        ax = abs(a*cos(theta))
        ay = abs(a*sin(theta))
        if dx<0 then ax = ax*-1 end
        if dy<0 then ay = ay*-1 end
        self.ax = self.ax + ax
        self.ay = self.ay + ay


    end,

    update_speed_position = function(self)
        self.vx = self.vx + self.ax
        self.vy = self.vy + self.ay
        self.x = self.x + self.vx
        self.y = self.y + self.vy
    end,

}

text_menu = {'Left Click: Interact with planet (push or attract)',
'Right Click (drag): Move camera',
'Right Click (click): Follow planet',
'1 - 3: Change scenes',
'R: Reset cursor',
'P: Pause',
'G: Grid',
'S: Show menu',
'F11: fullscreen',
'ALT F4: Quit',
}

preset = {

    function() --two suns
    G = 2
    zoom = 2
    body_spacing = 5
    body0 = Body:new(width/4, height/4, 0, 0, 0, 0, 3, 100, {255, 255, 255})
    body1 = Body:new(-200, 0, 0, 1.5, 0, 0, 20, 1000, {255, 255, 0}) --sun
    body2 = Body:new(200, 0, 0, -1.5, 0, 0, 20, 1000, {255, 255, 0}) --sun 2
    
    body = {body0, body1, body2}
end,

    function() --realistic solar system
    G = 10
    zoom = 0.05
    sun_mass = 10000
    body_spacing = 5
    body0 = Body:new(width/4, height/4, 0, 0, 0, 0, 50, 500, {255, 255, 255})
    body1 = Body:new(0, 0, 0, 0, 0, 0, 5000, sun_mass, {255, 255, 0}) --sun
    body2 = Body:new(0-5220, 0, 0, sqrt(G*sun_mass/5220)*1.01, 0, 0, 20, 200, {0, 255, 0}) --green
    body3 = Body:new(0, 7470, sqrt(G*sun_mass/7470)*-1.1, 0, 0, 0, 50, 100, {255, 100, 255})  --pink
    body4 = Body:new(0-12660, 0, 0, sqrt(G*sun_mass/12660)*-1, 0, 0, 20, 50, {0, 0, 255}) --blue
    body5 = Body:new(0-12780, 0, 0, sqrt(G*sun_mass/12780)*-1.66, 0, 0, 5, 0.1, {255, 255, 255}) --blue's moon
    body6 = Body:new(0-20500, 0, 0, sqrt(G*sun_mass/20500)*-1.2, 0, 0, 500, 200, {255, 165, 0}) --brown giant
    body7 = Body:new(0+55500, 54280, sqrt(G*sun_mass/55500)*0.5, sqrt(G*sun_mass/55500)*-0.7, 0, 0, 1200, 500, {13, 25, 135}) --big blue
    body8 = Body:new(0+57800, 54380, sqrt(G*sun_mass/12680)*0.5, sqrt(G*sun_mass/55500)*-1.7, 0, 0, 25, 10, {255, 255, 255}) --big blue's moon 1
    body9 = Body:new(0+65900, 52380, sqrt(G*sun_mass/12680)*0.1, sqrt(G*sun_mass/55500)*-1.0, 0, 0, 55, 30, {20, 255, 255}) --big blue's moon 2
    
    body = {body0, body1, body2, body3, body4, body5, body6, body7, body8, body9}

end,

    function() --mino solar system
    G = 0.05
    zoom = 2
    body_spacing = 5
    body0 = Body:new(width/4, height/4, 0, 0, 0, 0, 3, 100, {255, 255, 255})
    body1 = Body:new(0,     0, 0, 0, 0, 0, 20, 1000, {255, 255, 0}) --sun
    body2 = Body:new(0-35,  0, 0, sqrt(G*1000/35)*1.1, 0, 0, 3, 2, {0, 255, 0}) --green
    body3 = Body:new(0,     0+90, sqrt(G*1000/90)*-0.9, 0, 0, 0, 3, 2, {255, 100, 255})  --pink
    body4 = Body:new(0-160, 0, 0, sqrt(G*1000/160)*-1, 0, 0, 4, 20, {0, 0, 255}) --blue
    body5 = Body:new(0-170, 0, 0, sqrt(G*1000/170)*-1.55, 0, 0, 1, 0.1, {255, 255, 255}) --moon
    
    body = {body0, body1, body2, body3, body4, body5, }

end,
}