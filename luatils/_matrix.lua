local matrix = {}

matrix.includes = function(matrix, value)
    for k, v in pairs(matrix) do
        for k, v in pairs(v) do
            if (value == v) then
                return true
            end
        end
    end
    return false
end

matrix.new = function(sizex, sizey, sizez, value)
    local result = {}
    for x = 1, sizex do
        result[x] = {}
        for y = 1, sizey do
            if (value ~= nil) then
                result[x][y] = {}
                for z = 1, sizez, 1 do
                    result[x][y][z] = value
                end
            else
                result[x][y] = sizez
            end
        end
    end
    return result
end

matrix.tostring = function(matrix)
    local str = ''
    for x = 1, #matrix, 1 do
        for y = 1, #matrix[x], 1 do
            str = str .. matrix[x][y]
        end
        str = str .. '\n'
    end
    return str
end

matrix.minmax = function(matrix)
    local min_val = matrix[1][1]
    local max_val = matrix[1][1]
    for i = 1, #matrix do
        for j = 1, #matrix[i] do
            if matrix[i][j] < min_val then
                min_val = matrix[i][j]
            end
            if matrix[i][j] > max_val then
                max_val = matrix[i][j]
            end
        end
    end
    return min_val, max_val
end

matrix.unique = function(matrix)
    function contains(table, val)
        for i = 1, #table do
            if table[i] == val then
                return true
            end
        end
        return false
    end
    local unique_vals = {}
    for i = 1, #matrix do
        for j = 1, #matrix[i] do
            if not contains(unique_vals, math.floor(matrix[i][j])) then
                table.insert(unique_vals, math.floor(matrix[i][j]))
            end
        end
    end
    -- print(unique_vals[4],unique_vals[8])
    return unique_vals
end

matrix.average = function(matrix)
    local sum, count = 0, 0
    for x = 1, #matrix do
        for y = 1, #matrix[x] do
            sum = sum + matrix[x][y]
            count = count + 1
        end
    end
    return (sum / count)
end

matrix.map = function(matrix, callback)
    for x = 1, #matrix do
        for y = 1, #matrix[x] do
            matrix[x][y] = callback(matrix[x][y])
        end
    end
    return matrix
end

matrix.reduce = function(matrix, callback, initialValue)
    local accumulator = initialValue
    for x = 1, #matrix do
        for y = 1, #matrix[x] do
            accumulator = callback(accumulator, matrix[x][y])
        end
    end
    return accumulator
end

matrix.filter = function(matrix, callback)
    local filtered = {}
    for x = 1, #matrix do
        filtered[x] = {}
        for y = 1, #matrix[x] do
            if callback(matrix[x][y]) then
                filtered[x][y] = matrix[x][y]
            end
        end
    end
    return filtered
end

return matrix