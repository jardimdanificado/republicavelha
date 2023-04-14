local modulo = {}
modulo.types = require('src.republicanova.types')
modulo.util = require('src.republicanova.util')
modulo.map = require('src.republicanova.map')
modulo.world = require('src.republicanova.world')
modulo.plants = require("src.republicanova.plants")
modulo.mew = function()
    local data = modulo.util.bank()
    for k,v in pairs(modulo.types) do
        data:new(v,k)
        print(v)
    end
    return data
end
return modulo