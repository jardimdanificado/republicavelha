import * as Util from "./util.mjs";
import * as Terrain from './terrain.mjs';

export async function genMap(mapsize,multiHorizontal,smooth,randomize,subdivide,postslices ,retry )
{
    var terrain = await Terrain.AutoTerrain(mapsize,multiHorizontal,smooth,randomize,subdivide,postslices ,retry);
    var temperature = Util.create3DArray(terrain.length,terrain[0].length,terrain[0][0].length,29);
    return {block:terrain,temperature:temperature};
}