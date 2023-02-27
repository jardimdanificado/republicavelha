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
	constructor(specie = 'human', gender = 'female', status = '', birth = 0, position = { x: 0, y: 0, z: 0 }, quality = 100, condition = 100) 
	{
		super('block', status, birth, position, quality, condition);
		this.specie = specie; //earth,wood,rock
		this.gender = gender;
	}
}

export class Plant extends Generic 
{
	constructor(specie = 'cannabis', status = 'idle', birth = 0, position = { x: 0, y: 0, z: 0 }, quality = 100, condition = 100) 
	{
		super('plant', status, birth, position, quality, condition);
		this.specie = specie;
	}
}

export class Seed extends Generic 
{
	constructor(specie = 'cannabis', status = 'idle', birth = 0, position = { x: 0, y: 0, z: 0 }, quality = 100, condition = 100, decayRate = 2592000/*(30days)*/) 
	{
		super('seed', status, birth, position, quality, condition, decayRate);
		this.specie = specie;
		this.breed = 0;
	}
}