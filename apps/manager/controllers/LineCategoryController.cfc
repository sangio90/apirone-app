component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        prc.title = "Categorie delle linee";

        prc.lineCategories = super.fire( "lineCategory.list" );

        prc.jsScripts.add( "app-line-category" );

        event.setView("line/category/list");

    }

}
