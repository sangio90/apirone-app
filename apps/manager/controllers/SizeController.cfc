component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        prc.title = "Dimensioni placche";

        prc.jsScripts.add( "app-size" );

        event.setView("size/list");

    }
    
}
