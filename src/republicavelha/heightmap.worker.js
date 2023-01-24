"use strict";

onmessage = async function(event) 
{
	postMessage((await import("./terrain.mjs")).Heightmap.apply(null,event.data));
	self.close();
};