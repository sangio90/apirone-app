component {

	function configure(){

		setFullRewrites( true );

		post( "raw-products/:rawProductId/notify-change" )
			.to( "RawProductController.notifyChange" ).end();

		get( "customers/:customerId/quotations" )
			.to( "CustomerQuotationsController.list" ).end();
		// Preventivi per periodo, usati dal CRM (statistica Budget di vendita)
		get( "quotations" )
			.to( "QuotationsController.list" ).end();

	}

}
