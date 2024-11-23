component extends="com.apirone.core.controller.AbsController" {

    function get( event, rc, prc ){

        prc.title = "Il mio account";

        event.setView( "my/account" );

    }
    
}
