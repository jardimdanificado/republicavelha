export const Util = await import("./republicavelha/util.mjs");
import * as _Terrain from "./republicavelha/terrain.mjs"

export const Modificator = 
{
	Storage:function(amount,type,capacity)
	{
		//solid(kg),liquid(liter),gas(m³),writing(characters)
		return{type:Util.defsto(type,'solid'),capacity:Util.defsto(capacity,1),amount:Util.defsto(amount,1)}
	},
	Modificator: function(type,subtype,status,quality,condition,func)
	{
		return(
			{
				type:type,//trait,mood,memory,
				subtype:Util.defsto(subtype,'permanent'),//permanent,temporary
				status:Util.defsto(status,'active'),
				active:true,
				quality:Util.defsto(quality,100),
				condition:Util.defsto(condition,100),
				func:Util.defsto(func,[])
			}
		);
	}
}

export const Terrain =
{
	Default:(mapsize,mwidth,smooth = false,randomize = false,subdivide = false,slices = 1, retry = 0)=>
	{
		return _Terrain.AutoTerrain(mapsize,mwidth,smooth,randomize,subdivide,slices,retry);
	}
}

export const Primitive =
{
	Generic:function(type,status,birth,position,quality,condition,mods)
	{
		return(
			{
				type:Util.defsto(type,'generic'),
				status:Util.defsto(status,''),
				mods:Util.defsto(mods,[]),
				quality:Util.defsto(quality,100),
				condition:Util.defsto(condition,100),
				position:Util.defsto(position,Util.Position(Util.Vector3Zero(),Util.Vector3Zero())),
				birth:Util.defsto(birth,0)//birth in seconds
			}
		);
	},
	Creature:function(specime,gender,birth,position)
	{
		return(
			{
				...this.Generic('creature','idle',birth,position),
				specime:specime,//human
				gender:gender,
				body:Body[specime][gender]()
			}
		);
	},
	Block:function(material,subtype,status,birth,position,quality,condition)
	{
		return(
			{
				...this.Generic('block',status,birth,position,quality,condition),
				material:Util.defsto(material,'earth'),//earth,wood,rock
				subtype:Util.defsto(subtype,'empty'),//empty,full,floor,half
			}
		);
	}
}

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