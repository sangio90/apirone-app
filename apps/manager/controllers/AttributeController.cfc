component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        prc.title = "Attributi e valori";

        prc.lineCategories = super.fire( "ProductCategory.list" );
        prc.statuses = super.fire( "status.list", ["FINISH"] );

        prc.page["categories"] = super.getCategoriesAsJSON();
        prc.page["attributeStatusList"] = prc.statuses;

        prc.jsScripts.add( "app-file" );
        prc.jsScripts.add( "app-component" );
        prc.jsScripts.add( "app-attribute-detail" );
        prc.jsScripts.add( "app-attribute-list" );

        event.setView("attribute/list");

    }

}
