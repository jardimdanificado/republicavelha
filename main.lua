package.path = package.path .. ";republicavelha/luatils/?.lua"
package.path = package.path .. ";republicavelha/luatils/init.lua"

-- Mouse Centered GUI
local mocegui = require("mocegui.init")

-- Republica's core
local republica = require("republicavelha.init")

-- republicavelha-raylib libs
local options = require('data.config')
local _render = require('render')
local teclado = require("teclado")

-- republicavelha-raylib vars
local exit = false

-- multithread for render
local function run_render(world,simplifiedterrain,watercube,republica,options,mocegui)
    while true do
        _render.render(world,simplifiedterrain,watercube,republica,options,mocegui)
        coroutine.yield()
    end
end

-- frame function
local function frame(world)
    if(options.paused == false) then
        world.frame(world)
    end
end

-- multithread for frame
local function run_frame(world)
    while true do
        frame(world)
        coroutine.yield()
    end
end



function options._debugger(world,customposition)
    -- this spawns the mocegui default debug window
    local debugpanel = mocegui.spawndebug(customposition)
    --debugpanel.text.new("pause\nfreeze\nrendergrass\nrenderterrain\nrenderwater\nrenderwires\npretty grass",{x=0,y=2+(mocegui.font.size*4)})
    --debugpanel.size.y = debugpanel.size.y + (mocegui.font.size+2)*6
    local function worldredraw()
        world.redraw = true
    end
    debugpanel.switch.new('paused',options,'paused',worldredraw)
    debugpanel.switch.new('freeze',options,'freeze',worldredraw)
    debugpanel.switch.new('rendergrass',options,'rendergrass',worldredraw)
    debugpanel.switch.new('renderterrain',options,'renderterrain',worldredraw)
    debugpanel.switch.new('renderwater',options,'renderwater',worldredraw)
    debugpanel.switch.new('renderwires',options,'renderwires',worldredraw)
    debugpanel.switch.new('prettygrass',options,'prettygrass',worldredraw)
    mocegui.newButton(debugpanel,function()
        print(mocegui.titlecache)
    end,{},'Console print test',nil,rl.WHITE)
end

-- main loop
function main()
    -- size up to 6 is safe, above 6 you can get buggy maps, default is 2
    -- layers up to 16 are safe, default is 8
    -- generate the world and map
    local world = republica.world(options.mapsize,options.mapquality,options.mappolish)
    
    -- set options redraw to world
    world.redraw = options.redraw
    options.redraw = nil

    -- checking options for raylib flags 
    if options.fullscreen then
        rl.SetConfigFlags(rl.FLAG_FULLSCREEN_MODE)
    end
    if options.vsync then
        rl.SetConfigFlags(rl.FLAG_VSYNC_HINT)
    end
    if options.runonbackground then
        rl.SetConfigFlags(rl.FLAG_WINDOW_ALWAYS_RUN)
    end
    if options.msaa then
        rl.SetConfigFlags(rl.FLAG_MSAA_4X_HINT)
    end
    if options.interlace then
        rl.SetConfigFlags(rl.FLAG_INTERLACED_HINT)
    end 
    if options.highdpi then
        rl.SetConfigFlags(rl.FLAG_WINDOW_HIGHDPI)
    end

    -- by default ive set window resizable
    rl.SetConfigFlags(rl.FLAG_WINDOW_RESIZABLE)

    -- creates window
    rl.InitWindow(options.screen.x, options.screen.y, options.title)

    -- sets target fps from options
    rl.SetTargetFPS(options.framerate)

    -- starts MoCeGUI
    mocegui.startup(options.screen,16)

    -- creates a render text, as we dont draw on the screen directly
    options.rendertexture = rl.LoadRenderTexture(options.screen.x, options.screen.y)
    
    -- sets the default camera
    options.camera = rl.new("Camera", {
        position = options.cameraposition,
        target = rl.new("Vector3", #world.map.height/2, republica.util.matrix.average(world.map.height), #world.map.height/2),
        up = rl.new("Vector3", 0, 1, 0),
        fovy = options.fov,
        type = rl.CAMERA_PERSPECTIVE,
    })
    options.cameraposition = nil
    
    -- gets min and max heights from de generated map
    local min,max = republica.util.matrix.minmax(world.map.height)
    
    -- reduces a huge amount of cubes into a few for faster rendering
    local simpler = _render.simplify_blocks(world.map.height)
    
    -- just a big blue cube, to be removed when fluids fully implemented
    local watercube = {{x=0+#world.map.height/2,y=0.5,z=#world.map.height[1]/2},#world.map.height,world.map.waterlevel*2,#world.map.height[1],rl.new("Color",0,190,125,185)}
    
    -- just a console message that logs the total amount of cubes and the reduced amount after simplification
    print("\nmerged " .. #world.map.height*#world.map.height[1] .. ' blocks into ' .. #simpler .. ' blocks\n')
    
    -- sets variables for multithreading
    local frame_co
    local render_co
    
    -- sets multithreading
    if(options.multithread) then
        frame_co = coroutine.create(run_frame)
        render_co = coroutine.create(run_render)
        coroutine.resume(frame_co, world)--pre start the routines
        coroutine.resume(render_co, world, simpler, watercube, republica, options, mocegui)
    end

    -- spawns extended debugger window
    options._debugger(world)

    --startup message
    local versiculo = 
[[1 No principio, Deus criou os ceus e a terra.
2 A terra estava informe e vazia; as trevas cobriam o
abismo e o Espirito de Deus pairava sobre as aguas. 
3 Deus disse: 'Faca-se a luz!' E a luz foi feita.
4 Deus viu que a luz era boa, e separou a luz das trevas.
5 Deus chamou a luz DIA, e as trevas NOITE. 
Sobreveio a tarde e depois a manha: foi o primeiro dia.
]]
.. [[                                            Genesis 1:1-5]]

    -- this set the message window that pops up then disapears
    local txtwin = mocegui.newTextWindow(nil,versiculo)
    txtwin.switch.new('paused',options,'paused')
    txtwin.position = {x=options.screen.x-txtwin.size.x,y=options.screen.y-txtwin.size.y-1}
    mocegui.timeout(txtwin,7)
    
    
    -- main loop
    while not rl.WindowShouldClose() do
        
        -- keyboard function
        teclado(world,republica,options)

        -- main loop condition, checks if is multithreaded or not then do 
        if(options.multithread) then
            if coroutine.status(frame_co) == "suspended" then
                coroutine.resume(frame_co, world)
            end
            if coroutine.status(render_co) == "suspended" and world.time % options.slowrender == 0 then
                coroutine.resume(render_co, world,simpler,watercube,republica,options,mocegui)
            end
        else
            frame(world)
            _render.render(world,simpler,watercube,republica,options,mocegui)
        end

    end
    exit = true
    rl.CloseWindow()
end

main()--