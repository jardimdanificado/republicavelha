import {randomInRange,LimitTo,autoOrganizeArray,organizeArray,expandMatrix,customSplitMatrix,Size} from "./util.mjs"
import { Block, Vector2 } from "./types.mjs" 

//-----------------------------------
//TERRAIN
//-----------------------------------
export function Heightmap(size) 
{
	const N = (8+randomInRange(0,5));
	const RANDOM_INITIAL_RANGE = (10+randomInRange(0,3));
	var MATRIX_LENGTH = Math.pow(2, N)+1;

	const generateMatrix = function() 
	{
		const matrix = new Array(MATRIX_LENGTH)
			.fill(0)
			.map(() => new Array(MATRIX_LENGTH).fill(null));

		matrix[0][MATRIX_LENGTH - 1] = randomInRange(0, RANDOM_INITIAL_RANGE);
		matrix[MATRIX_LENGTH - 1][0] = randomInRange(0, RANDOM_INITIAL_RANGE);
		matrix[0][0] = randomInRange(0, RANDOM_INITIAL_RANGE);
		matrix[MATRIX_LENGTH - 1][MATRIX_LENGTH - 1] = randomInRange(
			0,
			RANDOM_INITIAL_RANGE
		);

		return matrix;
	}

	const calculateSquare = function(matrix, chunkSize, randomFactor) 
	{
		let sumComponents = 0;
		let sum = 0;
		for (let i = 0; i < matrix.length - 1; i += chunkSize) 
		{
			for (let j = 0; j < matrix.length - 1; j += chunkSize) 
			{
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
					(result, value) => 
					{
						if (isFinite(value) && value != null) 
						{
							result.sum += value;
							result.count += 1;
						}
						return result;
					},
					{ sum: 0, count: 0 }
				);
				matrix[j + chunkSize / 2][i + chunkSize / 2] =
					sum / count + randomInRange(-randomFactor, randomFactor);
			}
		}
	}

	const calculateDiamond = function(matrix, chunkSize, randomFactor) 
	{
		const half = chunkSize / 2;
		for (let y = 0; y < matrix.length; y += half) {
			for (let x = (y + half) % chunkSize; x < matrix.length; x += chunkSize) 
			{
				const BOTTOM = matrix[y + half] ? matrix[y + half][x] : null;
				const LEFT = matrix[y][x - half];
				const TOP = matrix[y - half] ? matrix[y - half][x] : null;
				const RIGHT = matrix[y][x + half];
				const { count, sum } = [BOTTOM, LEFT, TOP, RIGHT].reduce(
					(result, value) => 
					{
						if (isFinite(value) && value != null) 
						{
							result.sum += value;
							result.count += 1;
						}
						return result;
					},
					{ sum: 0, count: 0 }
				);
				matrix[y][x] = sum / count + randomInRange(-randomFactor, randomFactor);
			}
		}
		return matrix;
	}

	const diamondSquare = function(matrix) 
	{
		let chunkSize = MATRIX_LENGTH - 1;
		let randomFactor = RANDOM_INITIAL_RANGE;

		while (chunkSize > 1) 
		{
			calculateSquare(matrix, chunkSize, randomFactor);
			calculateDiamond(matrix, chunkSize, randomFactor);
			chunkSize /= 2;
			randomFactor /= 2;
		}

		return matrix;
	}

	const normalizeMatrix = function(matrix) 
	{
		const maxValue = matrix.reduce((max, row) => 
		{
			return row.reduce((max, value) => Math.max(value, max));
		}, -Infinity);

		return matrix.map((row) => 
		{
			return row.map((val) => val / maxValue);
		});
	}
	
	if (typeof size != 'undefined')
		MATRIX_LENGTH = size + 1;
	
	return (normalizeMatrix(diamondSquare(generateMatrix())));
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
	corner ??= randomInRange(0,3);
	switch(corner)
	{
		case 0:
		{
			for(let x = 0;x < (hm.length);x+=1)
				for(let y = 0;y < (hm.length);y+=1)
					hm[x][y] = smoothBlock(hm,new Vector2(x,y));
		}
		break;
		case 1:
		{
			for(let x = hm.length-1;x >=0;x-=1)
				for(let y = 0;y < (hm.length);y+=1)
					hm[x][y] = smoothBlock(hm,new Vector2(x,y));
		}
		break;
		case 2:
		{
			for(let x = hm.length-1;x >=0;x-=1)
				for(let y = hm.length-1;y >=0;y-=1)
					hm[x][y] = smoothBlock(hm,new Vector2(x,y));
		}
		break;
		case 3:
		{
			for(let x = 0;x < (hm.length);x+=1)
				for(let y = hm.length-1;y >=0;y-=1)
					hm[x][y] = smoothBlock(hm,new Vector2(x,y));
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
			hm[x][y] = Math.round((hm[x][y] +min)*(Math.pow(10,((Math.trunc(min) + '').length))));
		}
	return hm;
}

