console = {}

function console:new( x, y)
--libs
    utf8 = require 'utf8'
    
--tables
    self.meta = {}
    self.meta.x, self.meta.y, self.meta.w, self.meta.h, self.meta.r = x or 0, y or 0 , 512, 256, 20
    self.meta.text = {}
    self.meta.font = love.graphics.newFont( 16, 'mono')
    self.meta.commands = { { name = "help";
            func = function()
                console:print( "command list:")
                for i, command in ipairs(self.meta.commands) do
                    if command.description ~= nil then
                        console:print( command.name .. ": " .. command.description)
                    end
                end
            end
        };
        {   name = "echo";
            description = "A simple text command.";
            func = function(...)
                local tkns = cpack({...})
                
                if ... == nil then
                    console:print( "Error[N°2]: no output.", 255)
                else
                    console:print( table.concat( cunpack(tkns), " "))
                end
            end
        };
        {   name = "dice";
            description = "A random number of 1 to 6.";
            func = function()
                console:print(math.random( 1, 6))
            end
        };
        {   name = "cls";
            description = "Clear the text on terminal.";
            func = function()
                self.meta.console.text = {}
            end
        };
        {   name = "stop";
            description = "Stop the terminal.";
            func = function()
                self.consolePlay = false
            end
        };
        {   name = "play";
            description = "Play the terminal.";
            func = function()
                self.consolePlay = true
            end
        };
    }

--vars
    self.openConsole = false
    self.consolePlay = true
    self.keyboardUpper = false
    self.input = ""
end

function console:render()
    local textY = self.meta.y + self.meta.h - 48 --the y text position
    
    --button
    console:drawButton( "open Console", { love.graphics.getWidth() - 96; 0; 96; 32}, { 100; 100; 100; 50})
    
    --when the console open
    if self.openConsole then
        love.graphics.setColor( .25, .25, .25)
            love.graphics.rectangle( 'fill',
                self.meta.x,
                self.meta.y,
                self.meta.w,
                self.meta.h,
                self.meta.r
            )
        love.graphics.setColor( .75, .75, .75)
            love.graphics.rectangle( 'fill',
                self.meta.x + 8,
                self.meta.y + 8,
                self.meta.w - 16,
                self.meta.h - 16,
                self.meta.r
            )
        love.graphics.setColor( 0, 0, 0)
            love.graphics.print( "Console: ", self.meta.x + 16, self.meta.y + 16)
            love.graphics.print( "C//: ", self.meta.x + 16, self.meta.y + self.meta.h - 28)
            love.graphics.print( self.input, self.meta.x + 16 + self.meta.font:getWidth("C//: "), self.meta.y + self.meta.h - 28)
            
            --button
            console:drawButton( "send", {self.meta.x + self.meta.w - 48; self.meta.y + self.meta.h - 30; 32; 18}, { 100; 100; 100})
            
            for i, text in ipairs(self.meta.text) do
                if text.type == 'colored' then
                    love.graphics.setColor(text.colors)
                        love.graphics.print( self.meta.text[i].text, self.meta.x + 16, textY)
                    love.graphics.setColor( 1, 1, 1)
                else
                    love.graphics.print( self.meta.text[i], self.meta.x + 16, textY)
                end

                textY = textY - 16
            end
        love.graphics.setColor( 1, 1, 1)
    end
end

