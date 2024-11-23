component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var data = [];
        var result = super.getResult();
        var dm = getDataMapper();

        var params = super.paramsFromUrl();

        var rows = super.fire( "productionTime.search", params );

        for ( var row in rows.getData() ) {
            var obj = dm.convert( row, "productionTime", true );
            data.add( obj );
        }

        result.setTotal( rows.getTotal() );
        result.setCount( rows.getCount() );
        result.setData( data );

        event.setValue("result", result);
        
    }

}
