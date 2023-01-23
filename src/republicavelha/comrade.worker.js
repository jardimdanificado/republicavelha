"use strict";

onmessage = async function(event) 
{
	postMessage((await import(event.data.modulePath))[event.data.method].apply(null,event.data.args));
};