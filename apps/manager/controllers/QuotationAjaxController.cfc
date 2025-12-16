component extends="com.apirone.core.controller.AbsController" {

	function listCategories( event, rc, prc ){
		var data = [];

		var result = super.getResult();
		var params = super.paramsFromUrl();
		var mem    = super.getMementify();

		params[ "typeId" ] = rc.typeId;

		var rows = super.fire( "productCategory.list", params );
		var data = mem.convertList( rows, "list" );

		result.setTotal( rows.len() );
		result.setCount( rows.len() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function listLines( event, rc, prc ){
		var data = [];

		var result = super.getResult();
		var params = super.paramsFromUrl();
		var mem    = super.getMementify();

		params[ "catalogBundleCategoryId" ] = rc.categoryId;

		var rows = super.fire( "line.list", params );

		var data = mem.convertList( rows, "list" );

		result.setTotal( rows.len() );
		result.setCount( rows.len() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function listModels( event, rc, prc ){
		var data = [];

		var result = super.getResult();
		var params = super.paramsFromUrl();
		var mem    = super.getMementify();

		params[ "catalogBundleLineId" ] = rc.lineId;

		var rows = super.fire( "model.list", params );

		var data = mem.convertList( rows, "list" );

		result.setTotal( rows.len() );
		result.setCount( rows.len() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function listFinishes( event, rc, prc ){
		var data = [];

		var result = super.getResult();
		var params = super.paramsFromUrl();
		var mem    = super.getMementify();

		params[ "lineId" ]            = rc.lineId;
		params[ "productCategoryId" ] = rc.categoryId;

		var rows = super.fire( "finish.list", params );
		var data = mem.convertList( rows, "list" );

		result.setTotal( rows.len() );
		result.setCount( rows.len() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function list( event, rc, prc ){
		var data = [];

		var result = super.getResult();
		var params = super.paramsFromUrl();
		var mem    = super.getMementify();

		var rows = super.fire( "quotation.search", params );
		var data = mem.convertList( rows.getData() );

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		var thisId    = "";
		var messageId = "";
		var result    = super.getResult();

		var currency      = super.bean( "Currency" );
		var quotation     = super.bean( "Quotation" );
		var paymentMethod = super.bean( "PaymentMethod" );
		
		quotation.setId( json.id );
		quotation.setName( json.name );
		//quotation.setQuotationNumber( json.quotationNumber );
		quotation.setOwner( session.user.getAccount() );

		quotation.setValidityDate( IsDate( json?.validityDate ) ? json.validityDate : NullValue() );
		quotation.setQuotationDate( IsDate( json?.quotationDate ) ? json.quotationDate : NullValue() );
		quotation.setNotes( json.notes );
		
		quotation.setActive( true );
		quotation.setLang( super.fire( "lang.get", [ json.lang.id ] ) );


		if ( Val( json?.vatCode?.id ) ) {
			quotation.setVatCode( super.fire( "vatCode.get", [ json.vatCode.id ] ) );
		};

		if ( Len( json?.opportunity?.id ) ) {
			quotation.setOpportunity( super.fire( "opportunity.get", [ json.opportunity.id ] ) );
		};

		if ( Len( json?.lead?.id ) ) {
			quotation.setLead( super.fire( "lead.get", [ json.lead.id ] ) );
		};

		if ( Len( json?.customer?.id ) ) {
			quotation.setCustomer( super.fire( "customer.get", [ json.customer.id ] ) )
		}

		if ( Len( json?.shippingProfile?.id ) ) {
			quotation.setShippingProfile( super.bean("ShippingProfile").setId( json.shippingProfile.id ) );
		}

		quotation.setPaymentMethod( paymentMethod.setId( json.paymentMethod.id ) );
		quotation.setCurrency( currency.setId( json.currency.id ) );
		// quotation.setBillingProfile( type.setId( json.billingProfile.id ) );
		// quotation.setShippingProfile( type.setId( json.shippingProfile.id ) );
		// quotation.setSalesAgentAccount( type.setId( json.salesAgentAccount.id ) );
		// quotation.setGraphicTechnicianAccount( type.setId( json.graphicTechnicianAccount.id ) );
		if ( !Len( json.id ) ) {
			
			thisId = super.fire( "quotation.create", [ quotation, session.user.getAccount().getId() ] );
			messageId = "quotation.created";
			
		} else {
			// update
			var bean = super.fire( "Quotation.get", [ rc.id ] );

			// quotation.setActive( 0 );
			// thisId = super.fire( "quotation.clone", [ quotation, statusId ] );
			
			if ( !isNull(json.status.id) && ( json.status.id != bean.getStatus().getId() ) ) {
				var errorMessage = this.setQuotationStatusHistory(json);
				if (!isNull(errorMessage)) {
					result.setData( { "error" = errorMessage } );
					return event.setValue( "result", result );
				}
			}
			var status = super.fire( "status.get", [ json.status.id ] );
			quotation.setStatus( super.fire( "status.get", [ json.status.id ] ) );
			thisId    = super.fire( "quotation.update", [ quotation ] )
			messageId = "quotation.updated";
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message, "payload" = { "id" = thisId }, "error" = {} } );
		event.setValue( "result", result );
	}

	function setQuotationStatusHistory(json) {
		var quotationStatusHistories = super.fire( "QuotationStatusHistory.list", [ "quotationId" = json.id ] );
		//gli status history sono ordinati per data creazione decrescente, quindi cerco l'ultimo e verifico che lo status sia diverso. Se è diverso ne creo uno nuovo, altrimenti sono in modifica.
		if ( quotationStatusHistories.len() > 0 && quotationStatusHistories[1].getStatus().getId() == json.status.id ) {
			var quotationStatusHistory = quotationStatusHistories[1];
			thisId = quotationStatusHistory.getId();
		} else {
			var quotationStatusHistory = super.bean( "QuotationStatusHistory" );
			quotationStatusHistory.setQuotationId( json.id );
			quotationStatusHistory.setAccount( session.user.getAccount() );
			quotationStatusHistory.setStatus( super.service( "Status" ).get( json.status.id ) );
			messageId = "quotationStatusHistory.created";
			thisId    = super.fire( "quotationStatusHistory.create", [ quotationStatusHistory ] );
		}

		if ( StructKeyExists( json, "statusFile" ) AND json.status.id == 'CCN' ) {
			var tmpDir = getTempDir();
			var extension = super.fire( "File.getExtensionFromDataUrl", [ json.statusFile.file ] );
			if (IsNull(extension)) {
				return "Formato File non valido.";
			}
			fileName   = "quotation_status_history_" & json.id & "_" & json.status.id & "." & extension;
			filePath   = tmpDir & "/" & fileName;
			binaryData = ToBinary( json.statusFile.file );

			FileWrite( filePath, binaryData );

			var files = super.fire( "File.search", { quotationStatusHistoryId = thisId } );
			if ( Len( files.getData() ) ) {
				for ( var file in files.getData() ) {
					super.fire( "File.delete", { fileId = file.getId() } );
				}
			}

			var entity = super.bean( "Entity" );

			var kindId = "quotationStatusHistory";
			entity.setKey( "quotationStatusHistory.id" );
			entity.setValue( thisId );

			var fileId = super.fire(
				"file.create",
				{
					filePath = filePath,
					typeId   = "default",
					kindId   = kindId,
					entity   = entity
				}
			);
		}

		return null;
	}

	function delete( event, rc, prc ){
		var result    = super.getResult();
		var list      = GetHTTPRequestData().content;
		var messageId = "quotation.deletedAllRecords";

		var errors  = [];
		var payload = "";

		var ids = ListToArray( list );

		for ( var id in ids ) {
			var outcome = super.fire( "quotation.delete", [ id ] );

			if ( outcome.getStatus() == "ERROR" ) {
				errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
			}
		}

		if ( errors.len() ) {
			messageId = "quotation.deletedNotAllRecords"
			payload   = { "errors" = errors };
		}

		var message = super.completeMessage( messageId );

		result.setData( { "message" = message, "payload" = payload } );

		event.setValue( "result", result );
	}

	function crmCustomers( event, rc, prc ){
		param rc.str = "";

		var result = super.getResult();
		var mem    = super.getMementify();

		var rows = super.fire( "customer.search", [ rc.str ] );
		var data = mem.convertList( rows.getData() );

		result.setTotal( rows.getTotal() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function crmOpportunities( event, rc, prc ){
		param rc.str = "";

		var result = super.getResult();
		var mem    = super.getMementify();

		var rows = super.fire( "opportunity.search", [ rc.str ] );
		var data = mem.convertList( rows.getData() );

		result.setTotal( rows.getTotal() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function crmLeads( event, rc, prc ){
		param rc.str = "";

		var result = super.getResult();
		var memy   = super.getMementify();

		var rows = super.fire( "lead.search", [ rc.str ] );

		var data = memy.convertList( rows.getData() );

		result.setTotal( rows.getTotal() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function get( event, rc, prc ){
		var result = super.getResult();
		var memy   = super.getMementify();

		var bean = super.fire( "Quotation.get", [ rc.id ] );
		var data = memy.convert( bean, "detail" );

		event.setValue( "result", data );
	}
	
	function updateTotals( event, rc, prc ){

		var json = DeserializeJSON( GetHTTPRequestData().content );

		var pricing = super.bean( "QuotationPrice" );
		var service = super.service( "QuotationPrice" );

		pricing.setQuotationId( rc.id );
		pricing.setDiscount1( Val( json.pricing?.discount1 ) ? json.pricing.discount1 : 0 );
		pricing.setDiscount2( Val( json.pricing?.discount2 ) ? json.pricing.discount2 : 0 );

		pricing.setShippingCost( Len( json.pricing?.shippingCost ) ? json.pricing.shippingCost : 0 );

		service.save( pricing );

		var data = getTotals( rc.id );

		event.setValue( "result", data );

	}

	function totals( event, rc, prc ){

		var data = getTotals( rc.id );

		event.setValue( "result", data );

	}

	function exportProducts( event, rc, prc ){
		var data = [];

		var result = super.getResult();
		
		var quotationItems = super.fire( "QuotationItem.list", [ "quotationId" = rc.id ] );

		var result         = super.fire( "Quotation.exportProducts", [ quotationItems ] );

		event.setValue( "result", result );
	}

	function export( event, rc, prc ){
		var data = [];

		var result = super.getResult();
		var params = super.paramsFromUrl();

		params[ "id" ] = rc.id;

		var quotationItems = super.fire( "QuotationItem.list", [ "quotationId" = rc.id ] );
		var result         = super.fire( "Quotation.export", [ quotationItems ] );

		if (result.success) {
			var quotation = super.fire( "Quotation.get",[ rc.id ]);
			quotation.setExported( true );
			super.fire( "quotation.update", [ quotation ] );
		}

		event.setValue( "result", result );
	}

	
	/*
		private methods
	*/
	
	private Struct function getQuantities( quotationId ){

		var acc = super.service( "QuotationItem" ).list( quotationId = quotationId, typeId = "ACC" );
		var pla = super.service( "QuotationItem" ).list( quotationId = quotationId, typeId = "PLA" );
		var seg = super.service( "QuotationItem" ).list( quotationId = quotationId, typeId = "SEG" );

		var data = {
			"accessories" = acc.len(),
			"plates" = pla.len(),
			"signages" = seg.len(),
		}

		return data;
		
	}
	
	private Struct function getTotals( quotationId ){

		var service = super.service( "QuotationPrice" );

		var result = service.calculate( quotationId );
		var counters = getQuantities( quotationId );

		var values = result.getCalculatedTotals();

		var data = {
			"counters" = counters,
			"pricing" = values
		}

		return data;
		
	}	

}
