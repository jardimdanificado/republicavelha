import * as util from "./essential.mjs"
import { Primitive } from "../republicavelha.mjs" 

//-----------------------------------
//TERRAIN
//-----------------------------------
export function Heightmap(size) 
{
	const N = (8+util.randi(0,5));
	const RANDOM_INITIAL_RANGE = (10+util.randi(0,3));
	var MATRIX_LENGTH = Math.pow(2, N)+1;

	const generateMatrix = function() {
		const matrix = new Array(MATRIX_LENGTH)
			.fill(0)
			.map(() => new Array(MATRIX_LENGTH).fill(null));

		matrix[0][MATRIX_LENGTH - 1] = util.randomInRange(0, RANDOM_INITIAL_RANGE);
		matrix[MATRIX_LENGTH - 1][0] = util.randomInRange(0, RANDOM_INITIAL_RANGE);
		matrix[0][0] = util.randomInRange(0, RANDOM_INITIAL_RANGE);
		matrix[MATRIX_LENGTH - 1][MATRIX_LENGTH - 1] = util.randomInRange(
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
					sum / count + util.randomInRange(-randomFactor, randomFactor);
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
				matrix[y][x] = sum / count + util.randomInRange(-randomFactor, randomFactor);
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

export function randomizeHeightmap(hm)
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

export function subdivideHeightmap(hm)
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

export function expandHeightmap(heightmap) 
{
  // Create a new 2D array with 3 times the number of rows and columns
  var expandedHeightmap = new Array(heightmap.length * 3);
  for (var i = 0; i < expandedHeightmap.length; i++) {
    expandedHeightmap[i] = new Array(heightmap[0].length * 3);
  }
  
  // Fill the expanded array with the values from the original heightmap
  for (var row = 0; row < heightmap.length; row++) {
    for (var col = 0; col < heightmap[row].length; col++) {
      var value = heightmap[row][col];
      expandedHeightmap[row * 3][col * 3] = value;
      expandedHeightmap[row * 3 + 1][col * 3] = value;
      expandedHeightmap[row * 3 + 2][col * 3] = value;
      expandedHeightmap[row * 3][col * 3 + 1] = value;
      expandedHeightmap[row * 3 + 1][col * 3 + 1] = value;
      expandedHeightmap[row * 3 + 2][col * 3 + 1] = value;
      expandedHeightmap[row * 3][col * 3 + 2] = value;
      expandedHeightmap[row * 3 + 1][col * 3 + 2] = value;
      expandedHeightmap[row * 3 + 2][col * 3 + 2] = value;
    }
  }
  
  return expandedHeightmap;
}

export function smoothBlock(hm,position)
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

export function smoothHeightmap(hm,corner)
{
	corner ??= util.randi(0,3);
	switch(corner)
	{
		case 0:
		{
			for(let x = 0;x < (hm.length);x+=1)
				for(let y = 0;y < (hm.length);y+=1)
					hm[x][y] = smoothBlock(hm,util.Vector2(x,y));
		}
		break;
		case 1:
		{
			for(let x = hm.length-1;x >=0;x-=1)
				for(let y = 0;y < (hm.length);y+=1)
					hm[x][y] = smoothBlock(hm,util.Vector2(x,y));
		}
		break;
		case 2:
		{
			for(let x = hm.length-1;x >=0;x-=1)
				for(let y = hm.length-1;y >=0;y-=1)
					hm[x][y] = smoothBlock(hm,util.Vector2(x,y));
		}
		break;
		case 3:
		{
			for(let x = 0;x < (hm.length);x+=1)
				for(let y = hm.length-1;y >=0;y-=1)
					hm[x][y] = smoothBlock(hm,util.Vector2(x,y));
		}
		break;
	}
	return hm;
}

export function roundHeightmap(hm)
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
			hm[x][y] = Math.round((hm[x][y])+(min*Math.pow(10,((Math.trunc(min) + '').length))));//flat
		}
	return hm;
}

export function polishHeightmap(heightmap,fixedHeight)//same as smooth but different
{
	// Define a function to be applied to each element of the matrix
	const yCallback = function(num) 
	{
	  return Math.round(util.limito(num,fixedHeight-((fixedHeight/4)*3),fixedHeight-2));
	}
	
	// Define a function to be applied to each row of the matrix
	const xCallback = function(row) 
	{
	  return row.map(yCallback);
	}

	// Apply the doubleRow() function to each row of the matrix using map()
	return(heightmap.map(xCallback));
}

export function autoSmoothHeightmap(hm,times)//deprecated
{
	while(times>0)
	{	
		hm = smoothHeightmap(hm,util.randi(0,3))
		times--;
	};
	return(hm);
}

export async function autoRoundHeightmap(hm,divider = 1)//deprecated
{
	if(divider === 1)
		return roundHeightmap(hm);
	else if(divider > 1)
	{
		let promises = [];
		let divided = await util.splitMatrix(hm);
		for(let x =0;x<divided.length;x++)
			for(let y = 0;y<divided[x].length;y++)
				promises.push(util.Comrade("../terrain.mjs","roundHeightmap",[divided[x][y]]))
		
		return (await Promise.all(promises)
				.then(async (results) => 
				{
					results = results.map(val => val.data);
		            results = await util.autoOrganizeArray(results);
		            return(await util.expandMatrix(results));
	        	}
			)
		)
	}
}

export async function autoHeightmap(mapsize, multi) 
{
	let promises = [];
	for (let x = 0; x < multi; x++) 
	{
		for (let y = 0; y < multi; y++) 
		{
			promises.push(util.Comrade('../terrain.mjs','Heightmap',[mapsize]));
		}
	}
	return (await Promise.all(promises)
			.then(async (results) => 
			{
				results = results.map(val => val.data);
				results = await util.organizeArray(results,multi);
				return(util.expandMatrix(results));
			}
		)
	)
}

function heightmapVariablitity(heightmap) 
{
  let uniqueValues = new Set();//Set() is a array of unique values
  
  for (let i = 0; i < heightmap.length; i++) {
    for (let j = 0; j < heightmap[0].length; j++) {
      uniqueValues.add(heightmap[i][j]);
    }
  }
  
  return uniqueValues.size;
}

export function heightmapModder(hm,smooth,randomize,subdivide)
{
	let condition = function(im){return(im>0)};
	
	while(condition(randomize))
	{
		hm = randomizeHeightmap(hm);
		randomize-=1;
	}
	while(condition(subdivide))
	{
		hm = subdivideHeightmap(hm);
		subdivide-=1;
	}
	while(condition(smooth))
	{
		hm = smoothHeightmap(hm,util.randi(0,3));
		smooth-=1;
	}
	
	return hm;
}

export async function Terrain(map,fixedHeight = 128)
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
			
			result[x][y] = Array(map[x][y]).fill([Primitive.Block('earth','full')]);
			result[x][y] = result[x][y].concat(Array(fixedHeight - map[x][y]).fill([Primitive.Block('air','empty')]));
		}
	}
	return(result);
}

