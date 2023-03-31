local util = {}

util.math = {}
util.string = {}
util.array = {}
util.matrix = {}
util.file = {}
util.file.save = {}
util.file.load = {}
util.func = {}

util.array.unpack = unpack or table.unpack

util.math.vec2 = function(x, y)
    return {x=x, y=y}
end

util.math.vec2add = function(vec0, vec1)
    return 
    {
        x = vec0.x + vec1.x,
        y = vec0.y + vec1.y
    }
end

util.math.vec2sub = function(vec0, vec1)
    return 
    {
        x = vec0.x - vec1.x,
        y = vec0.y - vec1.y
    }
end

util.math.vec2div = function(vec0, vec1)
    return 
    {
        x = vec0.x / vec1.x,
        y = vec0.y / vec1.y
    }
end

util.math.vec2mod = function(vec0, vec1)
    return 
    {
        x = vec0.x % vec1.x,
        y = vec0.y % vec1.y
    }
end

util.math.vec2mul = function(vec0, vec1)
    return 
    {
        x = vec0.x * vec1.x,
        y = vec0.y * vec1.y
    }
end

util.math.vec3 = function(x, y, z)
    return {x=x, y=y, z=z}
end

util.math.vec3add = function(vec0, vec1)
    return 
    {
        x = vec0.x + vec1.x,
        y = vec0.y + vec1.y,
        z = vec0.z + vec1.z
    }
end

util.math.vec3sub = function(vec0, vec1)
    return 
    {
        x = vec0.x - vec1.x,
        y = vec0.y - vec1.y,
        z = vec0.z - vec1.z
    }
end

util.math.vec3mul = function(vec0, vec1)
    return 
    {
        x = vec0.x * vec1.x,
        y = vec0.y * vec1.y,
        z = vec0.z * vec1.z
    }
end

util.math.vec3div = function(vec0, vec1)
    return 
    {
        x = vec0.x / vec1.x,
        y = vec0.y / vec1.y,
        z = vec0.z / vec1.z
    }
end

util.math.vec3mod = function(vec0, vec1)
    return 
    {
        x = vec0.x % vec1.x,
        y = vec0.y % vec1.y,
        z = vec0.z % vec1.z
    }
end

util.math.limit = function(value, min, max)
    local range = max - min
    if range <= 0 then
        return min
    end
    local offset = (value - min) % range
    return offset + min + (offset < 0 and range or 0)
end

util.math.rotate = function(position, pivot, angle)
    -- convert angle to radians
    angle = math.rad(angle)
    
    -- calculate sine and cosine of angle
    local s = math.sin(angle)
    local c = math.cos(angle)
    
    -- translate position so that pivot is at the origin
    local translated = util.math.vec3sub(position,{x=pivot.x,y=pivot.y,z=pivot.z})
    
    -- apply rotation
    local rotated =
    {
        x=translated.x * c - translated.z * s,
        y=position.y,
        z=translated.x * s + translated.z * c
    }
    
    -- translate back to original position
    return util.math.vec3add(rotated,{x=pivot.x,y=0,z=pivot.z})
end  

util.string.split = function(str, separator)
    local parts = {}
    local start = 1
    local splitStart, splitEnd = string.find(str, separator, start)
    while splitStart do
        table.insert(parts, string.sub(str, start, splitStart - 1))
        start = splitEnd + 1
        splitStart, splitEnd = string.find(str, separator, start)
    end
    table.insert(parts, string.sub(str, start))
    return parts
end

util.string.includes = function(str,substring)
    return string.find(str, substring, 1, true) ~= nil
end

util.file.load.text = function(path)
    local file = io.open(path, "r")
    local contents = file("*all")
    file:close()
    return contents
end

util.file.save.text = function(path, text)
    local file = io.open(path, "w")
    file:write(text)
    file:close()
end

util.array.slice = function(arr, start, final)
    local sliced_array = {}
    for i = start, final do
        table.insert(sliced_array, arr[i])
    end
    return sliced_array
end

util.array.organize = function(arr, parts)
    local columns,rows = parts,parts
    local matrix = {}
    for i = 1, rows do
        matrix[i] = {}
        for j = 1, columns do
            local index = (i - 1) * columns + j
            matrix[i][j] = arr[index]
        end
    end
    
    return matrix
end

util.array.expand = function(matrix)
    local nSubMatrices = #matrix
    local subMatrixSize = #matrix[1]

    local result = {}

    for i = 1, nSubMatrices * subMatrixSize do
        result[i] = {}
        for j = 1, nSubMatrices * subMatrixSize do
            local subMatrixIndexI = math.ceil(i / subMatrixSize)
            local subMatrixIndexJ = math.ceil(j / subMatrixSize)
            local subMatrix = matrix[subMatrixIndexI][subMatrixIndexJ]
            local subMatrixRow = (i - 1) % subMatrixSize + 1
            local subMatrixCol = (j - 1) % subMatrixSize + 1
            result[i][j] = subMatrix[subMatrixRow][subMatrixCol]
        end
    end

    return result
