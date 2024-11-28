component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        prc.title = "Categorie";

        prc.statuses = super.fire( "status.list", ["PRODUCT_CATEGORY"] );

        prc.page["statuses"] = prc.statuses;

        prc.jsScripts.add( "app-product-category" );

        event.setView("product-category/list");

    }

}
