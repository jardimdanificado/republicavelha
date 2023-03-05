import { Vector3 } from "./types.mjs";

export function HSL2RGB(h, s, l) 
{
	var r, g, b;
	if (s == 0) 
	{
		r = g = b = l; // achromatic
	}
	else 
	{
		var hue2rgb = function hue2rgb(p, q, t) 
		{
			if (t < 0) t += 1;
			if (t > 1) t -= 1;
			if (t < 1 / 6) return p + (q - p) * 6 * t;
			if (t < 1 / 2) return q;
			if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
			return p;
		}

		var q = l < 0.5 ? l * (1 + s) : l + s - l * s;
		var p = 2 * l - q;
		r = hue2rgb(p, q, h + 1 / 3);
		g = hue2rgb(p, q, h);
		b = hue2rgb(p, q, h - 1 / 3);
	}

	return (RGB(Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)));
}

export function HSL2RGBA(h, s, l) 
{
	let temp = HSL2RGB(h, s, l);
	temp.a = 255;
	return (temp);
}

export async function organizeArray(arr, parts) 
{
	let matrix = [];
	let chunkSize = Math.ceil(arr.length / parts);
	for (let i = 0; i < parts; i++) 
	{
		matrix.push(arr.slice(i * chunkSize, (i + 1) * chunkSize));
	}
	return matrix;
}

export async function autoOrganizeArray(arr) 
{
	let matrix = [];
	let parts = Math.ceil(Math.sqrt(arr.length));
	let chunkSize = Math.ceil(arr.length / parts);
	for (let i = 0; i < arr.length; i += chunkSize) 
	{
		matrix.push(arr.slice(i, i + chunkSize));
	}
	return matrix;
}

export function recursiveMap(arr, callback) 
{
	return arr.map(function(element) 
	{
	  if (Array.isArray(element)) 
	  {
		return recursiveMap(element, callback);
	  } 
	  else 
	  {
		return callback(element);
	  }
	});
} 

export function flattenMatrix(matrix) 
{
	return matrix.reduce((flatArray, currentRow) => flatArray.concat(currentRow), []);
}

function shuffleArray(arr) 
{
	for (let i = arr.length - 1; i > 0; i--) 
	{
	  const j = Math.floor(Math.random() * (i + 1));
	  [arr[i], arr[j]] = [arr[j], arr[i]];
	}
	return arr;
}

export function Size(w, h) 
{
	var temp = { w: w, h: h }; temp.height = temp.h; temp.width = temp.w; return temp; 
}

export function randomIntArray(start, end, size) 
{
	const result = [];
	const range = end - start + 1;
	for (let i = 0; i < size; i++) {
	  const randomInt = Math.floor(Math.random() * range) + start;
	  result.push(randomInt);
	}
	return result;
  }

export function getSizeInBytes(input) 
{
	if (typeof input == 'function') 
		return (input.toString().length); 
	else 
		return (JSON.stringify(input).length); 
}

//-----------------------------------
//UTILS
//-----------------------------------

export function roleta(...odds) 
{
	var roleta = []; 
	for(let i = 0; i<odds.length;i++)
		roleta = roleta.concat(Array(odds[i]).fill(i));
	return(shuffleArray(roleta)[randomInRange(0, roleta.length - 1)]);
}

export function repeatWithInterval(func, args, delay) 
{
	function runFunc() 
	{
	  // Call the function with the provided arguments
	  func.apply(null, args);
	}
  
	// Start the initial execution of the function with setInterval
	var intervalHandle = setInterval(runFunc, delay);
  
	// Return the handle to the current setInterval call
	return intervalHandle;
}

export function repeatWithAnimationFrame(func, args) 
{
	function runFunc() 
	{
	  // Call the function with the provided arguments
	  func.apply(null, args);
  
	  // Set up the next execution of the function with requestAnimationFrame
	  animationFrameHandle = requestAnimationFrame(runFunc);
	}
  
	// Start the initial execution of the function with requestAnimationFrame
	var animationFrameHandle = requestAnimationFrame(runFunc);
  
	// Return the handle to the current requestAnimationFrame call
	return animationFrameHandle;
}

