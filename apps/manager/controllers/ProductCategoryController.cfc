component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        prc.title = "Categorie";

        prc.lineCategories = super.fire( "lineCategory.list" );

        prc.jsScripts.add( "app-product-category" );

        event.setView("line/category/list");

    }

}
