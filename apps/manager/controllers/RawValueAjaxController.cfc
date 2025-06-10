component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var data = [];
        var dm = getDataMapper();
        var result = super.getResult();

        var params = super.paramsFromUrl();

        var rows = super.fire( "rawValue.search", params );

        for ( var row in rows.getData() ) {

            var obj = dm.convert( row, "RawValue", true );
            data.add( obj );
        
        }

        result.setCount( rows.getCount() );
        result.setTotal( rows.getTotal() );
        result.setData( data );

        event.setValue("result", result );
        
    }

    function get( event, rc, prc ){

        param rc.id = "";

        var dm = getDataMapper();
        var result = super.getResult();

        var row = super.fire( "rawValue.get", { rawValueId = rc.id } );

        var obj = dm.convert( row, "RawValue", true );
        //data.add( obj );

        //result.setCount( rows.getCount() );
        //result.setTotal( rows.getTotal() );
        result.setData( obj );

        event.setValue("result", result );
        
    }

	function codeExists( event, rc, prc ){
		param rc.id   = "_";
		param rc.code = "";

        var result = super.getResult();

		var exist = super.fire( "RawValue.codeExists", { code = rc.code, excludedId = rc.id } );

        result.setData( exist );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
        
        var result = super.getResult();
        var list = GetHTTPRequestData().content;
        var messageId = "RawValue.deletedAllRecords";

        var errors = [];
        var payload = "";

        var ids = ListToArray( list );

        for( var id in ids ) {
            var outcome = super.fire( "RawValue.delete", [ id ] );

            if( outcome.getStatus() == "ERROR"  ) {
                errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
            }

        }

        if( errors.len() ) {
            messageId = "RawValue.deletedNotAllRecords"
            payload = { "errors": errors } ;
        }

        var message = super.completeMessage( messageId );

        result.setData( { "message" = message, "payload" =  payload } );
        
		event.setValue( "result", result );
	}

    function save( event, rc, prc ){

        var result = super.getResult();
    
        var thisId = "";
        var messageId = "";
        var texts = [];

        var json = DESerializeJSON( GetHTTPRequestData().content );

        var rawValue = super.bean("RawValue");
        
        var text = super.bean("Text");
        var lang = super.bean("Lang");
        var status = super.bean("Status");
        var valueStatus = super.bean("Status");

        text.setLang( lang.setId( json.mainText.lang.id ) );
        text.setStatus( status.setId( json.mainText.id ) );

        text.setId( json.mainText.id );
        text.setName( json.mainText.name );

        rawValue.setId( json?.id );
        rawValue.setTexts( [ text ] );
        rawValue.setStatus( valueStatus.setId( json.status.id ) );
        rawValue.setCode( json.code );

        if( !Len( json?.id ) ) {
            
            messageId = "RawValue.created";
            thisId = super.fire( "RawValue.create", [ rawValue ] )
            
        } else {

            messageId = "RawValue.updated";
            thisId = super.fire( "RawValue.update", [ rawValue ] )
            
        }

        var message = super.completeMessage( messageId );

        result.setData( { "message" = message, "payload" = { "id" = thisId }  } );
        
        event.setValue( "result", result );
        
    }

    function order( event, rc, prc ){
    }

}
