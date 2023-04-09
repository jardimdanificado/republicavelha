local util = require("src.republicanova.util")
local types = require ("src.republicanova.types")

-------------------------------------------------
--TERRAIN
-------------------------------------------------

function Heightmap(size) 
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

function smoothBlock(hm,position)
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

function smoothHeightmap(hm,corner)
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

function increaseDistance(hm,corner)
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
    
function roundHeightmap(hm)
    local min = -math.huge;
    for x = 1, #hm do
        for y = 1, #hm do
            if(min > -math.huge and min > hm[x][y]) then
                min = hm[x][y]
            end
        end
    end
    for x = 1, #hm do
        for y = 1, #hm do
            if min > -math.huge then
                hm[x][y] = hm[x][y] + min
            end
        end
    end
    for x = 1,#hm,1 do
        for y = 1, #hm,1 do
            if min > -math.huge then
                hm[x][y] = math.floor(((hm[x][y] +min)*((10^(string.len(math.floor(min)))))+0.5));
            end
        end
    end
    return hm;
end

function polishHeightmap(heightmap, fixedHeight)
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


function autoHeightmap(mapsize, multi) 
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

function autoSmoothHeightmap(hm,smooth)
    local tempfunc = smoothHeightmap
    rand = 1
    while(smooth>0) do
        rand = util.random(1,4)
        hm = tempfunc(hm,rand)
        smooth = smooth-1
    end
    return hm
end

function autoExpandHeightmap(hm,smooth)
    local tempfunc = increaseDistance
    local rand = 1
    while(smooth>0) do
        rand = util.random(1,4)
        hm = tempfunc(hm,rand)
        smooth = smooth-1
    end
    return hm
end

function terrify(map,fixedHeight)
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

function fixHeightmap(heightmap)
    local threshold = 10 -- the maximum difference allowed between adjacent cells
    local maxDiff = 20 -- the maximum amount to reduce a cell by
    for i = 1, #heightmap do
        for j = 1, #heightmap[i] do
            local currentValue = heightmap[i][j]
            local hasNeighbor = false
            for x = -1, 1 do
                for y = -1, 1 do
                    if (x ~= 0 or y ~= 0) then
                        local neighborI = i + x;
                        local neighborJ = j + y;
                        if (
                            neighborI >= 1 and
                            neighborI <= #heightmap and
                            neighborJ >= 1 and
                            neighborJ <= #heightmap[i]
                        ) then
                            local neighborValue = heightmap[neighborI][neighborJ];
                            if (math.abs(currentValue - neighborValue) > threshold) then
                                hasNeighbor = true;
                                break
                            end
                        end
                    end
                end
                
                if (hasNeighbor) then -- if there is an abrupt change, reduce the value of this cell by up to maxDiff
                    heightmap[i][j] = math.max(currentValue - maxDiff, heightmap[i][j])
                    currentValue = heightmap[i][j] -- update currentValue to reflect the new value of this cell
                end
                
            end
            
        end
    
    end
    
    return heightmap
end

function adjustHeightmap(heightmap)
    for i = 1, #heightmap do
        for j = 1, #heightmap[i] do
            local currentValue = heightmap[i][j]
            local hasNeighbor = false
            for x = -1, 1 do
                for y = -1, 1 do
                    if (x ~= 0 or y ~= 0) then
                        local neighborI = i + x;
                        local neighborJ = j + y;
                        if (
                            neighborI >= 1 and
                            neighborI <= #heightmap and
                            neighborJ >= 1 and
                            neighborJ <= #heightmap[i]
                        ) then
                            local neighborValue = heightmap[neighborI][neighborJ];
                            if (math.abs(currentValue - neighborValue) <= 1) then
                                hasNeighbor = true;
                                break
                            end
                        end
                    end
                end
                if (hasNeighbor) then
                    break
                end
            end
            
            if (not hasNeighbor) then -- if there is no suitable neighbor, adjust the value of this cell
                if i > 1 and i < #heightmap and j > 1 and j < #heightmap[i] then
                    local nearby = {
                        heightmap[i-1][j-1], heightmap[i-1][j], heightmap[i-1][j+1],
                        heightmap[i][j-1], heightmap[i][j+1],
                        heightmap[i+1][j-1], heightmap[i+1][j], heightmap[i+1][j+1],
                    }
                    table.sort(nearby)
                    local targetValue = nearby[util.random(2,7)]
                    if targetValue < currentValue - 1 then
                        heightmap[i][j] = currentValue - 1
                    elseif targetValue > currentValue + 1 then
                        heightmap[i][j] = currentValue + 1
                    else
                        heightmap[i][j] = targetValue
                    end
                elseif currentValue > 1 then
                    heightmap[i][j] = currentValue - 1
                else
                    heightmap[i][j] = currentValue + 1
                end
            end
            
        end
    
    end
    
    return heightmap
