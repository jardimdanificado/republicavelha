"use strict";

onmessage = async function(event) 
{
	var modul = await import(event.data.modulePath);
	var args = event.data.args;
	var option = event.data.method;
	postMessage(modul[option].apply(null,args));
};