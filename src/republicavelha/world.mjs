import * as Util from "./util.mjs";
import * as Terrain from "./terrain.mjs";

export async function Map(mapsize,multiHorizontal,smooth,randomize,subdivide,postslices ,retry)
{
    var block = await Terrain.AutoTerrain(mapsize,multiHorizontal,smooth,randomize,subdivide,postslices ,retry);
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

export async function World(mapsize,multiHorizontal,smooth,randomize,subdivide,postslices ,retry)
{
    return(
        {
            time:0,
            map:await Map(mapsize,multiHorizontal,smooth,randomize,subdivide,postslices ,retry)
        }
    )
}

//INTERPRETATION
export function frame(world)
{

	world.time++;
}