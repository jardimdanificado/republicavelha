export const Util = await import("./republicavelha/essential.mjs");
export const Modificator = await import("./republicavelha/modificator.mjs");
export const Terrain = await import("./republicavelha/terrain.mjs");
export const Bodies = await import("./republicavelha/body.mjs");
export const Objecto = await import("./republicavelha/objecto.mjs");

export const Room = 
{
	Generic:function(objectos,collision,temperature)
	{
		return(	
			{
				map:
				{
					objecto:Util.defsto(objectos,[]),
					collision:Util.defsto(collision,[]),
					temperature:Util.defsto(temperature,[])
				}
			}
		)
	},
}
export const World = function(rooms)
{
	return(	
		{
			time:0,
			creatures:[],
			rooms:Util.defsto(rooms,[]),
		}
	)
}

//INTERPRETATION
export function frame(world)
{
	world.time++;
}