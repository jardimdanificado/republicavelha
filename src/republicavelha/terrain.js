import * as rve from "./essential.js"
import * as Objecto from "./objecto.js"

//-----------------------------------
//TERRAIN
//-----------------------------------
function Heightmap(size) {
	const N = (8+rve.randi(0,5));
	const RANDOM_INITIAL_RANGE = (10+rve.randi(0,3));
	var MATRIX_LENGTH = Math.pow(2, N)+1;

	const generateMatrix = function() {
		const matrix = new Array(MATRIX_LENGTH)
			.fill(0)
			.map(() => new Array(MATRIX_LENGTH).fill(null));

		matrix[0][MATRIX_LENGTH - 1] = rve.randomInRange(0, RANDOM_INITIAL_RANGE);
		matrix[MATRIX_LENGTH - 1][0] = rve.randomInRange(0, RANDOM_INITIAL_RANGE);
		matrix[0][0] = rve.randomInRange(0, RANDOM_INITIAL_RANGE);
		matrix[MATRIX_LENGTH - 1][MATRIX_LENGTH - 1] = rve.randomInRange(
			0,
			RANDOM_INITIAL_RANGE
		);

		return matrix;
	}

	const calculateSquare = function(matrix, chunkSize, randomFactor) {
		let sumComponents = 0;
		let sum = 0;
		for (let i = 0; i < matrix.length - 1; i += chunkSize) {
			for (let j = 0; j < matrix.length - 1; j += chunkSize) {
				const BOTTOM_RIGHT = matrix[j + chunkSize]
					? matrix[j + chunkSize][i + chunkSize]
					: null;
				const BOTTOM_LEFT = matrix[j + chunkSize]
					? matrix[j + chunkSize][i]
					: null;
				const TOP_LEFT = matrix[j][i];
				const TOP_RIGHT = matrix[j][i + chunkSize];
				const { count, sum } = [
					BOTTOM_RIGHT,
					BOTTOM_LEFT,
					TOP_LEFT,
					TOP_RIGHT
				].reduce(
					(result, value) => {
						if (isFinite(value) && value != null) {
							result.sum += value;
							result.count += 1;
						}
						return result;
					},
					{ sum: 0, count: 0 }
				);
				matrix[j + chunkSize / 2][i + chunkSize / 2] =
					sum / count + rve.randomInRange(-randomFactor, randomFactor);
			}
		}
	}

	const calculateDiamond = function(matrix, chunkSize, randomFactor) {
		const half = chunkSize / 2;
		for (let y = 0; y < matrix.length; y += half) {
			for (let x = (y + half) % chunkSize; x < matrix.length; x += chunkSize) {
				const BOTTOM = matrix[y + half] ? matrix[y + half][x] : null;
				const LEFT = matrix[y][x - half];
				const TOP = matrix[y - half] ? matrix[y - half][x] : null;
				const RIGHT = matrix[y][x + half];
				const { count, sum } = [BOTTOM, LEFT, TOP, RIGHT].reduce(
					(result, value) => {
						if (isFinite(value) && value != null) {
							result.sum += value;
							result.count += 1;
						}
						return result;
					},
					{ sum: 0, count: 0 }
				);
				matrix[y][x] = sum / count + rve.randomInRange(-randomFactor, randomFactor);
			}
		}
		return matrix;
	}

	const diamondSquare = function(matrix) {
		let chunkSize = MATRIX_LENGTH - 1;
		let randomFactor = RANDOM_INITIAL_RANGE;

		while (chunkSize > 1) {
			calculateSquare(matrix, chunkSize, randomFactor);
			calculateDiamond(matrix, chunkSize, randomFactor);
			chunkSize /= 2;
			randomFactor /= 2;
		}

		return matrix;
	}

	const normalizeMatrix = function(matrix) {
		const maxValue = matrix.reduce((max, row) => {
			return row.reduce((max, value) => Math.max(value, max));
		}, -Infinity);

		return matrix.map((row) => {
			return row.map((val) => val / maxValue);
		});
	}
	
	if (typeof size != 'undefined')
		MATRIX_LENGTH = size + 1;
	
	return (normalizeMatrix(diamondSquare(generateMatrix())));
}

