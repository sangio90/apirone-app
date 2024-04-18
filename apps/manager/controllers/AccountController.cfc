component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var user = arguments.event.getValue( "User" );

        prc.title = "Lista degli account";

        prc.list = DESerializeJSON( FileRead( '/config/data/fake/accounts.json.cfm' ) );

        prc.jsScripts.add( 'app-account' );

        event.setView('account/list');

    }
    
    function get( event, rc, prc ){

        var user = arguments.event.getValue( "User" );

        prc.title = "Account";

        prc.jsScripts.add( 'app-account' );

        prc.perms = DESerializeJSON( FileRead( '/config/data/fake/perms.json.cfm' ) );

        event.setView('account/detail');

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
