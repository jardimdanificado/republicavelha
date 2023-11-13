local util = {}

util.char = 
{
    [0] = '\0', [1] = '\x01', [2] = '\x02', [3] = '\x03', [4] = '\x04', [5] = '\x05', [6] = '\x06', [7] = '\a',
    [8] = '\b', [9] = '\t', [10] = '\n', [11] = '\v', [12] = '\f', [13] = '\r', [14] = '\x0e', [15] = '\x0f',
    [16] = '\x10', [17] = '\x11', [18] = '\x12', [19] = '\x13', [20] = '\x14', [21] = '\x15', [22] = '\x16', [23] = '\x17',
    [24] = '\x18', [25] = '\x19', [26] = '\x1a', [27] = '\x1b', [28] = '\x1c', [29] = '\x1d', [30] = '\x1e', [31] = '\x1f',
    [32] = ' ', [33] = '!', [34] = '"', [35] = '#', [36] = '$', [37] = '%', [38] = '&', [39] = "'",
    [40] = '(', [41] = ')', [42] = '*', [43] = '+', [44] = ',', [45] = '-', [46] = '.', [47] = '/',
    [48] = '0', [49] = '1', [50] = '2', [51] = '3', [52] = '4', [53] = '5', [54] = '6', [55] = '7',
    [56] = '8', [57] = '9', [58] = ':', [59] = ';', [60] = '<', [61] = '=', [62] = '>', [63] = '?',
    [64] = '@', [65] = 'A', [66] = 'B', [67] = 'C', [68] = 'D', [69] = 'E', [70] = 'F', [71] = 'G',
    [72] = 'H', [73] = 'I', [74] = 'J', [75] = 'K', [76] = 'L', [77] = 'M', [78] = 'N', [79] = 'O',
    [80] = 'P', [81] = 'Q', [82] = 'R', [83] = 'S', [84] = 'T', [85] = 'U', [86] = 'V', [87] = 'W',
    [88] = 'X', [89] = 'Y', [90] = 'Z', [91] = '[', [92] = '\\', [93] = ']', [94] = '^', [95] = '_',
    [96] = '`', [97] = 'a', [98] = 'b', [99] = 'c', [100] = 'd', [101] = 'e', [102] = 'f', [103] = 'g',
    [104] = 'h', [105] = 'i', [106] = 'j', [107] = 'k', [108] = 'l', [109] = 'm', [110] = 'n', [111] = 'o',
    [112] = 'p', [113] = 'q', [114] = 'r', [115] = 's', [116] = 't', [117] = 'u', [118] = 'v', [119] = 'w',
    [120] = 'x', [121] = 'y', [122] = 'z', [123] = '{', [124] = '|', [125] = '}', [126] = '~', [127] = '\x7f',
    [128] = '\x80', [129] = '\x81', [130] = '\x82', [131] = '\x83', [132] = '\x84', [133] = '\x85', [134] = '\x86', [135] = '\x87',
    [136] = '\x88', [137] = '\x89', [138] = '\x8a', [139] = '\x8b', [140] = '\x8c', [141] = '\x8d', [142] = '\x8e', [143] = '\x8f',
    [144] = '\x90', [145] = '\x91', [146] = '\x92', [147] = '\x93', [148] = '\x94', [149] = '\x95', [150] = '\x96', [151] = '\x97',
    [152] = '\x98', [153] = '\x99', [154] = '\x9a', [155] = '\x9b', [156] = '\x9c', [157] = '\x9d', [158] = '\x9e', [159] = '\x9f',
    [160] = '\xa0', [161] = '¡', [162] = '¢', [163] = '£', [164] = '¤', [165] = '¥', [166] = '¦', [167] = '§',
    [168] = '¨', [169] = '©', [170] = 'ª', [171] = '«', [172] = '¬', [173] = '­', [174] = '®', [175] = '¯',
    [176] = '°', [177] = '±', [178] = '²', [179] = '³', [180] = '´', [181] = 'µ', [182] = '¶', [183] = '·',
    [184] = '¸', [185] = '¹', [186] = 'º', [187] = '»', [188] = '¼', [189] = '½', [190] = '¾', [191] = '¿',
    [192] = 'À', [193] = 'Á', [194] = 'Â', [195] = 'Ã', [196] = 'Ä', [197] = 'Å', [198] = 'Æ', [199] = 'Ç',
    [200] = 'È', [201] = 'É', [202] = 'Ê', [203] = 'Ë', [204] = 'Ì', [205] = 'Í', [206] = 'Î', [207] = 'Ï',
    [208] = 'Ð', [209] = 'Ñ', [210] = 'Ò', [211] = 'Ó', [212] = 'Ô', [213] = 'Õ', [214] = 'Ö', [215] = '×',
    [216] = 'Ø', [217] = 'Ù', [218] = 'Ú', [219] = 'Û', [220] = 'Ü', [221] = 'Ý', [222] = 'Þ', [223] = 'ß',
    [224] = 'à', [225] = 'á', [226] = 'â', [227] = 'ã', [228] = 'ä', [229] = 'å', [230] = 'æ', [231] = 'ç',
    [232] = 'è', [233] = 'é', [234] = 'ê', [235] = 'ë', [236] = 'ì', [237] = 'í', [238] = 'î', [239] = 'ï',
    [240] = 'ð', [241] = 'ñ', [242] = 'ò', [243] = 'ó', [244] = 'ô', [245] = 'õ', [246] = 'ö', [247] = '÷',
    [248] = 'ø', [249] = 'ù', [250] = 'ú', [251] = 'û', [252] = 'ü', [253] = 'ý', [254] = 'þ', [255] = 'ÿ',
}

