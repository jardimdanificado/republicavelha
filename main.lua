local republica = require("src.republicanova")
local exit = false

local options

function ytoz(vec3)
    return {x = vec3.x, y = vec3.z, z = vec3.y}
end

function y_rgba(index, min_val, max_val, invert)
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

function simplify(arr)
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
        local mm = republica.util.matrix.minmax(arr)
        b[i]={
            position = rl.new("Vector3",b[i].min.x-0.5+(b[i].max.x-b[i].min.x+1)/2,b[i].value-mm.min+1,b[i].min.y-0.5+(b[i].max.y-b[i].min.y+1)/2),
            size = rl.new("Vector3",(b[i].max.x-b[i].min.x+1),1,(b[i].max.y-b[i].min.y+1)),
            color = y_rgba(b[i].value,mm.min,mm.max),
            gridcolor = y_rgba(b[i].value,mm.min,mm.max,true)
        }
        table.insert(blocks,b[i])
    end

    return blocks;
end 

function teclado()
    if(rl.IsKeyPressed(rl.KEY_INSERT)) then
        options.redraw = true
        options.simple = (options.simple == false) and true or false
    elseif(rl.IsKeyPressed(rl.KEY_C)) then
        options.redraw = true
        options.dynadraw = (options.dynadraw == false) and true or false
    elseif(rl.IsKeyPressed(rl.KEY_F)) then
        options.redraw = true
        print(options.world.time)
    elseif(rl.IsKeyPressed(rl.KEY_G)) then
        options.redraw = true
        options.rendergrass = (options.rendergrass == false) and true or false
    elseif(rl.IsKeyPressed(rl.KEY_T)) then
        options.redraw = true
        options.renderterrain = (options.renderterrain == false) and true or false
    elseif(rl.IsKeyDown(rl.KEY_PAGE_UP)) then
        options.redraw = true
        options.camera.position.y = options.camera.position.y + 2
        rl.UpdateCamera(options.camera,0)
    elseif(rl.IsKeyDown(rl.KEY_PAGE_DOWN)) then
        options.redraw = true
        options.camera.position.y = options.camera.position.y - 2
        rl.UpdateCamera(options.camera,0)
    elseif(rl.IsKeyDown(rl.KEY_UP)) then
        options.redraw = true
        options.camera.target.y = options.camera.target.y + 2
        rl.UpdateCamera(options.camera,0)
    elseif(rl.IsKeyDown(rl.KEY_DOWN)) then
        options.redraw = true
        options.camera.target.y = options.camera.target.y - 2
        rl.UpdateCamera(options.camera,0)
    elseif(rl.IsKeyDown(rl.KEY_RIGHT)) then
        options.redraw = true
        options.camera.position = republica.util.math.rotate(options.camera.position,options.camera.target,-3)
        rl.UpdateCamera(options.camera,0)
        options.camera.target = {x=#options.world.map.height/2,y=options.camera.target.y,z=#options.world.map.height/2}
    elseif(rl.IsKeyDown(rl.KEY_LEFT)) then
        options.redraw = true
        options.camera.position = republica.util.math.rotate(options.camera.position,options.camera.target,3)
        rl.UpdateCamera(options.camera,0)
        options.camera.target = {x=#options.world.map.height/2,y=options.camera.target.y,z=#options.world.map.height/2}
    elseif(rl.IsKeyPressed(rl.KEY_SPACE)) then
        options.redraw = true
        options.paused = (options.paused == false) and true or false
        print("paused = " .. (options.paused and 'true' or 'false'))
    end
    
end

function start()
    --size up to 6 is safe, above 6 you can get buggy maps, default is 2
    --layers up to 16 are safe, default is 8
    options = 
    {
        screen = {x=800,y=450},
        title = 'republica nova',
        simple = true,
        paused = true,
        redraw = true,
        dynadraw = false, -- (optimization) this make the screen render only when a key is pressed
        rendergrass = true,
        renderterrain = true
    }
    local world = republica.world(2,16)
    rl.SetConfigFlags(rl.FLAG_WINDOW_RESIZABLE)
    rl.InitWindow(options.screen.x, options.screen.y, 'Republica Velha')
    rl.SetTargetFPS(0)
    options.rendertexture = rl.LoadRenderTexture(options.screen.x, options.screen.y)
    options.world = world
    options.camera = rl.new("Camera", {
        position = rl.new("Vector3", 0, #world.map.height, 0),
        target = rl.new("Vector3", #world.map.height/2, republica.util.matrix.average(world.map.height), #world.map.height/2),
        up = rl.new("Vector3", 0, 1, 0),
        fovy = 45,
        type = rl.CAMERA_PERSPECTIVE
    })

    local mm = republica.util.matrix.minmax(world.map.height)
    local simpler = simplify(world.map.height)
    print("\nmerged " .. #world.map.height*#world.map.height[1] .. ' blocks into ' .. #simpler .. ' blocks\n')

    while not rl.WindowShouldClose() do
        if(rl.IsWindowResized()) then
            --print(rl.GetScreenWidth(),rl.GetScreenHeight())
            rl.UnloadRenderTexture(options.rendertexture)
            options.screen.x = rl.GetScreenWidth()
            options.screen.y = rl.GetScreenHeight()
            options.rendertexture = rl.LoadRenderTexture(options.screen.x, options.screen.y)
        end
        teclado(options.camera)
        rl.BeginDrawing()
        if(options.redraw == true) then
            rl.BeginTextureMode(options.rendertexture)
            rl.ClearBackground(rl.RAYWHITE)
            rl.BeginMode3D(options.camera)
            if options.renderterrain then
                if(options.simple == true) then
                    for x = 1, #simpler do
                        rl.DrawCube(simpler[x].position,simpler[x].size.x,1,simpler[x].size.z,simpler[x].color)
                        rl.DrawCubeWires(simpler[x].position,simpler[x].size.x,1,simpler[x].size.z,simpler[x].gridcolor)
                    end
                else
                    for x = 1, #world.map.height do
                        for z = 1, #world.map.height do
                            rl.DrawCube({x=x,y=world.map.height[x][z],z=z},1,1,1,y_rgba(world.map.height[x][z],mm.min,mm.max))
                            rl.DrawCubeWires({x=x,y=world.map.height[x][z],z=z},1,1,1,y_rgba(world.map.height[x][z],mm.min,mm.max,true))
                        end
                    end
                end
            end
                
            for i, plant in ipairs(world.plant) do 
                if plant.type == 'seed' then
                    rl.DrawCube(ytoz(plant.position),0.5,0.5,0.5,rl.new("Color",0,0,0,125))
                elseif plant.specie == 'grass' then
                    if options.rendergrass then
                        rl.DrawCube(ytoz(plant.position),1,1,1,rl.GREEN)
                    end
                elseif republica.plants[plant.specie].size.max <=100 then
                    local tempposi = ytoz(plant.position)
                    tempposi.y = tempposi.y + 1
                    rl.DrawCube(tempposi,1,1,1,rl.YELLOW)
                elseif republica.util.string.includes(republica.plants[plant.specie].type,'tree') then
                    for i, trunk in ipairs(plant.trunk) do
                        rl.DrawCube(ytoz(trunk.position),1,1,1,rl.BROWN)
                    end
                    for i, branch in ipairs(plant.branch) do
                        rl.DrawCube(ytoz(branch.position),1,1,1,rl.RED)
                    end
                end
            end
            rl.EndMode3D()
            rl.EndTextureMode();
            if(options.dynadraw) then
                options.redraw = false
            end
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
        rl.DrawFPS(10, 10)
        rl.EndDrawing()
        if(options.paused == false) then
            world.frame(world)
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
            local execpath =  (sys == "Windows") and "./raylua_r.exe" or "./raylua_r"
            if(republica.util.file.exist(execpath) == false) then 
                setup(sys)
            end
            os.execute(
                    "zip -r compile.zip main.lua src \n" ..
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