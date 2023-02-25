export const Util = await import("./republicavelha/util.mjs");
import * as _World from "./republicavelha/world.mjs"
import * as _Creature from "./republicavelha/creature.mjs"

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

export const Primitive =
{
	Generic:function(type = generic,status = '',birth = 0,position = Util.Vector3Zero(),quality = 100,condition = 100,mods = [])
	{
		return(
			{
				type:type,
				status:status,
				mods:mods,
				quality:quality,
				condition:condition,
				position:position,
				birth:birth//birth in seconds
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
				body:_Creature.Body[specime][gender]()
			}
		);
	},
	Block:function(material,amount = 100,status = '',birth = 0,position = Util.Vector3Zero(),quality = 100,condition = 100)
	{
		return(
			{
				...this.Generic('block',status,birth,position,quality,condition),
				material:material,//earth,wood,rock
				amount:amount
			}
		);
	}
}

export const World =
{
	Map:_World.Map,
}

//INTERPRETATION
export function frame(world)
{
	world.time++;
}