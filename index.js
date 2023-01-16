"use strict";
var mapa, Republica, htmltxt;//declared outside debug function so we can console.log it globally
async function debug()
{
	Republica = await import("./src/republicavelha.mjs");
	console.log(Republica)
	console.log(Republica.Objecto.Creature('human','male'));
	
	mapa = Republica.Terrain.AutoTerrain(16,'flat',1,1,40,0,0);
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
					htmltxt += '>> ';
					ok=true;
					break;
				}
				else if(mapa[x][y][z][0].subtype === "full"&&mapa[x][y][z+1][0].subtype === "empty")
				{
					if(z<10)
					{	
						htmltxt += ('0'+z + ' ');
						ok = true;
					}	
					else
					{
						htmltxt += (z+' ');
						ok = true;
					}
					break;
				}
			}
			if(!ok)
			{
				htmltxt += "JJ ";
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
};
debug();