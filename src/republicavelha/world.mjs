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

function findTrunkGrowPosition(collisionMap,x,y,z)//this try to find a air block in the 9 above blocks
{
    if(collisionMap[x][y][z+1]  <75)//5
    {
        return {
            x:x,
            y:y,
            z:z+1
        };
    }
    else if(collisionMap[x-1][y][z+1]  <75)//4
        return {
            x:x-1,
            y:y,
            z:z
        };
    else if(collisionMap[x+1][y][z+1]  <75)//6
        return {
            x:x+1,
            y:y,
            z:z
        };
    else if(collisionMap[x+1][y+1][z+1]  <75)//3
        return {
            x:x+1,
            y:y+1,
            z:z
        };
    else if(collisionMap[x-1][y+1][z+1]  <75)//1
        return {
            x:x-1,
            y:y+1,
            z:z
        };
    else if(collisionMap[x][y+1][z+1]  <75)//2
        return {
            x:x,
            y:y+1,
            z:z
        };
    else if(collisionMap[x][y-1][z+1]  <75)//8
        return {
            x:x,
            y:y-1,
            z:z
        };
    else if(collisionMap[x+1][y-1][z+1]  <75)//9
        return {
            x:x+1,
            y:y-1,
            z:z
        };
    else if(collisionMap[x-1][y-1][z+1]  <75)//7
        return {
            x:x-1,
            y:y-1,
            z:z
        };
    else 
        return null;
}

export async function Map(mapsize,multiHorizontal,smooth,randomize,subdivide,postslices ,retry)//create the map
{
    var block = await AutoTerrain(mapsize,multiHorizontal,smooth,randomize,subdivide,postslices ,retry);
    var heightmap = block.heightmap;
    delete block.heightmap;
    var temperature = Util.create3DArray(block.length,block[0].length,block[0][0].length,29);
    var plant = Util.create3DArray(block.length,block[0].length,block[0][0].length,[]);
    var collision = block.map((value)=>
    {
        return (
                value.map((value)=>
                {
                    return (
                            value.map((value)=>
                            {
                                return (
                                    (value.material !== 'air')?100:0
                                )
                            })
                    )
                })
        )
    })
    return {
      block,
      heightmap,
      temperature,
      plant,
      collision,
    };
}

export const Life = 
{
    Spawn:
    {
        Seed:(world,specie = 'caju', status = 'idle', position = {x:0,y:0,z:0}, quality = 100, condition = 100, decayRate = 2592000/*(30days)*/)=>
        {
            world.plant.push(new Seed(specie, status, world.time, position, quality, condition, decayRate));
        },
        Plant:(world,specie = 'caju', status = 'idle', position = {x:0,y:0,z:0}, quality = 100, condition = 100)=>
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

function gravity(collisionMap,position)
{
    return(
        (position.z > 1 && collisionMap[position.x][position.y][position.z-1]<75) ? {x:position.x,y:position.y,z:position.z-1}:position
    );
}

function seedFrame(world,plant)
{
    if(typeof world.map.block[plant.position.x][plant.position.y][plant.position.z-1] !== 'undefined')
    {
        plant.position = gravity(world.map.collision,plant.position);
        if(world.time%60==0&&world.map.block[plant.position.x][plant.position.y][plant.position.z-1].material == 'earth')
        {
            plant.germination++;
            plant.status = (plant.status !== 'germinating') ? 'germinating' : plant.status;
            if(plant.status === 'germinating')
                if(plant.germination >= Plants[plant.specie].time.maturing.max/100000 || (Util.roleta(19,1) == 1&& plant.germination>=(Plants[plant.specie].time.maturing.min/100000)))
                    return(new Plant(plant.specie,plant.status,world.time,plant.position,plant.quality,100));
        }
    }
    return(plant);
}

function growLeaf(plant)
{
    if(plant.leaf.length < Plants[plant.specie].leaf.max)
        if(Util.roleta(14,1) == 1)
            plant.leaf += 1;
    return plant;
}

function growBranch(plant,time)
{
    if(plant.branch.length < Plants[plant.specie].leaf/10)
    {
        if(Util.roleta(29,1) == 1)
            plant.branch.push(new Branch(plant.specie,'idle',time,plant.position,plant.quality,plant.condition));
    }
    return plant;
}

function growTrunk(plant,collisionMap,time)
{
   
    let lastTrunkPosition = plant.position;
    if(plant.trunk.length > 0)
        lastTrunkPosition = plant.trunk[plant.trunk.length-1].position;

    var position = findTrunkGrowPosition(collisionMap,lastTrunkPosition.x,lastTrunkPosition.y,lastTrunkPosition.z);

    if(typeof position == 'undefined'||position==null)
        return plant;
    else if(plant.trunk.length < Plants[plant.specie].size.max/1000)
        if(Util.roleta(20,1) == 1)
        {
            plant.trunk.push(new Trunk(plant.specie,'idle',time,position,plant.quality,plant.condition));
        }  
    
    return plant;
}

function plantFrame(world,plant)
{
    
    if(world.time % (Plants[plant.specie].time.maturing.min/1000000)===0)
    {
        plant = growLeaf(plant);
    }

    if(Plants[plant.specie].type == 'herb')
    {

    }
    else if(Plants[plant.specie].type == 'plant')
    {
        if(world.time % (Plants[plant.specie].time.maturing.min/100000)===0)
        {
            plant = growBranch(plant,world.time);
        }
    }
    else if(Plants[plant.specie].type == 'tree'||Plants[plant.specie].type == 'fruit tree')
    {
        let lastTrunkPosition = plant.position;
        if(plant.trunk.length > 0)
            lastTrunkPosition = plant.trunk[plant.trunk.length-1].position;
        if(world.time % Util.LimitTo(Plants[plant.specie].time.maturing.min,1,1000)===0 && lastTrunkPosition.x < world.map.block[0][0].length-1)
        {
            plant = growBranch(plant,world.time);
            plant = growTrunk(plant,world.map.collision,world.time);
        }
        
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
    start:(world,type)=>
    {
        if(typeof type === 'number')
        {
            if(world.loop.id != null)
                Loop.stop(world);
            world.loop.cooldown = 4;
            world.loop.id = Util.repeatWithInterval(frame,[world],world.loop.cooldown);
        }
        else if(typeof type == 'undefined'||(type !== 'raf'&&type !== 'interval'))
        {
            if(world.loop.type == 'raf')
            {
                if(world.loop.id != null)
                    Loop.stop(world);
                world.loop.id = Util.repeatWithAnimationFrame(frame,[world]);
            }
            else if (world.loop.type == 'interval')
            {
                if(world.loop.id != null)
                    Loop.stop(world);
                world.loop.id = Util.repeatWithInterval(frame,[world],world.loop.cooldown);
            }
        }
        else if(type == 'raf')
        {
            if(world.loop.id != null)
                Loop.stop(world);
            world.loop.type = 'raf';
            world.loop.id = Util.repeatWithAnimationFrame(frame,[world]);
        }
        else if (type == 'interval')
        {
            if(world.loop.id != null)
                Loop.stop(world);
            world.loop.type = 'interval';
            world.loop.id = Util.repeatWithInterval(frame,[world],world.loop.cooldown);
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
            type:'interval',
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
        Loop.stop(result.loop);
    };
    result.loop.switch = (type)=>
    {
        Loop.switch(result.loop,type);
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