export async function fastTerrain(hm,fixedHeight,slices)
{
	let divided = await util.customSplitMatrix(hm,slices);
	let terrs = [];
	for(let i = 0;i<slices**2;i++)
		terrs.push(util.asyncComrade("../terrain.mjs","Terrain",[divided[i],fixedHeight]));
	return (
				await Promise.all(terrs)
				.then(async (results) => 
					{
						results = results.map((val) => val.data);
						results = await util.autoOrganizeArray(results);
						results = await util.expandMatrix(results);
						results.heightmap = hm;
						return (results);
					})
			)
}

export async function rampifyTerrain(terrain)
{
	for(let x = 0;x<terrain.length;x++)
		for(let y = 0;y<terrain[0].length;y++)
			for(let z = 0;z<terrain[0][0].length-2;z++)
			{
				if(terrain[x][y][z][0].subtype == "full" && terrain[x][y][z+1][0].subtype == "empty")
				{
					if(
						(x<terrain.length-1 &&
						 terrain[x+1][y][z+1][0].subtype == "full" &&
						 terrain[x+1][y][z+2][0].subtype == "empty")||
						(x>0&&
						 terrain[x-1][y][z+1][0].subtype == "full" &&
						 terrain[x-1][y][z+2][0].subtype == "empty")||
						(y<terrain.length-1 &&
						 terrain[x][y+1][z+1][0].subtype == "full" &&
						 terrain[x][y+1][z+2][0].subtype == "empty")||
						(y>0 &&
						 terrain[x][y-1][z+1][0].subtype == "full" &&
						 terrain[x][y-1][z+2][0].subtype == "empty") ||
						
						(x<terrain.length-1 &&
						 y<terrain.length-1 &&
						 terrain[x+1][y+1][z+1][0].subtype == "full" && 
						 terrain[x+1][y+1][z+2][0].subtype == "empty")||
						(x>0&&
						 y<terrain.length-1 &&
						 terrain[x-1][y+1][z+1][0].subtype == "full" && 
						 terrain[x-1][y+1][z+2][0].subtype == "empty")||
						(x<terrain.length-1 &&
						 y>0 &&
						 terrain[x+1][y-1][z+1][0].subtype == "full" &&
						 terrain[x+1][y-1][z+2][0].subtype == "empty")||
						(x>0 &&
						 y>0 &&
						 terrain[x-1][y-1][z+1][0].subtype == "full" &&
						 terrain[x-1][y-1][z+2][0].subtype == "empty")
					)	
					{
						terrain[x][y][z][0].subtype = 'half';
					}
				}
			}
	return terrain;
}

