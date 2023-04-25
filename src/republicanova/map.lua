local util = require("src.republicanova.util")
local types = require ("src.republicanova.types")
local Materials = require("src.republicanova.materials")

-------------------------------------------------
--TERRAIN
-------------------------------------------------

local function Heightmap(size) 
    local N = (8+util.random(0,5))
    local RANDOM_INITIAL_RANGE = (10+util.random(0,3))
    local MATRIX_LENGTH = (2 ^ N)+1
    function generateMatrix() 
        local matrix = {}
        for i=1,MATRIX_LENGTH do
            local arr = {}
            for k=1, MATRIX_LENGTH do
                table.insert(arr,0)
            end
            table.insert(matrix,arr)
        end

        matrix[1][MATRIX_LENGTH] = util.random(0, RANDOM_INITIAL_RANGE)
        matrix[MATRIX_LENGTH][1] = util.random(0, RANDOM_INITIAL_RANGE)
        matrix[1][1] = util.random(0, RANDOM_INITIAL_RANGE)
        matrix[MATRIX_LENGTH][MATRIX_LENGTH] = util.random(
            0,
            RANDOM_INITIAL_RANGE
        )
        return matrix
    end

    function calculateSquare(matrix, chunkSize, randomFactor) 
        local sumComponents = 0
        local sum = 0
        chunkSize = math.ceil(chunkSize)
        for i = 1, #matrix,chunkSize do
            for j = 1, #matrix, chunkSize do
                local BOTTOM_RIGHT = (matrix[j + chunkSize]) and matrix[j + chunkSize][i + chunkSize] or 0
                local BOTTOM_LEFT = (matrix[j + chunkSize]) and matrix[j + chunkSize][i] or 0
                local TOP_LEFT = matrix[j][i]
                local TOP_RIGHT = matrix[j][i + chunkSize]
                local values = {BOTTOM_RIGHT, BOTTOM_LEFT, TOP_LEFT, TOP_RIGHT}
                local count, sum = 0, 0
                
                for i = 0, #values do
                    if type(values[i]) == "number" then
                        sum = sum + values[i]
                        count = count + 1
                    end
                end
                matrix[j + math.floor(chunkSize / 2)][i + math.floor(chunkSize / 2)] = sum / count + util.random(-randomFactor, randomFactor)
            end
        end
    end

    function calculateDiamond(matrix, chunkSize, randomFactor) 
        local half = math.floor(chunkSize / 2)
        for y = 1, #matrix, half do
            for x = ((y + half) % chunkSize), #matrix, chunkSize do
                local BOTTOM = (matrix[y + half]) and matrix[y + half][x] or nil
                local LEFT = matrix[y][x - half]
                local TOP = (matrix[y - half]) and matrix[y - half][x] or nil
                local RIGHT = matrix[y][x + half]

                local myTable = {BOTTOM, LEFT, TOP, RIGHT}
                local count, sum = 0, 0

                for i=1, #myTable do
                    if type(myTable[i]) == "number" then
                        sum = sum + myTable[i]
                        count = count + 1
                    end
                end
                matrix[y][x] = sum / count + util.random(-randomFactor, randomFactor)
            end
        end
        return matrix
    end

    function diamondSquare(matrix) 
        local chunkSize = MATRIX_LENGTH 
        local randomFactor = RANDOM_INITIAL_RANGE

        while (chunkSize > 1) do
            calculateSquare(matrix, chunkSize, randomFactor)
            calculateDiamond(matrix, chunkSize, randomFactor)
            chunkSize = chunkSize/2
            randomFactor = math.ceil(randomFactor/2)
        end
        return matrix
    end

    function normalizeMatrix(matrix)

        local maxValue = -math.huge

        for _, row in ipairs(matrix) do
            for _, value in ipairs(row) do
                maxValue = math.max(maxValue, value)
            end
        end
        
        for _, row in ipairs(matrix) do
            for i, value in ipairs(row) do
                row[i] = value / maxValue
            end
        end
        
        return matrix
    end
    
    if (type(size) ~= nil) then
        MATRIX_LENGTH = size
    end

    return (normalizeMatrix(diamondSquare(generateMatrix())))
end

local function smoothBlock(hm,position)
    local x = position.x
    local y = position.y
    local sum = 0
    local count = 0
    if x > 1 and y > 1 then
        sum = sum + hm[x-1][y-1]
        count = count + 1
    end
    if y > 1 then
        sum = sum + hm[x][y-1]
        count = count + 1
    end
    if x < #hm and y > 1 then
        sum = sum + hm[x+1][y-1]
        count = count + 1
    end
    if x > 1 then
        sum = sum + hm[x-1][y]
        count = count + 1
    end
    sum = sum + hm[x][y]
    count = count + 1
    if x < #hm then
        sum = sum + hm[x+1][y]
        count = count+1
    end
    if x > 1 and y < #hm then
        sum = sum + hm[x-1][y+1]
        count = count+1
    end
    if y < #hm then
        sum = sum + hm[x][y+1]
        count = count+1
    end
    if x < #hm and y < #hm then
        sum = sum + hm[x+1][y+1]
        count = count+1
    end
    return sum / count
end

