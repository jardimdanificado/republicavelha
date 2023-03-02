import * as Plants from './plants.mjs';

export class Generic 
{
	constructor(type = "generic", status = "", birth = 0, position = { x: 0, y: 0, z: 0 }, quality = 100, condition = 100, decayRate = 0, mods = []) 
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

export class Block extends Generic 
{
	constructor(material = air, amount = 100, status = '', birth = 0, position = { x: 0, y: 0, z: 0 }, quality = 100, condition = 100) 
	{
		super('block', status, birth, position, quality, condition);
		this.material = material; //earth,wood,rock
		this.amount = amount;
		this.velocityZ = 0;
	}
}

export class Creature extends Generic 
{
	constructor(specie = 'human', gender = 'female', status = 'idle', birth = 0, position = { x: 0, y: 0, z: 0 }, quality = 100, condition = 100) 
	{
		super('block', status, birth, position, quality, condition);
		this.specie = specie; //earth,wood,rock
		this.gender = gender;
	}
}

export class Plant extends Generic 
{
	constructor(specie = 'grass', status = 'idle', birth = 0, position = { x: 0, y: 0, z: 0 }, quality = 100, condition = 100) 
	{
		super('plant', status, birth, position, quality, condition);
		this.specie = specie;
		this.leaf = (Plants[this.specie].leaf !== null) ? []:null;
		this.flower = (Plants[this.specie].flower !== null) ? []:null;
		this.branch = (Plants[this.specie].type !== 'herb') ? []:null;
		this.trunk = (Plants[this.specie].wood !== null) ? []:null;
		this.fruit = (Plants[this.specie].fruit !== null) ? []:null;
	}
}

export class Seed extends Generic 
{
	constructor(specie = 'tomato', status = 'idle', birth = 0, position = { x: 0, y: 0, z: 0 }, quality = 100, condition = 100, decayRate = 2592000/*(30days)*/) 
	{
		super('seed', status, birth, position, quality, condition, decayRate);
		this.specie = specie;
		this.germination = 0;
	}
}

export class Leaf extends Generic
{
	constructor(specie = 'grass', status = 'idle', birth = 0, position = { x: 0, y: 0, z: 0 }, quality = 100, condition = 100) 
	{
		super('leaf', status, birth, position, quality, condition);
		this.specie = specie;
	}
}

export class Trunk extends Generic
{
	constructor(specie = 'tamarind', status = 'idle', birth = 0, position = { x: 0, y: 0, z: 0 }, quality = 100, condition = 100) 
	{
		super('trunk', status, birth, position, quality, condition);
		this.specie = specie;
	}
}

export class Branch extends Generic
{
	constructor(specie = 'tamarind', status = 'idle', birth = 0, position = { x: 0, y: 0, z: 0 }, quality = 100, condition = 100) 
	{
		super('branch', status, birth, position, quality, condition);
		this.specie = specie;
	}
}

export class Flower extends Generic
{
	constructor(specie = 'cannabis', status = 'idle', birth = 0, position = { x: 0, y: 0, z: 0 }, quality = 100, condition = 100) 
	{
		super('flower', status, birth, position, quality, condition);
		this.specie = specie;
		this.flowering = 0;
	}
}

export class Fruit extends Generic
{
	constructor(specie = 'tomato', status = 'idle', birth = 0, position = { x: 0, y: 0, z: 0 }, quality = 100, condition = 100) 
	{
		super('fruit', status, birth, position, quality, condition);
		this.specie = specie;
		this.maturation = 0;
		this.seed = 1;
	}
}