export const Util = await import("./republicavelha/util.mjs");
import * as _World from "./republicavelha/world.mjs"
import * as _Creature from "./republicavelha/creature.mjs"

class Generic
{
  constructor(type = "generic",status = "",birth = 0,position = Util.Vector3Zero(),quality = 100,condition = 100,decayRate=0,mods = []) 
  {
	this.type = type;
	this.status = status;
	this.mods = mods;
	this.quality = quality;
	this.condition = condition;
	this.position = position;
	this.birth = birth;
	this.decayRate = decayRate;
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
	constructor(specie = 'human', gender = 'female', status = '', birth = 0, position = Util.Vector3Zero(), quality = 100, condition = 100) 
	{
	  super('block', status, birth, position, quality, condition);
	  this.specie = specie; //earth,wood,rock
	  this.gender = gender;
	}
}

export const Direction = ['left','up','right','down'];

export const Primitive = {Creature,Block,Generic};

export const World = _World.World;

