component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var data = [];
        var result = super.getResult();
        var dm = getDataMapper();

        var params = super.paramsFromUrl();

        var rows = super.fire( "fruit.search", params );

        for ( var row in rows.getData() ) {
            var obj = dm.convert( row, "Fruit", true );
            data.add( obj );
        }

        result.setTotal( rows.getTotal() );
        result.setCount( rows.getCount() );
        result.setData( data );

        event.setValue("result", result);

    }

    function get( event, rc, prc ){

        param rc.id = "___";
        var result = super.getResult();

        if ( !super.isUuid( rc.id ) ) {
            return event.setValue("result", "No UUID");
        }

        var bean = super.fire( "fruit.get", [ rc.id ] );

        var obj = super.getDataMapper().convert( bean, "Fruit", true );

        result.setData( obj );

        event.setValue("result", result);

    }

	function codeExists( event, rc, prc ){
		param rc.id   = "_";
		param rc.code = "";

		var result = super.fire( "fruit.codeExists", { code = rc.code, excludedId = rc.id } );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var result = super.getResult();

		var fruit  = super.bean( "Fruit" );
		var status = super.bean( "Status" );
		var text   = super.bean( "Text" );
		var lang   = super.bean( "Lang" );

		var json = deserializeJSON( getHTTPRequestData().content );

		fruit.setId( json.id );
		fruit.setCode( json.code );

		fruit.setStatus( status.setId( json.status.id ) );
        fruit.setPositionsCount( json.positionsCount )

        text.setLang( lang.setId( json.mainText.lang.id ) );
        text.setStatus( status.setId( "ACT" ) );

        text.setId( json.mainText.id );
        text.setName( json.name );

        fruit.setTexts( [ text ] );

		if ( !len( json.id ) ) {
			var messageId = "fruit.created";
			var thisId    = super.fire( "fruit.create", [ fruit ] )
		} else {
			var messageId = "fruit.updated";
			var thisId    = super.fire( "fruit.update", [ fruit ] )
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}


	function delete( event, rc, prc ){
        
        var result = super.getResult();
        var list = GetHTTPRequestData().content;
        var messageId = "fruit.deletedAllRecords";

        var errors = [];
        var payload = "";

        var ids = ListToArray( list );

        for( var id in ids ) {
            var outcome = super.fire( "fruit.delete", [ id ] );

            if( outcome.getStatus() == "ERROR"  ) {
                errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
            }

        }

        if( errors.len() ) {
            messageId = "fruit.deletedNotAllRecords"
            payload = { "errors": errors } ;
        }

        var message = super.completeMessage( messageId );

        result.setData( { "message" = message, "payload" =  payload } );
        
		event.setValue( "result", result );
	}    

}
