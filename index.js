"use strict";
var mundo;//declared outside debug function so we can console.log it globally
var Republica;

function plantCount(specie = 'caju')
{
	return(mundo.plant.filter((element) => 
	{
 		return element.specie === specie;
	}))
}

function grassify(mundo)
{
	for(let x = 0;x<mundo.map.heightmap.length;x++)
		for(let y = 0;y<mundo.map.heightmap[0].length;y++)
		{
			mundo.plant.spawn(//this spawns a grass seed at each xy position
				'seed',
				'grass',
				'idle', 
				{x:x,y:y,z:mundo.map.block[0][0].length-1}, 
				100, 
				100
			);

			if(Republica.Util.roleta(50,Republica.Util.randomInRange(1,50)))//if roleta == 1
			{	
				let temptype = Object.keys(Republica.Encyclopedia.Plants)
				[
					Republica.Util.roleta.apply(
						this,
						Republica.Util.randomIntArray(
							1,
							10,
							Object.keys(Republica.Encyclopedia.Plants).length
						)
					)
				]
				if(temptype !== 'grass')
					mundo.plant.spawn(//this spawns a random seed at the xy position
						'seed', 
						temptype,
						'idle', 
						{x:x,y:y,z:mundo.map.block[0][0].length-1}, 
						100, 
						100
					);
			}
		}
	return mundo;
}

async function debug(msize,mwidth,mquality)
{
	Republica = await import("./src/republicavelha.mjs");
	console.log(Republica);
	console.time((msize.w*mwidth) + "x" + (msize.w*mwidth) + " map generated in");
	mundo = await Republica.World.New(msize.w,mwidth,(mwidth**mquality)*(msize.w),0,0,1,true);
	console.timeEnd((msize.w*mwidth) + "x" + (msize.w*mwidth) + " map generated in");
	var htmltxt = '';
	for(let x = 0;x<mundo.map.block.length;x++)
	{
		for(let y = 0;y<mundo.map.block[0].length;y++)
		{
			let ok = false;
			for(let z = 0;z<mundo.map.block[0][0].length-1;z++)
			{
				if(mundo.map.block[x][y][z][0].amount === 50)
				{
					let temp = (mundo.map.block.length + '').length;
					for(let p = 0; p < temp; p++)
						htmltxt += '>';
					htmltxt += ' ';
					ok=true;
					break;
				}
				else if(mundo.map.block[x][y][z][0].material === "earth"&&mundo.map.block[x][y][z+1][0].material === "air")
				{
					let temp = (mundo.map.block.length  + '').length-(z+'').length;
					for(let p = 0; p < temp; p++)
						htmltxt += '0';
					htmltxt += z;
					htmltxt += ' ';
					ok = true;
					break;
				}
			}
			if(!ok)
			{
				let temp = (mundo.map.block.length + '').length;
				for(let p = 0; p < temp; p++)
					htmltxt += 'J';
				htmltxt += ' ';
			}
		}
		if(typeof window !== 'undefined')
			htmltxt += '<br>';
		else if(typeof process !== 'undefined')
			htmltxt += '\n';
	}
	
	if(typeof window !== 'undefined')
		document.getElementById("console-screen").innerHTML = htmltxt;
	else if(typeof process !== 'undefined')
	{
		console.clear();
		process.stdout.write(htmltxt);
	}
	mundo.loop.start('interval');
	mundo = grassify(mundo);
};
debug({w:64,h:128},2,1);