local function smoothHeightmap(hm,corner)
    corner = corner or util.random(1,4)
    local corners = 
    {
        {x = {min=1,max=#hm}, y = {min=1,max=#hm}},
        {x = {min=1,max=#hm}, y = {min=#hm,max=1}},
        {x = {min=#hm,max=1}, y = {min=1,max=#hm}},
        {x = {min=#hm,max=1}, y = {min=#hm,max=1}}
    }
    corner = corners[corner]
    for x = corner.x.min, corner.x.max do
        for y = corner.y.min,corner.y.max do
            hm[x][y] = smoothBlock(hm,{x=x, y=y})
        end
    end
    return hm
end

local function increaseDistance(hm,corner)
    corner = corner or util.random(1,4)
    local corners = 
    {
        {x = {min=1,max=#hm}, y = {min=1,max=#hm}},
        {x = {min=1,max=#hm}, y = {min=#hm,max=1}},
        {x = {min=#hm,max=1}, y = {min=1,max=#hm}},
        {x = {min=#hm,max=1}, y = {min=#hm,max=1}}
    }
    corner = corners[corner]

    for x = corner.x.min, corner.x.max do
        for y = corner.y.min,corner.y.max do
            hm[x][y] = hm[x][y] * 2 -- increase distance
            hm[x][y] = hm[x][y] + (x + y) / (#hm * 2) -- add gradient
        end
    end
    return hm
end

local function polishHeightmap(heightmap, fixedHeight)
    local floor = math.floor
    local limit = util.math.limit
    local hmcache = #heightmap
    local threshold = 0
    local max = -math.huge
    local min = math.huge
    for x = 1, hmcache do
        for y = 1, hmcache do
            if heightmap[x][y] > max then
                max = heightmap[x][y]
            end
            if heightmap[x][y] < min then
                min = heightmap[x][y]
            end
        end
    end

    if max > fixedHeight then
        threshold = math.ceil(max - fixedHeight)
    end

    if min < 1 - threshold then
        threshold = 1 - min
    end

    for x = 1, hmcache do
        for y = 1, hmcache do
            if heightmap[x][y] >= fixedHeight then
                heightmap[x][y] = fixedHeight
            elseif heightmap[x][y] < fixedHeight - threshold then
                heightmap[x][y] = floor(limit(heightmap[x][y] + threshold, 1, fixedHeight))
            else
                heightmap[x][y] = fixedHeight - 1
            end
        end
    end

    return heightmap
end

local function autoHeightmap(mapsize, multi) 
    local results = {}
    for x = 1, multi do
        for y = 1, multi do
            local map = Heightmap(mapsize)
            for xx = 1, mapsize do
                -- Add a new row to the results table for each xx value
                if not results[((x-1)*mapsize)+xx] then
                    results[((x-1)*mapsize)+xx] = {}
                end
                for yy = 1, mapsize do
                    -- Add the value from the sub-heightmap to the corresponding
                    -- position in the results table
                    results[((x-1)*mapsize)+xx][((y-1)*mapsize)+yy] = map[xx][yy]
                end
            end
        end
    end
    return results
end

local function autoSmoothHeightmap(hm,smooth)
    local tempfunc = smoothHeightmap
    while(smooth>0) do
        hm = tempfunc(hm,util.random(1,4))
        smooth = smooth-1
    end
    return hm
end

local function autoExpandHeightmap(hm,smooth)
    local tempfunc = increaseDistance
    while(smooth>0) do
        hm = tempfunc(hm,util.random(1,4))
        smooth = smooth-1
    end
    return hm
end

local function terrify(map,fixedHeight)
    if type(fixedHeight) == nil then
        fixedHeight = 128
    end
    
    local result = {}
    for x = 1, #map do
        result[x] = {}
        for y = 1, #map do
            result[x][y] = {}
            for z = 1, fixedHeight do
                result[x][y][z] = (z < map[x][y]) and 2 or 1 --check materials.lua for material types
            end
        end
    end
    return(result)
end

local function Terrain(multiHorizontal, layers,retry)
    local floor = math.floor
    local mapsize = {w=64,h=64}
    multiHorizontal = multiHorizontal or 2
    layers = layers or 8
    local smooth = mapsize.w * (multiHorizontal^2)/2
    retry = retry or 1
    local hmap = util.func.time({autoHeightmap,"autoHeightmap"},mapsize.w,multiHorizontal)
    hmap = util.func.time({autoExpandHeightmap,"autoExpandHeightmap"},hmap,mapsize.h/2)
    hmap = util.func.time({autoSmoothHeightmap,"autoSmoothHeightmap"},hmap,smooth)
    hmap = util.func.time({polishHeightmap,"polishHeightmap"},hmap,mapsize.h+mapsize.h/32)

    local mmm = util.matrix.minmax(hmap)
    local munique = util.matrix.unique(hmap)
    local taverage = util.matrix.average(hmap)

    if(mmm.min>=16) then
        util.matrix.map(hmap,function(value) return value-(mmm.min/2) end)
    end

    if(retry>=1) then
        if (mmm.min<1 or mmm.max > mapsize.w or #munique <= 4 and #munique < layers) then
            if(retry > 1) then
                print("retry number " .. retry)
            end
            return(Terrain(multiHorizontal, layers, retry+1))
        end
    end
    if(retry > 0) then
        print('heightmap generated in ' .. retry .. ' retries.')
    end
    hmap = polishHeightmap(hmap,mapsize.h)
    local terrain = {}
    terrain = terrify(hmap,mapsize.h)
    return {terrain, hmap}
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
                                if(Materials[value].solid == true) then
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

return Map