import * as Util from "./util.mjs";
import { AutoTerrain } from "./terrain.mjs";
import { Creature, Plant, Seed } from "./types.mjs";
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

export const Loop = 
{
    stop:(world)=>
    {
        if(world.loop.type == 'raf')
        {
            cancelAnimationFrame(world.loop.id);
            world.loop.id = null;
        }
        else if (world.loop.type == 'interval')
        {
            clearInterval(world.loop.id);
            world.loop.id = null;
        }
    },
    start:(world,type)=>
    {
        if(typeof type == 'undefined'||(type !== 'raf'&&type !== 'interval'))
        {
            if(world.loop.type == 'raf')
            {
                if(world.loop.id != null)
                    Loop.stop(world);
                world.loop.id = Util.repeatWithAnimationFrame(Republica.World.frame,[mundo]);
            }
            else if (world.loop.type == 'interval')
            {
                if(world.loop.id != null)
                    Loop.stop(world);
                world.loop.id = Util.repeatWithInterval(Republica.World.frame,[mundo],4);
            }
        }
        else if(type == 'raf')
        {
            if(world.loop.id != null)
                Loop.stop(world);
            world.loop.type = 'raf';
            world.loop.id = Util.repeatWithAnimationFrame(Republica.World.frame,[mundo]);
        }
        else if (type == 'interval')
        {
            if(world.loop.id != null)
                Loop.stop(world);
            world.loop.type = 'interval';
            world.loop.id = Util.repeatWithInterval(Republica.World.frame,[mundo],4);
        }
    },
    switch:(world,type)=>
    {
        if(typeof type == 'undefined'||(type !== 'raf'&&type !== 'interval'))
        {
            if(world.loop.type === 'raf')
                world.loop.type = 'interval'
            else if (world.loop.type === 'interval')
                world.loop.type = 'raf';
        }
    }
};

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

//INTERPRETATION
export function frame(world)
{
	world.time++;
    if(world.plant.length>0)
    {
        world.plant = world.plant.map((seed)=>
            {
                if(seed.type == 'seed')
                {
                    if(seed.position.z > 1)
                        seed.position.z -= 1;
                    if(world.time%60==0&&typeof world.map.block[seed.position.x][seed.position.y][seed.position.z-1] !== 'undefined')
                        if(world.map.block[seed.position.x][seed.position.y][seed.position.z-1][0].material == 'earth')
                        {
                            seed.breed++;
                            if(seed.breed>=40)
                            {
                                let temp = seed.birth;
                                return(new Plant(seed.specie,seed.status,seed.birth,seed.position,seed.quality,100));
                            }
                        }
                }
                return(seed);
            }
        )
    }
}

export async function Create(mapsize,multiHorizontal,smooth,randomize,subdivide,postslices ,retry)
{
    var result = 
    {
        loop:
        {
            id:null,
            type:'raf',
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

