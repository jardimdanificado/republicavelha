local util = require("src.republicanova.util")
local Terrain = require("src.republicanova.terrain")
local types = require("src.republicanova.types")
local materials = types.materials
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
            --
                world.plant.spawn(--//this spawns a grass seed at each xy position
                world,
                'grass',
                {x=x,y=y,z=#world.map.block[1][1]}
            )--]]
            if(util.random(1,100) == 1) then --random seeds start here
                local temptype = util.array.keys(plants)[util.random(1,util.len(plants))]
                
                if(temptype ~= 'grass') then
                    world.plant.spawn(--this spawns a random seed at the xy position
                        world,
                        temptype,
                        {x=x,y=y,z=#world.map.block[1][1]}
                    )
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
    collision.colliders.new = function(position,value, active,relatives,parent)
        table.insert(collision.colliders,types.collider(position,value, active,relatives,parent))
    end
    collision.map = util.array.map(blockmap,function(value,x)
        return (
                util.array.map(value,function(value,y)
                    return (
                            util.array.map(value,function(value,z)
                                local result = 0
                                if(materials[value].solid == true) then
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

    collision.check=function(position,value)--returns true if no collider in the specified position, of if the colliders in the position are below value
        value = value or 75
        if(
            position.x <1 or 
            position.y <1 or 
            position.z <1 or 
            position.x >#collision.map or 
            position.y >#collision.map[1] or 
            position.z >#collision.map[1][1]
        ) then
            return true
        elseif(collision.map[position.x][position.y][position.z] > value) then
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

local function Map(multiHorizontal,quality)--create the map
    local block,heightmap = util.array.unpack(Terrain(multiHorizontal,quality))
    local temperature = util.matrix.new(#block,#block[1],#block[1][1],29)
    return {
        block = block,
        height = heightmap,
        temperature = temperature,
        collision = Collision(block)
    }
end

--
local function findTrunkGrowPosition(collisionMap,x,y,z)--this try to find a air block in the 9 above blocks
    local directions = 
    {
        {x= -1, y= 0,z=1}, --4
        {x= 1, y= 0,z=1},  --6
        --{x= 1, y= 1,z=1},  --3
        --{x= -1, y= 1,z=1}, --1
        {x= 0, y= 0,z=1},
        {x= 0, y= 1,z=1},  --2
        {x= 0, y= -1,z=1}, --8
        --{x= 1, y= -1,z=1}, --9
        --{x= -1, y= -1,z=1} --7
    }
    
    for i = 1, #directions do
        opt = directions[i]
        if((x+opt.x >1 and y+opt.y>1 and x+opt.x < #collisionMap and y+opt.y < #collisionMap[1])~= true) then
        elseif(collisionMap[x+opt.x][y+opt.y][z+opt.z]  <75) then
            return opt
        end
    end
    return
end

local function findRootGrowPosition(collisionMap,x,y,z)--this try to find a air block in the 9 below blocks
    local directions = 
    {
        {x= -1, y= 0,z=-1}, --4
        {x= 1, y= 0,z=-1},  --6
        {x= 1, y= 1,z=-1},  --3
        {x= -1, y= 1,z=-1}, --1
        {x= 0, y= 1,z=-1},  --2
        {x= 0, y= -1,z=-1}, --8
        {x= 1, y= -1,z=-1}, --9
        {x= -1, y= -1,z=-1} --7
    }
    for i = 1, #directions do
        opt = directions[i]
        if((x+opt.x >=1 and y+opt.y>=1 and z+opt.z >=1 and x+opt.x < #collisionMap and y+opt.y < #collisionMap[1] and z+opt.z < #collisionMap[1]) ~= true)then
        elseif(collisionMap[x+opt.x][y+opt.y][z+opt.z]  <75) then
            return opt
        end
    end
    return
end

local function findBranchGrowPosition(collisionMap,x,y,z)--this try to find a air block in the 8 surrounding blocks, if fail try the 9 above
    local directions = 
    {
        {x= -1, y= 0,z=0}, --4
        {x= 1, y= 0,z=0},  --6
        {x= 1, y= 1,z=0},  --3
        {x= -1, y= 1,z=0}, --1
        {x= 0, y= 1,z=0},  --2
        {x= 0, y= -1,z=0}, --8
        {x= 1, y= -1,z=0}, --9
        {x= -1, y= -1,z=0} --7
    }
    for i = 1, #directions do
        opt = directions[i]
        if((x+opt.x >1 and y+opt.y>1 and x+opt.x < #collisionMap and y+opt.y < #collisionMap[1])~= true) then
        elseif(collisionMap.check({x=x+opt.x,y=y+opt.y,z=z+opt.z})) then
            return opt
        end
    end
    return findTrunkGrowPosition(collisionMap,x,y,z)
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
    if(util.roleta(14,1,16) == 2) then
        plant.leaf = plant.leaf + 1
    end
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
    if(height > 3 and #plant.branch < plants[plant.specie].size.max/2) then
        local lposi = directions[util.roleta(0,1,0,1,0,1,0,1,0)]
        lposi.z = util.random(0,1)
        local numb = util.random((#plant.branch/2)*-1,#plant.branch)
        local pposi = plant.position
        if(plant.branch[numb] ~= nil) then 
            pposi = plant.branch[numb].position 
        elseif(#plant.trunk > 0) then
            pposi = plant.trunk[util.random(1,#plant.trunk)].position
        end
        if pposi.z-math.floor((plants[plant.specie].size.max/100)/2.5) > plant.position.z and world.map.collision.check(util.math.vec3add(lposi,pposi),75) then         
            table.insert(plant.branch,types.branch(plant.specie,'idle',time,util.math.vec3add(lposi,pposi),plant.quality,plant.condition))
            table.insert(world.map.collision.colliders,types.collider(lposi,75))
        end
    end
    return plant
end

local function growTrunk(world,plant,time)
    local height = #plant.trunk ~= 0 and plant.trunk[#plant.trunk].position.z - plant.position.z or 0
    if(height < (plants[plant.specie].size.max/100)) then
        local lposi = directions[util.roleta(0,1,0,1,10,1,0,1,0)]
        lposi.z = (lposi.x == 0 and lposi.x == 0) and 1 or 0
        local pposi = #plant.trunk ~= 0 and plant.trunk[#plant.trunk].position or plant.position
        if world.map.collision.check(util.math.vec3add(lposi,pposi),75) then
            table.insert(plant.trunk,types.trunk(plant.specie,'idle',time,util.math.vec3add(lposi,pposi),plant.quality,plant.condition))
            table.insert(world.map.collision.colliders,types.collider(lposi))
        end
    end
    return plant
end

local function plantFrame(world,plant)
    if(plant.leaf ~= nil) then
        if(plant.leaf < plants[plant.specie].leaf.max and world.time % 5 ==0) then
            --[[
            if(plants[plant.specie].size.max > 100) then
                growBranch(world,plant,world.time)
            end
            --]]
            growLeaf(plant)
        end
    end
        
    if plants[plant.specie].type == 'fruit tree' then
        --print(plants[plant.specie].type)
        local lastTrunkPosition = plant.position
        if(#plant.trunk > 0) then
            lastTrunkPosition = plant.trunk[#plant.trunk].position
        end
            
        growBranch(world,plant,world.time)
        if(world.time % util.math.limit(plants[plant.specie].time.maturing.min,1,100)==0) then
            --print 'a'
            growTrunk(world,plant,world.time)
        end
    end
    return(plant)
end

local function gravity(collisionMap,position)
    if(position.z > 1 and collisionMap.check({x=position.x,y=position.y,z=position.z-1})) then
        return{x=position.x,y=position.y,z=position.z-1}
    end
    return(position)
end

local function seedFrame(world,plant)
    local v = plant
    if(plant.position.z-1 >1) then
        
        if(world.time%6==0 and materials[world.map.block[plant.position.x][plant.position.y][plant.position.z-1] ].name == 'earth') then
            plant.germination = plant.germination + 1
            plant.status = (plant.status ~= 'germinating') and 'germinating' or plant.status
            if(plant.status == 'germinating') then
                if(plant.germination >= plants[plant.specie].time.maturing.max/1000000 or (util.roleta(19,1) == 2 and plant.germination>=(plants[plant.specie].time.maturing.min/1000000))) then
                    return(types.plant(plant.specie,plant.status,world.time,plant.position,plant.quality,100))
                end
            end
        end
        plant.position = gravity(world.map.collision,plant.position)
    end
    return(plant)
end
--]]

local function frame(world)
    world.time = world.time + 1
    --
    for i, v in ipairs(world.plant) do
        if(v.type == 'seed') then
            util.assign(v,seedFrame(world,v))
        elseif(v.type == 'plant') then
            util.assign(v,plantFrame(world,v))
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
        },
        data = {}
    }
    world.map = Map(size,quality)
    world = grassify(world)
    return world
end

return world