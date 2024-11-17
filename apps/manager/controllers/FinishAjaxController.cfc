component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var data = [];
        var result = super.getResult();
        var dm = getDataMapper();

        var params = super.paramsFromUrl();

        var rows = super.fire( "finish.list", params );

        for ( var row in rows ) {
            var obj = dm.convert( row, "Finish", true );
            data.add( obj );
        }

        result.setTotal( data.len() );
        result.setCount( data.len() );
        result.setData( data );

        event.setValue("result", result);

    }

    function codeExists( event, rc, prc ){

        param rc.id = "_";
        param rc.code = "";

        var result = super.fire( "finish.codeExists", { code = rc.code, excludedId = rc.id } );

        event.setValue("result", result);

    }

}
