local types = {}
types.plants = {}
types.plants.orange = {
    type = 'fruit tree',
    fruit = {
        name = 'orange',
        min = 3, -- number of fruits per tree
        max = 200 -- number of fruits per tree
    },
    size = {
        min = 200, -- centimeters in diameter
        max = 400 -- centimeters in diameter
    },
    wood = 'orange wood',
    leaf = {
        name = 'orange leaf',
        min = 100, -- number of leaves per tree
        max = 1000 -- number of leaves per tree
    },
    flower = {
        name = 'orange flower',
        min = 500, -- number of flowers per tree
        max = 5000 -- number of flowers per tree
    },
    seed = {
        name = 'orange seed',
        min = 0, -- number of seeds per fruit
        max = 10 -- number of seeds per fruit
    },
    place = 'outdoor',
    time = {
        maturing = {
            min = 15552000, -- sec from blossom to fruit
            max = 25920000 -- sec from blossom to fruit
        },
        lifespan = {
            min = 315360000, -- sec (10 years)
            max = 630720000 -- sec (20 years)
        }
    }
};
types.plants.grass = {
    type = 'herb',
    size = {
        min = 5, -- centimeters
        max = 50 -- centimeters
    },
    leaf = {
        name = 'grass leaf',
        min = 50, -- leaves per plant
        max = 500 -- leaves per plant
    },
    seed = {
        name = 'grass seed',
        min = 100, -- seeds per plant
        max = 1000 -- seeds per plant
    },
    place = 'outdoor',
    time = {
        maturing = {
            min = 2592000, -- 1 month
            max = 6048000 -- 2 months
        },
        lifespan = {
            min = 60480000, -- 2 years
            max = 120960000 -- 4 years
        }
    }
};
types.plants.caju = {
    type = 'fruit tree',
    fruit = {
        name = 'caju',
        min = 1, -- number of fruits per tree
        max = 200 -- number of fruits per tree
    },
    size = {
        min = 5, -- centimeters in length
        max = 11 -- centimeters in length
    },
    wood = 'caju wood',
    leaf = {
        name = 'caju leaf',
        min = 200, -- number of leaves per tree
        max = 5000 -- number of leaves per tree
    },
    flower = {
        name = 'caju flower',
        min = 100, -- number of flowers per tree
        max = 1000 -- number of flowers per tree
    },
    seed = {
        name = 'caju seed',
        min = 1, -- number of seeds per fruit
        max = 3 -- number of seeds per fruit
    },
    place = 'outdoor',
    time = {
        maturing = {
            min = 7776000, -- seconds from blossom to fruit (90 days)
            max = 10368000 -- seconds from blossom to fruit (120 days)
        },
        lifespan = {
            min = 788940000, -- seconds (25 years)
            max = 1261440000 -- seconds (40 years)
        }
    }
};
types.plants.cannabis = {
    type = 'herb',
    size = {
        min = 60, -- centimeters
        max = 300 -- centimeters
    },
    wood = 'hemp',
    leaf = {
        name = 'cannabis leaf',
        min = 50, -- leaves per plant
        max = 300 -- leaves per plant
    },
    flower = {
        name = 'cannabis flower',
        min = 10, -- flowers per plant
        max = 100 -- flowers per plant
    },
    seed = {
        name = 'cannabis seed',
        min = 10, -- seeds per plant
        max = 100 -- seeds per plant
    },
    place = 'indoor',
    time = {
        maturing = {
            min = 4838400, -- 8 weeks
            max = 7257600 -- 12 weeks
        },
        lifespan = {
            min = 48384000, -- 14 months
            max = 72576000 -- 24 months
        }
    }
};
types.plants.tamarind = {
    type = 'fruit tree',
    fruit = {
        name = 'tamarind',
        min = 5, -- number of fruits per tree
        max = 500 -- number of fruits per tree
    },
    size = {
        min = 200, -- centimeters in length
        max = 1500 -- centimeters in length
    },
    wood = 'tamarind wood',
    leaf = {
        name = 'tamarind leaf',
        min = 500, -- number of leaves per tree
        max = 10000 -- number of leaves per tree
    },
    flower = {
        name = 'tamarind flower',
        min = 1000, -- number of flowers per tree
        max = 20000 -- number of flowers per tree
    },
    seed = {
        name = 'tamarind seed',
        min = 1, -- number of seeds per fruit
        max = 12 -- number of seeds per fruit
    },
    place = 'outdoor',
    time = {
        maturing = {
            min = 15552, -- sec from blossom to fruit
            max = 31536000 -- sec from blossom to fruit
        },
        lifespan = {
            min = 630720000, -- days (20 years)
            max = 946080000 -- days (30 years)
        }
    }
};
types.plants.rice = {
    type = 'grain',
    size = {
        min = 20,
        max = 80
    },
    leaf = {
        name = 'rice leaf',
        min = 4, -- number of leaves per plant
        max = 20 -- number of leaves per plant
    },
    flower = {
        name = 'rice flower',
        min = 1, -- number of flowers per plant
        max = 10 -- number of flowers per plant
    },
    seed = {
        name = 'rice seed',
        min = 100, -- number of seeds per plant
        max = 500 -- number of seeds per plant
    },
    place = 'paddy field',
    time = {
        maturing = {
            min = 2592000, -- seconds from seed to harvest (30 days)
            max = 5184000 -- seconds from seed to harvest (60 days)
        },
        lifespan = {
            min = 10368000, -- seconds (120 days)
            max = 15552000 -- seconds (180 days)
        }
    }
};
types.plants.starfruit = {
    type = 'fruit tree',
    fruit = {
        name = 'starfruit',
        min = 50, -- number of fruits per tree
        max = 300 -- number of fruits per tree
    },
    size = {
        min = 700, -- centimeters in length
        max = 1500 -- centimeters in length
    },
    wood = 'starfruit wood',
    leaf = {
        name = 'starfruit leaf',
        min = 500, -- number of leaves per tree
        max = 10000 -- number of leaves per tree
    },
    flower = {
        name = 'starfruit flower',
        min = 1000, -- number of flowers per tree
        max = 20000 -- number of flowers per tree
    },
    seed = {
        name = 'starfruit seed',
        min = 3, -- number of seeds per fruit
        max = 12 -- number of seeds per fruit
    },
    place = 'outdoor',
    time = {
        maturing = {
            min = 6912000, -- seconds from blossom to fruit (80 days)
            max = 10368000 -- seconds from blossom to fruit (120 days)
        },
        lifespan = {
            min = 1261440000, -- seconds (40 years)
            max = 1576800000 -- seconds (50 years)
        }
    }
};
types.plants.tomato = {
    type = 'plant',
    fruit = {
        name = 'tomato',
        min = 1, -- number of tomatoes per plant
        max = 50 -- number of tomatoes per plant
    },
    size = {
        min = 20, -- centimeters in diameter
        max = 60 -- centimeters in diameter
    },
    leaf = {
        name = 'tomato leaf',
        min = 10, -- number of leaves per plant
        max = 100 -- number of leaves per plant
    },
    flower = {
        name = 'tomato flower',
        min = 10, -- number of flowers per plant
        max = 100 -- number of flowers per plant
    },
    seed = {
        name = 'tomato seed',
        min = 10, -- number of seeds per fruit
        max = 500 -- number of seeds per fruit
    },
    place = 'outdoor',
    time = {
        maturing = {
            min = 604800, -- seconds from seed to fruit (7 days)
            max = 2419200 -- seconds from seed to fruit (28 days)
        },
        lifespan = {
            min = 15552000, -- seconds (6 months)
            max = 23328000 -- seconds (9 months)
        }
    }
};
types.plants.jackfruit = {
    type = 'fruit tree',
    fruit = {
        name = 'jackfruit',
        min = 1, -- number of fruits per tree
        max = 200 -- number of fruits per tree
    },
    size = {
        min = 1000, -- centimeters in diameter
        max = 2500 -- centimeters in diameter
    },
    wood = 'jackfruit wood',
    leaf = {
        name = 'jackfruit leaf',
        min = 500, -- number of leaves per tree
        max = 10000 -- number of leaves per tree
    },
    flower = {
        name = 'jackfruit flower',
        min = 1000, -- number of flowers per tree
        max = 20000 -- number of flowers per tree
    },
    seed = {
        name = 'jackfruit seed',
        min = 50, -- number of seeds per fruit
        max = 500 -- number of seeds per fruit
    },
    place = 'outdoor',
    time = {
        maturing = {
            min = 7776000, -- seconds from blossom to fruit (90 days)
            max = 10368000 -- seconds from blossom to fruit (120 days)
        },
        lifespan = {
            min = 788940000, -- seconds (25 years)
            max = 1261440000 -- seconds (40 years)
        }
    }
}
types.blocks =  
{
    {name = 'air',solid = false},
    {name = 'earth',solid = true},
    {name = 'rock',solid = true},
    {name = 'sand',solid = true}
}
types.fluids = 
{
    {name = 'water',density=1},--density is measured by g/cm³ and is only used for verifying which fluid block should be above
    {name = 'mud',density=1.73},
    {name = 'pee',density=1.003},
    {name = 'dog pee',density=1.035},
    {name = 'oil',density=0.850},
}
types.items = 
{
    {name="shit",size=10},--size is measured in centimeters, 100 = one full block
}

