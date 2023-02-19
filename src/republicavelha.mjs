export const Util = await import("./republicavelha/essential.mjs");
import * as _Terrain from "./republicavelha/terrain.mjs"

export const Modificator = 
{
	Storage:function(amount,type,capacity)
	{
		//solid(kg),liquid(liter),gas(m³),writing(characters)
		return{type:Util.defsto(type,'solid'),capacity:Util.defsto(capacity,1),amount:Util.defsto(amount,1)}
	},
	Limb:function(type,importance,condition)
	{
		return(
			{
				type:Util.defsto(type,'breeder'),//all,viewer,breeder,eater,grabber,speaker,listener,smeller,breather,thinker,pisser,shitter,walker,other
				importance:Util.defsto(importance,10),//0 = NO IMPORTANCE, 10 = VERY IMPORTANT, INFINITY = ESSENTIAL
				quality:100,
				condition:Util.defsto(condition,100)
			}
		);
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

export const Body = 
{
	human:
	{
		_both:
		{
			eye:Array(2).fill(Modificator.Limb('viewer')),
			hand:Array(2).fill(Modificator.Limb('grabber')),
			feet:Array(2).fill(Modificator.Limb('walker')),
			finger:Array(10).fill(Modificator.Limb('grabber',1)).concat(Array(10).fill(Modificator.Limb('walker',1))),
			nail:Array(10).fill(Modificator.Limb('grabber',1)).concat(Array(10).fill(Modificator.Limb('walker',1))),
			arm:Array(2).fill(Modificator.Limb('grabber')),
			leg:Array(2).fill(Modificator.Limb('walker')),
			ear:Array(2).fill(Modificator.Limb('listener')),
			mouth:Modificator.Limb('eater'),
			teeth:Array(32).fill(Modificator.Limb('eater',1)),
			nose:Modificator.Limb('smeller,breather','10,2'),
			lung:Array(2).fill(Modificator.Limb('breather',8)),
			neck:Modificator.Limb('all',Infinity),
			head:Modificator.Limb('all',Infinity),
			brain:Modificator.Limb('thinker'),
			torso:Modificator.Limb('all',Infinity),
			anus:Modificator.Limb('shitter'),
		},
		_male:
		{
			penis:Modificator.Limb('breeder,pisser'),
			testicule:Array(2).fill(Modificator.Limb('breeder')),	
		},
		_female:
		{
			vagina:Modificator.Limb('breeder,pisser'),
			ovary:Array(2).fill(Modificator.Limb('breeder')),	
		},
		male:function(){return{...this._both,...this._male}},
		female:function(){return{...this._both,...this._female}},
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