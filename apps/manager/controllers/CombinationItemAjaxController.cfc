component extends="com.apirone.core.controller.AbsController" {

    function listComponents( event, rc, prc ){

        var data = [];
        var result = super.getResult();

        /*
        var  items = super.fire("CombinationItem.getTree", { combinationId = rc.id } );

        for( var item in items ) {

            var row = super.getDataMapper().convert( item, "CombinationItem", true );

            row["level"] = RepeatString( "&nbsp;&nbsp;&nbsp;&nbsp;", item.getLevel() );

            data.add( row );

        }
        */

        result.setTotal( 0 );
        result.setCount( 0 );
        result.setData( data );

        event.setValue("result", result );

    }

    function saveComponents( event, rc, prc ){

        dump(rc);
        abort;

        var data = [];
        var result = super.getResult();

        result.setTotal( 0 );
        result.setCount( 0 );
        result.setData( data );

        event.setValue("result", result );

    }

}
