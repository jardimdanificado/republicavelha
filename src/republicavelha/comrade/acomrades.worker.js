"use strict";

onmessage = async function(event) 
{
	const modul = await import(event.data[0]);
	let result;
	if(typeof event.data[4] !== 'undefined')
		result = event.data[4];
	let counter = 0;
	while(counter<event.data[3])
	{
		result = modul[event.data[1]].apply(this,event.data[2]);
		counter++;
	}

	postMessage(await Promise.all(result).then((results)=>{return results}));
	self.close();
};