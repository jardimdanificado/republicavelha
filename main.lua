local republica = require("src.republicanova")
local exit = false

local options

function grassify(world)
    for  x = 1, #world.map.height do
        for y = 1, #world.map.height[1] do
            world.plant.spawn(--//this spawns a grass seed at each xy position
                world,
                'grass',
                {x=x,y=y,z=#world.map.block[1][1]}
            )

            if(x>1 and y>1 and x<=#world.map.height and y<=#world.map.height[1]) then
                if(republica.util.roleta(50,math.random(1,50)) == 2) then --if roleta == 1
                    local temptype = Object.keys(republica.plants)
                    [
                        republica.util.roleta(
                            this,
                            republica.util.array.random(
                                1,
                                10,
                                util.array.keys(republica.plants)
                            )
                        )
                    ]
                    if(temptype ~= 'grass') then
                        world.plant.spawn(--this spawns a random seed at the xy position
                            'seed', 
                            temptype,
                            'idle', 
                            {x=x,y=y,z=#world.map.block[1][1]}, 
                            100, 
                            100
                        )
                    end
                end
            end
        end
    end
    return world;
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
        options.simple = (options.simple == false) and true or false
    elseif(rl.IsKeyPressed(rl.KEY_F)) then
        print(options.world.time)
    elseif(rl.IsKeyPressed(rl.KEY_G)) then
        print(options.world.plant[5].germination)
    elseif(rl.IsKeyDown(rl.KEY_PAGE_UP)) then
        options.camera.position.y = options.camera.position.y + 2
        rl.UpdateCamera(options.camera,0)
    elseif(rl.IsKeyDown(rl.KEY_PAGE_DOWN)) then
        options.camera.position.y = options.camera.position.y - 2
        rl.UpdateCamera(options.camera,0)
    elseif(rl.IsKeyDown(rl.KEY_UP)) then
        options.camera.target.y = options.camera.target.y + 2
        rl.UpdateCamera(options.camera,0)
    elseif(rl.IsKeyDown(rl.KEY_DOWN)) then
        options.camera.target.y = options.camera.target.y - 2
        rl.UpdateCamera(options.camera,0)
    elseif(rl.IsKeyDown(rl.KEY_RIGHT)) then
        options.camera.position = republica.util.math.rotate(options.camera.position,options.camera.target,-3)
        rl.UpdateCamera(options.camera,0)
        options.camera.target = {x=#options.world.map.height/2,y=options.camera.target.y,z=#options.world.map.height/2}
    elseif(rl.IsKeyDown(rl.KEY_LEFT)) then
        options.camera.position = republica.util.math.rotate(options.camera.position,options.camera.target,3)
        rl.UpdateCamera(options.camera,0)
        options.camera.target = {x=#options.world.map.height/2,y=options.camera.target.y,z=#options.world.map.height/2}
    elseif(rl.IsKeyPressed(rl.KEY_SPACE)) then
        options.paused = (options.paused == false) and true or false
        print("paused = " .. (options.paused and 'true' or 'false'))
    end
end

function start()
    local world = republica.world(2,16)
    world = grassify(world)
    options = 
    {
        world = world,
        camera = rl.new("Camera", {
            position = rl.new("Vector3", 0, #world.map.height, 0),
            target = rl.new("Vector3", #world.map.height/2, republica.util.matrix.average(world.map.height), #world.map.height/2),
            up = rl.new("Vector3", 0, 1, 0),
            fovy = 45,
            type = rl.CAMERA_PERSPECTIVE
        }),
        screen = {x=800,y=450},
        title = 'republica nova',
        simple = true,
        paused = true
    }
    --size up to 6 is safe, above 6 you can get buggy maps, default is 2
    --layers up to 16 are safe, default is 8
    rl.SetConfigFlags(rl.FLAG_VSYNC_HINT)
    rl.InitWindow(options.screen.x, options.screen.y, options.title)
    --print (world.map.height[1][1])
    local mm = republica.util.matrix.minmax(world.map.height)
    local simpler = simplify(world.map.height)
    print("\nmerged " .. #world.map.height*#world.map.height[1] .. ' blocks into ' .. #simpler .. ' blocks\n')

    while not rl.WindowShouldClose() do
        rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)
        rl.BeginMode3D(options.camera)
        teclado(options.camera)
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
        if(options.paused == false) then
            world.frame(world)
        end
        rl.EndMode3D()

        rl.DrawFPS(10, 10)
        rl.EndDrawing()
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
            "make  and  cd .. \n" .. 
            "mv ./raylib-lua/raylua_* . \n" ..
            "rm -rf raylib-lua \n")
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
                    execpath .. " compile.zip  and  rm -f compile.zip  and  mv compile_out republicanova" .. extension)
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