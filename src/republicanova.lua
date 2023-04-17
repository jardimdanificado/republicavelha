local modulo = {}
modulo.types = require('src.republicanova.types')
modulo.util = require('src.republicanova.util')
modulo.map = require('src.republicanova.map')
local newWorld = require('src.republicanova.world')
modulo.plants = require("src.republicanova.plants")
modulo.new = function(multiHorizontal,quality)
    local data = modulo.util.bank()
    for k,v in pairs(modulo.types) do
        data:new(v,k)
        print(k)
    end
    local world = newWorld(data,multiHorizontal,quality)
    return data,world
end
return modulo