component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        prc.title = "Tempi di produzione";

        //prc.list = super.fire("ProductionTime.list");

        prc.jsScripts.add( "app-production-time" );

        event.setView( "production-time/list" );

    }
    
    function get( event, rc, prc ){
    }
    
}
