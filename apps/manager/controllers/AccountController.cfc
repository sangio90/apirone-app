component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var user = arguments.event.getValue( "User" );

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
