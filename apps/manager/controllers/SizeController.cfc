component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        prc.title = "Dimensioni";

        prc.statuses = super.fire( "status.list", ["SIZE"] );
        prc.lineCategories = super.fire( "lineCategory.list" );

        var categories = [];

        for( var thisCategory in prc.lineCategories ) {
            var row = super.getDataMapper().convert( thisCategory, "LineCategory", true );
            categories.add( row );
        }

        prc.page["categories"] = categories;
        prc.page["statuses"] = prc.statuses;

        prc.jsScripts.add( "app-size" );

        event.setView("size/list");

    }
    
}
