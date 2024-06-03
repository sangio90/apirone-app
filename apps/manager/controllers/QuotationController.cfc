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

        prc.jsScripts.add( "app-quotation" );

        event.setView( "quotation/detail" );

    }
    
    function get( event, rc, prc ){

        var user = prc.user;

        prc.title = "Preventivo";

        prc.jsScripts.add( "app-fruit" );

        event.setView( "quotation/detail" );

    }
   
}
