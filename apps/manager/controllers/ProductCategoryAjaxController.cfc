component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var data = [];
        var result = super.getResult();
        var dm = super.getDataMapper();

        var params = super.paramsFromUrl();
        params["orderBy"] = [ { "field": 'ProductCategory.id' } ]

        var rows = super.fire( "ProductCategory.search", params );

        for ( var row in rows.getData() ) {
            var obj = dm.convert( row, "ProductCategory", true );
            data.add( obj );
        }

        result.setTotal( rows.getTotal() );
        result.setCount( rows.getCount() );
        result.setData( data );

        event.setValue("result", result);

    }

	function delete( event, rc, prc ){
        
        var result = super.getResult();
        var list = GetHTTPRequestData().content;
        var messageId = "productCategory.deletedAllRecords";

        var errors = [];
        var payload = "";

        var ids = ListToArray( list );

        for( var id in ids ) {
            var outcome = super.fire( "productCategory.delete", [ id ] );

            if( outcome.getStatus() == "ERROR"  ) {
                errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
            }

        }

        if( errors.len() ) {
            messageId = "productCategory.deletedNotAllRecords"
            payload = { "errors": errors } ;
        }

        var message = super.completeMessage( messageId );

        result.setData( { "message" = message, "payload" =  payload } );
        
		event.setValue( "result", result );
	}    


}
