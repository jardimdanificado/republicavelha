//-----------------------------------
//PRIMITIVES
//-----------------------------------

function RGB(r,g,b){return({r:r,g:g,b:b});}
function RGBA(r,g,b,a){return({r:r,g:g,b:b,a:a});}
function HSL2RGB(h, s, l)
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
function HSL2RGBA(h, s, l)
{
	let temp = HSL2RGB(h,s,l);
	temp.a = 255;
	return(temp);
};
function Vector3(x,y,z){return({x:x,y:y,z:z});}
function Vector3Zero(){return({x:0,y:0,z:0});}
function Vector2(x,y){return({x:x,y:y});}
function Vector2Zero(){return({x:0,y:0});}
function BoundingBox(min,max){return({min:{x:min.x,y:min.y,z:min.z},max:{x:max.x,y:max.y,z:max.z}});}
function Position(local,global){return({local:local,global:global})};

//-----------------------------------
//UTILS
//-----------------------------------

function manualLength(arr)
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
function DefaultsTo(target,def)
{
	target ??= def;
	return target;
}
const defsto = DefaultsTo;

function LimitItTo(value,min,max)
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
const limito = LimitItTo;

var pendingList = [];
function Pending(frames,func,args)
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
const pendent = Pending;
const pend = Pending;
const pending = Pending;

const randomInRange = function(min, max){return Math.floor(Math.random() * (max - min + 1) + min);}
const randi = randomInRange;
//-----------------------------------
//CALCULATE
//-----------------------------------

function DifferenceFloat(a, b){return((a+b+Math.abs(a-b))/2);}
function DifferenceVec3(vec1, vec2){return(Vector3(DifferenceFloat(vec1.x, vec2.x),DifferenceFloat(vec1.y, vec2.y),DifferenceFloat(vec1.z, vec2.z)));}
function RotateAroundPivot(point,pivot,angle)
{
	angle = (angle ) * (Math.PI/180); // Convert to radians
	var rotatedX = Math.cos(angle) * (point.x - pivot.x) - Math.sin(angle) * (point.z-pivot.z) + pivot.x;
	var rotatedZ = Math.sin(angle) * (point.x - pivot.x) + Math.cos(angle) * (point.z -pivot.z) + pivot.z;
	return Vector3(rotatedX,point.y,rotatedZ);
}

//-----------------------------------
//MODIFICATOR//MODIFICATOR//MODIFICATOR//MODIFICATOR
//MODIFICATOR//MODIFICATOR//MODIFICATOR//MODIFICATOR
//MODIFICATOR//MODIFICATOR//MODIFICATOR//MODIFICATOR
//MODIFICATOR//MODIFICATOR//MODIFICATOR//MODIFICATOR
//MODIFICATOR//MODIFICATOR//MODIFICATOR//MODIFICATOR
//-----------------------------------

const Storage = function(amount,type,capacity)
{
	//solid(kg),liquid(liter),gas(m³),writing(characters)
	return{type:defsto(type,'solid'),capacity:defsto(capacity,1),amount:defsto(amount,1)}
}

const Limb = function(type,importance,condition)
{
	return(
		{
			type:defsto(type,'breeder'),//all,viewer,breeder,eater,grabber,speaker,listener,smeller,breather,thinker,pisser,shitter,walker,other
			importance:defsto(importance,10),//0 = NO IMPORTANCE, 10 = VERY IMPORTANT, INFINITY = ESSENTIAL
			quality:100,
			condition:defsto(condition,100)
		}
	);
}

const Modificator = function(type,subtype,status,quality,condition,func)
{
	return(
		{
			type:type,//trait,mood,memory,
			subtype:defsto(subtype,'permanent'),//permanent,temporary
			status:defsto(status,'active'),
			active:true,
			quality:defsto(quality,100),
			condition:defsto(condition,100),
			func:defsto(func,[])
		}
	);
}

//-----------------------------------
//TERRAIN
//-----------------------------------

function Heightmap(size) {
	const N = (8+randi(0,5));
	const RANDOM_INITIAL_RANGE = (10+randi(0,3));
	var MATRIX_LENGTH = Math.pow(2, N)+1;

	const generateMatrix = function() {
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
					sum / count + randomInRange(-randomFactor, randomFactor);
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
				matrix[y][x] = sum / count + randomInRange(-randomFactor, randomFactor);
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

function smoothHeightmap(hm)
{
	var result = [];
	
	for(let x = 0;x < (hm.length);x+=1)
	{
		result[x] = [];
		for(let y = 0;y < (hm.length);y+=1)
		{
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
			result[x][y] = sum/count;
		}
	}
	return result;
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
			var earthb = Math.round(limito(mt[x][y],(mt.length-((mt.length/4)*3)),(mt.length-(mt.length/4))));
			var airb = mt.length - earthb;
			if(earthb >=1)
				result[x][y] = Array(earthb-1).fill([Objecto.Block('earth','full')]);
			
			result[x][y] = result[x][y].concat([[Objecto.Block('earth','full'),Objecto.Block('grass','floor')]]);
			if(airb >= 1)
				result[x][y] = result[x][y].concat(Array(airb).fill([Objecto.Block('air','empty')]));
		}
	}
	return(result);
}

