component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var user = arguments.event.getValue( "User" );

        prc.title = "Ordini";

        prc.list = super.service("Document").search();

        event.setView('document/list');

    }
    
    function get( event, rc, prc ){

        var user = arguments.event.getValue( "User" );


        prc.detail = super.service("Document").get( rc.id );

        prc.title = "Ordine #prc.detail.getCode()#";


        event.setView('document/detail');

    }
    
}
