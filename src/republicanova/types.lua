local types = {}
local Plants = require("src.republicanova.plants")

function types.integer(input)
    return math.floor(input or 1)
end

function types.float(input)
    local result = input ~= nil and input + 0 or 1.0
    return result
end

function types.string(input)
    local result = input ~= nil and input .. '' or '1'
    return result
end

function types.vector2(x,y)
    return{x=x or 1,y=y or 1}
end

function types.vector3(x,y,z)
    return{x=x or 1,y=y or 1,z=z or 1}
end

function types.collider(position,value, active)
    return{
		position = position or {x=1,y=1,z=1},
		value = value or 0,
		active = active or true,
        relatives = {},
        parent = 0
    }
end

function types.generic(type, status, birth, position, quality, condition, decayRate, mods)
    return {
        type = type or "generic",
        status = status or "",
        mods = mods or {},
        quality = quality or 100,
        condition = condition or 100,
        position = position or {x=1,y=1,z=1},
        birth = birth or 0,
        decayRate = decayRate or 0
    }
end

function types.creature(specie, status, birth, position, quality, condition)  
    local seed = types.generic('creature', status or 'idle', birth or 0, position or {x=1,y=1,z=1}, quality or 100, condition or 100)
    seed.specie = specie or 'human'
    seed.gender = gender or 'female'
    return seed
end

function types.plant(specie, status, birth, position, quality, condition) 
    local plant = types.generic('plant', status or 'idle', birth or 0, position or {x=1,y=1,z=1}, quality or 100, condition or 100)
    plant.specie = specie or 'tomato'
    plant.leaf = 0
    plant.flower = (type(Plants[plant.specie].flower) ~= nil) and {} or 0
    plant.branch = (Plants[plant.specie].type ~= 'herb') and {} or 0
    plant.trunk = (type(Plants[plant.specie].wood) ~= nil) and {} or 0
    plant.fruit = (type(Plants[plant.specie].fruit) ~= nil) and {} or 0
    return plant
end

function types.seed(specie, status, birth, position, quality, condition) 
    local seed = types.generic('seed', status or 'idle', birth or 0, position or {x=1,y=1,z=1}, quality or 100, condition or 100,2592000)
    seed.specie = specie or 'tomato'
    seed.germination = 0
    return seed
end

function types.leaf(specie, status, birth, position, quality, condition) 
    local leaf = types.generic('leaf', status or 'idle', birth or 0, position or {x=1,y=1,z=1}, quality or 100, condition or 100)
    leaf.specie = specie or 'grass'
    return leaf
end

function types.trunk(specie, status, birth, position, quality, condition) 
    local trunk = types.generic('trunk', status or 'idle', birth or 0, position or {x=1,y=1,z=1}, quality or 100, condition or 100)
    trunk.specie = specie or 'tamarind'
    return trunk
end

function types.branch(specie, status, birth, position, quality, condition) 
    local branch = types.generic('branch', status or 'idle', birth or 0, position or {x=1,y=1,z=1}, quality or 100, condition or 100)
    branch.specie = specie or 'jackfruit'
    return branch
end

function types.flower(specie, status, birth, position, quality, condition) 
    local flower = types.generic('flower', status or 'idle', birth or 0, position or {x=1,y=1,z=1}, quality or 100, condition or 100)
    flower.specie = specie or 'cannabis'
    flower.flowering = 0
    return flower
end

function types.fruit(specie, status, birth, position, quality, condition) 
    local fruit = types.generic('fruit', status or 'idle', birth or 0, position or {x=1,y=1,z=1}, quality or 100, condition or 100)
    fruit.specie = specie or 'tomato'
    fruit.maturation = maturation or 0
    fruit.seed = seed or 1
    return fruit
end

function types.block(name,solid)
    return{name = name, solid = solid}
end

return types