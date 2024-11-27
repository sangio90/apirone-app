component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        prc.title = "Categorie";

        prc.statusList = super.fire( "status.list", ["product_category"] );

        prc.jsScripts.add( "app-product-category" );

        event.setView("product-category/list");

    }

}
