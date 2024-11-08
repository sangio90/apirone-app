component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var data = [];
        var result = super.getResult();
        var dm = getDataMapper();
        
        var rows = super.fire( "size.list" );

        for ( var row in rows ) {
            var obj = dm.convert( row, "Size", true );
            data.add( obj );
        }

        result.setTotal( data.len() );
        result.setData( data );

        event.setValue( "result", result );
        
    }

}
