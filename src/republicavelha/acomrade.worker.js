"use strict";

onmessage = async function(event) 
{
    const lib = await import(event.data[0]);
	postMessage(await lib[event.data[1]].apply(null,event.data[2]));
	self.close();
};