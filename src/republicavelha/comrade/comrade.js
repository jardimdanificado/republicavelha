"use strict";
export function modular(modulePath,functionName,args)
{
	var worker = new Worker("./src/republicavelha/comrade/comrade.worker.js");
	worker.result = [];
	worker.done = false;
	var content = 
	{
		modulePath:modulePath,
		method:functionName,
		args:args
	};
	worker.postMessage(content);
	worker.onmessage = function(event)
	{
		worker.result = event.data;
		worker.terminate();
		worker.done = true;
		console.log(modulePath + '.' + functionName+ "(" + args + ') is done;');
	};
	return(worker);
}