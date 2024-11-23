component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var data = [];
        var result = super.getResult();
        var dm = super.getDataMapper();

        var params = super.paramsFromUrl();
        params["orderBy"] = [ { "field": 'lineCategory.id' } ]

        var rows = super.fire( "lineCategory.search", params );

        for ( var row in rows.getData() ) {
            var obj = dm.convert( row, "LineCategory", true );
            data.add( obj );
        }

        result.setTotal( rows.getTotal() );
        result.setCount( rows.getCount() );
        result.setData( data );

        event.setValue("result", result);

    }

}
