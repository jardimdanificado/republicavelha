local modulo = {}
modulo.types = require('src.republicanova.types')
modulo.util = require('src.republicanova.util')
modulo.terrain = require('src.republicanova.terrain')
modulo.plants = modulo.types.plants
modulo.materials = modulo.types.materials
modulo.world = require('src.republicanova.world')
return modulo