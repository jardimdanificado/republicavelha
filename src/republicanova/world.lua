local util = require("src.republicanova.util")
local map = require("src.republicanova.map")
local types = require("src.republicanova.types")
local Materials = require("src.republicanova.materials")
local Plants = require("src.republicanova.plants")

function getHourOfDay(totalSeconds) 
    return math.floor(totalSeconds / 3600) % 24
end

function getMinuteOfDay(totalSeconds) 

    return math.floor((totalSeconds % 3600) / 60)
end

function getSecondOfDay(totalSeconds) 

    return totalSeconds % 60
end

function getSunIntensity(minHour, maxHour, seconds) 

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
--[[
function findTrunkGrowPosition(collisionMap,x,y,z)--this try to find a air block in the 9 above blocks
    local directions = 
    {
        {x= -1, y= 0,z=1}, --4
        {x= 1, y= 0,z=1},  --6
        --{x= 1, y= 1,z=1},  --3
        --{x= -1, y= 1,z=1}, --1
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

function findRootGrowPosition(collisionMap,x,y,z)--this try to find a air block in the 9 below blocks
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

function findBranchGrowPosition(collisionMap,x,y,z)--this try to find a air block in the 8 surrounding blocks, if fail try the 9 above
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
            local newobject = types.plant(specie, status, world.time, position, quality, condition, decayRate)
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

function gravity(collisionMap,position)
    if(position.z > 1 and collisionMap.check({x=position.x,y=position.y,z=position.z-1})) then
        return{x=position.x,y=position.y,z=position.z-1}
    end
    return(position)
end

function growLeaf(plant)
    --print(time)
    if(util.roleta(14,1,16) == 2) then
        plant.leaf = plant.leaf + 1
    end
    return plant
end

function growBranch(plant,collisionMap,time)
    --print(time)
    if(type(plant.trunk) ~= nil and #plant.trunk>=2 and #plant.branch < Plants[plant.specie].leaf.max/1000 and util.roleta(2,1,2) == 1) then
        local customX = util.roleta(1,0,1)-2
        local customY = util.roleta(1,0,1)-2
        --print(customX, customY)
        table.insert(plant.branch,1,types.branch(plant.specie,'idle',time,{x=customX,y=customY,z=0},plant.quality,plant.condition))
        local collisionPositions = (#plant.trunk>1) and {plant.position,plant.trunk[2].position,plant.branch[1].position} or {plant.position,plant.trunk[1].position,plant.branch[1].position}
        collisionMap.new(collisionPositions)
    end
    return plant
end

function growTrunk(world,plant,time)
    local collisionMap = world.map.collision
    if(type(plant.trunk) ~= nil and #plant.trunk < (Plants[plant.specie].size.max/100)) then
        local customX = util.roleta(1,10,1)-2
        local customY = util.roleta(1,10,1)-2
        for i = 1, #plant.trunk do
            local trunk = plant.trunk[i]
            if(trunk.position.z < #world.map.block[1][1]) then
                trunk.position.z = trunk.position.z + 1
                trunk.position.y = trunk.position.y + customY
                trunk.position.x = trunk.position.x + customX
            end
        end
        for i = 1, #plant.branch do
            local branch = plant.branch[i]
            if(branch.position.z < #world.map.block[1][1]) then
                branch.position.z = branch.position.z + 1
                branch.position.y = branch.position.y + customY
                branch.position.x = branch.position.x + customX
            end
        end
        table.insert(plant.trunk,1,types.trunk(plant.specie,'idle',time,{x=1,y=1,z=1},plant.quality,plant.condition))
        collisionMap.new.relative(plant.position,plant.trunk[1].position)
    end
    return plant
end

function plantFrame(world,plant)
    if(plant.leaf < Plants[plant.specie].leaf.max and world.time % 5 ==0) then
        if(Plants[plant.specie].size.max > 100) then
            --print 'b'
            plant = growBranch(plant,world.map.collision,world.time)
        end
        --print 'c'
        plant = growLeaf(plant)
    end
    
    if util.string.includes(Plants[plant.specie].type,'tree') then
        local lastTrunkPosition = plant.position
        if(#plant.trunk > 0) then
            lastTrunkPosition = plant.trunk[#plant.trunk].position
        end
        if(world.time % util.math.limit(Plants[plant.specie].time.maturing.min,1,100)==0 and lastTrunkPosition.x < #world.map.block[1][1]) then
            --print 'a'
            plant = growTrunk(world,plant,world.time)
        end
    end
    return(plant)
end

function seedFrame(world,plant)
    if(world.map.block[plant.position.x][plant.position.y][plant.position.z-1] ~= nil) then
        plant.position = gravity(world.map.collision,plant.position)
        if(world.time%6==0 and plant.position.z> 2 and Materials[world.map.block[plant.position.x][plant.position.y][plant.position.z-1] ].name == 'earth') then
            plant.germination = plant.germination + 1
            plant.status = (plant.status ~= 'germinating') and 'germinating' or plant.status
            if(plant.status == 'germinating') then
                if(plant.germination >= Plants[plant.specie].time.maturing.max/1000000 or (util.roleta(19,1) == 2 and plant.germination>=(Plants[plant.specie].time.maturing.min/1000000))) then
                    --print("specie = " .. plant.specie)
                    return(types.plant(plant.specie,plant.status,world.time,plant.position,plant.quality,100))
                end
            end
        end
    end
    return(plant)
end
--]]

function frame(world)
    world.time = world.time + 1
    if(#world.data.plant>0) then
        world.data.plant = util.array.map(world.data.plant,function(plant)
            if(plant.type == 'seed') then
                return(seedFrame(world,plant))
            elseif(plant.type == 'plant') then
                return(plantFrame(world,plant))
            end
            return(plant)
        end)
    end
end

function world(size,quality)
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
    world.map = map(size,quality)
    return world
end

return world