function console:update()
    --console
    if #self.meta.text > 12 then
        table.remove( self.meta.text, #self.meta.text)
    end
    
    if isTouchOnButton({love.graphics.getWidth() - 96, 0, 96, 32}) then
        if not self.openConsole then
            self.openConsole = true
        else
            self.openConsole = false
        end
    end
    
    if self.openConsole then
        if isTouchOnButton({ self.meta.x + self.meta.w - 48; self.meta.y + self.meta.h - 30; 48; 30}) then
            if self.input ~= "" then
                console:print(self.input)
                console:run(self.input)
            end
            self.input = ""
        elseif isTouchOnButton({ self.meta.x + 16 + self.meta.font:getWidth("C//: "); self.meta.y + self.meta.h - 28; self.meta.w - 50, 24}) then
            love.keyboard.setTextInput(true)
        end
    end
end

function console:keypressed(k)
    if k == "backspace" then
        local byteoffset = utf8.offset( self.input, -1)
        
        if byteoffset then
            self.input = string.sub( self.input, 1, byteoffset - 1)
        end
    end
end

function console:keyboard(t)
    self.input = self.input .. t
end

function console:run(cmd)
    local token = tokenize( cmd, " ")
    
    for i, cmd in ipairs(self.meta.commands) do
        if cmd.name == token[1] then
            table.remove( token, 1)
            pcall( cmd.func, unpack(token))
            break
        end
        
        if i == #self.meta.commands and cmd.name ~= token[1] then
            console:print( "Error[N°1]: command not exist.", 'red')
        end
    end
    
    token = {}
end

function console:print( text, colors)
    
    clrbystr = { { name = 'red'; rgb = { 255; 0; 0}};
        { name = 'blue'; rgb = { 0; 0; 255}};
        { name = 'green'; rgb = { 0; 255; 0}};
        { name = 'purple'; rgb = { 255; 0; 255}};
        { name = 'yellow'; rgb = { 255; 255; 0}}
    }
    
    if colors == nil then
        colors = { 0; 0; 0}
    elseif type(colors[1]) ~= 'number' then
        for i, color in ipairs(clrbystr) do
            if colors == color.name then
                colors = color.rgb
                break
            end
        end
    end
    
    msg = {}
    msg.text = tostring(text) --text to print on console
    msg.type = 'colored' --if is colored or no
    msg.colors = { (colors[1] or 0) / 255; (colors[2] or 0) / 255; (colors[3] or 0) / 255} --text color
    
    if #self.meta.text > 12 then
        table.remove( self.meta.text, #self.meta.text) --to works with more efficiency
    end

    if self.consolePlay then
        table.insert( self.meta.text, 1, msg)
    end
end

--especial functions
function isTouchOnButton(object)
    local touches = love.touch.getTouches()
    
    for i, touch in ipairs(touches) do
        local tx, ty = love.touch.getPosition(touch)
        
        if tx >= object[1] and tx <= object[1] + object[3] and ty >= object[2] and ty <= object[2] + object[4] then
            return true,
            love.timer.sleep(1 / 12)
        end
    end
end

function console:drawButton( text, object, bgColors, fgColors)
    if bgColors == nil then
        bgColors = { 255; 255; 255; 100}
    end
    
    if fgColors == nil then
        fgColors = { 0; 0; 0; 100}
    end
    
    love.graphics.setColor( (bgColors[1] or 255) / 255, (bgColors[2] or 255) / 255, (bgColors[3] or 255) / 255, (bgColors[4] or 100) / 100)
        love.graphics.rectangle( 'fill',
            object[1],
            object[2],
            object[3],
            object[4],
            object[5] or 4
        )
    love.graphics.setColor( (fgColors[1] or 0) / 255, (fgColors[2] or 0) / 255, (fgColors[3] or 0) / 255, (fgColors[4] or 100) / 100)
        love.graphics.print(text,
            object[1] + object[3] / 2,
            object[2] + object[4] / 2,
            nil,
            nil,
            nil,
            self.meta.font:getWidth(text) / 3,
            self.meta.font:getHeight() / 3
       )
    love.graphics.setColor( 1, 1, 1)
end

function tokenize( inputstr, sep)
    local t = {}
    
    for str in string.gmatch( inputstr, '([^' .. (sep or 's%') .. ']+)') do
        table.insert( t, str)
    end
    
    return t
end

function cpack( t, drop, indent)
    assert(type(t) == "table", "Can only TSerial.pack tables.")
    local s, indent = "{"..(indent and "\n" or ""), indent and math.max(type(indent)=="number" and indent or 0,0)
    for k, v in pairs(t) do
        local tk, tv, skip = type(k), type(v)
        if tk == "boolean" then k = k and "[true]" or "[false]"
        elseif tk == "string" then if string.format("%q",k) ~= '"'..k..'"' then k = '['..string.format("%q",k)..']' end
        elseif tk == "number" then k = "["..k.."]"
        elseif tk == "table" then k = "["..cpack(k, drop, indent and indent+1).."]"
        elseif type(drop) == "function" then k = "["..string.format("%q",drop(k)).."]"
        elseif drop then skip = true
        else error("Attempted to TSerial.pack a table with an invalid key: "..tostring(k))
        end
        if tv == "boolean" then v = v and "true" or "false"
        elseif tv == "string" then v = string.format("%q", v)
        elseif tv == "number" then    -- no change needed
        elseif tv == "table" then v = cpack(v, drop, indent and indent+1)
        elseif type(drop) == "function" then v = "["..string.format("%q",drop(v)).."]"
        elseif drop then skip = true
        else error("Attempted to TSerial.pack a table with an invalid value: "..tostring(v))
        end
        if not skip then s = s..string.rep("\t",indent or 0)..k.."="..v..","..(indent and "\n" or "") end
    end
    return s..string.rep("\t",(indent or 1)-1).."}"
end

function cunpack(s)
    assert(type(s) == "string", "Can only TSerial.unpack strings.")
    assert(loadstring("ctable="..s))()
    local t = ctable
    ctable = nil
    return t
end

return console