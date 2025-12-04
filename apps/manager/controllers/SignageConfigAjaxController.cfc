component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		// TODO: viene usato?
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
		var json   = DeserializeJSON( GetHTTPRequestData().content );
		var result = super.getResult();

		//dump( json );

		var thisId     = "";
		var messageId  = "";
		var newIds     = [];
		var deletedIds = [];
		var updatedIds = [];

		for ( var thisConfig in json.configs ) {

			var sizes         = [];
			var font          = super.bean( "Font" );
			var signageConfig = super.bean( "SignageConfig" );

			signageConfig.setId( thisConfig?.id );

			signageConfig.setFont( font.setId( thisConfig.font.id ) );

			if ( json.catalogBundle.keyExists( "id" ) AND Len( json.catalogBundle.id ) ) {
				signageConfig.getCatalogBundle().setId( json.catalogBundle.id );
			} else {
				var model    = super.bean( "Model" );
				var line     = super.bean( "Line" );
				var category = super.bean( "ProductCategory" );

				signageConfig.setLine( line.setId( json.catalogBundle.lineId ) );
				signageConfig.setModel( model.setId( json.catalogBundle.modelId ) );
				signageConfig.setCategory( category.setId( json.catalogBundle.categoryId ) );
			}

			for ( var item in thisConfig.items._data ) {

				if( item.keyExists( "deleted" ) AND item.deleted ) {
					
					super.fire( "signageConfigItem.delete", [ item.id ] );
					deletedIds.add( item.id );		
					continue;
				}

				var bean = super.bean( "signageConfigItem" );

				bean.setId( item.id );
				bean.setHeightInPixel( item.heightInPixel );

				bean.setSize( super.fire( "FontFamilySize.get", [ item.size.id ] ) );

				bean.setCharCount( item.charCount );
				bean.setRowCount( item.rowCount );

				sizes.add( bean );
			}

			signageConfig.setItems( sizes );

			if ( thisConfig.keyExists( "id" ) AND Len( thisConfig.id ) ) {
				thisId = super.fire( "signageConfig.update", [ signageConfig ] );
				messageId = "signageConfig.updated";
			} else {
				// create new config
				thisId = super.fire( "signageConfig.create", [ signageConfig ] );
				messageId = "signageConfig.created";
			}

			newIds.add( thisId );
			
		}

		var message = completeMessage( messageId );

		result.setData(
			{ "message" = message },
			{ "payload" = { "updatedIds" = updatedIds, "newIds" = newIds, "deletedIds" = deletedIds } }
		);

		event.setValue( "result", result );
	}

}

