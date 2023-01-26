"use strict";
var mapa, Republica, htmltxt;//declared outside debug function so we can console.log it globally
async function debug()
{
	Republica = await import("./src/republicavelha.mjs");
	console.log(Republica)
	console.log(Republica.Objecto.Creature('human','male'));
	let msize = 128;
	let mwidth = 4;
	//mapa = await Republica.Terrain.AutoTerrain(Republica.Util.Size(msize,32),mwidth,mwidth,mwidth,0);//boring plains
	mapa = await Republica.Terrain.AutoTerrain(Republica.Util.Size(msize,32),mwidth,(mwidth**3)*msize,0,0);//cool terrains
	var htmltxt = '';
	for(let x = 0;x<mapa.length;x++)
	{
		for(let y = 0;y<mapa[0].length;y++)
		{
			let ok = false;
			for(let z = 0;z<mapa[0][0].length-1;z++)
			{
				if(mapa[x][y][z][0].subtype === 'half')
				{
					let temp = (mapa.length + '').length;
					for(let p = 0; p < temp; p++)
						htmltxt += '>';
					htmltxt += ' ';
					ok=true;
					break;
				}
				else if(mapa[x][y][z][0].subtype === "full"&&mapa[x][y][z+1][0].subtype === "empty")
				{
					let temp = (mapa.length  + '').length-(z+'').length;
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
				let temp = (mapa.length + '').length;
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
};
debug();