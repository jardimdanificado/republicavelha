local modulo = {}
if not rl then
    gl = '21'
    rl = require('lib.raylib')
    gl = nil
end
modulo.types = require('src.republicanova.types')
modulo.util = require('src.republicanova.util')
modulo.terrain = require('src.republicanova.terrain')
modulo.plants = modulo.types.plants
modulo.world = require('src.republicanova.world')
return modulo