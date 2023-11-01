local _string = require "string"
local file = {}
file.save = {}
file.load = {}

file.list = function(folderPath)
    folderPath = folderPath or './'
    local is_windows = package.config:sub(1,1) == '\\'  -- Check if the system is Windows

    local files = {}
    local folders = {}

    local popen_cmd = is_windows and 'dir "'..folderPath..'" /b /a-d' or 'ls -p "'..folderPath..'" | grep -v /$'

    local currentDir = io.popen(popen_cmd):read("*all")

    for file in currentDir:gmatch("[^\r\n]+") do
        table.insert(files, folderPath .. "/" .. file)
    end

    if not is_windows then
        local popen_cmd_folders = 'ls -p "'..folderPath..'" | grep /$'
        local subfolders_output = io.popen(popen_cmd_folders):read("*all")

        for folder in subfolders_output:gmatch("[^\r\n]+") do
            table.insert(folders, folder:sub(1, -2))  -- Remove trailing '/'
        end
    end

    for _, subfolder in ipairs(folders) do
        local subFolderPath = folderPath .. "/" .. subfolder
        local subfolderFiles = file.list(subFolderPath)

        for _, file in ipairs(subfolderFiles) do
            table.insert(files, file)
        end
    end

    return files
end

file.isdir = function(path)
    local handle = io.popen("cd " .. path .. " 2>&1")
    local result = handle:read("*all")
    handle:close()
    return result:find("Not a directory") == nil
end

file.load.text = function(path)
    local file = io.open(path, "r")
    local contents = file:read("*all")
    file:close()
    return contents
end

file.save.text = function(path, text)
    local file = io.open(path, "w")
    file:write(text)
    file:close()
end

file.save.intMap = function(filename, matrix)
    local file = io.open(filename, "w")
    local max = 0
    for i = 1, #matrix do
        for j = 1, #matrix[i] do
            if matrix[i][j] > max then
                max = matrix[i][j]
            end
        end
    end
    local digits = #tostring(max)
    for i = 1, #matrix do
        for j = 1, #matrix[i] do
            local value = matrix[i][j]
            file:write(string.format("%0" .. digits .. "d", value))
            if j < #matrix[i] then
                file:write(" ")
            end
        end
        file:write("\n")
    end
    file:close()
end

file.save.charMap = function(filename, matrix)
    local file = io.open(filename, "w")
    for x = 1, #matrix, 1 do
        for y = 1, #matrix[x], 1 do
            if type(matrix[x][y]) == 'table' then
                file:write(matrix[x][y].id)
            else
                file:write(matrix[x][y])
            end

        end
        file:write("\n")
    end
    file:close()
end

file.load.charMap = function(filename)
    local file = io.open(filename, "r")
    local matrix = {}
    for line in file:lines() do
        local row = {}
        for i = 1, #line do
            row[i] = string.sub(line, i, i)
        end
        table.insert(matrix, row)
    end
    file:close()
    return matrix
end

file.load.map = function(filepath)
    local text = file.load.text(filepath)
    local spl = _string.split(text, "\n")
    local result = {}
    for x, v in spl do
        v = _string.split(v, " ")
        result[x] = {}
        for y, l in ipairs(v) do
            result[x][y] = l
        end
    end
    return result
end

file.exist = function(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    else
        return false
    end
end

file.check = function(path)
    local file = io.open(path, "r")
    if file then
        local info = file:read("*a")
        if info:sub(1, 4) == "RIFF" then
            return true, 'wav'
        else
            return true, 'folder'
        end
        file:close()
    else
        return false, 'none'
    end
end

return file