function roundHeightmap(hm,type)
{
	var min = Infinity;
	for(let x = 0 ;x < hm.length; x++)
		for(let y = 0;y < hm.length;y++)
			if(min > hm[x][y]) 
				min = hm[x][y];
	for(let x = 0 ;x < hm.length; x++)
		for(let y = 0;y < hm.length;y++)
			hm[x][y] += min;
	for(let x = 0;x < hm.length;x++)
		for(let y = 0;y < hm.length;y++)
		{
			hm[x][y] = Math.round((hm[x][y] +min)*(Math.pow(10,((Math.trunc(min) + '').length))));//default is random
			
			if(type == 0 || type == 'flat')
				hm[x][y] = Math.round((hm[x][y])+(min*Math.pow(10,((Math.trunc(min) + '').length))));//flat
			else if(type == 1 || type == 'random')
				hm[x][y] = Math.round((hm[x][y] +min)*(Math.pow(10,((Math.trunc(min) + '').length))));//random
		}
	return hm;
}

function randomizeHeightmap(hm)
{
	for(let x = 1 ;x < hm.length-1; x+=2)
	{
		for(let y = 1;y < hm.length-1;y+=2)
		{
			let grid = 
			[
				hm[x-1][y-1],hm[x][y-1],hm[x+1][y-1],
				hm[x-1][y],hm[x][y],hm[x+1][y],
				hm[x-1][y+1],hm[x][y+1],hm[x+1][y+1]
			];
			let center = grid[4];
			let up = 0;
			let down = 0;
			for(let i = 0 ;i < 9; i+=1)
			{
				if(i==4)
					continue;
				if(grid[i]>center)
				{
					up += 1;
				}
				else if(grid[i]<center)
				{
					down += 1;
				}
			}
			if(up > down)
				hm[x][y] += 1;
			else if(down > up)
				hm[x][y] -= 1;
		}
	}
	return(hm);
}

function subdivideHeightmap(hm)
{
	function grid(input)
	{
		return(Array(9).fill(input));
	}
	var grided = [];
	for(let x = 0;x < hm.length-1;x++)
	{
		grided[x] = [];
		for(let y = 0;y < hm.length-1;y++)
		{
			let g = grid(hm[x][y]);
			if(x > 0)
			{
				g[3] = Math.round((hm[x-1][y]+g[3])/2);
				if(x<hm.length-1)
				{
					g[5] = Math.round((hm[x+1][y]+g[5])/2);
					if(y>0)
					{
						g[2] = Math.round((hm[x+1][y-1]+g[2])/2);
						if(y<hm.length-1)
						{
							g[8] = Math.round((hm[x+1][y+1]+g[8])/2);
							g[6] = Math.round((hm[x-1][y+1]+g[6])/2);
						}
					}
				}
				if(y>0)
					g[0] = Math.round((hm[x-1][y-1]+g[0])/2);
			}
			if(y > 0)
			{
				g[1] = Math.round((hm[x][y-1]+g[1])/2);
				if(y<hm.length)
				{
					g[7] = Math.round((hm[x][y+1]+g[7])/2);
					if(x>0)
					{
						g[6] = Math.round((hm[x-1][y+1]+g[2])/2);
						if(x<hm.length)
						{
							g[8] = Math.round((hm[x+1][y+1]+g[8])/2);
							g[6] = Math.round((hm[x-1][y+1]+g[6])/2);
						}
					}
				}
			}
			grided[x][y] = g;
		}
	}
	var result = [];
	for(let x = 0;x < (hm.length-1)*3;x+=1)
		result[x] = [];
	for(let x = 1;x < (hm.length-1)*3;x+=3)
	{
		for(let y = 1;y < (hm.length-1)*3;y+=3)
		{
			result[x-1][y-1] = grided[Math.round(x/3)][Math.round(y/3)][0];
			result[x][y-1] = grided[Math.round(x/3)][Math.round(y/3)][1];
			result[x+1][y-1] = grided[Math.round(x/3)][Math.round(y/3)][2];
			result[x-1][y] = grided[Math.round(x/3)][Math.round(y/3)][3];
			result[x][y] = grided[Math.round(x/3)][Math.round(y/3)][4];
			result[x+1][y] = grided[Math.round(x/3)][Math.round(y/3)][5];
			result[x-1][y+1] = grided[Math.round(x/3)][Math.round(y/3)][6];
			result[x][y+1] = grided[Math.round(x/3)][Math.round(y/3)][7];
			result[x+1][y+1] = grided[Math.round(x/3)][Math.round(y/3)][8];
		}
	}
	return result;
}