export async function rampifyTerrainHM(terrain,heightmap)
{
	for(let x = 0;x<terrain.length;x++)
		for(let y = 0;y<terrain[0].length;y++)
		{
			if(
				(x<terrain.length-1 &&
				 terrain[x+1][y][heightmap[x][y]][0].subtype == "full" &&
				 terrain[x+1][y][heightmap[x][y]+1][0].subtype == "empty")||
				(x>0&&
				 terrain[x-1][y][heightmap[x][y]][0].subtype == "full" &&
				 terrain[x-1][y][heightmap[x][y]+1][0].subtype == "empty")||
				(y<terrain.length-1 &&
				 terrain[x][y+1][heightmap[x][y]][0].subtype == "full" &&
				 terrain[x][y+1][heightmap[x][y]+1][0].subtype == "empty")||
				(y>0 &&
				 terrain[x][y-1][heightmap[x][y]][0].subtype == "full" &&
				 terrain[x][y-1][heightmap[x][y]+1][0].subtype == "empty") ||
				
				(x<terrain.length-1 &&
				 y<terrain.length-1 &&
				 terrain[x+1][y+1][heightmap[x][y]][0].subtype == "full" && 
				 terrain[x+1][y+1][heightmap[x][y]+1][0].subtype == "empty")||
				(x>0&&
				 y<terrain.length-1 &&
				 terrain[x-1][y+1][heightmap[x][y]][0].subtype == "full" && 
				 terrain[x-1][y+1][heightmap[x][y]+1][0].subtype == "empty")||
				(x<terrain.length-1 &&
				 y>0 &&
				 terrain[x+1][y-1][heightmap[x][y]][0].subtype == "full" &&
				 terrain[x+1][y-1][heightmap[x][y]+1][0].subtype == "empty")||
				(x>0 &&
				 y>0 &&
				 terrain[x-1][y-1][heightmap[x][y]][0].subtype == "full" &&
				 terrain[x-1][y-1][heightmap[x][y]+1][0].subtype == "empty")
			)	
			{
				terrain[x][y][heightmap[x][y]][0].subtype = 'half';
			}
		}
	return terrain;
}

export async function countRampsHeightmap(terrain,heightmap)
{
	let counter = 0;
	for(let x = 0;x<terrain.length;x++)
		for(let y = 0;y<terrain[0].length;y++)
		{
			if(terrain[x][y][heightmap[x][y]][0].subtype == "half")
				 
			{
				counter++;
			}
		}
	return counter;
}

export async function fastRampify(terrain,slices,heightmap)
{
	let dividedMap = await util.customSplitMatrix(terrain,slices);
	let terrs = [];
	if(typeof heightmap !== 'undefined')
	{
		let dividedHeightmap = await util.customSplitMatrix(heightmap,slices);
		for(let i = 0;i<slices**2;i++)
		{
			terrs.push(util.asyncComrade("../terrain.mjs","rampifyTerrainHM",[dividedMap[i],dividedHeightmap[i]]));
		}
	}
	else
		for(let i = 0;i<slices**2;i++)
		{
			terrs.push(util.asyncComrade("../terrain.mjs","rampifyTerrain",[dividedMap[i]]));
		}
	return (
				await Promise.all(terrs)
				.then(async (results) => 
					{
						results = results.map((val) => val.data);
						let rst = await util.autoOrganizeArray(results)
						return (await util.expandMatrix(rst));
					})
			)
}

//cool and variated maps, very cpu consuming, larges maps are a pain to generate
export async function AutoTerrain(mapsize,multiHorizontal,smooth = false,randomize = false,subdivide = false,postslices = 1,retry = 0)
{
	//note that multiHorizontal multiplyes the mapsize, putting different maps side by side
	
	if(typeof mapsize == 'undefined')
		mapsize = util.Size(128,64);	
	else if(typeof mapsize == 'number')
		mapsize = util.Size(mapsize,mapsize);
	else if(typeof mapsize == 'array')
		mapsize = util.Size(mapsize[0],mapsize[1]);
	
	var hmap;
	console.time("autoHeightmap");
	hmap = await autoHeightmap(mapsize.w,multiHorizontal);
	console.timeEnd("autoHeightmap");
	
	console.time("roundHeightmap");
	hmap = await roundHeightmap(hmap);
	console.timeEnd("roundHeightmap");

	console.time("heightmapModder");
	hmap = await(util.Comrade('../terrain.mjs','heightmapModder',[hmap,smooth,randomize,subdivide]))
		.then(resolvedValue => {
			return resolvedValue.data;
  	});
	console.timeEnd("heightmapModder");

	console.time("polishHeightmap");
	hmap = polishHeightmap(hmap,mapsize.h);
	console.timeEnd("polishHeightmap");
	
	var terr = [];
	//console.log("post variability:"+heightmapVariablitity(hmap));
	
	console.time("fastTerrain");
	terr = await fastTerrain(hmap,mapsize.h,postslices);
	console.timeEnd("fastTerrain");

	console.time("fastRampify");
	terr = await fastRampify(terr,postslices,hmap);
	console.timeEnd("fastRampify");

	var rampcount = await countRampsHeightmap(terr,hmap);
	console.log("ramp count:"+ rampcount );
	if(retry>=1&&rampcount>((mapsize.w*multiHorizontal)**2)/4)
	{
		console.log("retry number " + retry);
		retry++;
		return(AutoTerrain(mapsize,multiHorizontal,smooth,randomize,subdivide,postslices,retry));
	}
	if(retry >= 2)
		console.log('map generated in ' + retry + ' retries.')
	return(terr);
}