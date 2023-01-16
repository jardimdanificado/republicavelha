import {Limb} from "./modificator.mjs"

export const human =
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
