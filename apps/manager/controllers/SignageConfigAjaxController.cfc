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

		var thisId    = "";
		var messageId = "";

		var result = super.getResult();

		dump( json );
		abort;

		for ( var thisConfig in json.configs ) {
			var sizes         = [];
			var font          = super.bean( "Font" );
			var signageConfig = super.bean( "SignageConfig" );

			signageConfig.setFont( font.setId( thisConfig.font.id ) );

			if ( json.catalogBundle.id.len() ) {
				signageConfig.getCatalogBundle().setId( json.catalogBundle.id );
			} else {
				var model    = super.bean( "Model" );
				var line     = super.bean( "Line" );
				var category = super.bean( "ProductCategory" );

				signageConfig.setModel( model.setId( json.catalogBundle.modelId ) );
				signageConfig.setCategory( category.setId( json.catalogBundle.categoryId ) );
				signageConfig.setLine( line.setId( json.catalogBundle.lineId ) );
			}

			for ( var item in thisConfig.items ) {
				var bean = super.bean( "signageConfigItem" );

				bean.setId( item.id );
				bean.setHeight( item.height );
				bean.setHeightInPx( item.heightInPx );
				bean.setCharCount( item.charCount );
				bean.setRowCount( item.rowCount );

				sizes.add( bean );
			}

			signageConfig.setItems( sizes );
		}

		if ( !Len( json.id ) ) {
			messageId = "signageConfig.created";
			thisId    = super.fire( "signageConfig.create", [ signageConfig ] )
		} else {
			messageId = "signageConfig.updated";
			thisId    = super.fire( "signageConfig.update", [ signageConfig ] )
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

}

