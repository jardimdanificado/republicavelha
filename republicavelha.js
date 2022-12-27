//-----------------------------------
//PRIMITIVES
//-----------------------------------

function RGBA(r,g,b,a){return({r:r,g:g,b:b,a:a});}
function Vector3(x,y,z){return({x:x,y:y,z:z});}
function Vector3Zero(){return({x:0,y:0,z:0});}
function Vector2(x,y){return({x:x,y:y});}
function Vector2Zero(){return({x:0,y:0});}
function BoundingBox(min,max){return({min:{x:min.x,y:min.y,z:min.z},max:{x:max.x,y:max.y,z:max.z}});}

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

const Container = function(amount,type,capacity)
{
	if(typeof amount == 'undefined'||amount == 1)
		return{type:defsto(type,'solid'),capacity:defsto(capacity,1),amount:defsto(amount,1)}
}

//types
const _Item = function(name,status,quality,condition,position)
{
	return(
		{
			name:name,
			type:'item',
			status:defsto(status,''),
			quality:defsto(quality,10),
			condition:defsto(condition,100),
			position:defsto(position,Vector3Zero())
		}
	);
}

//CREATURES
const Limb = function(type,quality,condition)
{
	return(
		{
			//viewer,breeder,eater,grabber,speaker,listener,smeller,breather,thinker,pisser,shitter,walker,other
			type:defsto(type,'breeder'),
			quality:defsto(quality,10),
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
			eye:Array(2).fill(Limb('viewer',5)),
			hand:Array(2).fill(Limb('grabber',1.25)),
			feet:Array(2).fill(Limb('walker',1.25)),
			finger:Array(10).fill(Limb('grabber',(1.25/20))).concat(Array(10).fill(Limb('walker',(1.25/20)))),
			nail:Array(10).fill(Limb('grabber',(1.25/20))).concat(Array(10).fill(Limb('walker',(1.25/20)))),
			arm:Array(2).fill(Limb('grabber',1.25)),
			leg:Array(2).fill(Limb('walker',1.25)),
			ear:Array(2).fill(Limb('listener',5)),
			mouth:Limb('eater',5),
			teeth:Array(32).fill(Limb('eater',(5/32))),
			nose:Limb('smeller,breather','10,2'),
			lung:Array(2).fill(Limb('breather',8)),
			head:Limb('other'),
			brain:Limb('thinker'),
			torso:Limb('other'),
			anus:Limb('shitter'),
		},
		_male:
		{
			penis:Limb('breeder,pisser','5,10'),
			testicule:Array(2).fill(Limb('breeder',2.5)),	
		},
		_female:
		{
			vagina:Limb('breeder,pisser',"5,10"),
			ovary:Array(2).fill(Limb('breeder',2.5)),	
		},
		male:function(){return{...this._both,...this._male}},
		female:function(){return{...this._both,...this._female}},
	}
	
};

const _Creature = function(specime,gender,age,position)
{
	return(
		{
			type:'creature',
			specime:specime,
			gender:gender,
			age:defsto(age,15*360),//age is in days
			status:'idle',
			body:Bodies[specime][gender](),
			position:defsto(position,Vector3(0,0,0))
		}
	);
};

//declaration
const Objeto = 
{
	New:_New,
	Item:_Item,
	Creature:_Creature
}
//test
console.log(_Creature('human','male'));