function polishHeightmap(heightmap,fixedHeight)//same as round but different
{
	// Define a function to be applied to each element of the matrix
	const yCallback = function(num) 
	{
	  return Math.round(LimitTo(num,fixedHeight-((fixedHeight/4)*3),fixedHeight-2));
	}
	
	// Define a function to be applied to each row of the matrix
	const xCallback = function(row) 
	{
	  return row.map(yCallback);
	}

	// Apply the doubleRow() function to each row of the matrix using map()
	return(heightmap.map(xCallback));
}

async function autoHeightmap(mapsize, multi) 
{
	let promises = [];

	for (let x = 0; x < multi; x++) 
	{
		for (let y = 0; y < multi; y++) 
		{
			promises.push(Heightmap(mapsize));
		}
	}
	
	return (await Promise.all(promises)
			.then(async (results) => 
			{
				results = await organizeArray(results,multi);
				return(expandMatrix(results));
			}
		)
	)
}

export function autoSmoothHeightmap(hm,smooth)
{
	while(smooth>0)
	{
		hm = smoothHeightmap(hm,randomInRange(0,3));
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
			
			result[x][y] = Array(map[x][y]).fill(new Block('earth'));
			result[x][y] = result[x][y].concat(Array(fixedHeight - map[x][y]).fill(new Block('air')));
		}
	}
	return(result);
}

async function fastTerrain(hm,fixedHeight,slices)
{
	let divided = await customSplitMatrix(hm,slices);
	let terrs = [];
	for(let i = 0;i<slices**2;i++)
		terrs.push(Terrain(divided[i],fixedHeight));
	return (
				await Promise.all(terrs)
				.then(async (results) => 
					{
						results = await autoOrganizeArray(results);
						results = await expandMatrix(results);
						results.heightmap = hm;
						return (results);
					})
			)
}

function checkDifference(heightmap) 
{
	let counter = 0;
  
	for (let i = 0; i < heightmap.length; i++) 
	{
	  for (let j = 0; j < heightmap[i].length; j++) 
	  {
		const currentValue = heightmap[i][j];
		let hasNeighbor = false;
  
		// Check neighbors
		for (let x = -1; x <= 1; x++) 
		{
			for (let y = -1; y <= 1; y++) 
			{
				if (x === 0 && y === 0) continue;

				const neighborI = i + x;
				const neighborJ = j + y;
				if (
					neighborI >= 0 &&
					neighborI < heightmap.length &&
					neighborJ >= 0 &&
					neighborJ < heightmap[i].length
				) 
				{
					const neighborValue = heightmap[neighborI][neighborJ];
					if (Math.abs(currentValue - neighborValue) === 1) 
					{
					hasNeighbor = true;
					break;
					}
				}
			}
			if (hasNeighbor) 
			break;
		}
  
		if (hasNeighbor) 
		{
			counter++;
		}
	  }
	}
	return counter;
}

export async function AutoTerrain(mapsize,multiHorizontal,smooth = false,postslices = 1,retry = 0)
{
	if(typeof mapsize == 'undefined')
		mapsize = Size(128,64);
	else if(typeof mapsize == 'number')
		mapsize = Size(mapsize,mapsize);
	else if(typeof mapsize == 'array')
		mapsize = Size(mapsize[0],mapsize[1]);
	var hmap;
	hmap = await autoHeightmap(mapsize.w,multiHorizontal);
	hmap = await roundHeightmap(hmap);
	hmap = await autoSmoothHeightmap(hmap,smooth);

	hmap = polishHeightmap(hmap,mapsize.h);
	
	if(retry>=1&&checkDifference(hmap)>((mapsize.w*multiHorizontal)**2)/2)
	{
		if(retry > 1)
			console.log("retry number " + retry);
		retry++;
		return(AutoTerrain(mapsize,multiHorizontal,smooth,postslices,retry));
	}
	if(retry >= 2)
		console.log('heightmap generated in ' + retry + ' retries.')

	var terrain = [];
	terrain = await fastTerrain(hmap,mapsize.h,postslices);
	//terrain = await rampifyTerrain(terrain);
	return(terrain);
}