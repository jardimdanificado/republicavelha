import * as Util from './util.mjs'
import { Generic } from '../republicavelha.mjs'

export const species =
{
    grass: {
        type: 'herb',
        fruit: null,
        size:
        {
            min: 5, // centimeters
            max: 50 // centimeters
        },
        wood: null,
        leaf:
        {
            name: 'grass leaf',
            min: 50, // leaves per plant
            max: 500 // leaves per plant
        },
        flower:
        {
            name: 'grass flower',
            min: 0, // flowers per plant
            max: 0 // flowers per plant
        },
        seed:
        {
            name: 'grass seed',
            min: 100, // seeds per plant
            max: 1000 // seeds per plant
        },
        place: 'outdoor',
        time:
        {
            maturing:
            {
                min: 2592000, // 1 month
                max: 6048000 // 2 months
            },
            lifespan:
            {
                min: 60480000, // 2 years
                max: 120960000 // 4 years
            }
        }
    },
    cannabis:
    {
        type: 'herb',
        fruit: null,
        size:
        {
            min: 60, // centimeters
            max: 300 // centimeters
        },
        wood: 'hemp',
        leaf:
        {
            name: 'cannabis leaf',
            min: 50, // leaves per plant
            max: 300 // leaves per plant
        },
        flower:
        {
            name: 'cannabis flower',
            min: 10, // flowers per plant
            max: 100 // flowers per plant
        },
        seed:
        {
            name: 'cannabis seed',
            min: 10, // seeds per plant
            max: 100 // seeds per plant
        },
        place: 'indoor',
        time:
        {
            maturing:
            {
                min: 4838400, // 8 weeks
                max: 7257600 // 12 weeks
            },
            lifespan:
            {
                min: 48384000, // 14 months
                max: 72576000 // 24 months
            }
        }
    },
    orange: {
        type: 'fruit',
        fruit: {
            name: 'orange',
            min: 3, // number of fruits per tree
            max: 200 // number of fruits per tree
        },
        size: {
            min: 5, // centimeters in diameter
            max: 10 // centimeters in diameter
        },
        wood: 'orange wood',
        leaf: {
            name: 'orange leaf',
            min: 100, // number of leaves per tree
            max: 1000 // number of leaves per tree
        },
        flower: {
            name: 'orange flower',
            min: 500, // number of flowers per tree
            max: 5000 // number of flowers per tree
        },
        seed: {
            name: 'orange seed',
            min: 0, // number of seeds per fruit
            max: 10 // number of seeds per fruit
        },
        place: 'outdoor',
        time: {
            maturing: {
                min: 15552000, // sec from blossom to fruit
                max: 25920000 // sec from blossom to fruit
            },
            lifespan: {
                min: 315360000, // sec (10 years)
                max: 630720000 // sec (20 years)
            }
        }
    },
    tamarind: {
        type: 'fruit',
        fruit: {
          name: 'tamarind',
          min: 5, // number of fruits per tree
          max: 500 // number of fruits per tree
        },
        size: {
          min: 2, // centimeters in length
          max: 15 // centimeters in length
        },
        wood: 'tamarind wood',
        leaf: {
          name: 'tamarind leaf',
          min: 500, // number of leaves per tree
          max: 10000 // number of leaves per tree
        },
        flower: {
          name: 'tamarind flower',
          min: 1000, // number of flowers per tree
          max: 20000 // number of flowers per tree
        },
        seed: {
          name: 'tamarind seed',
          min: 1, // number of seeds per fruit
          max: 12 // number of seeds per fruit
        },
        place: 'outdoor',
        time: {
          maturing: {
            min: 15552000, // sec from blossom to fruit
            max: 31536000 // sec from blossom to fruit
          },
          lifespan: {
            min: 630720000, // days (20 years)
            max: 946080000 // days (30 years)
          }
        }
      },
      starfruit: {
        type: 'fruit',
        fruit: {
          name: 'starfruit',
          min: 50, // number of fruits per tree
          max: 300 // number of fruits per tree
        },
        size: {
          min: 7, // centimeters in length
          max: 15 // centimeters in length
        },
        wood: 'starfruit wood',
        leaf: {
          name: 'starfruit leaf',
          min: 500, // number of leaves per tree
          max: 10000 // number of leaves per tree
        },
        flower: {
          name: 'starfruit flower',
          min: 1000, // number of flowers per tree
          max: 20000 // number of flowers per tree
        },
        seed: {
          name: 'starfruit seed',
          min: 3, // number of seeds per fruit
          max: 12 // number of seeds per fruit
        },
        place: 'outdoor',
        time: {
          maturing: {
            min: 6912000, // seconds from blossom to fruit (80 days)
            max: 10368000 // seconds from blossom to fruit (120 days)
          },
          lifespan: {
            min: 1261440000, // seconds (40 years)
            max: 1576800000 // seconds (50 years)
          }
        }
      },
      jackfruit: {
        type: 'fruit',
        fruit: {
          name: 'jackfruit',
          min: 1, // number of fruits per tree
          max: 200 // number of fruits per tree
        },
        size: {
          min: 30, // centimeters in diameter
          max: 100 // centimeters in diameter
        },
        wood: 'jackfruit wood',
        leaf: {
          name: 'jackfruit leaf',
          min: 500, // number of leaves per tree
          max: 10000 // number of leaves per tree
        },
        flower: {
          name: 'jackfruit flower',
          min: 1000, // number of flowers per tree
          max: 20000 // number of flowers per tree
        },
        seed: {
          name: 'jackfruit seed',
          min: 50, // number of seeds per fruit
          max: 500 // number of seeds per fruit
        },
        place: 'outdoor',
        time: {
          maturing: {
            min: 7776000, // seconds from blossom to fruit (90 days)
            max: 10368000 // seconds from blossom to fruit (120 days)
          },
          lifespan: {
            min: 788940000, // seconds (25 years)
            max: 1261440000 // seconds (40 years)
          }
        }
      },
      caju: {
        type: 'fruit',
        fruit: {
          name: 'caju',
          min: 1, // number of fruits per tree
          max: 200 // number of fruits per tree
        },
        size: {
          min: 5, // centimeters in length
          max: 11 // centimeters in length
        },
        wood: 'caju wood',
        leaf: {
          name: 'caju leaf',
          min: 200, // number of leaves per tree
          max: 5000 // number of leaves per tree
        },
        flower: {
          name: 'caju flower',
          min: 100, // number of flowers per tree
          max: 1000 // number of flowers per tree
        },
        seed: {
          name: 'caju seed',
          min: 1, // number of seeds per fruit
          max: 3 // number of seeds per fruit
        },
        place: 'outdoor',
        time: {
          maturing: {
            min: 7776000, // seconds from blossom to fruit (90 days)
            max: 10368000 // seconds from blossom to fruit (120 days)
          },
          lifespan: {
            min: 788940000, // seconds (25 years)
            max: 1261440000 // seconds (40 years)
          }
        }
      },
      rice: {
        type: 'grain',
        fruit: null,
        size: {
          min: 2, // millimeters in length
          max: 8 // millimeters in length
        },
        wood: null,
        leaf: {
          name: 'rice leaf',
          min: 4, // number of leaves per plant
          max: 20 // number of leaves per plant
        },
        flower: {
          name: 'rice flower',
          min: 1, // number of flowers per plant
          max: 10 // number of flowers per plant
        },
        seed: {
          name: 'rice seed',
          min: 100, // number of seeds per plant
          max: 500 // number of seeds per plant
        },
        place: 'paddy field',
        time: {
          maturing: {
            min: 2592000, // seconds from seed to harvest (30 days)
            max: 5184000 // seconds from seed to harvest (60 days)
          },
          lifespan: {
            min: 10368000, // seconds (120 days)
            max: 15552000 // seconds (180 days)
          }
        }
      },
      tomato: {
        type: 'fruit',
        fruit: {
          name: 'tomato',
          min: 1, // number of tomatoes per plant
          max: 50 // number of tomatoes per plant
        },
        size: {
          min: 2, // centimeters in diameter
          max: 10 // centimeters in diameter
        },
        wood: null,
        leaf: {
          name: 'tomato leaf',
          min: 10, // number of leaves per plant
          max: 100 // number of leaves per plant
        },
        flower: {
          name: 'tomato flower',
          min: 10, // number of flowers per plant
          max: 100 // number of flowers per plant
        },
        seed: {
          name: 'tomato seed',
          min: 10, // number of seeds per fruit
          max: 500 // number of seeds per fruit
        },
        place: 'outdoor',
        time: {
          maturing: {
            min: 604800, // seconds from seed to fruit (7 days)
            max: 2419200 // seconds from seed to fruit (28 days)
          },
          lifespan: {
            min: 15552000, // seconds (6 months)
            max: 23328000 // seconds (9 months)
          }
        }
      }      
}

export class plant extends Generic {
    constructor(specie = 'cannabis', status = 'idle', birth = 0, position = Util.Vector3Zero(), quality = 100, condition = 100) {
        super('plant', status, birth, position, quality, condition);
        this.specie = specie;
    }
}

export class seed extends Generic {
    constructor(specie = 'cannabis', status = 'idle', birth = 0, position = Util.Vector3Zero(), quality = 100, condition = 100, decayRate = 2592000/*(30days)*/) {
        super('seed', status, birth, position, quality, condition, decayRate);
        this.specie = specie;
    }
}