function smoothBlock(hm,position)
{
	let x = position.x;
	let y = position.y;
	let sum = 0;
	let count = 0;
	if(x>0&&y>0)
	{
		sum += hm[x-1][y-1];
		count++;
	}
	if(y>0)
	{	
		sum += hm[x][y-1];
		count++;
	}
	if(x<hm.length-1 && y>0)
	{	
		sum += hm[x+1][y-1];
		count++;
	}
	if(x>0)
	{	
		sum += hm[x-1][y];
		count++;
	}
	sum += hm[x][y];
	count++;
	if(x<hm.length-1)
	{	
		sum += hm[x+1][y];
		count++;
	}
	if(x>0&&y<hm.length-1)
	{	
		sum += hm[x-1][y+1];
		count++;
	}
	if(y<hm.length-1)
	{	
		sum += hm[x][y+1];
		count++;
	}
	if(x<hm.length-1&&y<hm.length-1)
	{	
		sum += hm[x+1][y+1];
		count++;
	}
	return(sum/count);
}

function smoothHeightmap(hm,corner)
{
	corner ??= randi(0,3);
	switch(corner)
	{
		case 0:
		{
			for(let x = 0;x < (hm.length);x+=1)
				for(let y = 0;y < (hm.length);y+=1)
					hm[x][y] = smoothBlock(hm,rve.Vector2(x,y));
		}
		break;
		case 1:
		{
			for(let x = hm.length-1;x >=0;x-=1)
				for(let y = 0;y < (hm.length);y+=1)
					hm[x][y] = smoothBlock(hm,rve.Vector2(x,y));
		}
		break;
		case 2:
		{
			for(let x = hm.length-1;x >=0;x-=1)
				for(let y = hm.length-1;y >=0;y-=1)
					hm[x][y] = smoothBlock(hm,rve.Vector2(x,y));
		}
		break;
		case 3:
		{
			for(let x = 0;x < (hm.length);x+=1)
				for(let y = hm.length-1;y >=0;y-=1)
					hm[x][y] = smoothBlock(hm,rve.Vector2(x,y));
		}
		break;
	}
	return hm;
}

function multiHeightmap(mapsize,multi)
{
	if(multi==1)
	{
		return(Heightmap(mapsize));
	}
	else
	{
		let result = [];
		let maps = [];
		for(let x = 0;x<mapsize*multi;x++)
			result[x] = [];
		
		for(let x = 0;x<multi;x++)
		{
			maps[x] = [];
			for(let y = 0;y<multi;y++)
				maps[x][y] = Heightmap(mapsize);
		}
		for(let x = 0;x<multi;x++)
			for(let y = 0;y<multi;y++)
				for(let xx = 0;xx<mapsize;xx++)
					for(let yy = 0;yy<mapsize;yy++)
						result[xx+(mapsize*x)][yy+(mapsize*y)] = maps[x][y][xx][yy];
		return(result);
	}
}

function HeightmapModder(hm,smooth,randomize,subdivide,pre)
{
	let mut = -1;
	let condition = function(im){return(im>0)};
	if(pre)
	{
		condition = function(im){return(im<0)};
		mut = 1
	}
	
	while(condition(randomize))
	{
		hm = randomizeHeightmap(hm);
		randomize+=mut;
	}
	while(condition(smooth))
	{
		hm = smoothHeightmap(hm,rve.randi(0,3));
		smooth+=mut;
	}
	while(condition(subdivide))
	{
		hm = subdivideHeightmap(hm);
		subdivide+=mut;
	}
	return hm;
}

