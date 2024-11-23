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
		var result     = super.getResult();
		var size     = super.bean( "Size" );
		var status     = super.bean( "Status" );
		var categories = [];

		var thisId    = "";
		var messageId = "";
		var texts     = [];

		var json = deserializeJSON( getHTTPRequestData().content );

		size.setId( json.id );
		size.setCode( json.code );
		size.setName( json.name );

        if ( Len( json?.selectedCategories ) ) {

            for ( var thisCategory in json.selectedCategories ) {
				
				var category   = super.bean( "LineCategory" );
                
				category.setId( thisCategory.id );
                categories.add( category );
            }

        }

		size.setCategories( categories );
		size.setStatus( status.setId( json.status.id ) );
		size.setFruitsCount( json.fruitsCount );

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


}
