component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var user = arguments.event.getValue( "User" );

        prc.title = "Lista dei ruoli";
        //prc.types = getAccessManager().exec( user, "Lookup.list", [ 'shipmentType' ] );

        prc.list = DESerializeJSON( FileRead( '/config/data/fake/roles.json.cfm' ) );

        prc.jsScripts.add( 'app-role' );

        event.setView('role/list');

    }
    
    function get( event, rc, prc ){

        var user = arguments.event.getValue( "User" );

        prc.title = "Ruolo";

        prc.jsScripts.add( 'app-role' );

        prc.perms = DESerializeJSON( FileRead( '/config/data/fake/perms.json.cfm' ) );

        event.setView('role/detail');

    }
    
    function print( event, rc, prc ) {

        var user = arguments.event.getValue( "User" );

        var result = getAccessManager()
                .exec( 
                    user, 
                    "Account.search"
                );

        prc.printArgs = {
            data = DESerializeJSON( SerializeJSON( result.getData() ) ),
            fields = "email,role"
        }

        event.setView( "util/print" ).setLayout( "print" );
        
    }
    
}
