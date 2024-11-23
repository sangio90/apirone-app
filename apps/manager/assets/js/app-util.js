AP.util = AP.util || {};

AP.util.getMainText = function (texts, langId="it") {

	for(var thisText of texts) {

		if (thisText.lang.id == langId.toUpperCase()) {
			return thisText;
		}

	}

	return undefined;

};