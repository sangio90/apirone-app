component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Preventivi";

		prc.statuses = super.fire( "status.list", [ "QUOTATION" ] );

		prc.jsScripts.add( "app-quotation" );

		event.setView( "quotation/list" );
	}

	function create( event, rc, prc ){

		var obj = super.bean("Quotation")
		obj.setName("Descrizione");
		obj.setQuotationNumber( Left( CreateUUID(), 5 ) );
		obj.setQuotationDate( now() );
		obj.setValidityDate( now() );
		obj.setPriceList( super.bean("PriceList").setId( "15460ccc-bda3-4657-abdb-96b369cd8649" ) );
		obj.setPaymentMethod( super.bean("PaymentMethod").setId( "479afd16-b5f4-476b-90b3-93c7ee169118" ) );
		obj.setCurrency( super.bean("Currency").setId( "f6a97ea2-d9d7-4c43-bc21-0d4a7111d85b" ) ); //TODO: replace pk with natural key
		obj.setStatus( super.bean("Status").setId( "ACT" ) );
		obj.setLang( super.bean("Lang").setId( "IT" ) );
		obj.setBillingProfile( super.bean("BillingProfile").setId( "9f36b292-7467-41de-91b2-51223f9694fa" ) ); //Nimesia
		obj.setShippingProfile( super.bean("ShippingProfile").setId( "3a9253a7-f299-4b46-8e6f-49d608eafc96" ) ); //Nimesia
		obj.setSalesAgentAccount( super.bean("Account").setId( "a3c69ebc-b06e-49b0-ac97-5e7004cd1cf8" ) ); //Nimesia
		obj.setGraphicTechnicianAccount( super.bean("Account").setId( "a3c69ebc-b06e-49b0-ac97-5e7004cd1cf8" ) ); //Nimesia
		obj.setActive( true ); 
		obj.setVersionNumber( 1 ); 

		var newId = super.fire( "quotation.create", [obj] );

		cflocation( url="/manager/quotations/#newId#", addToken=false );

		//event.setView( "quotation/list" );
	}

	function new( event, rc, prc ){
		var user = prc.user;

		prc.title = "Nuovo preventivo";

		prc.paymentMethod = super.service( "PaymentMethod" ).list();
		prc.pricelist     = super.service( "Pricelist" ).list();
		prc.currency      = super.service( "Currency" ).list();
		prc.statusList    = super.service( "Status" ).list( "QUOTATION" );
		prc.langs         = super.service( "Lang" ).list();

		prc.jsScripts.add( "app-quotation-detail" );

		event.setView( "quotation/detail" );
	}

	function get( event, rc, prc ){
		var user = prc.user;

		prc.title = "Dettagli preventivo";

		//prc.vatCodeList = super.service( "VatCode" ).list();
		prc.vatCodeList = [];

		prc.jsScripts.add( "app-quotation" );

		event.setView( "quotation/items" );
	}

	function items( event, rc, prc ){
		var user = prc.user;

		prc.title = "Dettagli preventivo";

		prc.vatCodeList = super.service( "VatCode" ).list();

		prc.zones  = DeserializeJSON( FileRead( "/config/data/fake/zones.json.cfm" ) );
		prc.plates = DeserializeJSON( FileRead( "/config/data/fake/plates.json.cfm" ) );
        prc.page["quotation"]["id"] = rc.id;

		prc.jsScripts.add( "app-signage" );
		prc.jsScripts.add( "app-plate" );
		prc.jsScripts.add( "app-quotation-items" );
	
		event.setView( "quotation/items" );
	}

}
