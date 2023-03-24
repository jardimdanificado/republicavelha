
local util = {}
util.math = require("_util")
util.string = {}
util.file = {}
util.file.save = {}
util.file.load = {}

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

return util