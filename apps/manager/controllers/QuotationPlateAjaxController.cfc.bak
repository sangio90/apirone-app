component extends="com.apirone.core.controller.AbsController" {

	function save( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		var categories = [];

		var thisId    = "";
		var messageId = "";
		var texts     = [];

		var result = super.getResult();

		var quotation = super.bean( "Quotation" );

		quotation.setId( json.id );
		quotation.setName( json.description );
		quotation.setQuotationNumber( json.quotation_number );
		quotation.setVersionNumber( json.version_number );
		quotation.setQuotationDate( json.quotation_date );
		quotation.setNotes( json.notes );
		quotation.setValidityDate( json.validity_date );
		quotation.setOpportunityId( json.opportunity.id );
		quotation.setLeadId( json.lead.id );
		quotation.setActive( json.active );
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

		if ( !Len( json.id ) ) {
			messageId = "quotation.created";
			thisId    = super.fire( "quotation.create", [ quotation ] )
		} else {
			var bean = super.fire( "Quotation.get", [ rc.id ] );
			if ( json.status != bean.getStatus().getId() ) {
				quotation.setActive( 0 );
				super.fire( "quotation.update", [ quotation ] )
				thisId    = super.fire( "quotation.clone", [ quotation ] );
				messageId = "quotation.updated";
			} else {
				messageId = "quotation.updated";
				thisId    = super.fire( "quotation.update", [ quotation ] )
			}
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
	}

}
