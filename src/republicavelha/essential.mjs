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

export function Size(w,h){var temp = {w:w,h:h};temp.height = temp.h;temp.width = temp.w;return temp;};

export function getSizeInBytes(input){if(typeof input == 'function')return(input.toString().length);else return(JSON.stringify(input).length);}
//-----------------------------------
//UTILS
//-----------------------------------

export function Assing(reference, array) {
    Object.assign(reference, array, { length: array.length });
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
			value -= max;
	}
	if(value < min)
	{
		while(value < min)
			value += max;
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
