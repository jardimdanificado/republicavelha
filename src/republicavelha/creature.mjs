export const Body = 
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
			stomach:Limb('food processor, food storage','2,10'),
			intestine:Limb('food processor, shit storage','8,10'),
			figado:Limb("energy storage",100),
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
}

function Limb(type = 'breeder',importance = 10,condition = 100)
{
	return(
		{
			type:type,//all,viewer,breeder,eater,grabber,speaker,listener,smeller,breather,thinker,pisser,shitter,walker,other
			importance:importance,//0 = NO IMPORTANCE, 10 = VERY IMPORTANT, INFINITY = ESSENTIAL
			quality:100,
			condition:condition
		}
	);
}

function Tought(type,intensity,content) 
{
	return{
		type:type,
		intensity:intensity,
		content:content
	}
}

function Creature(specime,gender,birth,position)
{
	return(
		{
			...this.Generic('creature','idle',birth,position),
			specime:specime,//human
			gender:gender,
			body:Body[specime][gender](),
			thought:[],
			
		}
	);
}

function determinateCreature(creature) 
{
	
}