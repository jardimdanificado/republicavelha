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

export async function World(mapsize,multiHorizontal,smooth,randomize,subdivide,postslices ,retry)
{
    return(
        {map:await Map(mapsize,multiHorizontal,smooth,randomize,subdivide,postslices ,retry)}
    )
}