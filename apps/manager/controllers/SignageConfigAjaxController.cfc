component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var dm     = getDataMapper();

		var params = super.paramsFromUrl();

		var rows = super.fire( "line.search", params );

		for ( var row in rows.getData() ) {
			var obj = dm.convert( row, "Line", true );
			data.add( obj );
		}

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		dump( json )
		abort;

		var result = super.getResult();

		for ( var item in json ) {
			var items         = [];
			var font          = super.bean( "Font" );
			var signageConfig = super.bean( "SignageConfig" );

			signageConfig.setFont( font.setId( json.font.id ) );

			// var catalogSet = super.bean( "CatalogSet" );
			// SignageConfig.setCatalogSet( catalogSet.setId( "" ) );

			for ( var item in thisItem.items ) {
				var bean = super.bean( "signageConfigItem" );
				bean.setId( item.id );
				bean.setHeight( item.height );
				bean.setHeightInPx( item.heightInPx );
				bean.setCharCount( item.charCount );
				bean.setRowCount( item.rowCount );
				thisSizes.add( bean );
			}

			signageConfig.setItems( thisSizes );

		}

		if ( !Len( json.id ) ) {
			messageId = "line.created";
			thisId    = super.fire( "line.create", [ line ] )
		} else {
			messageId = "line.updated";
			thisId    = super.fire( "line.update", [ line ] )
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

}