function types.vector2(x,y)
    return{x=x or 1,y=y or 1}
end

function types.vector3(x,y,z)
    return{x=x or 1,y=y or 1,z=z or 1}
end

function types.collider(position,value)
    return {
        position = position or {x=1,y=1,z=1},
        value = value or 0
    }
end

function types.fluid(fluidID,position,amount)
    return {
        position = position or {x=1,y=1,z=1},
        amount = amount or 0,
        material = fluids[fluidID]
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

function types.creature(specie, gender, status, birth, position, quality, condition)  
    local seed = types.generic('creature', status or 'idle', birth or 0, position or {x=1,y=1,z=1}, quality or 100, condition or 100)
    seed.specie = specie or 'human'
    seed.gender = gender or 'female'
    return seed
end

function types.plant(specie, status, birth, position, quality, condition) 
    local plant = types.generic('plant', status or 'idle', birth or 0, position or {x=1,y=1,z=1}, quality or 100, condition or 100)
    plant.specie = specie or 'tomato'
    plant.leaf = 0
    plant.flower = (types.plants[plant.specie].flower ~= nil) and {} or 0
    plant.branch = (types.plants[plant.specie].type ~= 'herb') and {} or 0
    plant.trunk = (types.plants[plant.specie].wood ~= nil) and {} or 0
    plant.fruit = (types.plants[plant.specie].fruit ~= nil) and {} or 0
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
    fruit.maturation = 0
    fruit.seed = 1
    return fruit
end

return types