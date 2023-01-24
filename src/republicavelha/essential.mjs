//-----------------------------------
//PRIMITIVES
//-----------------------------------

export function RGB(r,g,b){return({r:r,g:g,b:b});}
export function RGBA(r,g,b,a){return({r:r,g:g,b:b,a:a});}
export function HSL2RGB(h, s, l)
{
    var r, g, b;
    if(s == 0)
	{
        r = g = b = l; // achromatic
    }
	else
	{
        var hue2rgb = function hue2rgb(p, q, t)
		{
            if(t < 0) t += 1;
            if(t > 1) t -= 1;
            if(t < 1/6) return p + (q - p) * 6 * t;
            if(t < 1/2) return q;
            if(t < 2/3) return p + (q - p) * (2/3 - t) * 6;
            return p;
        }

        var q = l < 0.5 ? l * (1 + s) : l + s - l * s;
        var p = 2 * l - q;
        r = hue2rgb(p, q, h + 1/3);
        g = hue2rgb(p, q, h);
        b = hue2rgb(p, q, h - 1/3);
    }

    return(RGB(Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)));
}
export function HSL2RGBA(h, s, l)
{
	let temp = HSL2RGB(h,s,l);
	temp.a = 255;
	return(temp);
};
export function Vector3(x,y,z){return({x:x,y:y,z:z});}
export function Vector3Zero(){return({x:0,y:0,z:0});}
export function Vector2(x,y){return({x:x,y:y});}
export function Vector2Zero(){return({x:0,y:0});}
export function BoundingBox(min,max){return({min:{x:min.x,y:min.y,z:min.z},max:{x:max.x,y:max.y,z:max.z}});}
export function Position(local,global){return({local:local,global:global})};

export async function organizeArray(arr, parts) {
    let matrix = [];
    let chunkSize = Math.ceil(arr.length / parts);
    for (let i = 0; i < parts; i++) {
        matrix.push(arr.slice(i * chunkSize, (i + 1) * chunkSize));
    }
    return matrix;
}

export function Size(w,h){var temp = {w:w,h:h};temp.height = temp.h;temp.width = temp.w;return temp;};

export function getSizeInBytes(input){if(typeof input == 'function')return(input.toString().length);else return(JSON.stringify(input).length);}
//-----------------------------------
//UTILS
//-----------------------------------

