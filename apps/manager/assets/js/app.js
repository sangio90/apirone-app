AP.core = AP.core || {};

$(document).ready(function (){

    /* dom inits */

	if ($("#sidebar-left").length) {

		AP.core.init();

	}

	/* message */

	if (AP.message) {

		if (Object.keys(AP.message).length != 0) {

			AP.widget.notify(AP.message.type, AP.message.message);
		}

	}

});

AP.core = (function () {

	var pub = {};

	pub.init = function () {};

    pub.setSidebar = function (){};

    return pub;

}());
