component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var data = [];
        var result = super.getResult();
        var dm = getDataMapper();
        
        var rows = super.fire( "line.list" );

        for ( var row in rows ) {
            var obj = dm.convert( row, "Line", true );
            data.add( obj );
        }

        result.setTotal( data.len() );
        result.setCount( data.len() );
        result.setData( data );

        event.setValue("result", result);

    }

    function attributes( event, rc, prc ){

        param rc.str="";
        var result = super.getResult();

        var params = {}

        params.str = Len( rc.str ) ? rc.str : NullValue();

        var list = fire( "attributes.search", params );

        dump(list);
        abort;

        result = list;

        event.setValue("result", result);
        
    }

}
