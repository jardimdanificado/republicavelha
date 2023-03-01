import * as Util from "./util.mjs";
import { AutoTerrain } from "./terrain.mjs";
import { Creature, Plant, Seed , Leaf, Trunk, Branch, Fruit, Flower} from "./types.mjs";
import * as Plants from "./plants.mjs";

function getHourOfDay(totalSeconds) 
{
    return Math.floor(totalSeconds / 3600) % 24;
}

function getMinuteOfDay(totalSeconds) 
{
    return Math.floor((totalSeconds % 3600) / 60);
}

function getSecondOfDay(totalSeconds) 
{
    return totalSeconds % 60;
}

function getSunIntensity(minHour, maxHour, seconds) 
{
    const hours = (seconds / 3600) % 24; // convert to hours and wrap around 24 hours
    const hourRange = maxHour - minHour;
    const currentHour = (hours + 6) % 24; // add 6 to offset for range from 6am to 6pm
    const intensity = (currentHour < minHour || currentHour > maxHour) ? 0 :
                      (currentHour === (minHour + hourRange / 2)) ? 100 :
                      (currentHour < (minHour + hourRange / 2)) ?
                      ((currentHour - minHour) / (hourRange / 2) * 100) :
                      ((maxHour - currentHour) / (hourRange / 2) * 100);
    return intensity;
}

export async function Map(mapsize,multiHorizontal,smooth,randomize,subdivide,postslices ,retry)
{
    var block = await AutoTerrain(mapsize,multiHorizontal,smooth,randomize,subdivide,postslices ,retry);
    var heightmap = block.heightmap;
    delete block.heightmap;
    var temperature = Util.create3DArray(block.length,block[0].length,block[0][0].length,29);
    var plant = Util.create3DArray(block.length,block[0].length,block[0][0].length,[]);
    return {
      block,
      heightmap,
      temperature,
      plant,
    };
}

export const Life = 
{
    Spawn:
    {
        Seed:(world,specie = 'cannabis', status = 'idle', position = {x:0,y:0,z:0}, quality = 100, condition = 100, decayRate = 2592000/*(30days)*/)=>
        {
            world.plant.push(new Seed(specie, status, world.time, position, quality, condition, decayRate));
        },
        Plant:(world,specie = 'cannabis', status = 'idle', position = {x:0,y:0,z:0}, quality = 100, condition = 100)=>
        {
            let newobject = new Plant(specie, status, world.time, position, quality, condition, decayRate);
            world.plant.push(newobject);
            world.map.plant[position.x][position.y][position.z].push(newobject);
        },
        Creature:(world,specie = 'human', gender = 'female', status = 'idle', position = {x:0,y:0,z:0}, quality = 100, condition = 100)=>
        {
            world.creature.push(new Creature(specie,gender,status,world.time,position,quality,condition))
        }
    }
}

function gravity(blockMap,position)
{
    return(
        (position.z > 1 && blockMap[position.x][position.y][position.z-1][0].material == 'air') ? {x:position.x,y:position.y,z:position.z-1}:position
    );
}

function seedFrame(world,plant)
{
    if(typeof world.map.block[plant.position.x][plant.position.y][plant.position.z-1] !== 'undefined')
    {
        plant.position = gravity(world.map.block,plant.position);
        if(world.time%60==0&&world.map.block[plant.position.x][plant.position.y][plant.position.z-1][0].material == 'earth')
        {
            plant.germination++;
            plant.status = (plant.status !== 'germinating') ? 'germinating' : plant.status;
            if(plant.status === 'germinating')
                if(plant.germination >= Plants[plant.specie].time.maturing.max/10000 || (Util.roleta(1,19) == 1&& plant.germination>=(Plants[plant.specie].time.maturing.min/10000)))
                    return(new Plant(plant.specie,plant.status,world.time,plant.position,plant.quality,100));
        }
    }
    return(plant);
}

