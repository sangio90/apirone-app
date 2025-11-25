component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Preventivi";

		prc.statuses = super.fire( "status.list", [ "QUOTATION" ] );

		prc.jsFiles.add( "app-quotation-list" );

		event.setView( "quotation/list" );
	}

	function new( event, rc, prc ){
		prc.isEditing = false;

		prc.title = "Nuovo preventivo";
		rc.id     = 0;

		prc.page = getData().page;

		prc.jsFiles.add( "app-quotation-header" );
		prc.cssFiles.add( "quotation" );

		event.setView( "quotation/new" );
	}

	function edit( event, rc, prc ){
		param prc.id = "___invalid___";

		var memy = super.getMementify();

		prc.isEditing = true;
		prc.title     = "Modifica preventivo";
		prc.page      = getData().page;


		var quotation           = super.fire( "Quotation.get", [ rc.id ] );
		prc.page[ "quotation" ] = quotation;

		// prc.jsFiles.add( "app-plate-designer" );
		// prc.jsFiles.add( "app-quotation-header" );
		prc.jsFiles.add( "app-quotation-detail" );
		prc.jsFiles.add( "app-quotation-pricing" );

		prc.jsFiles.add( "app-quotation-plate" );
		prc.jsFiles.add( "app-quotation-signage" );
		prc.jsFiles.add( "app-quotation-accessory" );

		prc.cssFiles.add( "quotation" );

		// event.setView( "quotation/header" );
		event.setView( "quotation/detail" );
	}


	/*
		private methods
	*/

	private function getData(){
		var memy = super.getMementify();
		var page = {};

		page[ "statuses" ]       = memy.convertList( super.fire( "status.list", [ "QUOTATION" ] ) );
		page[ "languages" ]      = memy.convertList( super.fire( "lang.list" ) );
		page[ "paymentMethods" ] = memy.convertList( super.fire( "paymentMethod.list" ) );
		page[ "currencies" ]     = memy.convertList( super.fire( "currency.list" ) );
		// page[ "frames" ]         = memy.convertList( super.fire( "frame.list" ), "minimal" );
		page[ "vatCodes" ]       = memy.convertList( super.fire( "vatCode.list" ) );

		return { "page" = page }
	}

}