export function flattenMatrix(matrix) {
    let finalMatrix = [];
    let currentRow = 0;
    for (let i = 0; i < matrix.length; i++) {
        for (let j = 0; j < matrix[i].length; j++) {
            for (let x = 0; x < matrix[i][j].length; x++) {
                for (let y = 0; y < matrix[i][j][x].length; y++) {
                    if (!finalMatrix[currentRow + x]) {
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

export function divideMatrix(largeMatrix, size) {
    let dividedMatrix = [];
    for (let i = 0; i < largeMatrix.length; i += size) {
        let row = largeMatrix.slice(i, i + size);
        let dividedRow = [];
        for (let j = 0; j < row.length; j += size) {
            let subMatrix = row.map(x => x.slice(j, j + size));
            dividedRow.push(subMatrix);
        }
        dividedMatrix.push(dividedRow);
    }
    return dividedMatrix;
}

export var Comrade = 
{
	modular:function(modulePath,functionName,args)
	{
		var worker = new Worker("./src/republicavelha/comrade.worker.js");
		worker.result = [];
		var content = 
		{
			modulePath:modulePath,
			method:functionName,
			args:args
		};
		worker.onmessage = function(event)
		{
			worker.result = event.data;
			console.log(modulePath + '.' + functionName+ "(" + args + ') is done;');
			worker.terminate();
		};
		worker.postMessage(content);
		return(worker);
	},
	functional:function(func,args)
	{
		var worker = new Worker("./src/republicavelha/comrade.worker.js");
		worker.result = [];
		var content = 
		{
			method:func,
			args:args
		};
		worker.onmessage = function(event)
		{
			worker.result = event.data;
			console.log(modulePath + '.' + functionName+ "(" + args + ') is done;');
			worker.terminate();
		};
		worker.postMessage(content);
		return(worker);
	}
}

export function workerPromise(worker)
{
	return(new Promise((resolve) => {worker.onmessage = resolve;}))
}

export function Assign(reference, array) 
{
    Object.assign(reference, array, { length: array.length });
}

export function Retry(condition,func,args,delay)
{
	args ??= '[]';
	delay ??= 1000;
	let id = Date.now();
	var fname = 'func' + id;
	var fargs = 'args' + id;
	var txt = '';
	
	txt += 
	`
  	var timeout = function()
	{
	   	if($condition)
			setTimeout.apply(this,[timeout,$delay].concat($args))
	   	else
		{
  			let $fname = $func 
			let $fargs = $args
   
  			if($fargs.length > 0)
				$fname.apply(this,$fargs)
			else
   			$fname();
 		}
	};
 	timeout();
 `
	
	txt = txt.replace("$condition",condition);
	txt = txt.replace("$func",func);
	while(txt.includes("$args"))
		txt = txt.replace("$args",args);
	while(txt.includes("$delay"))
		txt = txt.replace("$delay",delay);
	while(txt.includes("$fname"))
		txt = txt.replace("$fname",fname);
	while(txt.includes("$fargs"))
		txt = txt.replace("$fargs",fargs);
	return(txt);
}

export function manualLength(arr)
{
	var count = 0;
	while(true)
	{
		if(typeof arr[count] != 'undefined')
			count++;
		else
			return count;
	}
}

//A QUICK IMPLEMENTATIONS TO DEFAULT ARGS
export function DefaultsTo(target,def)
{
	target ??= def;
	return target;
}
export const defsto = DefaultsTo;

export function LimitItTo(value,min,max)
{
	if(value > max)
	{
		while(value > max)
			value -= max-min;
	}
	if(value < min)
	{
		while(value < min)
			value += max-min;
	}
	return value;
}
export const limito = LimitItTo;

var pendingList = [];
export function Pending(frames,func,args)
{
	
	if(typeof frames != 'undefined'&& typeof func != 'undefined')
	{
		let temp = {};
		temp.frames = frames;
		temp.func = func;
		if(typeof args != 'undefined')
			temp.args = args;
		pendingList.push(temp);
	}
	else
	{
		for(let i = 0;i<pendingList.length;i++)
		{

			if(pendingList[i].frames > 0)
				pendingList[i].frames--;
			else
			{
				if(typeof pendingList[i].args == 'undefined')
					pendingList[i].func();
				else 
					pendingList[i].func.apply(null,pendingList[i].args);
				pendingList.splice(i,1);
			}
		}
	}
}
export const pendent = Pending;
export const pend = Pending;
export const pending = Pending;

export const randomInRange = function(min, max){return Math.floor(Math.random() * (max - min + 1) + min);}
export const randi = randomInRange;

//-----------------------------------
//CALCULATE
//-----------------------------------

export function DifferenceFloat(a, b){return((a+b+Math.abs(a-b))/2);}
export function DifferenceVec3(vec1, vec2){return(Vector3(DifferenceFloat(vec1.x, vec2.x),DifferenceFloat(vec1.y, vec2.y),DifferenceFloat(vec1.z, vec2.z)));}
export function RotateAroundPivot(point,pivot,angle)
{
	angle = (angle ) * (Math.PI/180); // Convert to radians
	var rotatedX = Math.cos(angle) * (point.x - pivot.x) - Math.sin(angle) * (point.z-pivot.z) + pivot.x;
	var rotatedZ = Math.sin(angle) * (point.x - pivot.x) + Math.cos(angle) * (point.z -pivot.z) + pivot.z;
	return Vector3(rotatedX,point.y,rotatedZ);
}