function plantFrame(world,plant)
{

    switch(plant.type)
    {
        case 'herb':
        {
            if(world.time % (Plants[plant.specie].time.maturing/100000)===0)
            {
                if(plant.leaf.length < Plants[plant.specie].leaf.max)
                    plant.leaf.push(new Leaf(plant.specie,'idle',world.time,plant.position,plant.quality,plant.condition));
            }
        }
        break;
    }
    return(plant);
}

//INTERPRETATION
export function frame(world)
{
	world.time++;
    if(world.plant.length>0)
    {
        world.plant = world.plant.map((plant)=>
            {
                if(plant.type == 'seed')
                {
                    return(seedFrame(world,plant));
                }
                if(plant.type == 'plant')
                {
                    return(plantFrame(world,plant));
                }
                return(plant);
            }
        )
    }
}

export const Loop = 
{
    stop:(wLoop)=>
    {
        if(wLoop.type == 'raf')
        {
            cancelAnimationFrame(wLoop.id);
            wLoop.id = null;
        }
        else if (wLoop.type == 'interval')
        {
            clearInterval(wLoop.id);
            wLoop.id = null;
        }
    },
    start:(wLoop,type)=>
    {
        if(typeof type === 'number')
        {
            if(wLoop.id != null)
                Loop.stop(world);
            wLoop.cooldown = 4;
            wLoop.id = Util.repeatWithInterval(Republica.World.frame,[mundo],wLoop.cooldown);
        }
        else if(typeof type == 'undefined'||(type !== 'raf'&&type !== 'interval'))
        {
            if(wLoop.type == 'raf')
            {
                if(wLoop.id != null)
                    Loop.stop(world);
                wLoop.id = Util.repeatWithAnimationFrame(Republica.World.frame,[mundo]);
            }
            else if (wLoop.type == 'interval')
            {
                if(wLoop.id != null)
                    Loop.stop(world);
                wLoop.id = Util.repeatWithInterval(Republica.World.frame,[mundo],wLoop.cooldown);
            }
        }
        else if(type == 'raf')
        {
            if(wLoop.id != null)
                Loop.stop(world);
            wLoop.type = 'raf';
            wLoop.id = Util.repeatWithAnimationFrame(Republica.World.frame,[mundo]);
        }
        else if (type == 'interval')
        {
            if(wLoop.id != null)
                Loop.stop(world);
            wLoop.type = 'interval';
            wLoop.id = Util.repeatWithInterval(Republica.World.frame,[mundo],wLoop.cooldown);
        }
    },
    reboot:(wLoop)=>
    {
        Loop.stop(wLoop);
        Loop.start(wLoop);
    },
    switch:(wLoop,type)=>
    {
        if(typeof type === 'number')
        {
            wLoop.type = 'interval';
            wLoop.cooldown = type;
            Loop.reboot(wLoop);
        }
        else if(typeof type == 'undefined'||(type !== 'raf'&&type !== 'interval'))
        {
            if(wLoop.type === 'raf')
                wLoop.type = 'interval'
            else if (wLoop.type === 'interval')
                wLoop.type = 'raf';
        }
    }
};

export async function New(mapsize,multiHorizontal,smooth,randomize,subdivide,postslices ,retry)
{
    var result = 
    {
        loop:
        {
            id:null,
            type:'raf',
            cooldown:4//only for interval
        },//types: raf(requireAnimationFrame), interval(setInterval)
        time:0,
        map:await Map(mapsize,multiHorizontal,smooth,randomize,subdivide,postslices ,retry),
        creature:[],
        plant:[],
        item:[],
    };
    //LOOP FUNCTIONS
    result.loop.start = (type)=>
    {
        Loop.start(result,type);
    };
    result.loop.stop = ()=>
    {
        Loop.stop(result);
    };
    result.loop.switch = (type)=>
    {
        Loop.switch(result,type);
    }
    //SPAWN FUNCTIONS
    result.plant.spawn = (type = 'seed', specie, status, position, quality, condition)=>
    {
        if(type == 'seed')
            Life.Spawn.Seed(result,specie, status, position, quality, condition);
        else if(type == 'plant')
            Life.Spawn.Plant(result,specie, status, position, quality, condition);
    }
    return(result)
}

