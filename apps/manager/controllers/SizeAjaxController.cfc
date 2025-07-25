component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var data = [];
        var result = super.getResult();
        var dm = getDataMapper();

		var params = super.paramsFromUrl();

        var rows = super.fire( "size.search", params );

        for ( var row in rows.getData() ) {
            var obj = dm.convert( row, "Size", true );
            data.add( obj );
        }

        result.setTotal( rows.getTotal() );
        result.setCount( rows.getCount() );
        result.setData( data );

        event.setValue( "result", result );
        
    }

	function codeExists( event, rc, prc ){
		param rc.id   = "_";
		param rc.code = "";

		var result = super.fire( "size.codeExists", { code = rc.code, excludedId = rc.id } );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){

		var json = deserializeJSON( getHTTPRequestData().content );

        var categories = [];

		var thisId    = "";
		var messageId = "";
		var texts     = [];
		
		var result = super.getResult();

		var size   = super.bean( "Size" );
		var type   = super.bean( "SizeType" );
		var status = super.bean( "Status" );
		var text   = super.bean("Text");
		var lang   = super.bean("Lang");

		size.setId( json.id );
		size.setCode( json.code );
        size.setType( type.setId( json.type.id ) );

        if ( Len( json?.selectedCategories ) ) {

            for ( var thisCategory in json.selectedCategories ) {
				
				var category   = super.bean( "ProductCategory" );
                
				category.setId( thisCategory.id );
                categories.add( category );
            }

        }

        text.setLang( lang.setId( json.mainText.lang.id ) );
        text.setStatus( status.setId( json.mainText.id ) );

        text.setId( json.mainText.id );
        text.setName( json.mainText.name );

        size.setTexts( [ text ] );

		size.setCategories( categories );
		size.setStatus( status.setId( json.status.id ) );
		size.setFruitsCount( Len( json.fruitsCount) ? json.fruitsCount : NullValue() );

		if ( !len( json.id ) ) {
			messageId = "size.created";
			thisId    = super.fire( "size.create", [ size ] )
		} else {
			messageId = "size.updated";
			thisId    = super.fire( "size.update", [ size ] )
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
        
        var result = super.getResult();
        var list = GetHTTPRequestData().content;
        var messageId = "size.deletedAllRecords";

        var errors = [];
        var payload = "";

        var ids = ListToArray( list );

        for( var id in ids ) {
            var outcome = super.fire( "size.delete", [ id ] );

            if( outcome.getStatus() == "ERROR"  ) {
                errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
            }

        }

        if( errors.len() ) {
            messageId = "size.deletedNotAllRecords"
            payload = { "errors": errors } ;
        }

        var message = super.completeMessage( messageId );

        result.setData( { "message" = message, "payload" =  payload } );
        
		event.setValue( "result", result );
	}	


}
