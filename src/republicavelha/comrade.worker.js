"use strict";

onmessage = async function(event) 
{
	postMessage((await import(event.data[0]))[event.data[1]].apply(null,event.data[2]));
	self.close();
};