ZB.core = ZB.core || {};
ZB.catalogue = ZB.catalogue || {};
ZB.cart = ZB.cart || {};
ZB.sales = ZB.sales || {};
ZB.company = ZB.company || {};
ZB.cardSlots = ZB.cardSlots || {};

$(document).ready(function(){

    /* dom inits */

	if ( $('#sidebar-left').length ) {

		ZB.core.init();

	}

	if ( $('#product-detail').length  ) {

		ZB.catalogue.product.init();
	}

	if ( $('#cart').length  ) {

		ZB.cart.init();
	}

	if ( $('#sales').length  ) {

		ZB.sales.init();
	}

	if ( $('#company-detail').length  ) {

		ZB.company.detail.init();
	}

	if ( $('#card-slots').length  ) {

		ZB.cardSlots.init();
	}


	/* message */

	if ( ZB.message ) {

		if ( Object.keys( ZB.message ).length != 0 ) {

			ZB.widget.notify( ZB.message.type, ZB.message.message );
		}

	}

})

ZB.core = function() {

	var pub = {}

	pub.init = function() {};

    pub.setSidebar = function(){}

    return pub;

}();


ZB.catalogue.product = function() {

	var pub = {}

	pub.init = function () {

		//console.log("ZB.catalogue.product")

		$('#product-detail-form').validate();

	}

    return pub;

}();

ZB.cart = function() {

	var pub = {}

	pub.init = function () {

		//console.log("cart")

		$('#cart-form').validate();

	}

    return pub;

}();

ZB.sales = function() {

	var pub = {}

	pub.init = function () {

		//console.log("sales")

		//$('#cart-form').validate();

	}

	pub.selectItem = function ( companyId ) {

		var totalPrice = parseFloat( 0 );

		$('input[name=selected_' + companyId + ']:checked' ).each(function(item) {

			var price = $( this ).data('balance')

			totalPrice = totalPrice + parseFloat( price );

			//console.log("item", $( this ));
		});

		$('#totalPrice_' + companyId ).html( totalPrice );

	}

	pub.checkAll = function ( companyId, button ) {

		var checked = $(button).prop('checked');

		var value = "checked";

		if ( !checked ) {
			value = "";
		}

		$('input[name=selected_' + companyId + ']' ).each(function(item) {

			$( this ).prop("checked", value);

		});

		this.selectItem( companyId )

	}

	pub.changeStatus = function () {

		var status = $('#sales-command .status');

		status.html('');

		var checked = $('#sales-list-form input[name^="selected_"]:checked' );

		if( checked.length ) {

			//$('#sales-list-form').submit()

			return true;

		} else {

			status.html("<span class='red'>Seleziona almeno una riga</span>")

			return false;

		}

	}

	pub.print = function () {

		var data = $('#sales-list-search').serialize();

		window.open( '/manager/sales/print?' + data );

	}	

    return pub;

}();


ZB.company.detail = function() {

	var pub = {}

	pub.init = function () {

		//console.log("company:init")

		$('#company-detail-form').validate();


	}

    return pub;

}();



ZB.cardSlots = function() {

	var pub = {}

	pub.init = function () {

		console.log("cardSlots::init")

	}
	pub.print = function () {

		window.open( '/manager/cards/slots/1000/print' );

	}	

    return pub;

}();