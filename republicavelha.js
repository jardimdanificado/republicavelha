//-----------------------------------
//PRIMITIVES
//-----------------------------------

function RGBA(r,g,b,a){return({r:r,g:g,b:b,a:a});}
function Vector3(x,y,z){return({x:x,y:y,z:z});}
function Vector3Zero(){return({x:0,y:0,z:0});}
function Vector2(x,y){return({x:x,y:y});}
function Vector2Zero(){return({x:0,y:0});}
function BoundingBox(min,max){return({min:{x:min.x,y:min.y,z:min.z},max:{x:max.x,y:max.y,z:max.z}});}
function Position(local,global){return({local:local,global:global})};

//-----------------------------------
//UTILS
//-----------------------------------

//A QUICK IMPLEMENTATIONS TO DEFAULT ARGS
function DefaultsTo(target,def)
{
	if(typeof target == 'undefined')
		return def;
	else 
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
			//console.log(pendingList)
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
	const N = 8;
	const RANDOM_INITIAL_RANGE = 10;
	var MATRIX_LENGTH = Math.pow(2, N) + 1;

	const randomInRange = function(min, max) {
		return Math.floor(Math.random() * (max - min + 1) + min);
	}

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

function Terrain(size)
{
	var mt = Heightmap(size);
	var mm = {max:Infinity*(-1),min:Infinity};
	var result = [];
	for(let x = 0 ;x < mt.length; x++)
	{
		for(let y = 0;y < mt.length;y++)
		{
			if(mm.min > mt[x][y]) 
			{
				mm.min = mt[x][y];
			}
			if(mm.max < mt[x][y]) 
			{
				mm.max = mt[x][y];
			}
		}
	}
	for(let x = 0;x < mt.length;x++)
	{
		result[x] = [];
		for(let y = 0;y < mt.length;y++)
		{
			result[x][y] = [];
			let hei = Math.abs(mm.min*Math.pow(10,((Math.round(mm.min) + '').length)));
			const earthBlocs = limito((Math.abs(Math.round(mt[x][y] + hei)))*4,1,mt.lenght);
			const airBlocks = limito(Math.round((mt.length) - earthBlocs-hei),2,mt.lenght);
			result[x][y] = Array(earthBlocs)
								.fill([Objecto.Block('earth','full')])
								.concat([[Objecto.Block('grass','floor'),Objecto.Block('air','empty')]])
								.concat(Array(airBlocks-1).fill([Objecto.Block('air','empty')]));
		}
	}
	return(result);
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

//test
console.log(Objecto.Creature('human','male'));
console.log(Terrain(32));