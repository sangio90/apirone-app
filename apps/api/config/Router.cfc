component {

	function configure(){

		setFullRewrites( true );

		post( "raw-products/:rawProductId/notify-change" )
			.to( "RawProductController.notifyChange" ).end();

		get( "customers/:customerId/quotations" )
			.to( "CustomerQuotationsController.list" ).end();

	}

}
