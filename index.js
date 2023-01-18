"use strict";
var mapa, Republica, htmltxt;//declared outside debug function so we can console.log it globally
let worker;
async function debug()
{
	Republica = await import("./src/republicavelha.mjs");
	console.log(Republica)
	console.log(Republica.Objecto.Creature('human','male'));
	let msize = 128;
	/*let cmr = await import("./src/republicavelha/comrade/comrade.js");
	worker = cmr.modular("../terrain.mjs","Terrain",[8]);
	console.log(worker)*/
	mapa = Republica.Terrain.AutoTerrain(msize,'flat',3,1,msize,0,0);
	function part2(mapa)
	{
		var htmltxt = '';
		for(let x = 0;x<mapa.length;x++)
		{
			for(let y = 0;y<mapa.length;y++)
			{
				let ok = false;
				for(let z = 0;z<mapa.length-1;z++)
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
		else if(typeof process !== 'undefined')//
		{
			console.clear();
			process.stdout.write(htmltxt);
		}
	}
	var timeout = function(mapa)
	{
	   if(mapa.length === 0)
			setTimeout(timeout,1000,mapa);
	   else
			part2(mapa);
	};
	setTimeout(timeout,1000,mapa);
};
debug();