end

util.array.new = function(size,value)
    local result = {}
    value = value or 0
    for i = 1, size do
        result[i] = value
    end
    return result
end

util.array.shuffle = function(arr)
	for i = #arr, 1, -1 do
	  local j = math.floor(math.random(1,#arr))
	  arr[i], arr[j] = arr[j], arr[i]
	end
	return arr
end

util.array.minmax = function(arr)
    local min = arr[1]
    local max = arr[1]
    for y = 1, #arr do
        if(arr[y] > max) then
            max = arr[y]
        elseif(arr[y] < min) then
            min = arr[y]
        end
    end
    return {min=min,max=max}
end

util.array.sum = function(arr)
    local sum = 0
    for i = 1, #arr, 1 do
        sum = sum + arr[i] 
    end
    return sum
end

util.array.map = function(arr, callback)
    local result = {}
    for i = 1, #arr do
        result[i] = callback(arr[i])
    end
    return result
    end
    
util.array.filter = function(arr, callback)
    local result = {}
    for i = 1, #arr do
        if callback(arr[i]) then
            table.insert(result, arr[i])
        end
    end
    return result
end
    
util.array.reduce = function(arr, callback, initial)
    local accumulator = initial
    for i = 1, #arr do
        accumulator = callback(accumulator, arr[i])
    end
    return accumulator
end

util.matrix.new = function(sizex,sizey,sizez,value)
    local result = {}
    value = value or 0
    for x = 1, sizex do
        result[x] = {}
        for y = 1, sizey do
            if(value ~= nil) then
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

util.matrix.minmax = function(matrix)
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
    return {min = min_val, max = max_val}
end

util.matrix.unique = function(matrix)
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
    --print(unique_vals[4],unique_vals[8])
    return unique_vals
end

util.matrix.average = function(matrix)
    local sum,count = 0,0
    for x = 1, #matrix do
        for y = 1, #matrix[x] do
            sum = sum + matrix[x][y]
            count = count + 1
        end
    end
    return(sum/count)
end

util.matrix.map = function(matrix, callback)
    for x = 1, #matrix do
        for y = 1, #matrix[x] do
            matrix[x][y] = callback(matrix[x][y])
        end
    end
    return matrix
end

util.matrix.reduce = function(matrix, callback, initialValue)
    local accumulator = initialValue
    for x = 1, #matrix do
        for y = 1, #matrix[x] do
            accumulator = callback(accumulator, matrix[x][y])
        end
    end
    return accumulator
end

util.matrix.filter = function(matrix, callback)
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

util.func.time = function(func,...)
    local name = 'noname'
    if type(func) == 'table' then
        func,name = func[1],func[2]
    end
    local tclock = os.clock()
    local result = func(util.array.unpack({...}))
    tclock = os.clock()-tclock
    print(name .. ": " .. tclock .. " seconds")
    return result,tclock
end

util.roleta = function(...) 
  local odds = {...}
	local roleta = {} 
	for i = 1,#odds do
    table.concat(roleta,util.array.new(odds[i],i))
		--roleta = roleta.concat(Array(odds[i]).fill(i));
	  return(util.array.shuffle(util.array.shuffle(util.array.shuffle(roleta)))[math.random(1,#roleta)])
  end
end

util.file.save.heightmap = function(matrix, filename)
    local file = io.open(filename, "w")
    local max = 0
    for i=1,#matrix do
        for j=1,#matrix[i] do
            if matrix[i][j] > max then
                max = matrix[i][j]
            end
        end
    end
    local digits = #tostring(max)
    for i=1,#matrix do
        for j=1,#matrix[i] do
            local value = matrix[i][j]
            if (i > 1 and matrix[i-1][j] == value - 1) or (i < #matrix and matrix[i+1][j] == value - 1) or (j > 1 and matrix[i][j-1] == value - 1) or (j < #matrix[i] and matrix[i][j+1] == value - 1) then
                file:write(string.rep(">", digits))
            else
                file:write(string.format("%0"..digits.."d", value))
            end
            if j < #matrix[i] then
                file:write(" ")
            end
        end
        file:write("\n")
    end
    file:close()
end

util.file.exist = function(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    else
        return false
    end
end

util.file.isFile = function(path)
    local mode = lfs.attributes(path, "mode")
    return mode == "file"
end

util.file.check = function(path)
    local file = io.open(path, "r")
    if file then
    local info = file:read("*a")
    if info:sub(1,4) == "RIFF" then
        return true,'wav'
    else
        return true,'folder'
    end
    file:close()
    else
        return false,'none'
    end

end

util.math.regrad3 = function(a, b, d) 
    local c = (a * d) / b
    return c
end

util.math.scale = function(value, min, max) 
    if (value > max) then
        while (value > max) do
            value = value - max - min
        end
    end
    if (value < min) then
        while (value < min) do
            value = value + (max - min)
        end
    end
    value = util.math.regrad3(max-min,100,value-min)
    return value;
end

return util