end

function checkDifference(heightmap) 
    local counter = 0;
    local abs = math.abs
    for i = 1, #heightmap do 
        for j = 1, #heightmap[i] do 
            local currentValue = heightmap[i][j]
            local hasNeighbor = false
        
            for x = -1, 1 do 
                for y = -1, 1 do
                    if (x ~= 0 or y ~= 0) then -- changed 'and' to 'or'
                        local neighborI = i + x;
                        local neighborJ = j + y;
                        if (
                            neighborI >= 1 and
                            neighborI <= #heightmap and -- changed '<' to '<='
                            neighborJ >= 1 and
                            neighborJ <= #heightmap[i] -- changed '<' to '<='
                        ) then
                            local neighborValue = heightmap[neighborI][neighborJ];
                            if (abs(currentValue - neighborValue) == 1) then
                                hasNeighbor = true;
                                break
                            end
                        end
                    end
                end
                if (hasNeighbor) then
                    break
                end
            end
            
            if (hasNeighbor) then -- moved this line inside the inner loop
                counter = counter + 1
            end
            
        end
    
    end
    
    return counter
end

function Terrain(data,multiHorizontal, layers,retry)
    local floor = math.floor
    local mapsize = {w=64,h=64}
    multiHorizontal = multiHorizontal or 2
    layers = layers or 8
    local smooth = mapsize.w * (multiHorizontal^2)/2
    retry = retry or 1
    local hmap = util.func.time({autoHeightmap,"autoHeightmap"},mapsize.w,multiHorizontal)
    hmap = util.func.time({autoExpandHeightmap,"autoExpandHeightmap"},hmap,mapsize.h/2)
    hmap = util.func.time({autoSmoothHeightmap,"autoSmoothHeightmap"},hmap,(smooth))
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
            return(AutoTerrain(multiHorizontal, layers, retry+1))
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

function Collision(data,blockmap)
    local collision = {}
    collision.list = {}
    collision.new={}
    collision.new.default = function(value,position)
        local positions = {...}
        local uid = util.id()
        collision.list[uid] = types.collider(position,value)
        return uid
    end
    collision.new.relative = function(parent,value,position)
        local uid = util.id()
        collision.list[uid] = types.collider(position,value)
        collision.list[uid].parent = parent
        table.insert(parent.relatives,collision.list[uid])
        return uid
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
    
    collision.move = function(id,newPosition)
        local position = collision.list[id].position
        local value = collision.list[id].value
        local old = collision.map[position.x][position.y][position.z]
        local new = collision.map[newPosition.x][newPosition.y][newPosition.z]
        old = old - value
        new = new + new
        collision.list[id].position = newPosition
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

function Map(data,multiHorizontal,quality)--create the map

    local block,heightmap = util.array.unpack(Terrain(data,multiHorizontal,quality))
    local temperature = util.matrix.new(#block,#block[1],#block[1][1],29)
    return {
        block = block,
        height = heightmap,
        temperature = temperature,
        collision = Collision(data,block)
    }
end

return Map