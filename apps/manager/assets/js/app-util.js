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

	var exists = callbackList?.hasOwnProperty(func);

	if(exists) {

		var thisCallback = callbackList[ func ];

		if(typeof thisCallback == "function") {
			thisCallback();
		}
	}

};