function Terrain(inmap)
{
	var mt = inmap;
	var result = [];
	for(let x = 0;x < mt.length;x++)
	{
		result[x] = [];
		for(let y = 0;y < mt.length;y++)
		{
			result[x][y] = [];
			var earthb = Math.round(rve.limito(mt[x][y],(mt.length-((mt.length/4)*3)),(mt.length-(mt.length/4))));
			var airb = mt.length - earthb;
			if(earthb >=1)
				result[x][y] = Array(earthb).fill([Objecto.Block('earth','full')]);
			if(airb >= 1)
				result[x][y] = result[x][y].concat(Array(airb).fill([Objecto.Block('air','empty')]));
		}
	}
	return(result);
}

function rampifyTerrain(terrain)
{
	for(let x = 0;x<terrain.length;x++)
		for(let y = 0;y<terrain.length;y++)
			for(let z = 0;z<terrain.length-2;z++)
			{
				if(terrain[x][y][z][0].subtype == "full" && terrain[x][y][z+1][0].subtype == "empty")
				{
					if(
						(x<terrain.length-1 && terrain[x+1][y][z+1][0].subtype == "full" && terrain[x+1][y][z+2][0].subtype == "empty")||
						(x>0&&terrain[x-1][y][z+1][0].subtype == "full" && terrain[x-1][y][z+2][0].subtype == "empty")||
						(y<terrain.length-1 && terrain[x][y+1][z+1][0].subtype == "full" && terrain[x][y+1][z+2][0].subtype == "empty")||
						(y>0 && terrain[x][y-1][z+1][0].subtype == "full" && terrain[x][y-1][z+2][0].subtype == "empty") ||
						(x<terrain.length-1 && y<terrain.length-1 && terrain[x+1][y+1][z+1][0].subtype == "full" && terrain[x+1][y+1][z+2][0].subtype == "empty")||
						(x>0&& y<terrain.length-1 &&terrain[x-1][y+1][z+1][0].subtype == "full" && terrain[x-1][y+1][z+2][0].subtype == "empty")||
						(x<terrain.length-1 && y<0 && terrain[x+1][y-1][z+1][0].subtype == "full" && terrain[x][y-1][z+2][0].subtype == "empty")||
						(x>0 && y>0 && terrain[x-1][y-1][z+1][0].subtype == "full" && terrain[x][y-1][z+2][0].subtype == "empty")
					)	
					{
						terrain[x][y][z][0].subtype = 'half';
					}
				}
			}
	return terrain;
}

export function AutoTerrain(mapsize,type,multiHorizontal,multiVertical,smooth,randomize,subdivide)
{
	//note that multiHorizontal multiplyes the mapsize, putting differentmaps side by side
	//while multiVertical keeps the mapsize, as it sum all layers
	var hmaps = [];
	var result = [];
	mapsize ??= 32;
	type ??= "flat";
	randomize ??= false;
	subdivide ??= false;
	smooth ??= false;
	multiHorizontal ??= 1;
	multiVertical ??= 1;
	for(let x = 0 ;x < Math.abs(multiVertical); x++)
	{
		let tmap = roundHeightmap(multiHeightmap(mapsize,Math.abs(multiHorizontal)),type);
		var lsub = subdivide;
		var lrnd = randomize;
		var lsmo = smooth;
		tmap = HeightmapModder(tmap,lsmo,lrnd,lsub,true);
		hmaps.push(tmap);
	}

	for(let k = 0 ;k < Math.abs(multiVertical); k++)
	{
		for(let x = 0 ;x < hmaps[0].length; x++)
		{
			if(typeof result[x] == 'undefined')
				result[x] = Array(hmaps[0].length).fill(0);
			for(let y = 0;y < hmaps[0].length;y++)
			{
				result[x][y] += hmaps[k][x][y];
			}
		}
	}
	result = HeightmapModder(result,lsmo,lrnd,lsub,false);
	var terr = [];
	terr = Terrain(result);
	while(typeof terr[0][0][0] == 'undefined'||terr[0][0][0].length === 0)
		terr = Terrain(result);
	terr = rampifyTerrain(terr);
	return(terr);
}