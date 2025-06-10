component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        prc.title = "Valori base";

        prc.page["statusList"] = super.fire( "status.list", ["RAW_VALUE"] );

        prc.jsScripts.add( "app-raw-value" );
        //prc.jsScripts.add( "app-attribute-list" );

        event.setView("raw-value/list");

    }

}
