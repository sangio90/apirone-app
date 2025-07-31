component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var data = [];
        var result = super.getResult();
        var dm = getDataMapper();
        
		var params = super.paramsFromUrl();

        var rows = super.fire( "quotation.search", params );
        
        for ( var row in rows.getData() ) {
            var obj = dm.convert( row, "Quotation", true );
            data.add( obj );
        }

        result.setTotal( rows.getTotal() );
        result.setCount( rows.getCount() );
        result.setData( data );

        event.setValue( "result", result );
        
    }

	function save( event, rc, prc ){

		var json = deserializeJSON( getHTTPRequestData().content );

        var categories = [];

		var thisId    = "";
		var messageId = "";
		var texts     = [];
		
		var result = super.getResult();

		var quotation   = super.bean( "Quotation" );

		quotation.setId( json.id );
		quotation.setDescription( json.description );
		quotation.setQuotationNumber( json.quotation_number );
		quotation.setQuotationDate( json.quotation_date );
		quotation.setNotes( json.notes );
		quotation.setValidityDate( json.validity_date );
		quotation.setOpportunityName( json.opportunity_name );
		quotation.setLeadName( json.lead_name );
		quotation.setCustomPaymentMethod( json.custom_payment_method );
        quotation.setPricelist( type.setId( json.pricelist.id ) );
        quotation.setPaymentMethod( type.setId( json.paymentMethod.id ) );
        quotation.setCurrency( type.setId( json.currency.id ) );
        quotation.setStatus( type.setId( json.status.id ) );
        quotation.setLang( type.setId( json.lang.id ) );
        quotation.setBillingProfile( type.setId( json.billingProfile.id ) );
        quotation.setShippingProfile( type.setId( json.shippingProfile.id ) );
        quotation.setSalesAgentAccount( type.setId( json.salesAgentAccount.id ) );
        quotation.setGraphicTechnicianAccount( type.setId( json.graphicTechnicianAccount.id ) );

		if ( !len( json.id ) ) {
			messageId = "quotation.created";
			thisId    = super.fire( "quotation.create", [ quotation ] )
		} else {
			messageId = "quotation.updated";
			thisId    = super.fire( "quotation.update", [ quotation ] )
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
        
        var result = super.getResult();
        var list = GetHTTPRequestData().content;
        var messageId = "quotation.deletedAllRecords";

        var errors = [];
        var payload = "";

        var ids = ListToArray( list );

        for( var id in ids ) {
            var outcome = super.fire( "quotation.delete", [ id ] );

            if( outcome.getStatus() == "ERROR"  ) {
                errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
            }

        }

        if( errors.len() ) {
            messageId = "quotation.deletedNotAllRecords"
            payload = { "errors": errors } ;
        }

        var message = super.completeMessage( messageId );

        result.setData( { "message" = message, "payload" =  payload } );
        
		event.setValue( "result", result );
	}
}
