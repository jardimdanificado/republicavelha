import * as Terrain from './terrain.mjs';

export async function genMap(mapsize,multiHorizontal,smooth,randomize,subdivide,postslices ,retry )
{
    var terrain = await Terrain.AutoTerrain(mapsize,multiHorizontal,smooth,randomize,subdivide,postslices ,retry);
/*    for (let x = 0; x < heightmap.length; x++) 
    {
      for (let y = 0; y < heightmap[0].length; y++) 
      {
        for (let z = 0; z < heightmap.maxHeight; z++) 
        {

        }
      }
    }*/
    return {block:terrain};
  }