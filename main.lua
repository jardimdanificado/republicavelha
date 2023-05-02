local republica = require("src.republicanova")
local exit = false
local options = require('data.config')

local function ytoz(vec3)
    return {x = vec3.x, y = vec3.z, z = vec3.y}
end

local function y_rgba(index, min_val, max_val, invert)
    local range = max_val - min_val
    local val = (index - min_val) / range
    local r = math.floor(255 * val)
    local b = math.floor(255 * (1 - val))
    local g = 128
    if(invert) then
        b,r,g = g,r,b
    end
    return rl.new("Color",r,g,b,255)
end

local function simplify(arr)
    local b = {}
    local dY = false
    local chk = {}
    for i=1,#arr do
        chk[i]={}
        for j=1,#arr[1] do chk[i][j]=false end
    end
    for x=1,#arr do
        for y=1,#arr[1] do
            if chk[x][y] then goto continue else
                local v = arr[x][y]
                local cB = {min={x=x,y=y},max={x=x,y=y},value=v}
                local cX = 0
                local exit = false
                while not exit do
                    if arr[x+cX] and arr[x+cX][y]==v then chk[x+cX][y]=true cX=cX+1 else exit=true end
                end
                exit = false
                local cY = 0
                while not exit and y+cY<#arr[1] do
                    if arr[x][y+cY]==v then
                        local cks={}
                        for xx=0,cX-1 do for yy=0,cY-1 do table.insert(cks,(arr[cB.max.x+xx][cB.max.y+yy]==v) and 1 or 0) end end
                        if republica.util.array.sum(cks)==#cks then
                            for xx=0,cX-1 do for yy=0,cY-1 do chk[cB.max.x+xx][cB.max.y+yy]=true end end
                            cY=cY+1
                        else exit=true end
                    else exit=true end
                end
                cB.max.y = cB.max.y + cY - 1
                cB.max.x = cB.max.x + cX - 1
                exit=false
                table.insert(b, cB)
            end
            ::continue::
        end
    end

    local blocks = {}
    for i=1,#b do 
        local min,max = republica.util.matrix.minmax(arr)
        b[i]={
            position = rl.new("Vector3",
            b[i].min.x-0.5+(b[i].max.x-b[i].min.x+1)/2,
            b[i].value-min+1,
            b[i].min.y-0.5+(b[i].max.y-b[i].min.y+1)/2),
            size = rl.new("Vector3",(b[i].max.x-b[i].min.x+1),1,(b[i].max.y-b[i].min.y+1)),
            color = y_rgba(b[i].value,min,max),
            gridcolor = y_rgba(b[i].value,min,max,true)
        }
        b[i].gridcolor.a = 200
        table.insert(blocks,b[i])
    end

    return blocks;
end 

local function render(world,simplifiedterrain,watercube)
    if(rl.IsWindowResized()) then
        rl.UnloadRenderTexture(options.rendertexture)
        options.screen.x = rl.GetScreenWidth()
        options.screen.y = rl.GetScreenHeight()
        options.rendertexture = rl.LoadRenderTexture(options.screen.x, options.screen.y)
        world.redraw=true
    end
    
    rl.BeginDrawing()
    if(world.redraw == true and options.freeze == false) then
        rl.BeginTextureMode(options.rendertexture)
        rl.ClearBackground(rl.RAYWHITE)
        rl.BeginMode3D(options.camera)
        if options.renderterrain then
            if(options.simple == true) then
                for x = 1, #simplifiedterrain do
                    if (options.renderwires) then
                        rl.DrawCubeWires(simplifiedterrain[x].position,simplifiedterrain[x].size.x,1,simplifiedterrain[x].size.z,simplifiedterrain[x].gridcolor)
                    end
                    rl.DrawCube(simplifiedterrain[x].position,simplifiedterrain[x].size.x,1,simplifiedterrain[x].size.z,simplifiedterrain[x].color)
                    
                end
            else
                for x = 1, #world.map.height do
                    for z = 1, #world.map.height do
                        rl.DrawCube({x=x,y=world.map.height[x][z],z=z},1,1,1,y_rgba(world.map.height[x][z],min,max))
                        if (options.renderwires) then
                            rl.DrawCubeWires({x=x,y=world.map.height[x][z],z=z},1,1,1,y_rgba(world.map.height[x][z],min,max,true))
                        end
                    end
                end
            end
        end
            
        for i, plant in ipairs(world.plant) do 
            if plant.type == 'seed' then
                rl.DrawCube(ytoz(plant.position),0.5,1.01,0.5,{r=0,g=255,b=0,a=55})
            elseif plant.specie == 'grass' then
                if options.rendergrass then
                    if(options.prettygrass == false) then
                        local temp = ytoz(plant.position)
                        temp.y = temp.y + 0.6
                        rl.DrawPlane(temp,{x=1,y=1},{r=100,g=255,b=50,a=95})
                    else
                        rl.DrawCube(ytoz(plant.position),republica.util.random(1.111,1.333),republica.util.random(1.111,1.333),republica.util.random(1.111,1.333),rl.new("Color",100,republica.util.random(200,255),50,republica.util.random(55,95)))
                    end
                end
            elseif republica.plants[plant.specie].size.max <=100 then
                local tempposi = ytoz(plant.position)
                tempposi.y = tempposi.y + 1
                rl.DrawCube(tempposi,1,1,1,rl.YELLOW)
                if(options.renderwires) then
                    rl.DrawCubeWires(ytoz(plant.position),1,1,1,rl.RED)
                end
            elseif republica.util.string.includes(republica.plants[plant.specie].type,'tree') then
                for i, trunk in ipairs(plant.trunk) do
                    rl.DrawCube(ytoz(trunk.position),1,1,1,{r=59,g=50,b=0,a=255})
                    if(options.renderwires) then
                        rl.DrawCubeWires(ytoz(trunk.position),1,1,1,{r=0,g=0,b=0,a=55})
                    end
                end
                for i, branch in ipairs(plant.branch) do
                    rl.DrawCube(ytoz(branch.position),1,1,1,{r=85,g=105,b=0,a=245})
                    if(options.renderwires) then
                        rl.DrawCubeWires(ytoz(branch.position),1,1,1,{r=0,g=0,b=0,a=55})
                    end
                end
                for i, root in ipairs(plant.root) do
                    rl.DrawCube(ytoz(root.position),1,1,1,{r=240,g=235,b=200,a=255})
                    if(options.renderwires) then
                        rl.DrawCubeWires(ytoz(root.position),1,1,1,{r=0,g=0,b=0,a=50})
                    end
                end
            end
        end
        if options.renderwater then
            rl.DrawCube(republica.util.array.unpack(watercube))
        end
        rl.EndMode3D()
        rl.EndTextureMode();
        world.redraw = false
    end
    rl.DrawTexturePro(
        options.rendertexture.texture,
        {
            x=0,
            y=0,
            width=options.screen.x,
            height=options.screen.y*-1
        },
        {x=0,y=0,width=options.screen.x,height=options.screen.y},
        {x=0,y=0},
        0,
        rl.WHITE
    );
    if options.fpscounter then
        rl.DrawFPS(10, 10)
    end
    
    rl.EndDrawing() 
