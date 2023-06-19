# Love2d-mobile-console
A undepedent mobile console on version 0.0.5 to use on love2d created by Ayano the Foxy with the help of Choco on 24th may 2023 made with the lua languague

# Features
- sample of use
- haven't external dependences
- have a list of commands to use

# How to use
To use the console you need download the code and put it in your program, using the love2d do like

```lua
function love.load()
    console = require 'console' --take the console script
    console:new(0, 0) --create a new console  at the position 0
end

function love.draw()
    console:render() --draw the console in the screen
end

function love.update(dt)
    console:update() --update the cosole
end
```