function AutoTerrain(mapsize,type,layercount,smooth,randomize,subdivide)
{
	var hmaps = [];
	var result = [];
	randomize ??= false;
	subdivide ??= false;
	smooth ??= false;
	layercount ??= 1;
	for(let x = 0 ;x < layercount; x++)
	{
		let tmap = roundHeightmap(Heightmap(mapsize),type);
		var lsub = subdivide;
		var lrnd = randomize;
		var lsmo = smooth;
		while(lsub<0)
		{
			tmap = subdivideHeightmap(tmap);
			lsub++;
		}
		while(lrnd<0)
		{
			tmap = randomizeHeightmap(tmap);
			lrnd++;
		}
		while(lsmo<0)
		{
			tmap = smoothHeightmap(tmap);
			lsmo++;
		}
		hmaps.push(tmap);
	}

	for(let k = 0 ;k < layercount; k++)
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
	while(randomize>0)
	{
		result = randomizeHeightmap(result);
		randomize--;
	}
	while(smooth>0)
	{
		result = smoothHeightmap(result);
		smooth--;
	}
	while(subdivide>0)
	{
		result = subdivideHeightmap(result);
		subdivide--;
	}
	var terr = Terrain(result);
	return(terr);
}

//-----------------------------------
//BODIES
//-----------------------------------

const Bodies = 
{
	human:
	{
		_both:
		{
			eye:Array(2).fill(Limb('viewer')),
			hand:Array(2).fill(Limb('grabber')),
			feet:Array(2).fill(Limb('walker')),
			finger:Array(10).fill(Limb('grabber',1)).concat(Array(10).fill(Limb('walker',1))),
			nail:Array(10).fill(Limb('grabber',1)).concat(Array(10).fill(Limb('walker',1))),
			arm:Array(2).fill(Limb('grabber')),
			leg:Array(2).fill(Limb('walker')),
			ear:Array(2).fill(Limb('listener')),
			mouth:Limb('eater'),
			teeth:Array(32).fill(Limb('eater',1)),
			nose:Limb('smeller,breather','10,2'),
			lung:Array(2).fill(Limb('breather',8)),
			neck:Limb('all',Infinity),
			head:Limb('all',Infinity),
			brain:Limb('thinker'),
			torso:Limb('all',Infinity),
			anus:Limb('shitter'),
		},
		_male:
		{
			penis:Limb('breeder,pisser'),
			testicule:Array(2).fill(Limb('breeder')),	
		},
		_female:
		{
			vagina:Limb('breeder,pisser'),
			ovary:Array(2).fill(Limb('breeder')),	
		},
		male:function(){return{...this._both,...this._male}},
		female:function(){return{...this._both,...this._female}},
	}
};

//-----------------------------------
//OBJETOS//OBJETOS//OBJETOS//OBJETOS
//OBJETOS//OBJETOS//OBJETOS//OBJETOS
//OBJETOS//OBJETOS//OBJETOS//OBJETOS
//OBJETOS//OBJETOS//OBJETOS//OBJETOS
//OBJETOS//OBJETOS//OBJETOS//OBJETOS
//-----------------------------------

//declaration
const Objecto = 
{
	Generic:function(type,status,birth,position,quality,condition,mods)
	{
		return(
			{
				type:defsto(type,'generic'),
				status:defsto(status,''),
				mods:defsto(mods,[]),
				quality:defsto(quality,100),
				condition:defsto(condition,100),
				position:defsto(position,Position(Vector3Zero(),Vector3Zero())),
				birth:defsto(birth,0)//birth in seconds
			}
		);
	},
	Creature:function(specime,gender,birth,position)
	{
		return(
			{
				...this.Generic('creature','idle',birth,position),
				specime:specime,//human
				gender:gender,
				body:Bodies[specime][gender]()
			}
		);
	},
	Block:function(material,subtype,status,birth,position,quality,condition)
	{
		return(
			{
				...this.Generic('block',status,birth,position,quality,condition),
				material:defsto(material,'earth'),//earth,wood,rock
				subtype:defsto(subtype,'empty'),//empty,full,floor,half
			}
		);
	}
};

const Room = 
{
	Generic:function(objectos,collision,temperature)
	{
		return(	
			{
				map:
				{
					objecto:defsto(objectos,[]),
					collision:defsto(collision,[]),
					temperature:defsto(temperature,[])
				}
			}
		)
	},
}
const World = function(rooms)
{
	return(	
		{
			time:0,
			creatures:[],
			rooms:defsto(rooms,[]),
		}
	)
}

//INTERPRETATION
function frame(world)
{
	world.time++;
}

console.log(Objecto.Creature('human','male'));
var mapa = AutoTerrain(16,'flat',145,512,25,1);
var htmltxt = '';

for(let x = 0;x<mapa.length;x++)
{
	for(let y = 0;y<mapa.length;y++)
	{
		for(let z = 0;z<mapa.length;z++)
			if(typeof mapa[x][y][z][1] !== 'undefined'&&mapa[x][y][z][1].subtype === "floor")
			{
				if(z<10)
					htmltxt += ('0'+z + ' ');
				else
					htmltxt += (z+' ');
				break;
			}
	}
	if(typeof window !== 'undefined')
		htmltxt += '<br>';
	else if(typeof process !== 'undefined')
		htmltxt += '\n';
}

if(typeof window !== 'undefined')
{
	document.getElementById("console-screen").innerHTML = htmltxt;
}
else if(typeof process !== 'undefined')
{
	console.clear();
	process.stdout.write(htmltxt);
}