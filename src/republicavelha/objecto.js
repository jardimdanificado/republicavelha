import * as rve from "./essential.js"
import * as Bodies from "./body.js"
export const Generic = function(type,status,birth,position,quality,condition,mods)
{
	return(
		{
			type:rve.defsto(type,'generic'),
			status:rve.defsto(status,''),
			mods:rve.defsto(mods,[]),
			quality:rve.defsto(quality,100),
			condition:rve.defsto(condition,100),
			position:rve.defsto(position,rve.Position(rve.Vector3Zero(),rve.Vector3Zero())),
			birth:rve.defsto(birth,0)//birth in seconds
		}
	);
}
export const Creature = function(specime,gender,birth,position)
{
	return(
		{
			...this.Generic('creature','idle',birth,position),
			specime:specime,//human
			gender:gender,
			body:Bodies[specime][gender]()
		}
	);
}
export const Block = function(material,subtype,status,birth,position,quality,condition)
{
	return(
		{
			...this.Generic('block',status,birth,position,quality,condition),
			material:rve.defsto(material,'earth'),//earth,wood,rock
			subtype:rve.defsto(subtype,'empty'),//empty,full,floor,half
		}
	);
}