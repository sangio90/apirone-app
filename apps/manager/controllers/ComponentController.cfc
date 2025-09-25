component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){       
        prc.title = "Gestione Componenti";

		prc.jsScripts.add( "app-reassign-component" );

        event.setView( "reassign-component/list" );

    }
    
}
