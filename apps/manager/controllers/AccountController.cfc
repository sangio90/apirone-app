component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        prc.title = "Lista degli account";

        //prc.list = DESerializeJSON( FileRead( '/config/data/fake/accounts.json.cfm' ) );

        prc.list = super.fire("account.search").getData();

        prc.jsScripts.add( "app-account" );

        event.setView("account/list");

    }
    
    function get( event, rc, prc ){

        var user = prc.user;

        prc.title = "Account";

        prc.jsScripts.add( 'app-account' );

        prc.perms = DESerializeJSON( FileRead( '/config/data/fake/perms.json.cfm' ) );

        event.setView('account/detail');

    }
    
    function print( event, rc, prc ) {

        var user = prc.user;

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