export async function expandMatrix(matrix) 
{
	let finalMatrix = [];
	let currentRow = 0;
	//console.log(matrix)
	for (let i = 0; i < matrix.length; i++) 
	{
		for (let j = 0; j < matrix[i].length; j++) 
		{
			for (let x = 0; x < matrix[i][j].length; x++) 
			{
				for (let y = 0; y < matrix[i][j][x].length; y++) 
				{
					if (!finalMatrix[currentRow + x]) 
					{
						finalMatrix[currentRow + x] = [];
					}
					finalMatrix[currentRow + x][y + matrix[i][j][x].length * j] = matrix[i][j][x][y];
				}
			}
		}
		currentRow += matrix[i][0].length;
	}
	return finalMatrix;
}

export async function splitMatrix(matrix) 
{
	let subMatrixSize = Math.ceil(matrix.length / 2);
	let subMatrix1 = matrix.slice(0, subMatrixSize).map(x => x.slice(0, subMatrixSize));
	let subMatrix2 = matrix.slice(0, subMatrixSize).map(x => x.slice(subMatrixSize));
	let subMatrix3 = matrix.slice(subMatrixSize).map(x => x.slice(0, subMatrixSize));
	let subMatrix4 = matrix.slice(subMatrixSize).map(x => x.slice(subMatrixSize));
	return [[subMatrix1, subMatrix2], [subMatrix3, subMatrix4]];
}

export async function customSplitMatrix(matrix, slices) 
{
	let subMatrixSize = Math.ceil(matrix.length / slices);
	let subMatrices = [];
	for (let i = 0; i < slices; i++) 
	{
		for (let j = 0; j < slices; j++) 
		{
			let subMatrix = matrix.slice(i * subMatrixSize, (i + 1) * subMatrixSize).map(x => x.slice(j * subMatrixSize, (j + 1) * subMatrixSize));
			subMatrices.push(subMatrix);
		}
	}
	return subMatrices;
}

export async function customMarginalSplitMatrix(matrix, slices = 2, margin = 0) 
{
	let subMatrixSize = Math.ceil(matrix.length / slices);
	let subMatrix1 = matrix.slice(0, subMatrixSize + margin).map(x => x.slice(0, subMatrixSize + margin));
	let subMatrix2 = matrix.slice(0, subMatrixSize + margin).map(x => x.slice(subMatrixSize - margin));
	let subMatrix3 = matrix.slice(subMatrixSize - margin).map(x => x.slice(0, subMatrixSize + margin));
	let subMatrix4 = matrix.slice(subMatrixSize - margin).map(x => x.slice(subMatrixSize - margin));
	return [[subMatrix1, subMatrix2], [subMatrix3, subMatrix4]];
}

export async function marginalSplitMatrix(matrix, margin = 8) 
{
	let subMatrixSize = Math.ceil(matrix.length / 2);
	let subMatrix1 = matrix.slice(0, subMatrixSize + margin).map(x => x.slice(0, subMatrixSize + margin));
	let subMatrix2 = matrix.slice(0, subMatrixSize + margin).map(x => x.slice(subMatrixSize - margin));
	let subMatrix3 = matrix.slice(subMatrixSize - margin).map(x => x.slice(0, subMatrixSize + margin));
	let subMatrix4 = matrix.slice(subMatrixSize - margin).map(x => x.slice(subMatrixSize - margin));
	return [[subMatrix1, subMatrix2], [subMatrix3, subMatrix4]];
}

export async function divideMatrix(largeMatrix, slices) 
{
	let dividedMatrix = [];
	let sliceSize = Math.floor(largeMatrix.length / slices);
	for (let i = 0; i < largeMatrix.length; i += sliceSize) 
	{
		let row = largeMatrix.slice(i, i + sliceSize);
		let dividedRow = [];
		for (let j = 0; j < row[0].length; j += sliceSize) 
		{
			let subMatrix = row.map(x => x.slice(j, j + sliceSize));
			dividedRow.push(subMatrix);
		}
		dividedMatrix.push(dividedRow);
	}
	return dividedMatrix;
}

