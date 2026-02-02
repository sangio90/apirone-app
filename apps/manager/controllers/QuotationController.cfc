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
		
		var quotation = super.fire( "Quotation.get", [ rc.id ] );

		prc.title     = "Modifica preventivo < #quotation.getQuotationNumber()# / #quotation.getVersionNumber()# > ";

		prc.quotation = quotation;

		prc.page = getData().page;
		prc.page[ "quotation" ]["id"] = quotation.getId();
		prc.page[ "quotation" ]["exported"] = quotation.getExported();

		prc.jsFiles.add( "app-quotation-header" );
		prc.jsFiles.add( "app-quotation-status" );
		prc.jsFiles.add( "app-quotation-detail" );
		prc.jsFiles.add( "app-quotation-pricing" );

		prc.jsFiles.add( "app-quotation-plate-designer" );
		prc.jsFiles.add( "app-quotation-plate" );
		prc.jsFiles.add( "app-quotation-signage" );
		prc.jsFiles.add( "app-quotation-accessory" );
		prc.jsFiles.add( "app-quotation-article" );

		prc.cssFiles.add( "quotation" );

		// event.setView( "quotation/header" );
		event.setView( "quotation/detail" );
	}


	/*
		private methods
	*/

	private function getData(){
		var page = {};
		var memy = super.getMementify();

		page[ "statuses" ]       = memy.convertList( super.fire( "status.list", [ "QUOTATION" ] ) );
		page[ "itemStatuses" ]       = memy.convertList( super.fire( "status.list", [ "QUOTATION_ITEM" ] ) );
		page[ "languages" ]      = memy.convertList( super.fire( "lang.list" ) );
		page[ "paymentMethods" ] = memy.convertList( [ super.fire( "paymentMethod.get", [18] ) ] );
		page[ "currencies" ]     = memy.convertList( super.fire( "currency.list" ) );
		page[ "frames" ]         = memy.convertList( super.fire( "frame.list" ), "minimal" );
		page[ "vatCodes" ]       = memy.convertList( super.fire( "vatCode.list" ) );
		page[ "techUsers" ]      = memy.convertList( super.fire( "user.list", { roleTypeId="TEC" } ) );
		page[ "saleUsers" ]      = memy.convertList( super.fire( "user.list", { roleTypeId="COM" } ) );

		return { "page" = page }
	
	}

}
