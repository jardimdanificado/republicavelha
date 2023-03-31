local republica = require("src.republicanova")

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


function main()
    local screenWidth = 800
    local screenHeight = 450
    --size up to 6 is safe, above 6 you can get buggy maps, default is 2
    --layers up to 16 are safe, default is 8
    local terrain = republica.terrain(2,16)
    local heightmap
    local simplerender = true
    terrain,heightmap = terrain[1],terrain[2]
    rl.SetConfigFlags(rl.FLAG_VSYNC_HINT)
    rl.InitWindow(screenWidth, screenHeight, "republica nova")
    
    local camera = rl.new("Camera", {
        position = rl.new("Vector3", 0, #heightmap, 0),
        target = rl.new("Vector3", #heightmap/2, republica.util.matrix.average(heightmap), #heightmap/2),
        up = rl.new("Vector3", 0, 1, 0),
        fovy = 45,
        type = rl.CAMERA_PERSPECTIVE
    })

    local mm = republica.util.matrix.minmax(heightmap)
    local simpler = simplify(heightmap)
    print("\nmerged " .. #heightmap*#heightmap[1] .. ' blocks into ' .. #simpler .. ' blocks\n')

    while not rl.WindowShouldClose() do
        rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)
        if(rl.IsKeyPressed(rl.KEY_INSERT)) then
            simple = simple == false and true or false
        end
        rl.BeginMode3D(camera)
        if(simple == true) then
            for x = 1, #simpler do
                rl.DrawCube(simpler[x].position,simpler[x].size.x,1,simpler[x].size.z,simpler[x].color)
                rl.DrawCubeWires(simpler[x].position,simpler[x].size.x,1,simpler[x].size.z,simpler[x].gridcolor)
            end
        else
            for x = 1, #heightmap do
                for z = 1, #heightmap do
                    rl.DrawCube({x=x,y=heightmap[x][z],z=z},1,1,1,y_rgba(heightmap[x][z],mm.min,mm.max))
                    rl.DrawCubeWires({x=x,y=heightmap[x][z],z=z},1,1,1,y_rgba(heightmap[x][z],mm.min,mm.max,true))
                end
            end
        end

        rl.EndMode3D()

        rl.DrawFPS(10, 10)
        rl.EndDrawing()
    end
    
    rl.CloseWindow()
end

if(arg[1] == 'setup') then
    os.execute("rm -rf raylib-lua")
    os.execute("git clone https://github.com/TSnake41/raylib-lua --depth 1")
    os.execute("cd raylib-lua")
    os.execute("git submodule init")
    os.execute("git submodule update")
    os.execute("make && cd ..")
else
    main()
end