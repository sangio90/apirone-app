component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){       
        prc.title = "Gestione componenti";

		prc.jsScripts.add( "app-reassign-component" );

        event.setView( "component/reassign" );

    }
    
}
