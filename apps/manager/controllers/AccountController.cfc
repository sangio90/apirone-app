component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var user = arguments.event.getValue( "User" );

        prc.title = "Lista degli account";
        //prc.types = getAccessManager().exec( user, "Lookup.list", [ 'shipmentType' ] );

        prc.jsScripts.add( 'app-account' );

        event.setView('account/list');

    }
    
    function get( event, rc, prc ){

        var user = arguments.event.getValue( "User" );

        dump("get");
        abort;

        prc.title = "Account";
        //prc.types = getAccessManager().exec( user, "Lookup.list", [ 'shipmentType' ] );

        event.setView('account/list');

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
