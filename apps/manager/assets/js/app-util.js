AP.util = AP.util || {};

AP.util.getMainText = function (texts, langId="it") {

	for(var thisText of texts) {

		if (thisText.lang.id == langId.toUpperCase()) {
			return thisText;
		}

	}

	return undefined;

};


AP.util.fireCallback = function ( func, callbacks ) {

	var callbackList = callbacks;

	console.log("callbackList", callbackList)


	var exists = callbackList?.hasOwnProperty(func);

	console.log("callbackList:func", exists, func)

	if(exists) {

		var thisCallback = callbackList[ func ];

		if(typeof thisCallback == "function") {
			
			console.log("callbackList:exec", func )

			thisCallback();
		}
	}

};
