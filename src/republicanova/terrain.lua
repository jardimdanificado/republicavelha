local util = require("src.republicanova.util")
local types = require ("src.republicanova.types")

function Heightmap(size) 
    math.randomseed(os.time()+size)
    local N = (8+math.random(0,5))
    local RANDOM_INITIAL_RANGE = (10+math.random(0,3))
    local MATRIX_LENGTH = (2 ^ N)+1
    math.randomseed(os.time()*N*RANDOM_INITIAL_RANGE)
    function generateMatrix() 
        local matrix = {}
        for i=1,MATRIX_LENGTH do
            local arr = {}
            for k=1, MATRIX_LENGTH do
                table.insert(arr,0)
            end
            table.insert(matrix,arr)
        end

        matrix[1][MATRIX_LENGTH] = math.random(0, RANDOM_INITIAL_RANGE)
        matrix[MATRIX_LENGTH][1] = math.random(0, RANDOM_INITIAL_RANGE)
        matrix[1][1] = math.random(0, RANDOM_INITIAL_RANGE)
        matrix[MATRIX_LENGTH][MATRIX_LENGTH] = math.random(
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
                matrix[j + math.floor(chunkSize / 2)][i + math.floor(chunkSize / 2)] = sum / count + math.random(-randomFactor, randomFactor)
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
                matrix[y][x] = sum / count + math.random(-randomFactor, randomFactor)
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
    corner = corner or math.random(1,4)
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
    corner = corner or math.random(1,4)
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

function polishHeightmap(heightmap,fixedHeight)
    local floor = math.floor
    local limit = util.math.limit
    local hmcache = #heightmap
    local threshold = 0
    local max = -math.huge
    local min = math.huge
    for x = 1,hmcache do
        for y = 1, hmcache do
            if(heightmap[x][y] > max) then
                max = heightmap[x][y]
            elseif(heightmap[x][y] < min) then
                min = heightmap[x][y]
            end
        end
    end
    
    if(max > fixedHeight) then
        threshold = math.ceil(max - fixedHeight)
    end

    
    if(min<1) then
        threshold = threshold + min
    end

    print(threshold)
    print(min.. ' ' .. max)

    for x = 1,hmcache do
        for y = 1, hmcache do
            heightmap[x][y] = (floor(util.math.limit(heightmap[x][y],1,fixedHeight)-(threshold)))
            --heightmap[x][y] = (floor(util.math.limit(heightmap[x][y],1,fixedHeight)))
        end
    end
    return(heightmap)
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
        math.randomseed(os.time()+smooth)
        rand = math.random(1,4)
        hm = tempfunc(hm,rand)
        smooth = smooth-1
    end
    return hm
end

function autoExpandHeightmap(hm,smooth)
    local tempfunc = increaseDistance
    local rand = 1
    math.randomseed(math.floor(os.time()*hm[4][8]))
    while(smooth>0) do
        rand = math.random(1,4)
        hm = tempfunc(hm,rand)
        smooth = smooth-1
    end
    return hm
end

function Terrain(map,fixedHeight)
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
                    local targetValue = nearby[math.random(2,7)]
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
                            if (math.abs(currentValue - neighborValue) == 1) then
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

function AutoTerrain(mapsize, multiHorizontal, layers, retry)
        mapsize = mapsize or {w=64,h=64}
        multiHorizontal = multiHorizontal or 2
        smooth = mapsize.w * multiHorizontal
        retry = retry or 1
        --local hmap = randommap(multiHorizontal*mapsize)
        local hmap = util.func.time({autoHeightmap,"autoHeightmap"},mapsize.w,multiHorizontal)
        --hmap = autoHeightmap(mapsize,multiHorizontal)
        hmap = util.func.time({autoExpandHeightmap,"autoExpandHeightmap"},hmap,mapsize.h/2)
        --hmap = util.func.time({roundHeightmap,"roundHeightmap"},hmap)
        --hmap = roundHeightmap(hmap)
        --hmap = autoSmoothHeightmap(hmap,smooth)
        --hmap = polishHeightmap(hmap,mapsize)
        --for _ = 1, mapsize/4 do
        --    hmap = fixHeightmap(hmap,mapsize)
        --end
        hmap = util.func.time({autoSmoothHeightmap,"autoSmoothHeightmap"},hmap,smooth)
        
        --for _ = 1, mapsize do
        --    hmap = fixHeightmap(hmap)
        --    hmap = adjustHeightmap(hmap)
        --end
        local mmm = util.matrix.minmax(hmap)
        local munique = util.matrix.unique(hmap)
        if(retry>=1) then
            if (#munique < layers or mmm.min<1 or mmm.max > mapsize.w ) then
                if(retry > 1) then
                    print("retry number " .. retry)
                end
                math.randomseed(math.floor(os.time()*(retry)))
                return(AutoTerrain(mapsize,multiHorizontal, layers,retry+1))
            end
        end
        if(retry >= 2) then
            print('heightmap generated in ' .. retry .. ' retries.')
        end
        hmap = util.func.time({polishHeightmap,"polishHeightmap"},hmap,mapsize.h)
        
        local terrain = {}
        terrain = {util.func.time({Terrain,"Terrain"},hmap,mapsize.h),hmap}
        --terrain = Terrain(hmap,mapsize)
        return(terrain)
end

return AutoTerrain