end

local function run_render(world,simplifiedterrain,watercube)
    
    while true do
        
        render(world,simplifiedterrain,watercube)
        coroutine.yield()
    end
end

local function frame(world)
    if(options.paused == false) then
        world.frame(world)
    end
end

local function run_frame(world)
    while true do
        frame(world)
        coroutine.yield()
    end
end

local function teclado(world)
    if(rl.IsKeyPressed(rl.KEY_C)) then
        world.redraw = true
        options.freeze = (options.freeze == false) and true or false
        print (options.freeze)
    elseif(rl.IsKeyPressed(rl.KEY_P)) then
        world.redraw = true
        options.prettygrass = (options.prettygrass == false) and true or false
    elseif(rl.IsKeyPressed(rl.KEY_W)) then
        world.redraw = true
        options.renderwater = (options.renderwater == false) and true or false
    elseif(rl.IsKeyPressed(rl.KEY_F)) then
        world.redraw = true
        print(world.time)
    elseif(rl.IsKeyPressed(rl.KEY_R)) then
        world.redraw = true
        options.renderwires = (options.renderwires == false) and true or false
    elseif(rl.IsKeyPressed(rl.KEY_G)) then
        world.redraw = true
        options.rendergrass = (options.rendergrass == false) and true or false
    elseif(rl.IsKeyPressed(rl.KEY_T)) then
        world.redraw = true
        options.renderterrain = (options.renderterrain == false) and true or false
    elseif(rl.IsKeyDown(rl.KEY_PAGE_UP)) then
        world.redraw = true
        options.camera.position.y = options.camera.position.y + 2
        rl.UpdateCamera(options.camera,0)
    elseif(rl.IsKeyDown(rl.KEY_PAGE_DOWN)) then
        world.redraw = true
        options.camera.position.y = options.camera.position.y - 2
        rl.UpdateCamera(options.camera,0)
    elseif(rl.IsKeyDown(rl.KEY_UP)) then
        world.redraw = true
        options.camera.target.y = options.camera.target.y + 2
        rl.UpdateCamera(options.camera,0)
    elseif(rl.IsKeyDown(rl.KEY_DOWN)) then
        world.redraw = true
        options.camera.target.y = options.camera.target.y - 2
        rl.UpdateCamera(options.camera,0)
    elseif(rl.IsKeyDown(rl.KEY_RIGHT)) then
        world.redraw = true
        options.camera.position = republica.util.math.rotate(options.camera.position,options.camera.target,-3)
        rl.UpdateCamera(options.camera,0)
        if(not rl.IsKeyDown(rl.KEY_LEFT_SHIFT) and not rl.IsKeyDown(rl.KEY_RIGHT_SHIFT)) then
            options.camera.target = {x=#world.map.height/2,y=options.camera.target.y,z=#world.map.height/2}
        end
    elseif(rl.IsKeyDown(rl.KEY_LEFT)) then
        world.redraw = true
        options.camera.position = republica.util.math.rotate(options.camera.position,options.camera.target,3)
        rl.UpdateCamera(options.camera,0)
        if(not rl.IsKeyDown(rl.KEY_LEFT_SHIFT) and not rl.IsKeyDown(rl.KEY_RIGHT_SHIFT)) then
            options.camera.target = {x=#world.map.height/2,y=options.camera.target.y,z=#world.map.height/2}
        end
    elseif(rl.IsKeyDown(rl.KEY_PERIOD)) then
        world.redraw = true
        options.camera.fovy = options.camera.fovy - 1
        rl.UpdateCamera(options.camera,0)
    elseif(rl.IsKeyDown(rl.KEY_COMMA)) then
        world.redraw = true
        options.camera.fovy = options.camera.fovy + 1
        rl.UpdateCamera(options.camera,0)
    elseif(rl.IsKeyPressed(rl.KEY_SPACE)) then
        world.redraw = true
        options.paused = (options.paused == false) and true or false
        print("paused = " .. (options.paused and 'true' or 'false'))
    end
end

function start()
    --size up to 6 is safe, above 6 you can get buggy maps, default is 2
    --layers up to 16 are safe, default is 8
    local world = republica.world(options.mapsize,options.mapquality,options.mappolish)
    world.redraw = options.redraw
    options.redraw = nil
    
    --rl.SetConfigFlags(rl.FLAG_MSAA_4X_HINT)

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
    rl.SetConfigFlags(rl.FLAG_WINDOW_RESIZABLE)
    rl.InitWindow(options.screen.x, options.screen.y, options.title)
    rl.SetTargetFPS(options.framerate)
    options.rendertexture = rl.LoadRenderTexture(options.screen.x, options.screen.y)
    options.camera = rl.new("Camera", {
        position = options.cameraposition,
        target = rl.new("Vector3", #world.map.height/2, republica.util.matrix.average(world.map.height), #world.map.height/2),
        up = rl.new("Vector3", 0, 1, 0),
        fovy = options.fov,
        type = rl.CAMERA_PERSPECTIVE,
    })
    options.cameraposition = nil
    local min,max = republica.util.matrix.minmax(world.map.height)
    local simpler = simplify(world.map.height)
    local watercube = {{x=0+#world.map.height/2,y=0.5,z=#world.map.height[1]/2},#world.map.height,world.map.waterlevel*2,#world.map.height[1],rl.new("Color",0,190,125,185)}
    print("\nmerged " .. #world.map.height*#world.map.height[1] .. ' blocks into ' .. #simpler .. ' blocks\n')
    local frame_co
    local render_co
    if(options.multithread) then
        frame_co = coroutine.create(run_frame)
        render_co = coroutine.create(run_render)
        coroutine.resume(frame_co, world)--pre start the routines
        coroutine.resume(render_co, world, simpler, watercube)
    end
    while not rl.WindowShouldClose() do
        teclado(world)
        if(options.multithread) then
            if coroutine.status(frame_co) == "suspended" then
                coroutine.resume(frame_co, world)
            end
            if coroutine.status(render_co) == "suspended" and world.time % options.slowrender == 0 then
                coroutine.resume(render_co, world,simpler,watercube)
            end
        else
            frame(world)
            render(world,simpler,watercube)
        end
    end
    exit = true
    rl.CloseWindow()
end

function setup(sys)
    if sys == "Windows" then    
        os.execute("curl -s https://api.github.com/repos/TSnake41/raylib-lua/releases/latest | grep \"browser_download_url.*zip\" | cut -d : -f 2,3 | tr -d \\\" | wget -qi - \n" ..
        "unzip -q raylua-*.zip")
    else
        os.execute(
            "rm raylua_* raylib-lua -rf \n" ..
            "git clone https://github.com/TSnake41/raylib-lua --depth 1 \n" ..
            "cd raylib-lua \n" ..
            "git submodule init \n" ..
            "git submodule update \n" ..
            "make  &&  cd .. \n" .. 
            "cp ./raylib-lua/raylua_* . \n")
    end

end

function setAndGo(sys)
    local execpath =  (sys == "Windows") and "./raylua_s.exe" or "./raylua_s"
    if(republica.util.file.exist(execpath) == false) then 
        setup(sys)
    end
    os.execute(execpath .. ' main.lua')
end

function main()
    local ffi = require "ffi"
    local sys = ffi.os
    if(arg[1] ~= nil and arg[1] ~= 'main.lua') then
        if(arg[1] == 'compile') then
            local extension = (sys == "Windows") and '.exe' or '.appimage'
            local execpath =  (sys == "Windows") and "./raylua_r.exe" or "./raylua_e"
            if(republica.util.file.exist(execpath) == false) then 
                setup(sys)
            end
            os.execute(
                    "zip -r compile.zip main.lua src data \n" ..
                    execpath .. " compile.zip &&  rm compile.zip &&  mv compile_out republicanova" .. extension)
            os.exit()
        elseif(arg[1] == 'setup') then
            setup(sys)
            return
        elseif(rl == nil) then
            setAndGo(sys)
        else
            start()
        end
    else
        if(rl == nil) then
            setAndGo(sys)
        else
            start()
        end
    end
end

main()--