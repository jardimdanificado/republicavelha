import * as Util from './util.mjs'
import { Generic } from '../republicavelha.mjs'

export const species =
{
    grass:
    {
        type: 'grass',
        fruit: 'none',
        size:
        {
            min: 0, // centimeters
            max: 10 // centimeters
        },
        wood: 'none',
        leaf: 'grass',
        flower: 'none',
        seed: 'nature',
        place: 'outdoor',
        time:
        {
            maturing: { min: 604800, max: 1209600 }, // 1-2 weeks
            lifespan: { min: 4838400, max: 7257600 } // 8-12 weeks
        }
    },
    cannabis:
    {
        type: 'plant',
        fruit: 'none',
        size:
        {
            min: 60, // centimeters
            max: 200 // centimeters
        },
        wood: 'hemp',
        leaf: 'cannabis leaf',
        flower: 'marijuana',
        seed: 'cannabis seed',
        place: 'indoor',
        time:
        {
            maturing: { min: 604800, max: 1209600 }, // 1-2 weeks
            lifespan: { min: 4838400, max: 7257600 } // 8-12 weeks
        }
    },
    tamarind:
    {
        type: 'tree',
        fruit: 'tamarind',
        size: { min: 1500, max: 3000 },
        wood: 'tamarind wood',
        leaf: 'tamarind leaf',
        flower: 'tamarind flower',
        seed: 'in fruit',
        place: 'outdoor',
        time:
        {
            maturing: { min: 6307200, max: 12614400 }, // 2-4 months
            lifespan: { min: 630720000, max: 946080000 } // 20-30 years
        }
    },
    beans:
    {
        type: 'legume',
        fruit: 'none',
        size: { min: 20, max: 50 }, // 20-50 cm
        wood: 'none',
        leaf: 'beans leaf',
        seed: 'beans',
        place: 'outdoor',
        time:
        {
            maturing: { min: 604800, max: 1209600 }, // 1-2 weeks
            lifespan: { min: 604800, max: 1209600 } // 1-2 weeks
        }
    },

    rice:
    {
        type: 'legume',
        fruit: 'none',
        size: { min: 60, max: 100 }, // 60-100 cm
        wood: 'none',
        leaf: 'rice leaf',
        seed: 'rice',
        place: 'outdoor',
        time:
        {
            maturing: { min: 604800, max: 1209600 }, // 1-2 weeks
            lifespan: { min: 604800, max: 1209600 } // 1-2 weeks
        }
    },

    cabbage:
    {
        type: 'vegetable',
        fruit: 'none',
        size: { min: 30, max: 40 }, // 30-40 cm
        wood: 'none',
        leaf: 'cabbage leaf',
        seed: 'cabbage seed',
        place: 'outdoor',
        time:
        {
            maturing: { min: 1209600, max: 1814400 }, // 2-3 weeks
            lifespan: { min: 4838400, max: 7257600 } // 8-12 weeks
        }
    },

    tomato:
    {
        type: 'vegetable',
        fruit: 'tomato',
        size: { min: 60, max: 180 }, // 60-180 cm
        wood: 'none',
        leaf: 'tomato leaf',
        seed: 'tomato seed',
        place: 'outdoor',
        time:
        {
            maturing: { min: 1209600, max: 2419200 }, // 2-4 weeks
            lifespan: { min: 7257600, max: 9676800 } // 12-16 weeks
        }
    },
    starFruit:
    {
        type: 'tree',
        fruit: 'star fruit',
        size: { min: 500, max: 700 }, // 500-700 cm
        wood: 'star fruit wood',
        leaf: 'star fruit leaf',
        seed: 'star fruit seed',
        place: 'outdoor',
        time:
        {
            maturing: { min: 4838400, max: 7257600 }, // 8-12 weeks
            lifespan: { min: 315360000, max: 473040000 } // 10-15 years
        }
    },
    boldo:
    {
        type: 'tree',
        fruit: 'small berry',
        size: { min: 300, max: 500 }, 
        wood: 'boldo wood',
        leaf: 'boldo leaf',
        flower: 'yellow',
        seed: 'boldo seed',
        place: 'outdoor',
        time: 
        {
            maturing: { min: 6307200, max: 9460800 }, // 2-3 months
            lifespan: { min: 631152000, max: 946728000 } // 20-30 years
        }
    },

    orange:
    {
        type: 'tree',
        fruit: 'orange',
        size: { min: 400, max: 800 }, 
        wood: 'orange wood',
        leaf: 'orange leaf',
        flower: 'white',
        seed: 'orange seed',
        place: 'outdoor',
        time: 
        {
            maturing: { min: 15768000, max: 23652000 }, // 6-9 months
            lifespan: { min: 946080000, max: 1576800000 } // 30-50 years
        }
    },

    aroeira:
    {
        type: 'tree',
        fruit: 'small berry',
        size: { min: 600, max: 1000 },
        wood: 'aroeira wood',
        leaf: 'aroeira leaf',
        flower: 'white',
        seed: 'aroeira seed',
        place: 'outdoor',
        time: 
        {
            maturing: { min: 9460800, max: 15768000 }, // 3-6 months
            lifespan: { min: 315360000, max: 630720000 } // 10-20 years
        }
    },

    jackfruit:
    {
        type: 'tree',
        fruit: 'jackfruit',
        size: { min: 800, max: 2500 },
        wood: 'jackfruit wood',
        leaf: 'jackfruit leaf',
        flower: 'yellow',
        seed: 'jackfruit seed',
        place: 'outdoor',
        time: 
        {
            maturing: { min: 7884000, max: 15768000 }, // 3-6 months
            lifespan: { min: 630720000, max: 946080000 } // 20-30 years
        }
    },

    pitomba:
    {
        type: 'tree',
        fruit: 'pitomba',
        size: { min: 300, max: 600 }, 
        wood: 'pitomba wood',
        leaf: 'pitomba leaf',
        flower: 'white',
        seed: 'pitomba seed',
        place: 'outdoor',
        time: 
        {
            maturing: { min: 7884000, max: 15768000 }, // 3-6 months
            lifespan: { min: 315360000, max: 472972800 } // 10-15 years
        }
    },
}

export class plant extends Generic
{
    constructor(specie = 'cannabis', status = 'idle', birth = 0, position = Util.Vector3Zero(), quality = 100, condition = 100) 
    {
        super('plant', status, birth, position, quality, condition);
        this.specie = specie;
    }
}

export class seed extends Generic 
{
    constructor(specie = 'cannabis', status = 'idle', birth = 0, position = Util.Vector3Zero(), quality = 100, condition = 100, decayRate = 2592000/*(30days)*/) 
    {
        super('seed', status, birth, position, quality, condition,decayRate);
        this.specie = specie;
    }
}
