local cjson = require('cjson')
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

local function newWorld(world)
    local ___world = 
    {
        time = world.time,
        map =
        {
            waterlevel = world.map.waterlevel, 
            size = world.map.size,
            collision = {colliders = world.map.collision.colliders}
        }
    }
    
    local ___plant = {}
    for i, v in ipairs(world.plant) do
        ___plant[i] = v 
    end
    
    republica.util.file.save.text('./data/save/temp/map/block.json', cjson.encode(world.map.block))
    republica.util.file.save.text('./data/save/temp/map/fluid.json', cjson.encode(world.map.fluid))
    republica.util.file.save.text('./data/save/temp/map/height.json', cjson.encode(world.map.height))
    republica.util.file.save.text('./data/save/temp/map/temperature.json', cjson.encode(world.map.temperature))
    republica.util.file.save.text('./data/save/temp/world.json', cjson.encode(___world))
    republica.util.file.save.text('./data/save/temp/plant.json', cjson.encode(___plant))
end

-- main loop
function main()
    -- size up to 6 is safe, above 6 you can get buggy maps, default is 2
    -- layers up to 16 are safe, default is 8
    -- generate the world and map
    local world = republica.world(options.mapsize,options.mapquality,options.mappolish)
    
    io.flush()
    local id = io.read()

    newWorld(world);
    
    io.flush()
    print('ok')

    -- main loop
    while not exit do
        io.flush()
        frame(world)
    end
    exit = true
end

main()--