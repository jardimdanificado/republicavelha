local invertlabel = function(table)
    local newtable = {}
    for i, v in pairs(table) do
        if v == nil or i == nil then
            break
        end
        newtable[v] = i
    end
    return newtable
end

local ascii = {
    ['\0'] = 0, ['\x01'] = 1, ['\x02'] = 2, ['\x03'] = 3, ['\x04'] = 4, ['\x05'] = 5, ['\x06'] = 6, ['\a'] = 7,
    ['\b'] = 8, ['\t'] = 9, ['\n'] = 10, ['\v'] = 11, ['\f'] = 12, ['\r'] = 13, ['\x0e'] = 14, ['\x0f'] = 15,
    ['\x10'] = 16, ['\x11'] = 17, ['\x12'] = 18, ['\x13'] = 19, ['\x14'] = 20, ['\x15'] = 21, ['\x16'] = 22, ['\x17'] = 23,
    ['\x18'] = 24, ['\x19'] = 25, ['\x1a'] = 26, ['\x1b'] = 27, ['\x1c'] = 28, ['\x1d'] = 29, ['\x1e'] = 30, ['\x1f'] = 31,
    [' '] = 32, ['!'] = 33, ['"'] = 34, ['#'] = 35, ['$'] = 36, ['%'] = 37, ['&'] = 38, ["'"] = 39,
    ['('] = 40, [')'] = 41, ['*'] = 42, ['+'] = 43, [','] = 44, ['-'] = 45, ['.'] = 46, ['/'] = 47,
    ['0'] = 48, ['1'] = 49, ['2'] = 50, ['3'] = 51, ['4'] = 52, ['5'] = 53, ['6'] = 54, ['7'] = 55,
    ['8'] = 56, ['9'] = 57, [':'] = 58, [';'] = 59, ['<'] = 60, ['='] = 61, ['>'] = 62, ['?'] = 63,
    ['@'] = 64, ['A'] = 65, ['B'] = 66, ['C'] = 67, ['D'] = 68, ['E'] = 69, ['F'] = 70, ['G'] = 71,
    ['H'] = 72, ['I'] = 73, ['J'] = 74, ['K'] = 75, ['L'] = 76, ['M'] = 77, ['N'] = 78, ['O'] = 79,
    ['P'] = 80, ['Q'] = 81, ['R'] = 82, ['S'] = 83, ['T'] = 84, ['U'] = 85, ['V'] = 86, ['W'] = 87,
    ['X'] = 88, ['Y'] = 89, ['Z'] = 90, ['['] = 91, ['\\'] = 92, [']'] = 93, ['^'] = 94, ['_'] = 95,
    ['`'] = 96, ['a'] = 97, ['b'] = 98, ['c'] = 99, ['d'] = 100, ['e'] = 101, ['f'] = 102, ['g'] = 103,
    ['h'] = 104, ['i'] = 105, ['j'] = 106, ['k'] = 107, ['l'] = 108, ['m'] = 109, ['n'] = 110, ['o'] = 111,
    ['p'] = 112, ['q'] = 113, ['r'] = 114, ['s'] = 115, ['t'] = 116, ['u'] = 117, ['v'] = 118, ['w'] = 119,
    ['x'] = 120, ['y'] = 121, ['z'] = 122, ['{'] = 123, ['|'] = 124, ['}'] = 125, ['~'] = 126, ['\x7f'] = 127,
    ['\x80'] = 128, ['\x81'] = 129, ['\x82'] = 130, ['\x83'] = 131, ['\x84'] = 132, ['\x85'] = 133, ['\x86'] = 134, ['\x87'] = 135,
    ['\x88'] = 136, ['\x89'] = 137, ['\x8a'] = 138, ['\x8b'] = 139, ['\x8c'] = 140, ['\x8d'] = 141, ['\x8e'] = 142, ['\x8f'] = 143,
    ['\x90'] = 144, ['\x91'] = 145, ['\x92'] = 146, ['\x93'] = 147, ['\x94'] = 148, ['\x95'] = 149, ['\x96'] = 150, ['\x97'] = 151,
    ['\x98'] = 152, ['\x99'] = 153, ['\x9a'] = 154, ['\x9b'] = 155, ['\x9c'] = 156, ['\x9d'] = 157, ['\x9e'] = 158, ['\x9f'] = 159,
    ['\xa0'] = 160,
}

local iascii = invertlabel(ascii)

local enc = {}

enc.shuffleTable = function(tbl, seed)
    math.randomseed(seed)
    local backup = {}
    
    for k, v in pairs(tbl) do
        backup[k] = v
    end
    
    tbl = backup

    local newtbl = {}
    local originalSize = #tbl

    for i = 1, originalSize do
        local j = math.random(#tbl)
        newtbl[i] = tbl[j]
        table.remove(tbl, j)
    end

    return newtbl
end

enc.invertlabel = invertlabel

enc.encrypt = function(text, key)
    key = key or 123
    local irandom = enc.shuffleTable(iascii, key)
    
    local result = ''
    for i = 1, #text do
        result = result .. irandom[ascii[text:sub(i, i)]]
    end
    return result
end

enc.decrypt = function(text, key)
    key = key or 123
    local irandom = enc.shuffleTable(iascii, key)    
    local random = enc.invertlabel(irandom)
    local result = ''
    for i = 1, #text do
        result = result .. iascii[random[text:sub(i, i)]]
    end
    return result
end

-- Function to Encode Text to Base64
function enc.base64Encode(text)
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((text:gsub('.', function(x)
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#text%3+1])
end

-- Function to Decode Base64 to Text
function enc.base64Decode(data)
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

function enc.save(filename, text, key)
    local binaryData = enc.encrypt(text,key)
    local file = io.open(filename, "wb")
    if not file then
        print("Error opening file for writing:", filename)
        return false
    end

    file:write(binaryData)
    file:close()
    return true
end

-- Function to Load Text from Binary File
function enc.load(filename,key)
    local file = io.open(filename, "rb")
    if not file then
        print("Error opening file for reading:", filename)
        return nil
    end

    local binaryData = file:read("*all")
    local text = enc.decrypt(binaryData,key)
    --print(binaryData)
    file:close()
    return text
end

return enc