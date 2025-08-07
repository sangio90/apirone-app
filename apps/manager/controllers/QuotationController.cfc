component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Preventivi";

		prc.statuses = super.fire( "status.list", [ "QUOTATION" ] );

		prc.jsScripts.add( "app-quotation" );

		event.setView( "quotation/list" );
	}

	function new( event, rc, prc ){
		var user = prc.user;

		prc.title = "Nuovo preventivo";

		prc.paymentMethod = super.service( "PaymentMethod" ).list();
		prc.pricelist     = super.service( "Pricelist" ).list();
		var currencies    = super.service( "Currency" ).list();
		prc.currency      = super.service( "Currency" ).list();
		prc.statusList    = super.service( "Status" ).list( "QUOTATION" );
		prc.langs         = super.service( "Lang" ).list();

		prc.jsScripts.add( "app-quotation" );

		event.setView( "quotation/detail" );
	}

	function get( event, rc, prc ){
		var user = prc.user;

		prc.title = "Dettagli preventivo";

		prc.vatCodeList = super.service( "VatCode" ).list();

		prc.jsScripts.add( "app-quotation" );

		event.setView( "quotation/items" );
	}

	function items( event, rc, prc ){
		var user = prc.user;

		prc.title = "Dettagli preventivo";

		prc.vatCodeList = super.service( "VatCode" ).list();

		prc.zones  = DeserializeJSON( FileRead( "/config/data/fake/zones.json.cfm" ) );
		prc.plates = DeserializeJSON( FileRead( "/config/data/fake/plates.json.cfm" ) );


		prc.jsScripts.add( "app-quotation" );

		event.setView( "quotation/items" );
	}

}
