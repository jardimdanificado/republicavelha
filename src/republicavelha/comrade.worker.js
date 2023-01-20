"use strict";
onmessage = async function(event) 
{
	if(typeof event.data.modulePath !== 'undefined')
	{
		var modul = await import(event.data.modulePath);
		var args = event.data.args;
		var option = event.data.method;
		postMessage(modul[option].apply(null,args));
	}
	else if(typeof event.data.method !== 'undefined')
	{
		var args = event.data.args;
		postMessage(event.data.method.apply(null,args));
	}
};