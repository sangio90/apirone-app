component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        prc.title = "Finiture";

        prc.lineCategories = super.fire( "lineCategory.list" );
        prc.statuses = super.fire( "status.list", ["FINISH"] );

        var categories = [];

        for( var thisCategory in prc.lineCategories ) {
            var row = super.getDataMapper().convert( thisCategory, "LineCategory", true );
            categories.add( row );
        }

        prc.page["categories"] = categories;
        prc.page["statuses"] = prc.statuses;

        prc.jsScripts.add( "app-finish" );

        event.setView("finish/list");

    }

}
