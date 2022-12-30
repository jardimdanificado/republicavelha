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
const infinity = Math.min();

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
function RotateBoundingBox(hitbox,pivot,angle)
{
	let temp = {min:{...hitbox.min},max:{...hitbox.max}};
	temp.min = RotateAroundPivot(temp.min,pivot,angle);
	temp.max = RotateAroundPivot(temp.max,pivot,angle);
	let result = {};
	result.max = {x:Math.max(temp.min.x,temp.max.x),y:Math.max(temp.min.y,temp.max.y),z:Math.max(temp.min.z,temp.max.z)}
	result.min = {x:Math.min(temp.min.x,temp.max.x),y:Math.min(temp.min.y,temp.max.y),z:Math.min(temp.min.z,temp.max.z)}
	return result;
}
function MoveBoundingBox(hitbox,position)
{
	let result = {};
	result.min = r.Vector3Add(hitbox.min,position);
	result.max = r.Vector3Add(hitbox.max,position);
	return result;
}
function RotateMoveBoundingBox(hitbox,angle,position){return(MoveBoundingBox(RotateBoundingBox(hitbox,Vector3(0,0,0),angle),position));}

//-----------------------------------
//OBJETOS//OBJETOS//OBJETOS//OBJETOS
//OBJETOS//OBJETOS//OBJETOS//OBJETOS
//OBJETOS//OBJETOS//OBJETOS//OBJETOS
//OBJETOS//OBJETOS//OBJETOS//OBJETOS
//OBJETOS//OBJETOS//OBJETOS//OBJETOS
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
			//all,viewer,breeder,eater,grabber,speaker,listener,smeller,breather,thinker,pisser,shitter,walker,other
			type:defsto(type,'breeder'),
			importance:defsto(importance,10),//0 = NO IMPORTANCE, 10 = VERY IMPORTANT, INFINITY = ESSENTIAL
			quality:100,
			condition:defsto(condition,100)
		}
	);
}

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
			neck:Limb('all',infinity),
			head:Limb('all',infinity),
			brain:Limb('thinker'),
			torso:Limb('all',infinity),
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
				specime:specime,
				gender:gender,
				body:Bodies[specime][gender]()
			}
		);
	},
	Block:function(subtype,status,birth,position,quality,condition)
	{
		return(
			{
				...this.Generic('block',status,birth,position,quality,condition),
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