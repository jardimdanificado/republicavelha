import * as Util from "./util.mjs";
import { AutoTerrain } from "./terrain.mjs";
import { Creature, Plant, Seed , Leaf, Trunk, Branch, Fruit, Flower, Vector3, Collider} from "./types.mjs";
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
    let directions = 
    [
        {x: -1, y: 0,z:1}, //4
        {x: 1, y: 0,z:1},  //6
        //{x: 1, y: 1,z:1},  //3
        //{x: -1, y: 1,z:1}, //1
        {x: 0, y: 1,z:1},  //2
        {x: 0, y: -1,z:1}, //8
        //{x: 1, y: -1,z:1}, //9
        //{x: -1, y: -1,z:1} //7
    ];
    directions = Util.shuffleArray(Util.shuffleArray(Util.shuffleArray(directions)));
    
    for (let opt of directions) 
    {
        if((x+opt.x >0&&y+opt.y>0&&x+opt.x <collisionMap.length&&y+opt.y <collisionMap[0].length)!== true)
            continue;
        if(collisionMap[x+opt.x][y+opt.y][z+opt.z]  <75)
            return opt;
    }
    return;
}

function findRootGrowPosition(collisionMap,x,y,z)//this try to find a air block in the 9 below blocks
{
    let directions = 
    [
        {x: -1, y: 0,z:-1}, //4
        {x: 1, y: 0,z:-1},  //6
        {x: 1, y: 1,z:-1},  //3
        {x: -1, y: 1,z:-1}, //1
        {x: 0, y: 1,z:-1},  //2
        {x: 0, y: -1,z:-1}, //8
        {x: 1, y: -1,z:-1}, //9
        {x: -1, y: -1,z:-1} //7
    ];
    directions = Util.shuffleArray(Util.shuffleArray(Util.shuffleArray(directions)));
    for (let opt of directions) 
    {
        if((x+opt.x >=0&&y+opt.y>=0&&z+opt.z >=0&&x+opt.x <collisionMap.length&&y+opt.y <collisionMap[0].length&&z+opt.z <collisionMap[0].length)!== true)
            continue;
        if(collisionMap[x+opt.x][y+opt.y][z+opt.z]  <75)
            return opt;
    }
    return;
}

function findBranchGrowPosition(collisionMap,x,y,z)//this try to find a air block in the 8 surrounding blocks, if fail try the 9 above
{
    let directions = 
    [
        {x: -1, y: 0,z:0}, //4
        {x: 1, y: 0,z:0},  //6
        {x: 1, y: 1,z:0},  //3
        {x: -1, y: 1,z:0}, //1
        {x: 0, y: 1,z:0},  //2
        {x: 0, y: -1,z:0}, //8
        {x: 1, y: -1,z:0}, //9
        {x: -1, y: -1,z:0} //7
    ];
    directions = Util.shuffleArray(Util.shuffleArray(Util.shuffleArray(directions)));
    for (let opt of directions) 
    {
        if((x+opt.x >0&&y+opt.y>0&&x+opt.x <collisionMap.length&&y+opt.y <collisionMap[0].length)!== true)
            continue;
        if(collisionMap.check(new Vector3(x+opt.x,y+opt.y,z+opt.z)))
            return opt;
    }
    return findTrunkGrowPosition(collisionMap,x,y,z);
}

