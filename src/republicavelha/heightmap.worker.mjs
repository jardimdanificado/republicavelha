"use strict";

onmessage = async function(event) 
{
	var terrain = await import("./terrain.mjs");
	postMessage(terrain.Heightmap.apply(null,event.data));
};