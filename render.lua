local util = require('mocegui.luatils.init')

local render_module = {}

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


function render_module.simplify_blocks(arr)
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
                        if util.array.sum(cks)==#cks then
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
        local min,max = util.matrix.minmax(arr)
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

function render_module.render(world,simplifiedterrain,watercube,republica,options,mocegui)
    if(rl.IsWindowResized()) then
        rl.UnloadRenderTexture(options.rendertexture)
        options.screen.x = rl.GetScreenWidth()
        options.screen.y = rl.GetScreenHeight()
        options.rendertexture = rl.LoadRenderTexture(options.screen.x, options.screen.y)
        world.redraw=true
    end
    mocegui.update()
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
                        rl.DrawCube(ytoz(plant.position),util.random(1.111,1.333),util.random(1.111,1.333),util.random(1.111,1.333),rl.new("Color",100,util.random(200,255),50,util.random(55,95)))
                    end
                end
            elseif republica.plants[plant.specie].size.max <=100 then
                local tempposi = ytoz(plant.position)
                tempposi.y = tempposi.y + 1
                rl.DrawCube(tempposi,1,1,1,rl.YELLOW)
                if(options.renderwires) then
                    rl.DrawCubeWires(ytoz(plant.position),1,1,1,rl.RED)
                end
            elseif util.string.includes(republica.plants[plant.specie].type,'tree') then
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
            rl.DrawCube(util.array.unpack(watercube))
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
    rl.DrawTexturePro(
        mocegui.bakeframe(),
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
    
    rl.EndDrawing() 
end

return render_module
