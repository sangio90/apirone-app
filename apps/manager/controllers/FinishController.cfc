component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        prc.title = "Finiture";

        prc.lineCategories = super.fire( "lineCategory.list" );

        prc.jsScripts.add( "app-finish" );

        event.setView("finish/list");

    }

}
