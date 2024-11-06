component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        prc.title = "Traduzioni";

        prc.langs = super.fire("lang.list");
        prc.statusList = super.fire("status.list", ['text']);

        prc.jsScripts.add( "app-text" );

        event.setView("text/list");

    }

}