util.math = require "_math"
util.string = require "_string"
util.table = require "_table"
util.array = require "_array"
util.matrix = require "_matrix"
util.file = require "_file"
util.encode = require "_encode"
util.console = require "_console"

util.isjit = function(iftrue,ifalse)
    return (jit and jit.version) and (iftrue or true) or (ifalse or false)
end

util.luaversion = function()
    return (jit and jit.version) or _VERSION
end

util.time = function(func, ...)
    local name = 'noname'
    if type(func) == 'table' then
        func, name = func[1], func[2]
    end
    local tclock = os.clock()
    local result = func(util.array.unpack({...}))
    tclock = os.clock() - tclock
    print(name .. ": " .. tclock .. " seconds")
    return result, tclock
end

randi = 1

util.random = function(min, max)
    math.randomseed(os.time() + randi)
    randi = randi + math.random(1, 40)
    return math.random(min, max)
end

util.roleta = function(...)
    local odds = {...}
    local total = 0
    for i = 1, #odds do
        total = total + odds[i]
    end

    local random_num = util.random(1, total)
    local sum = 0
    for i = 1, #odds do
        sum = sum + odds[i]
        if random_num <= sum then
            return i
        end
    end
end

util.id = function(charTable)
    charTable = charTable or util.char
    local tablelen = #charTable
    local numbers  = util.string.replace(os.clock() .. os.time(), '%.', '')
    numbers = util.string.split(numbers, '')
    local result = ""
    for i = 1, #numbers do
        -- print 'a'
        result = result .. numbers[i]
        result = result .. charTable[util.random(1, tablelen)]
    end
    return result
end

util.assign = function(obj1,obj2)
    for k, v in pairs(obj2) do
        obj1[k] = obj2[k]
    end
end

util.len = function(obj)
    local count = 0
    for k, v in pairs(obj) do
        count = count + 1
    end
    return count
end

util.turn = function(bool)
    if bool == false then
        return true
    else
        return false
    end
end

util.load = loadstring or load

