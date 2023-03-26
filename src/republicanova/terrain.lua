local util = require("src.republicanova.util")
local types = require ("src.republicanova.types")

function Heightmap(size) 
    local N = (8+math.random(0,5))
    local RANDOM_INITIAL_RANGE = (10+math.random(0,3))
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
    if(x>1 and y>1) then
        sum = sum + hm[x-1][y-1]
        count = count + 1
    end
    if(y>1) then
        sum = sum + hm[x][y-1]
        count = count + 1
    end
    if(x<#hm and y>1) then	
        sum = sum + hm[x+1][y-1]
        count = count + 1
    end
    if(x>1) then
        sum = sum + hm[x-1][y]
        count = count + 1
    end
    sum = sum + hm[x][y]
    count = count + 1
    if(x<#hm) then
        sum = sum + hm[x+1][y]
        count = count+1
    end
    if(x>1 and y<#hm) then
        sum = sum + hm[x-1][y+1]
        count = count+1
    end
    if(y<#hm) then
        sum = sum + hm[x][y+1]
        count = count+1
    end
    if(x<#hm and y<#hm) then
        sum = sum + hm[x+1][y+1]
        count = count+1
    end
    return(sum/count)
end

function smoothHeightmap(hm) 
    local corner = math.random(0,3)
    if corner == 0 then
            for x = 1, #hm do
                for y = 1,#hm do
                    hm[x][y] = smoothBlock(hm,{x=x, y=y})
                end
            end
    end
    if corner == 1 then
            for x = #hm,1,-1 do
                for y = 1,#hm,1 do
                    hm[x][y] = smoothBlock(hm,{x=x, y=y})
                end
            end
    end
    if corner == 2 then
            for x = #hm, 1, -1 do
                for y = #hm, 1, -1 do
                    hm[x][y] = smoothBlock(hm,{x=x, y=y})
                end
            end
    end
    if corner == 3 then
            for x = 1,#hm,1 do
                for y = #hm, 1, -1 do
                    hm[x][y] = smoothBlock(hm,{x=x, y=y})
                end
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
    for x = 1,#heightmap do
        for y = 1, #heightmap[x] do
            local ints = {}
            ints[1] = math.floor(heightmap[x][y])
            ints[2] = math.floor(fixedHeight-((fixedHeight/4)*3))
            ints[3] = math.floor(fixedHeight-2)
            heightmap[x][y] = math.floor(util.math.limitTo(ints[1],ints[2],ints[3]))
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
    while(smooth>0) do
        hm = smoothHeightmap(hm)
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
                result[x][y][z] = (z < map[x][y]) and 'earth' or 'air'
            end
        end
    end
    return(result)
end

function checkDifference(heightmap) 
    local counter = 0;
    
    for i = 1, #heightmap do 
        for j = 1, j < #heightmap[i] do 
            local currentValue = heightmap[i][j]
            local hasNeighbor = false
        
            for x = -1, x <= 1, 1 do 
                for y = -1, 1 do
                    if (x ~= 0 and y ~= 0) then
                        local neighborI = i + x;
                        local neighborJ = j + y;
                        if (
                            neighborI >= 1 and
                            neighborI < #heightmap and
                            neighborJ >= 1 and
                            neighborJ < #heightmap[i]
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
        end
    
        if (hasNeighbor) then
            counter = counter + 1
        end
    end
    return counter
end

function AutoTerrain(mapsize, multiHorizontal, smooth, retry)
        mapsize = mapsize or {w=128,h=64}
        multiHorizontal = multiHorizontal or 2
        smooth = smooth or 0
        retry = retry or 0
        local hmap
        hmap = autoHeightmap(mapsize.w,multiHorizontal)
        hmap = roundHeightmap(hmap)
        hmap = autoSmoothHeightmap(hmap,smooth)
        hmap = polishHeightmap(hmap,mapsize.h)
        
        if(retry>=1 and checkDifference(hmap)>((mapsize.w*multiHorizontal)^2)/2) then
            if(retry > 1) then
                print("retry number " .. retry)
            end
            retry = retry +1
            return(AutoTerrain(mapsize,multiHorizontal,smooth,postslices,retry))
        end
        if(retry >= 2) then
            print('heightmap generated in ' .. retry .. ' retries.')
        end
        local terrain = {}
        print(os.clock())
        terrain = Terrain(hmap,mapsize.h)
        print(os.clock())
        return(terrain)
end

local terrain = AutoTerrain
return terrain