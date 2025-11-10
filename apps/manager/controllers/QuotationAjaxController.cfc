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

		var categories = [];

		var thisId    = "";
		var messageId = "";
		var texts     = [];

		var result = super.getResult();

		transaction {
			try {
				var quotation = super.bean( "Quotation" );

				quotation.setId( json.id );
				quotation.setName( json.name );
				quotation.setQuotationNumber( json.quotationNumber );
				quotation.setVersionNumber( json.versionNumber );
				quotation.setQuotationDate( json.quotationDate );
				quotation.setNotes( !isNull(json.notes) ? json.notes : null );
				quotation.setValidityDate( json.validityDate );
				quotation.setOpportunity( !isNull(json.opportunity) ? super.fire( "opportunity.get", [ json.opportunity.id ] ) : null );
				quotation.setLead( !isNull(json.lead) ? super.fire( "lead.get", [ json.lead.id ] ) : null );
				quotation.setActive( true );
				var statusId = json.status.id != '' ? json.status.id : 'NEW';
				quotation.setLang( super.fire( "lang.get", [ json.lang.id ] ) );
				quotation.setCustomer( !isNull(json.customer) ? super.fire( "customer.get", [ json.customer.id ] ) : null );
				quotation.setCustomerAddressId( !isNull(json.shippingAddress) ? json.shippingAddress.id : null );
				// quotation.setCustomPaymentMethod( json.custom_payment_method );
				// quotation.setPricelist( type.setId( json.pricelist.id ) );
				// quotation.setPaymentMethod( type.setId( json.paymentMethod.id ) );
				// quotation.setCurrency( type.setId( json.currency.id ) );
				// quotation.setBillingProfile( type.setId( json.billingProfile.id ) );
				// quotation.setShippingProfile( type.setId( json.shippingProfile.id ) );
				// quotation.setSalesAgentAccount( type.setId( json.salesAgentAccount.id ) );
				// quotation.setGraphicTechnicianAccount( type.setId( json.graphicTechnicianAccount.id ) );

				if ( !Len( json.id ) ) {
					messageId = "quotation.created";
					quotation.setStatus( super.fire( "status.get", [ statusId ] ) );
					thisId    = super.fire( "quotation.create", [ quotation ] );
				} else {
					var bean = super.fire( "Quotation.get", [ rc.id ] );
					if ( json.status.id != bean.getStatus().getId() ) {
						quotation.setActive( 0 );
						quotation.setStatus( bean.getStatus() );
						thisId    = super.fire( "quotation.clone", [ quotation, statusId ] );
						super.fire( "quotation.update", [ quotation ] )
						messageId = "quotation.updated";
					} else {
						quotation.setStatus( bean.getStatus() );
						messageId = "quotation.updated";
						thisId    = super.fire( "quotation.update", [ quotation ] )
					}
				}

				var message = completeMessage( messageId );
				result.setData( { "message" = message,  "payload" = { id = thisId } } );
				event.setValue( "result", result );
				return;
			} catch ( any e ) {
				transaction action="rollback";
				var message = "Errore nella creazione/aggiornamento del Preventivo: #e.message#";
				result.setData( { "error" = message } );
				result.setStatus( "ERRORE" );
				event.setValue( "result", result );
				return;
			}
		}
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
		var data = [];
		var name = rc.str;
		var result = super.getResult();
		var mem    = super.getMementify();

		var rows = super.fire( "customer.search", [ name ] );
		var data = mem.convertList( rows.getData() );
		result.setTotal( rows.getTotal() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function crmOpportunities( event, rc, prc ){
		var data = [];
		var name = rc.str;
		var result = super.getResult();
		var mem    = super.getMementify();

		var rows = super.fire( "opportunity.search", [ name ] );
		var data = mem.convertList( rows.getData() );
		result.setTotal( rows.getTotal() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function crmLeads( event, rc, prc ){
		var data = [];
		var name = rc.str;
		var result = super.getResult();
		var mem    = super.getMementify();

		var rows = super.fire( "lead.search", [ name ] );
		var data = mem.convertList( rows.getData() );
		result.setTotal( rows.getTotal() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function export( event, rc, prc ){
		var data = [];

		var result = super.getResult();
		var params = super.paramsFromUrl();

		params[ "id" ]            = rc.id;
		var quotationItems = super.fire( "QuotationItem.list", [ 'quotationId' = rc.id ] );
		var result = super.fire( "Quotation.export", [ quotationItems ] );
		dump( result );abort;
		event.setValue( "result", result );
	}
}
