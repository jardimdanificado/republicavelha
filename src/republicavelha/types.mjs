import * as Plants from './plants.mjs';//plants info

//-----------------------------------------------------
//MATH CLASSES
//-----------------------------------------------------

export class Vector3
{ 
	constructor(x=0, y=0, z=0) 
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}
}

export class Vector2
{ 
	constructor(x=0, y=0)
	{
		this.x = x;
		this.y = y;
	}
}

export class BoundingBox
{ 
	constructor(minX=0,minY=0,minZ=0,maxX=0,maxY=0,maxZ=0) 
	{
		if(typeof minX == 'object')
		{
			this.min = {...minX};
			this.max = {...minY};
		}
		else
		{
			this.min = {minX,minY,minZ};
			this.max = {maxX,maxY,maxZ};
		}
	}
}

//-----------------------------------------------------
//COLOR CLASSES
//-----------------------------------------------------

export class HSL
{ 
	constructor(h=0, s=0, l=0) 
	{
		this.h = h;
		this.s = s;
		this.l = l;
	}
}

export class RGB
{ 
	constructor(r=0, g=0, b=0) 
	{
		this.r = r;
		this.g = g;
		this.b = b;
	}
}

export class RGBA extends RGB
{ 
	constructor(r=0, g=0, b=0, a=0) 
	{
		super(r,g,b);
		this.a = a;
	}
}

//-----------------------------------------------------
//SIMULATION CLASSES
//-----------------------------------------------------

export class Generic 
{
	constructor(type = "generic", status = "", birth = 0, position = new Vector3(), quality = 100, condition = 100, decayRate = 0, mods = []) 
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
	constructor(material = air, status = 'idle', birth = 0, position = new Vector3(), quality = 100, condition = 100) 
	{
		super('block', status, birth, position, quality, condition);
		this.material = material; //earth,wood,rock
	}
}

export class Creature extends Generic 
{
	constructor(specie = 'human', gender = 'female', status = 'idle', birth = 0, position = new Vector3(), quality = 100, condition = 100) 
	{
		super('block', status, birth, position, quality, condition);
		this.specie = specie; //earth,wood,rock
		this.gender = gender;
	}
}

export class Plant extends Generic 
{
	constructor(specie = 'grass', status = 'idle', birth = 0, position = new Vector3(), quality = 100, condition = 100) 
	{
		super('plant', status, birth, position, quality, condition);
		this.specie = specie;
		this.leaf = 0;
		this.flower = (typeof Plants[this.specie].flower !== 'undefined') ? []:undefined;
		this.branch = (Plants[this.specie].type !== 'herb') ? []:undefined;
		this.trunk = (typeof Plants[this.specie].wood !== 'undefined') ? []:undefined;
		this.fruit = (typeof Plants[this.specie].fruit !== 'undefined') ? []:undefined;
	}
}

export class Seed extends Generic 
{
	constructor(specie = 'tomato', status = 'idle', birth = 0, position = new Vector3(), quality = 100, condition = 100, decayRate = 2592000/*(30days)*/) 
	{
		super('seed', status, birth, position, quality, condition, decayRate);
		this.specie = specie;
		this.germination = 0;
	}
}

export class Leaf extends Generic
{
	constructor(specie = 'grass', status = 'idle', birth = 0, position = new Vector3(), quality = 100, condition = 100) 
	{
		super('leaf', status, birth, position, quality, condition);
		this.specie = specie;
	}
}

export class Trunk extends Generic
{
	constructor(specie = 'tamarind', status = 'idle', birth = 0, position = new Vector3(), quality = 100, condition = 100) 
	{
		super('trunk', status, birth, position, quality, condition);
		this.specie = specie;
	}
}

export class Branch extends Generic
{
	constructor(specie = 'tamarind', status = 'idle', birth = 0, position = new Vector3(), quality = 100, condition = 100) 
	{
		super('branch', status, birth, position, quality, condition);
		this.specie = specie;
	}
}

export class Flower extends Generic
{
	constructor(specie = 'cannabis', status = 'idle', birth = 0, position = new Vector3(), quality = 100, condition = 100) 
	{
		super('flower', status, birth, position, quality, condition);
		this.specie = specie;
		this.flowering = 0;
	}
}

export class Fruit extends Generic
{
	constructor(specie = 'tomato', status = 'idle', birth = 0, position = new Vector3(), quality = 100, condition = 100) 
	{
		super('fruit', status, birth, position, quality, condition);
		this.specie = specie;
		this.maturation = 0;
		this.seed = 1;
	}
}