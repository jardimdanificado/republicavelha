local _string = {}

_string.endsWith = function(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end


_string.split = function(str, separator)
    local parts = {}
    local start = 1
    separator = separator or ''
    if separator == '' then
        for i = 1, #str do
            parts[i] = string.sub(str, i, i)
        end
        return parts
    end
    local splitStart, splitEnd = string.find(str, separator, start)
    while splitStart do
        table.insert(parts, string.sub(str, start, splitStart - 1))
        start = splitEnd + 1
        splitStart, splitEnd = string.find(str, separator, start)
    end
    table.insert(parts, string.sub(str, start))
    return parts
end

_string.replace = function(inputString, oldSubstring, newSubstring)
    newSubstring = newSubstring or ''
    return inputString:gsub(oldSubstring, newSubstring)
end

_string.includes = function(str, substring)
    return string.find(str, substring, 1, true) ~= nil
end

_string.trim = function(s)
    return s:gsub("^%s+", ""):gsub("%s+$", "")
end

return _string