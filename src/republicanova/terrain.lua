function Heightmap(size) 
    local N = (8+math.random(0,5))
    local RANDOM_INITIAL_RANGE = (10+math.random(0,3))
    local MATRIX_LENGTH = math.pow(2, N)+1

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
--                print(math.floor(j + chunkSize / 2))
--                print(math.floor(i + chunkSize / 2))
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
    if(x>0) then
        sum = sum + hm[x-1][y]
        count = count + 1
    end
    --sum += hm[x][y]
    --count++
    if(x<hm.length-1) then
        sum = sum + hm[x+1][y]
        count = count+1
    end
    if(x>0 and y<hm.length-1) then
        sum = sum + hm[x-1][y+1]
        count = count+1
    end
    if(y<hm.length-1) then
        sum = sum + hm[x][y+1]
        count = count+1
    end
    if(x<hm.length-1 and y<hm.length-1) then
        sum = sum + hm[x+1][y+1]
        count = count+1
    end
    return(sum/count)
end

function smoothHeightmap(hm,corner) 
    local corner = randomInRange(0,3)
    switch(corner)--lua does not have switch blocks, redo so with if-else
    {
        case 0:
        {
            for x = 1, #hm do
                for y = 0,#hm)
                    hm[x][y] = smoothBlock(hm,new Vector2(x,y));--get this from util later
        }
        break
        case 1:
        {
            for(let x = hm.length-1;x >=0;x-=1)
                for(let y = 0;y < (hm.length);y+=1)
                    hm[x][y] = smoothBlock(hm,new Vector2(x,y));
        }
        break
        case 2:
        {
            for(let x = hm.length-1;x >=0;x-=1)
                for(let y = hm.length-1;y >=0;y-=1)
                    hm[x][y] = smoothBlock(hm,new Vector2(x,y));
        }
        break
        case 3:
        {
            for(let x = 0;x < (hm.length);x+=1)
                for(let y = hm.length-1;y >=0;y-=1)
                    hm[x][y] = smoothBlock(hm,new Vector2(x,y));
        }
        break
    }
    return hm
end
    