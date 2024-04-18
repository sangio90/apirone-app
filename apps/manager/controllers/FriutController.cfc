component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var user = arguments.event.getValue( "User" );

        prc.title = "Lista dei frutti";

        prc.list = DESerializeJSON( FileRead( '/config/data/fake/fruits.json.cfm' ) );

        prc.jsScripts.add( 'app-fruit' );

        event.setView('fruit/list');

    }
    
    function get( event, rc, prc ){

        var user = arguments.event.getValue( "User" );

        prc.title = "Frutto";

        prc.jsScripts.add( 'app-fruit' );

        event.setView('fruit/detail');

    }
    
}