util.unix = function(ifUnix, ifWindows) -- returns ifunix if unix, if windows return ifWindows, if no args return true if is unix
    ifUnix = ifUnix or true
    ifWindows = ifWindows or false
    if package.config:sub(1, 1) == '\\' then
        return ifWindows
    else
        return ifUnix
    end
end

util.isDumpable = function(func,name)
    -- Attempt to dump the function
    local success, dumpResult = pcall(string.dump, func)
    if name and not success then
        print((name or 'noname') .. " is not dumpable.")
    end
    -- If there were no errors while dumping, the function is dumpable
    return success
end

util.stringify = function(obj, indent)
    if obj == nil then
        return ''
    end
    indent = indent or 0
    local str = ""
    local indentStr = string.rep(" ", indent ) -- Use 4 spaces for each level of indentation

    local function recursiveToString(tbl, depth)
        local tableStr = ""
        local nextDepth = depth + 1
        for k, v in pairs(tbl) do
            if type(v) == "table" then
                tableStr = tableStr .. string.rep(" ", nextDepth ) .. tostring(k) .. " = {\n"
                tableStr = tableStr .. recursiveToString(v, nextDepth)
                tableStr = tableStr .. string.rep(" ", nextDepth ) .. "},\n"
            elseif type(v) == "function" then
                -- Handle functions
                if util.isDumpable(v,k) then
                    tableStr = tableStr .. string.rep(" ", nextDepth ) .. tostring(k) .. string.dump(v)
                else
                    tableStr = tableStr .. string.rep(" ", nextDepth ) .. tostring(k) .. "<function>\n"
                end
            elseif type(v) == "boolean" then
                -- Handle booleans
                tableStr = tableStr .. string.rep(" ", nextDepth ) .. tostring(k) .. " = " .. tostring(v) .. ",\n"
            else
                -- Handle other types
                tableStr = tableStr .. string.rep(" ", nextDepth ) .. tostring(k) .. " = " .. tostring(v) .. ",\n"
            end
        end
        return tableStr
    end

    if type(obj) == "table" then
        str = str .. "{\n"
        str = str .. recursiveToString(obj, 0) -- Start with depth 0 for the initial table
        str = str .. "}"
    else
        -- Handle other types
        str = tostring(obj)
    end
    return str
end

util.visufy = function(tableToConvert, indent, visited, topLevelName)
    indent = indent or 0
    visited = visited or {}
    topLevelName = topLevelName or "Table"
    local result = string.rep(" ", indent) .. topLevelName .. " (table):\n"

    for key, value in pairs(tableToConvert) do
        local valueType = type(value)
        if valueType == "table" then
            if not visited[value] then
                visited[value] = true
                result = result .. util.visualstringify(value, indent + 2, visited, key)
                visited[value] = nil
            else
                result = result .. string.rep(" ", indent + 2) .. key .. ": Cyclic reference\n"
            end
        else
            result = result .. string.rep(" ", indent + 2) .. key .. ": " .. valueType .. "\n"
        end
    end
    return result
end

util.visualtable = function(tableToPrint, topLevelName)
    local stringRepresentation = util.visufy(tableToPrint, 0, nil, topLevelName)
    return stringRepresentation
end

util.visualstringify = function (obj,indent)
    print(util.stringify(obj,indent))
end

util.repeater = function(plist, func, args, time, _type)
  _type = _type or 0
  if not func then 
      for i,v in ipairs(plist) do
         if v.type == 1 then
             if v.clockstart + v.time < os.time() then 
               v.func(util.array.unpack(v.args))
               plist[i] = nil
               util.array.selfclear(plist)
               
               return plist
             end
          else
            if v.clockstart + v.time < os.time() then 
               plist[i] = nil
               util.array.selfclear(plist)
               return plist
            end
            v.func(util.array.unpack(v.args))
          end
      end
  else
      table.insert(plist,{clockstart=os.time(),time=time,func=func,args=args,type=_type})
  end
  return plist
end

util.agendar = function(plist, func, args, time)
  return util.repeater(plist,func,args,time,1)
end

return util