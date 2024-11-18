component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        prc.title = "Attributi e valori";

        prc.lineCategories = super.fire( "lineCategory.list" );
        prc.statuses = super.fire( "status.list", ["FINISH"] );

        prc.page["categories"] = super.getCategoriesForJSON();
        prc.page["statuses"] = prc.statuses;

        prc.jsScripts.add( "app-attribute" );

        event.setView("attribute/list");

    }

}
