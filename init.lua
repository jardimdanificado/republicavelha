local modulo = {}
if not rl and not love then
    gl = '21'
    rl = require('lib.raylib')
    gl = nil
end
modulo.util = require('republicanova.luatils')
modulo.types = require('republicanova.types')
modulo.terrain = require('republicanova.terrain')
modulo.plants = modulo.types.plants
modulo.world = require('republicanova.world')
return modulo