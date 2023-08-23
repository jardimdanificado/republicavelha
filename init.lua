local modulo = {}
modulo.util = require(mocegui and 'mocegui.luatils' or 'luatils')
modulo.types = require('republicanova.types')
modulo.terrain = require('republicanova.terrain')
modulo.plants = modulo.types.plants
modulo.world = require('republicanova.world')
return modulo