export async function Map(mapsize,multiHorizontal,smooth,randomize,subdivide,postslices ,retry)//create the map
{
    var block = await AutoTerrain(mapsize,multiHorizontal,smooth,randomize,subdivide,postslices ,retry);
    var heightmap = block.heightmap;
    delete block.heightmap;
    var temperature = Util.create3DArray(block.length,block[0].length,block[0][0].length,29);
    var plant = Util.create3DArray(block.length,block[0].length,block[0][0].length,[]);
    var staticCollision = block.map((value)=>
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
    var collision = 
    {
        static:staticCollision,
        dynamic:[],
        new:(value,...positions)=>
        {
            collision.dynamic.push(new Collider(positions,value));
        },
        check:(position,value = 75)=>//returns true if no collider in the specified position, of if the colliders in the position are below value;
        {
            if(collision.static[position.x][position.y][position.z-1] > value)
            {
                return false;
            }
            for(let collider of collision.dynamic)
            {
                let tposition = collider.positions.reduce((accumulator, currentValue) => 
                {
                    return {
                      x: accumulator.x + currentValue.x,
                      y: accumulator.y + currentValue.y,
                      z: accumulator.z + currentValue.z
                    };
                });

                if(
                    tposition.x == position.x&&
                    tposition.y == position.y&&
                    tposition.z == position.z
                )
                {
                    if(collider.value>=value)
                    {
                        return false;
                    }
                    else
                        acumulator+=collider.value;

                    if(acumulator >= value)
                        return false;
                }
            }
            return true;
        }
    };
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
    let staticmap = collisionMap.static;
    if(position.z > 1 && staticmap[position.x][position.y][position.z-1]<75)
    {
        return{x:position.x,y:position.y,z:position.z-1};
    }
    else if(collisionMap.check(new Vector3(position.x,position.y,position.z-1)))
    {
        return{x:position.x,y:position.y,z:position.z-1};
    }
    return(position);
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
    if(Util.roleta(14,1,16) == 1)
        plant.leaf += 1;
    return plant;
}

function growBranch(plant,collisionMap,time)
{
    if(typeof plant.trunk != 'undefined'&& plant.trunk.length>=1&&plant.branch.length < Plants[plant.specie].leaf.max/1000&&Util.roleta(2,1,2) == 1)
    {
        let customX = Util.roleta(1,0,1)-1;
        let customY = Util.roleta(1,0,1)-1;
        
        plant.branch.unshift(new Branch(plant.specie,'idle',time,{x:customX,y:customY,z:0},plant.quality,plant.condition));
        let collisionPositions = (plant.trunk.length>1)?[plant.position,plant.trunk[1].position,plant.branch[0].position]:[plant.position,plant.trunk[0].position,plant.branch[0].position];
        collisionMap.new(collisionPositions);
    }
    return plant;
}

function growTrunk(plant,collisionMap,time)
{
    if(typeof plant.trunk !== "undefined"&&plant.trunk.length < (Plants[plant.specie].size.max/100))
    {
        let customX = Util.roleta(1,10,1)-1;
        let customY = Util.roleta(1,10,1)-1;
        for (let trunk of plant.trunk) 
        {
            trunk.position.z++;
            trunk.position.y += customY;
            trunk.position.x += customX;
        }
        for (let branch of plant.branch) 
        {
            branch.position.z++;
            branch.position.y += customY;
            branch.position.x += customX;
        }
        plant.trunk.unshift(new Trunk(plant.specie,'idle',time,{x:0,y:0,z:0},plant.quality,plant.condition));
        collisionMap.new([plant.position,plant.trunk[0]]);
    }
    return plant;
}

function plantFrame(world,plant)
{
    if(plant.leaf < Plants[plant.specie].leaf.max&&world.time % Util.LimitTo(Plants[plant.specie].time.maturing.min,0,10)===0)
    {
        if(Plants[plant.specie].size.max > 100)
        {
            if(world.time % Util.LimitTo(Plants[plant.specie].time.maturing.min,0,10)===0)
            {
                plant = growBranch(plant,world.map.collision,world.time);
            }
        }
        plant = growLeaf(plant);
    }

    if(Plants[plant.specie].type.includes('tree'))
    {
        let lastTrunkPosition = plant.position;
        if(plant.trunk.length > 0)
            lastTrunkPosition = plant.trunk[plant.trunk.length-1].position;
        if(world.time % Util.LimitTo(Plants[plant.specie].time.maturing.min,1,100)===0 && lastTrunkPosition.x < world.map.block[0][0].length-1)
        {
            plant = growTrunk(plant,world.map.collision,world.time);
        }
    }
    return(plant);
}

//INTERPRETATION
export function frame(world)
{
    //console.time('wframe')
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
    //console.timeEnd('wframe')
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
        collider:[]
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

