component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        prc.title = "Finiture";

        prc.lineCategories = super.fire( "lineCategory.list" );
        prc.statuses = super.fire( "status.list", ["FINISH"] );

        var data = [];

        for( var thisCategory in prc.lineCategories ) {
            var row = super.getDataMapper().convert( thisCategory, "LineCategory", true );
            data.add( row );
        }

        prc.page["categories"] = data;
        prc.page["statuses"] = prc.statuses;

        prc.jsScripts.add( "app-finish" );

        event.setView("finish/list");

    }

}