export function create3DArray(dimX, dimY, dimZ, input) 
{
	const arr3D = [];

	for (let i = 0; i < dimX; i++) 
	{
		const arr2D = [];
		for (let j = 0; j < dimY; j++) 
		{
			const arr1D = [];
			for (let k = 0; k < dimZ; k++) 
			{
				if (typeof input === 'function') 
				{
					arr1D.push(input());
				}
				else if (typeof input === 'object' || typeof input === 'number' || typeof input === 'string') 
				{
					arr1D.push(input);
				}
				else if (typeof input === 'function' && input.prototype.constructor) 
				{
					arr1D.push(new input());
				}
				else 
				{
					arr1D.push({});
				}
			}
			arr2D.push(arr1D);
		}
		arr3D.push(arr2D);
	}
	return arr3D;
}

export function manualLength(arr) 
{
	var count = 0;
	while (true) 
	{
		if (typeof arr[count] != 'undefined')
			count++;
		else
			return count;
	}
}

export function customFilter(array,property,value)
{
	return(array.filter((element) => 
	{
 		return element[property] === value;
	}))
}

export function LimitTo(value, min, max) 
{
	if (value > max) {
		while (value > max)
			value -= max - min;
	}
	if (value < min) {
		while (value < min)
			value += max - min;
	}
	return value;
}

export function Pending(pendingList,frames, func, args) 
{
	if (typeof frames != 'undefined' && typeof func != 'undefined') 
	{
		let temp = {};
		temp.frames = frames;
		temp.func = func;
		if (typeof args != 'undefined')
			temp.args = args;
		pendingList.push(temp);
	}
	else {
		for (let i = 0; i < pendingList.length; i++) 
		{
			if (pendingList[i].frames > 0)
				pendingList[i].frames--;
			else 
			{
				if (typeof pendingList[i].args == 'undefined')
					pendingList[i].func();
				else
					pendingList[i].func.apply(null, pendingList[i].args);
				pendingList.splice(i, 1);
			}
		}
	}
}

export const randomInRange = function (min, max) 
{ 
	return Math.floor(Math.random() * (max - min + 1) + min); 
}

//-----------------------------------
//CALCULATE
//-----------------------------------

export function FloatDifference(a, b) 
{ 
	return ((a + b + Math.abs(a - b)) / 2); 
}

export function Vector3Difference(vec1, vec2) 
{ 
	return (new Vector3(FloatDifference(vec1.x, vec2.x), FloatDifference(vec1.y, vec2.y), FloatDifference(vec1.z, vec2.z))); 
}

export function RotateAroundPivot(point, pivot, angle) 
{
	angle = (angle) * (Math.PI / 180); // Convert to radians
	var rotatedX = Math.cos(angle) * (point.x - pivot.x) - Math.sin(angle) * (point.z - pivot.z) + pivot.x;
	var rotatedZ = Math.sin(angle) * (point.x - pivot.x) + Math.cos(angle) * (point.z - pivot.z) + pivot.z;
	return (new Vector3(rotatedX, point.y, rotatedZ));
}

//-----------------------------------
//DEBUG
//-----------------------------------

export function benchy(callback, args, optName = "unamed") 
{
	callback.name ??= optName;
	console.time(callback.name);
	const result = callback.apply(this, args);
	console.timeEnd(callback.name);
	if(typeof result == 'undefined')
		return null;
	return (result);
}

export async function abenchy(callback, args, optName = "unamed") 
{
	if (optName == "unamed" && callback.name.length > 0)
		optName = callback.name;
	console.time(optName);
	const result = await callback.apply(this, args);
	console.timeEnd(optName);
	if(typeof result == 'undefined')
		return null;
	return (result)
}