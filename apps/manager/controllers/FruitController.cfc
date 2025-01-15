component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        prc.title = "Frutti";
        prc.statuses = super.fire( "status.list", ["FRUIT"] );

        prc.jsScripts.add( "app-fruit" );

        prc.page["statuses"] = prc.statuses;

        event.setView("fruit/list");

    }
    
    function get( event, rc, prc ){

        var user = prc.user;

        prc.title = "Frutto";

        prc.jsScripts.add( 'app-fruit' );

        event.setView('fruit/detail');

    }
    
}
