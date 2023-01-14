export const Util = await import("./republicavelha/essential.js");
export const Modificator = await import("./republicavelha/modificator.js");
export const Terrain = await import("./republicavelha/terrain.js");
export const Bodies = await import("./republicavelha/body.js");
export const Objecto = await import("./republicavelha/objecto.js");

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