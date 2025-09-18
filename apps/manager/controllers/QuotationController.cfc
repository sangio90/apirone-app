component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Preventivi";

		prc.statuses = super.fire( "status.list", [ "QUOTATION" ] );

		prc.jsScripts.add( "app-quotation" );

		event.setView( "quotation/list" );
	}

	function create( event, rc, prc ){
		var obj = super.bean( "Quotation" )
		obj.setName( "Descrizione" );
		obj.setQuotationNumber( Left( CreateUUID(), 5 ) );
		obj.setQuotationDate( Now() );
		obj.setValidityDate( Now() );
		obj.setPriceList( super.bean( "PriceList" ).setId( "15460ccc-bda3-4657-abdb-96b369cd8649" ) );
		obj.setPaymentMethod( super.bean( "PaymentMethod" ).setId( "479afd16-b5f4-476b-90b3-93c7ee169118" ) );
		obj.setCurrency( super.bean( "Currency" ).setId( "f6a97ea2-d9d7-4c43-bc21-0d4a7111d85b" ) ); // TODO: replace pk with natural key
		obj.setStatus( super.bean( "Status" ).setId( "ACT" ) );
		obj.setLang( super.bean( "Lang" ).setId( "IT" ) );
		obj.setBillingProfile( super.bean( "BillingProfile" ).setId( "9f36b292-7467-41de-91b2-51223f9694fa" ) ); // Nimesia
		obj.setShippingProfile( super.bean( "ShippingProfile" ).setId( "3a9253a7-f299-4b46-8e6f-49d608eafc96" ) ); // Nimesia
		obj.setSalesAgentAccount( super.bean( "Account" ).setId( "a3c69ebc-b06e-49b0-ac97-5e7004cd1cf8" ) ); // Nimesia
		obj.setGraphicTechnicianAccount( super.bean( "Account" ).setId( "a3c69ebc-b06e-49b0-ac97-5e7004cd1cf8" ) ); // Nimesia
		obj.setActive( true );
		obj.setVersionNumber( 1 );

		var newId = super.fire( "quotation.create", [ obj ] );

		cflocation( url = "/manager/quotations/#newId#", addToken = false );

		// event.setView( "quotation/list" );
	}

	function new( event, rc, prc ){
		var user = prc.user;

		prc.title = "Nuovo preventivo";

		prc.page[ "statuses" ]       = super.fire( "status.list", [ "QUOTATION" ] );
		prc.page[ "languages" ]      = super.fire( "lang.list" );
		prc.page[ "pricelists" ]     = super.fire( "pricelist.list" );
		prc.page[ "paymentMethods" ] = super.fire( "paymentMethod.list" );
		prc.page[ "currencies" ]     = super.fire( "currency.list" );
		var countries                = [
			{ "id" = 1, "name" = "Italia" },
			{ "id" = 2, "name" = "Francia" },
			{ "id" = 3, "name" = "Germania" },
			{ "id" = 4, "name" = "Spagna" },
			{ "id" = 5, "name" = "Regno Unito" }
		];
		prc.page[ "countries" ] = countries;
		prc.page[ "states" ]    = [
			{ "id" = 1, "name" = "Roma", "countryId" = 1 },
			{ "id" = 2, "name" = "Milano", "countryId" = 1 },
			{ "id" = 3, "name" = "Napoli", "countryId" = 1 },
			{ "id" = 4, "name" = "Parigi", "countryId" = 2 },
			{ "id" = 5, "name" = "Lione", "countryId" = 2 },
			{ "id" = 6, "name" = "Marsiglia", "countryId" = 2 },
			{ "id" = 7, "name" = "Berlino", "countryId" = 3 },
			{ "id" = 8, "name" = "Monaco di Baviera", "countryId" = 3 },
			{ "id" = 9, "name" = "Amburgo", "countryId" = 3 },
			{ "id" = 10, "name" = "Madrid", "countryId" = 4 },
			{ "id" = 11, "name" = "Barcellona", "countryId" = 4 },
			{ "id" = 12, "name" = "Valencia", "countryId" = 4 },
			{ "id" = 13, "name" = "Londra", "countryId" = 5 },
			{ "id" = 14, "name" = "Manchester", "countryId" = 5 },
			{ "id" = 15, "name" = "Birmingham", "countryId" = 5 }
		];

		prc.plates = DeserializeJSON( FileRead( "/config/data/fake/plates.json.cfm" ) );

		prc.jsScripts.add( "app-quotation-detail" );

		event.setView( "quotation/detail" );
	}

	function edit( event, rc, prc ){
		var user = prc.user;

		prc.title = "Modifica preventivo";

		prc.page[ "statuses" ]       = super.fire( "status.list", [ "QUOTATION" ] );
		prc.page[ "languages" ]      = super.fire( "lang.list" );
		prc.page[ "pricelists" ]     = super.fire( "pricelist.list" );
		prc.page[ "paymentMethods" ] = super.fire( "paymentMethod.list" );
		prc.page[ "currencies" ]     = super.fire( "currency.list" );
		var countries                = [
			{ "id" = 1, "name" = "Italia" },
			{ "id" = 2, "name" = "Francia" },
			{ "id" = 3, "name" = "Germania" },
			{ "id" = 4, "name" = "Spagna" },
			{ "id" = 5, "name" = "Regno Unito" }
		];
		prc.page[ "countries" ] = countries;
		prc.page[ "states" ]    = [
			{ "id" = 1, "name" = "Roma", "countryId" = 1 },
			{ "id" = 2, "name" = "Milano", "countryId" = 1 },
			{ "id" = 3, "name" = "Napoli", "countryId" = 1 },
			{ "id" = 4, "name" = "Parigi", "countryId" = 2 },
			{ "id" = 5, "name" = "Lione", "countryId" = 2 },
			{ "id" = 6, "name" = "Marsiglia", "countryId" = 2 },
			{ "id" = 7, "name" = "Berlino", "countryId" = 3 },
			{ "id" = 8, "name" = "Monaco di Baviera", "countryId" = 3 },
			{ "id" = 9, "name" = "Amburgo", "countryId" = 3 },
			{ "id" = 10, "name" = "Madrid", "countryId" = 4 },
			{ "id" = 11, "name" = "Barcellona", "countryId" = 4 },
			{ "id" = 12, "name" = "Valencia", "countryId" = 4 },
			{ "id" = 13, "name" = "Londra", "countryId" = 5 },
			{ "id" = 14, "name" = "Manchester", "countryId" = 5 },
			{ "id" = 15, "name" = "Birmingham", "countryId" = 5 }
		];

		// prc.jsScripts.add( "app-plate" );
		prc.jsScripts.add( "app-quotation-detail" );
		prc.jsScripts.add( "app-signage" );

		prc.vatCodeList = super.service( "VatCode" ).list();
		prc.plates      = DeserializeJSON( FileRead( "/config/data/fake/plates.json.cfm" ) );

		var quotation = super.fire( "Quotation.get", [ rc.id ] );

		quotation.setQuotationDate( DateFormat( quotation.getQuotationDate(), "yyyy-mm-dd" ) );
		quotation.setValidityDate( DateFormat( quotation.getValidityDate(), "yyyy-mm-dd" ) );

		prc.page[ "quotation" ] = quotation;

		event.setView( "quotation/detail" );
	}

	function get( event, rc, prc ){
		var user = prc.user;

		prc.title = "Dettagli preventivo";

		// prc.vatCodeList = super.service( "VatCode" ).list();
		prc.vatCodeList = [];

		prc.jsScripts.add( "app-quotation" );

		event.setView( "quotation/items" );
	}

}
