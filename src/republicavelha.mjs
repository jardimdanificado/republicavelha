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

class Generic
{
  constructor(type = "generic",status = "",birth = 0,position = Util.Vector3Zero(),quality = 100,condition = 100,mods = []) 
  {
	this.type = type;
	this.status = status;
	this.mods = mods;
	this.quality = quality;
	this.condition = condition;
	this.position = position;
	this.birth = birth;
  }
}

class Block extends Generic 
{
	constructor(material = air, amount = 100, status = '', birth = 0, position = Util.Vector3Zero(), quality = 100, condition = 100) 
	{
	  super('block', status, birth, position, quality, condition);
	  this.material = material; //earth,wood,rock
	  this.amount = amount;
	}
}
 
class Creature extends Generic 
{
	constructor(specime = 'human', gender = 'female', status = '', birth = 0, position = Util.Vector3Zero(), quality = 100, condition = 100) 
	{
	  super('block', status, birth, position, quality, condition);
	  this.specime = specime; //earth,wood,rock
	  this.gender = gender;
	}
}

export const Primitive = {Creature,Block,Generic};

export const World = _World.World;
//INTERPRETATION
export function frame(world)
{
	world.time++;
}