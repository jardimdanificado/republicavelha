local newWorld = require('src.republicanova.world')
local modulo = {}
modulo.types = require('src.republicanova.types')
modulo.util = require('src.republicanova.util')
modulo.map = require('src.republicanova.map')
modulo.plants = require("src.republicanova.plants")
modulo.new = function(multiHorizontal,quality)
    local colliders = modulo.util.bank()
    local world = newWorld(data,multiHorizontal,quality)

    return data,world
end
return modulo