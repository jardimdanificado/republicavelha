function splitString(str, separator)
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

function fileText(path)
    print(path)
    local file = io.open(path, "r")
    local contents = file:read("*all")
    file:close()
    return contents;
end

function saveFileText(path,text)
    -- Open the file
    local file = io.open(path, "w")

    -- Write the string to the file
    file:write(text)

    -- Close the file
    file:close()
end

local Out,In = 0,arg[1]

for i=1, #arg do
    if(arg[i] == "-o") then
        if(i == 1)then
            In = arg[3]
        end
        Out = arg[i+1]
        break
    end
end

if(Out == 0)then
    Out = string.gsub(In,'.clt','.pln')
end

local origin = fileText(In)
local splited = splitString(origin,"\n")
for i=1, #splited do
    if string.find(splited[i], "--include") then
        local path = splitString(splited[i]," ")[2]
        origin = string.gsub(origin,splited[i],fileText(path))
    end
end

saveFileText(Out,origin)