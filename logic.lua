local JSON = require('logic.json')
-- Republica's core
local republica = require("logic.init")
-- options
local options = require('data.config')

-- republicavelha-raylib vars
local exit = false

-- frame function
local function frame(world)
    if(options.paused == false) then
        world.frame(world)
    end
end


-- main loop
function main()
    -- size up to 6 is safe, above 6 you can get buggy maps, default is 2
    -- layers up to 16 are safe, default is 8
    -- generate the world and map
    print('debug')
    io.flush()
    local world = republica.world(options.mapsize,options.mapquality,options.mappolish)
    io.read()
    
    io.write(republica.util.stringify(world.map.block[1][1]))
    -- main loop
    while not exit do
        io.flush()
        frame(world)
    end
    exit = true
end

main()--