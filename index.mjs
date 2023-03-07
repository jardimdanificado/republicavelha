import * as Republica from './src/republicavelha.mjs';
var mundo;//declared outside debug function so we can console.log it globally

function plantCount(specie = 'caju')
{
	return Republica.Util.customFilter(mundo.plant,'specie',specie);
}

export function verifyRamps(blockMap,hmap,position)
{
	const {x, y} = position;
	if(
		(x<blockMap.length-1 &&
		blockMap[x+1][y][hmap[x][y]].material == "earth" &&
		blockMap[x+1][y][hmap[x][y]+1].material == "air")||
		(x>0&&
		blockMap[x-1][y][hmap[x][y]].material == "earth" &&
		blockMap[x-1][y][hmap[x][y]+1].material == "air")||
		(y<blockMap.length-1 &&
		blockMap[x][y+1][hmap[x][y]].material == "earth" &&
		blockMap[x][y+1][hmap[x][y]+1].material == "air")||
		(y>0 &&
		blockMap[x][y-1][hmap[x][y]].material == "earth" &&
		blockMap[x][y-1][hmap[x][y]+1].material == "air") ||

		(x<blockMap.length-1 &&
		y<blockMap.length-1 &&
		blockMap[x+1][y+1][hmap[x][y]].material == "earth" && 
		blockMap[x+1][y+1][hmap[x][y]+1].material == "air")||
		(x>0&&
		y<blockMap.length-1 &&
		blockMap[x-1][y+1][hmap[x][y]].material == "earth" && 
		blockMap[x-1][y+1][hmap[x][y]+1].material == "air")||
		(x<blockMap.length-1 &&
		y>0 &&
		blockMap[x+1][y-1][hmap[x][y]].material == "earth" &&
		blockMap[x+1][y-1][hmap[x][y]+1].material == "air")||
		(x>0 &&
		y>0 &&
		blockMap[x-1][y-1][hmap[x][y]].material == "earth" &&
		blockMap[x-1][y-1][hmap[x][y]+1].material == "air")
	)	
	{
		return true;
	}
	return false;
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

function HTMLRender(mundo)
{
	let htmltxt = '';
	let temp;
	for(let x = 0;x<mundo.map.block.length;x++)
	{
		for(let y = 0;y<mundo.map.block[0].length;y++)
		{
			for(let z = 0;z<mundo.map.block[0][0].length-1;z++)
			{
				if(verifyRamps(mundo.map.block,mundo.map.heightmap,{x:x,y:y})==true)
				{
					temp = (mundo.map.block.length + '').length;
					for(let p = 0; p < temp; p++)
						htmltxt += '>';
					htmltxt += ' ';
					break;
				}
				else if(mundo.map.block[x][y][z].material === "earth"&&mundo.map.block[x][y][z+1].material === "air")
				{
					temp = (mundo.map.block.length  + '').length-(z+'').length;
					for(let p = 0; p < temp; p++)
						htmltxt += '0';
					htmltxt += z;
					htmltxt += ' ';
					break;
				}
			}
		}
		htmltxt += '<br>';
	}
	document.getElementById("console-screen").innerHTML = htmltxt;
}

async function setupNodeJSREPL()
{
	let repl = await import('repl');
	let os = await import("os");
	let username = os.userInfo().username;
	console.log('system> Running under a NodeJS REPL, you can use "exit()" to exit.');
	repl.start(username + '> ');//username> 
	return;
}

export async function main(msize,mwidth,mquality,postslices,retry,isCustomCall=false)
{
	var world = await Republica.World.New(msize,mwidth,(mwidth**mquality)*(msize.w),postslices,retry);

	if(typeof window !== 'undefined'&&isCustomCall !== true)
		HTMLRender(world);
	else if(typeof process !== 'undefined')
		setupNodeJSREPL();
	world.loop.start('interval');
	world = grassify(world);

	if(typeof process!=='undefined')
	{
		global.plantCount = plantCount;
		global.Republica = Republica;
		global.exit = process.exit;
	}
	else if(typeof window !== 'undefined')
	{
		window.world = world;
		window.plantCount = plantCount;
		window.Republica = Republica;
	};
	
	return world;
};

if(typeof process !== 'undefined')
	global.world = await main({w:64,h:128},2,1,1,true);
