import * as Util from "./util.mjs";
import { AutoTerrain } from "./terrain.mjs";
import { Plant, Seed } from "./types.mjs";
import * as Plants from "./plants.mjs";

export async function Map(mapsize,multiHorizontal,smooth,randomize,subdivide,postslices ,retry)
{
    var block = await AutoTerrain(mapsize,multiHorizontal,smooth,randomize,subdivide,postslices ,retry);
    var temperature = Util.create3DArray(block.length,block[0].length,block[0][0].length,29);
    var creature = Util.create3DArray(block.length,block[0].length,block[0][0].length,[]);
    var plant = Util.create3DArray(block.length,block[0].length,block[0][0].length,[]);
    var item = Util.create3DArray(block.length,block[0].length,block[0][0].length,[]);
    return {
      block,
      temperature,
      creature,
      plant,
      item
    };
}

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

//INTERPRETATION
export function frame(world)
{
	world.time++;
}

export function startInterval(world)
{
    if(world.loop.id != null)
    {
        if(world.loop.type == 'raf')
        {
            cancelAnimationFrame(world.loop.id);
            world.loop.id = null;
            world.loop.type = null;
        }
        else if (world.loop.type == 'interval')
        {
            clearInterval(world.loop.id);
            world.loop.id = null;
            world.loop.type = null;
        }
    }
    world.loop.id = Util.repeatWithInterval(Republica.World.frame,[mundo],4);
    world.loop.type = 'interval';
}

export function startAnimationFrame(world)
{
    if(world.loop.id != null)
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
    }
    world.loop.type = 'raf';
    world.loop.id = Util.repeatWithAnimationFrame(Republica.World.frame,[mundo]);
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
        list:{creature:[],plant:[],item:[]}
    };
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
    return(result)
}

