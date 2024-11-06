component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        prc.title = "Traduzioni";

        prc.jsScripts.add( "app-text" );

        event.setView("text/list");

    }

}
