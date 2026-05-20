component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Preventivi";

		prc.statuses = super.fire( "status.list", [ "QUOTATION" ] );

		prc.jsFiles.add( "app-quotation-list" );

		event.setView( "quotation/list" );
	}

	function plantPositions( event, rc, prc ){
		var quotation = super.fire( "Quotation.get", [ rc.id ] );
		var settings = new config.Settings();

		var baseUrl = "#settings.get( "site.repository" )#";

		prc.title = "Posizioni in pianta - Preventivo < " & quotation.getName() & " >";

		prc.baseUrl = baseUrl;
		prc.quotation = quotation;
		prc.jsFiles.add( "app-quotation-plant-positions" );

		event.setView( "quotation/plant-positions" );
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

		var user = session.user;
		if (!isNull(user) && !isNull(user.getRole()) && user.getRole().getId() == 'CMJ' && quotation.getOwner().getId() != user.getId()) {
        	relocate( uri="/manager/dashboard", postProcessExempt=false, addToken=false );
			return;
		}
		if (!isNull(user) && !isNull(user.getRole()) && user.getRole().getId() == 'PRO' && quotation.getStatusHistory().getStatus().getId() != 'CON') {
        	relocate( uri="/manager/dashboard", postProcessExempt=false, addToken=false );
			return;
		}

		prc.title     = "Modifica preventivo < #quotation.getQuotationNumber()# / #quotation.getVersionNumber()# > ";

		prc.quotation = quotation;

		prc.page = getData().page;
		prc.page[ "quotation" ]["id"] = quotation.getId();
		prc.page[ "quotation" ]["exported"] = quotation.getExported();
		prc.page[ "canEdit" ] = (
			ArrayContains(['ADM', 'CMA', 'TCD', 'TCS', 'TCJ'], user.getRole().getId()) || 
			( 
				( quotation.getOwner().getId() == user.getId() || quotation.getSalesAgent().getId() == user.getId() ) && 
				quotation.getStatusHistory().getStatus().getOrderBy() < 20 
			)	
		)
		prc.page[ "canSee" ] = user.getRole().getId() == 'CMS' || prc.page[ "canEdit" ] == false || user.getRole().getId() == 'PRO';

		prc.jsFiles.add( "app-quotation-header" );
		prc.jsFiles.add( "app-quotation-status" );
		prc.jsFiles.add( "app-quotation-detail" );
		prc.jsFiles.add( "app-quotation-pricing" );

		prc.jsFiles.add( "app-quotation-plate-designer" );
		prc.jsFiles.add( "app-quotation-plate-product-items" );
		prc.jsFiles.add( "app-quotation-plate-api" );
		prc.jsFiles.add( "app-quotation-plate" );
		prc.jsFiles.add( "app-quotation-signage" );
		prc.jsFiles.add( "app-quotation-accessory" );
		prc.jsFiles.add( "app-quotation-article" );
		prc.jsFiles.add( "app-quotation-documents" );
		prc.jsFiles.add( "app-file" );

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

		page[ "userRole"]        = [ "id": session.user.getRole().getId(), "quotationMaxAmount": session.user.getRole().getQuotationMaxAmount(), "quotationMaxDiscount": session.user.getRole().getQuotationMaxDiscount() ];
		page[ "statuses" ]       = memy.convertList( super.fire( "status.list", [ "QUOTATION" ] ) );
		page[ "itemStatuses" ]   = memy.convertList( super.fire( "status.list", [ "QUOTATION_ITEM" ] ) );
		page[ "languages" ]      = memy.convertList( super.fire( "lang.list" ) );
		page[ "paymentMethods" ] = memy.convertList( super.fire( "paymentMethod.list" ) );
		page[ "currencies" ]     = memy.convertList( super.fire( "currency.list" ) );
		page[ "frames" ]         = memy.convertList( super.fire( "frame.list" ), "minimal" );
		page[ "vatCodes" ]       = memy.convertList( super.fire( "vatCode.list" ) );
		page[ "techUsers" ]      = memy.convertList( super.fire( "user.list", { roleTypeId="TEC", hasUtenteVerticale=true } ) );
		page[ "saleUsers" ]      = memy.convertList( super.fire( "user.list", { roleTypeId="COM", hasUtenteVerticale=true } ) );

		return { "page" = page }

	}

}
