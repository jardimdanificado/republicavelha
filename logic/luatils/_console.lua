local console = {}

console.colors = 
{
    black = '\27[30m',
    reset = '\27[0m',
    red = '\27[31m',
    green = '\27[32m',
    yellow = '\27[33m',
    blue = '\27[34m',
    magenta = '\27[35m',
    cyan = '\27[36m',
    white = '\27[37m',
}

console.colorstring = function(str,color)
    return console.colors[color] .. str .. console.colors.reset
end

console.boldstring = function(str)
    return "\27[1m" .. str .. "\27[0m"
end

console.randomcolor = function()
    return console.colors[console.random(3,#console.colors)]--ignores black and reset
end

console.movecursor = function(x, y)
    return io.write("\27[" .. x .. ";" .. y .. "H")
end

return console