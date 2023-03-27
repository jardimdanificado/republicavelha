
local util = {}


util.math = {}
util.string = {}
util.array = {}
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

util.math.limitTo = function(value, min, max)
    if value > max then
		while (value > max) do
			value = value - (max - min)
        end
	end
	if (value < min) then
		while (value < min) do
            value = value + (max - min)
        end
    end
	return value
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

return util