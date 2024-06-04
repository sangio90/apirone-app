component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var user = prc.user;

        prc.title = "Lista dei preventivi";

        prc.list = DESerializeJSON( FileRead( '/config/data/fake/quotations.json.cfm' ) );

        prc.jsScripts.add( "app-quotation" );

        event.setView( "quotation/list" );

    }

    function new( event, rc, prc ){

        var user = prc.user;

        prc.title = "Nuovo preventivo";

        prc.vatCodeList = super.service("VatCode").list();
        prc.jsScripts.add( "app-quotation" );

        event.setView( "quotation/detail" );

    }
    
    function get( event, rc, prc ){

        var user = prc.user;

        prc.title = "Dettagli preventivo";

        prc.vatCodeList = super.service("VatCode").list();

        prc.jsScripts.add( "app-quotation" );

        event.setView( "quotation/items" );

    }
   
    function items( event, rc, prc ){

        var user = prc.user;

        prc.title = "Dettagli preventivo";

        prc.vatCodeList = super.service("VatCode").list();

        prc.zones = DESerializeJSON( FileRead( '/config/data/fake/zones.json.cfm' ) );
        prc.plates = DESerializeJSON( FileRead( '/config/data/fake/plates.json.cfm' ) );

        prc.jsScripts.add( "app-quotation" );

        event.setView( "quotation/items" );

    }
   
}
