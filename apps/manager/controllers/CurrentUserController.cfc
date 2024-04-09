component extends="com.apirone.core.controller.AbsController" {

    function wallet( event, rc, prc ){

        var user = arguments.event.getValue( "User" );

        rc.list = DESerializeJSON( FileRead( '/config/data/fake-wallet.json' ) );

        rc.title = "Portafogli";

        event.setView('my/wallet');

    }
    
    function profile( event, rc, prc ){

        var user = arguments.event.getValue( "User" );

        rc.list = DESerializeJSON( FileRead( '/config/data/fake-wallet.json' ) );

        rc.title = "I miei dati";

        event.setView('my/profile');

    }
    
}
