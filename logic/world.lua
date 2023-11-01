local util = require("logic.luatils.init")
local Terrain = require("logic.terrain")
local types = require("logic.types")
local blocks = types.blocks
local plants = types.plants

local function getHourOfDay(totalSeconds) 
    return math.floor(totalSeconds / 3600) % 24
end

local function getMinuteOfDay(totalSeconds) 
    return math.floor((totalSeconds % 3600) / 60)
end

local function getSecondOfDay(totalSeconds) 
    return totalSeconds % 60
end

local function getSunIntensity(minHour, maxHour, seconds) 
    local hours = (seconds / 3600) % 24 -- convert to hours and wrap around 24 hours
    local hourRange = maxHour - minHour
    local currentHour = (hours + 6) % 24 -- add 6 to offset for range from 6am to 6pm
    local intensity = (currentHour < minHour or currentHour > maxHour) and 0 or
                        (currentHour == (minHour + hourRange / 2)) and 100 or
                        (currentHour < (minHour + hourRange / 2)) and
                        ((currentHour - minHour) / (hourRange / 2) * 100) or
                        ((maxHour - currentHour) / (hourRange / 2) * 100)
    return intensity
end

local function grassify(world)
    for  x = 1, #world.map.height do
        for y = 1, #world.map.height[x] do
            if(world.map.height[x][y] > world.map.waterlevel+1) then
                world.plant.spawn(-- this spawns a grass seed at each xy position
                world,
                'grass',
                {x=x,y=y,z=#world.map.block[1][1]}
                )--]]
                if(util.random(1,100) == 1) then -- random seeds start here
                    local temptype = util.array.keys(plants)[util.random(1,util.len(plants))]
                    if(temptype ~= 'grass') then
                        world.plant.spawn(-- this spawns a random seed at the xy position
                            world,
                            temptype,
                            {x=x,y=y,z=#world.map.block[1][1]}
                        )
                    end
                end
            end
        end
    end
    return world
end

-------------------------------------------------
--COLLISION
-------------------------------------------------

local function Collision(blockmap)
    local collision = {}
    collision.colliders = {}
    collision.map = util.array.map(blockmap,function(value,x)
        return (
                util.array.map(value,function(value,y)
                    return (
                            util.array.map(value,function(value,z)
                                local result = 0
                                if(blocks[value].solid == true) then
                                    result = 100
                                end
                                return (result)
                            end)
                    )
                end)
        )
    end)
    
    collision.move = function(collider,newPosition)
        local position = collider.position
        local value = collider.value
        local old = collision.map[position.x][position.y][position.z]
        local new = collision.map[newPosition.x][newPosition.y][newPosition.z]
        old = old - value
        new = new + value
        position.x = newPosition.x
        position.y = newPosition.y
        position.z = newPosition.z
    end

    collision.check=function(position,value,reduce)--returns true if no collider in the specified position, of if the colliders in the position are below value
        value = value or 75
        reduce = reduce or 0
        if(
            position.x <1 or 
            position.y <1 or 
            position.z <1 or 
            position.x >#collision.map or 
            position.y >#collision.map[1] or 
            position.z >#collision.map[1][1]
        ) then
            return false
        elseif(collision.map[position.x][position.y][position.z] > value+reduce) then
            return false
        else
            return true
        end
    end
    return collision
end

-------------------------------------------------
--MAP
-------------------------------------------------

local function Map(multiHorizontal,quality,polishment)--create the map
    polishment = polishment or 2
    local block,heightmap = util.array.unpack(Terrain(multiHorizontal,quality,polishment))
    local temperature = util.matrix.new(#block,#block[1],#block[1][1],29)
    local waterlevel = util.matrix.average(heightmap)
    local fluid = {}
    for x = 1, #block, 1 do
        fluid[x] = {}
        for y = 1, #block[1], 1 do
            fluid[x][y] = {}
            for z = 1, #block[1][1], 1 do
                if z < waterlevel then
                    if block[x][y][z] == 1 then--here block[1] is air
                        fluid[x][y][z] = 1 --fluids[1] is water
                    end
                else
                    fluid[x][y][z] = 0 --fluids[0] is nothing
                end
            end
        end
    end
    return {
        block = block,
        height = heightmap,
        fluid = fluid,
        temperature = temperature,
        collision = Collision(block),
        waterlevel = waterlevel,
        size = {#block,#block[1],#block[1][1]}
    }
end

local fluidpathfinder = function(matrix, x, y, z)
    -- Define the default numpad pattern
    local directions = {
        {x = -1, y = -1, z = 0}, -- 7
        {x = 0, y = -1, z = 0}, -- 8
        {x = 1, y = -1, z = 0}, -- 9
        {x = -1, y = 0, z = 0}, -- 4
        {x = 1, y = 0, z = 0}, -- 6
        {x = -1, y = 1, z = 0}, -- 1
        {x = 0, y = 1, z = 0}, -- 2
        {x = 1, y = 1, z = 0}, -- 3
    }
    local queue = {{x = x, y = y, z = z}}
    local visited = {[z]={[y]={[x]=true}}}
    local parent = {}

    while #queue > 0 do
        local current = table.remove(queue, 1)

        for i, dir in ipairs(directions) do
            local next_x = current.x + dir.x
            local next_y = current.y + dir.y
            local next_z = current.z + dir.z

            -- Skip over the starting position
            if next_x == x and next_y == y and next_z == z then
                goto continue
            end

            -- Check if the next position is out of bounds
            if next_x < 1 or next_x > #matrix[1][1] or 
               next_y < 1 or next_y > #matrix[1] or 
               next_z < 1 or next_z > #matrix then
                goto continue
            end

            -- Check if the next position has already been visited
            if visited[next_z][next_y][next_x] then
                goto continue
            end

            -- Check if the next position contains a 1
            if matrix[next_z][next_y][next_x] == 1 then
                -- Reconstruct the path to the nearest 1
                local path = {}
                local current_pos = {x = next_x, y = next_y, z = next_z}
                while current_pos.x ~= x or current_pos.y ~= y do
                    local p = parent[current_pos.z][current_pos.y][current_pos.x]
                    table.insert(path, p)
                    current_pos.x = current_pos.x - directions[p].x
                    current_pos.y = current_pos.y - directions[p].y
                    current_pos.z = current_pos.z - directions[p].z
                end
                return path
            end

            -- Add the next position to the queue and mark it as visited
            table.insert(queue, {x = next_x, y = next_y, z = next_z})
            visited[next_z][next_y][next_x] = true
            parent[next_z][next_y][next_x] = i

            ::continue::
        end
    end

    -- If there is no path to a 1, return an empty array
    return {}
end



local Life = 
{
    Spawn =
    {
        Seed = function(world,specie, status, position, quality , condition , decayRate)
            specie = specie or 'caju'
            status = status or 'idle'
            position = position or {x=1,y=1,z=1}
            quality = quality or 100
            condition = condition or 100
            decayRate = decayRate or 2592000
            table.insert(world.plant,types.seed(specie, status, world.time, position, quality, condition, decayRate))
        end,
        Plant = function(world,specie, status, position, quality, condition)
            specie = specie or 'caju'
            status = status or 'idle'
            position = position or {x=1,y=1,z=1}
            quality = quality or 100
            condition = condition or 100
            local newobject = types.plant(specie, status, world.time, position, quality, condition, 0)
            table.insert(world.plant,newobject)
            table.insert(world.map.plant[position.x][position.y][position.z],newobject)
        end,
        Creature = function(world,specie, gender, status, position, quality, condition)
            specie = specie or 'human'
            status = status or 'idle'
            gender = gender or 'female'
            position = position or {x=1,y=1,z=1}
            quality = quality or 100
            condition = condition or 100
            table.insert(world.creature,types.creature(specie,gender,status,world.time,position,quality,condition))
        end
    }
}

local function growLeaf(plant)
    plant.leaf = plant.leaf + 1
    return plant
end

local directions = --based on keypad
{
    {x= -1, y= 1,z=0}, --1
    {x= 0, y= 1,z=0},  --2
    {x= 1, y= 1,z=0},  --3
    {x= -1, y= 0,z=0}, --4
    {x= 0, y= 0,z=0},  --5
    {x= 1, y= 0,z=0},  --6
    {x= -1, y= -1,z=0}, --7
    {x= 0, y= -1,z=0}, --8
    {x= 1, y= -1,z=0} --9
}

local function growBranch(world,plant,time)
    local height = #plant.trunk ~= 0 and plant.trunk[#plant.trunk].position.z - plant.position.z or 0
    if(height*10 > plants[plant.specie].size.min/40 and #plant.branch < plants[plant.specie].size.max/12) then
        local lposi = directions[util.roleta(0,1,0,1,0,1,0,1,0)]
        lposi.z = util.random(0,1)
        local numb = util.random((#plant.branch/2)*-1,#plant.branch)
        local pposi = plant.position
        if(plant.branch[numb] ~= nil) then 
            pposi = plant.branch[numb].position 
        elseif(#plant.trunk > 0) then
            pposi = plant.trunk[util.random(1,#plant.trunk)].position
        end
        if pposi.z-math.floor((plants[plant.specie].size.max/100)/2.5) > plant.position.z and world.map.collision.check(util.math.vec3add(lposi,pposi),100) then         
            table.insert(plant.branch,types.branch(plant.specie,'idle',time,util.math.vec3add(lposi,pposi),plant.quality,plant.condition))
            table.insert(world.map.collision.colliders,types.collider(lposi,100))
            world.redraw = true
        end
    end
    return plant
end

local function growTrunk(world,plant,time)
    local height = #plant.trunk ~= 0 and plant.trunk[#plant.trunk].position.z - plant.position.z or 0
    if(height < (plants[plant.specie].size.max/100)) then
        local lposi = directions[util.roleta(0,1,0,1,2,1,0,1,0)]
        lposi.z = (lposi.x == 0 and lposi.x == 0) and 1 or 0
        local pposi = #plant.trunk ~= 0 and plant.trunk[#plant.trunk].position or plant.position
        local randomnumber=0
        if #plant.trunk > 1 and world.time % 29 == 0 then 
            randomnumber = util.random(-1*math.floor(#plant.trunk),#plant.trunk)
            if(randomnumber>1)then
                pposi = plant.trunk[randomnumber].position
            end
        end
        if world.map.collision.check(util.math.vec3add(lposi,pposi),75) then
            table.insert(plant.trunk,types.trunk(plant.specie,'idle',time,util.math.vec3add(lposi,pposi),plant.quality,plant.condition))
            table.insert(world.map.collision.colliders,types.collider(lposi,100))
            world.redraw = true
        end
    end
    return plant
end

local function growRoot(world,plant,time)
    if(#plant.root < (plants[plant.specie].size.max/72)) then
        local lposi = directions[util.roleta(0,1,0,1,2,1,0,1,0)]
        lposi.z = 0
        local pposi = #plant.root ~= 0 and plant.root[#plant.root].position or plant.position
        local randomnumber = 0 
        if #plant.root > 1 then 
            lposi.z = -1
            randomnumber = util.random(-1*math.floor(#plant.root/2),#plant.root)
            if randomnumber>1 then
                pposi = plant.root[randomnumber].position
            end
        end
        local posit = util.math.vec3add(lposi,pposi)
        if world.map.collision.check(util.math.vec3add(lposi,pposi),75,100) then
            table.insert(plant.root,types.root(plant.specie,'idle',time,util.math.vec3add(lposi,pposi),plant.quality,plant.condition))
            table.insert(world.map.collision.colliders,types.collider(lposi))
            --world.redraw = true
        end
    end
    return plant
end

local function plantFrame(world,plant)
    if(world.time % 13 == 0) then
        growRoot(world,plant,world.time)
        if(plant.leaf < plants[plant.specie].leaf.max) then
            growLeaf(plant)
        end
    end
    if plants[plant.specie].type == 'fruit tree' then
        local lastTrunkPosition = plant.position
        if(#plant.trunk > 0) then
            lastTrunkPosition = plant.trunk[#plant.trunk].position
            if(world.time % util.math.limit(plants[plant.specie].time.maturing.min,1,10)==0) then
                growBranch(world,plant,world.time)
            end
        end
        
        if(world.time % 233==0 or (world.time % 23==0 and #plant.root > (plants[plant.specie].size.max/75)/2)) then
            growTrunk(world,plant,world.time)
        end
    end
    return(plant)
end

local function gravity(world,object)
    if(object.position.z > 1 and world.map.collision.check({x=object.position.x,y=object.position.y,z=object.position.z-1})) then
        local check = false
        for i = object.position.z, object.position.z - object.falltime, -1 do
            if world.map.collision.map[object.position.x][object.position.y][i-1] >0 then
                object.position.z = i
                object.falltime = 1
                check = true
                world.redraw = true
                break
            end
        end
        if check == false then
            object.position.z = object.position.z - object.falltime+1
            object.falltime = object.falltime + 1
            world.redraw = true
        end
    end
end

local function seedFrame(world,plant)

    if(world.time%6==0 and world.map.block[plant.position.x][plant.position.y][plant.position.z-1] == 2) then
        plant.germination = plant.germination + 1
        if(plant.germination >= plants[plant.specie].time.maturing.max/100000 or util.roleta(19,1) == 2 and plant.germination>=(plants[plant.specie].time.maturing.min)) then
            world.redraw = true
            return(types.plant(plant.specie,plant.status,world.time,plant.position,plant.quality,100))
        end
    end
    gravity(world,plant)
    return(plant)
end
--]]

local function frame(world)
    world.time = world.time + 1
    --
    for i, v in ipairs(world.plant) do
        if(v.type == 'plant' and v.specie ~= 'grass') then
            util.assign(v,plantFrame(world,v))
        elseif(v.type == 'seed') then
            util.assign(v,seedFrame(world,v))
        end
    end
    --]]
end

local function world(size,quality)
    local world = 
    {
        time = 0,
        frame = frame,
        plant = 
        {
            spawn = function(world,specie,position) 
                table.insert(world.plant,types.seed(specie,'idle',world.time,position)) 
            end
        }
    }
    world.map = Map(size,quality)
    world = grassify(world)
    world.redraw = true
    return world
end

return world