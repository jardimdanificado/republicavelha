import * as rve from "./essential.mjs"

export const Storage = function(amount,type,capacity)
{
	//solid(kg),liquid(liter),gas(m³),writing(characters)
	return{type:rve.defsto(type,'solid'),capacity:rve.defsto(capacity,1),amount:rve.defsto(amount,1)}
}

export const Limb = function(type,importance,condition)
{
	return(
		{
			type:rve.defsto(type,'breeder'),//all,viewer,breeder,eater,grabber,speaker,listener,smeller,breather,thinker,pisser,shitter,walker,other
			importance:rve.defsto(importance,10),//0 = NO IMPORTANCE, 10 = VERY IMPORTANT, INFINITY = ESSENTIAL
			quality:100,
			condition:rve.defsto(condition,100)
		}
	);
}

export const Modificator = function(type,subtype,status,quality,condition,func)
{
	return(
		{
			type:type,//trait,mood,memory,
			subtype:rve.defsto(subtype,'permanent'),//permanent,temporary
			status:rve.defsto(status,'active'),
			active:true,
			quality:rve.defsto(quality,100),
			condition:rve.defsto(condition,100),
			func:rve.defsto(func,[])
		}
	);
}