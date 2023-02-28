"use strict";

class Generic 
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

class Block extends Generic 
{
	constructor(material = air, amount = 100, status = '', birth = 0, position = { x: 0, y: 0, z: 0 }, quality = 100, condition = 100) 
	{
		super('block', status, birth, position, quality, condition);
		this.material = material; //earth,wood,rock
		this.amount = amount;
		this.velocityZ = 0;
	}
}

async function Terrain(map,fixedHeight = 128)
{
	var result = [];
	for(let x = 0;x < map.length;x++)
	{
		result[x] = [];
		for(let y = 0;y < map.length;y++)
		{
			result[x][y] = [];
			//var earthb = map[x][y];
			//var airb = fixedHeight - earthb;
			
			result[x][y] = Array(map[x][y]).fill([new Block('earth',100)]);
			result[x][y] = result[x][y].concat(Array(fixedHeight - map[x][y]).fill([new Block('air',100)]));
		}
	}
	return(result);
}

onmessage = async function(event) 
{
	postMessage(await Terrain(event.data[0],event.data[1]));
	self.close();
};