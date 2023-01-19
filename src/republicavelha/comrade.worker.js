onmessage = async function(event) 
{
	var func = await import(event.data.modulePath);
	var args = event.data.args;
	var option = event.data.method;
	postMessage(func[option].apply(null,args));
};