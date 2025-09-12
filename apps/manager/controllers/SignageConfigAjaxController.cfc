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
		var json = DeserializeJSON( GetHTTPRequestData().content );

		var thisId     = "";
		var messageId  = "";
		var newIds     = [];
		var updatedIds = [];

		var result = super.getResult();

		for ( var thisConfig in json.configs ) {
			var sizes         = [];
			var font          = super.bean( "Font" );
			var signageConfig = super.bean( "SignageConfig" );

			signageConfig.setFont( font.setId( thisConfig.font.id ) );

			if ( json.catalogBundle.keyExists( "id" ) AND Len( json.catalogBundle.id ) ) {
				signageConfig.getCatalogBundle().setId( json.catalogBundle.id );
			} else {
				var model    = super.bean( "Model" );
				var line     = super.bean( "Line" );
				var category = super.bean( "ProductCategory" );

				signageConfig.setModel( model.setId( json.catalogBundle.modelId ) );
				signageConfig.setCategory( category.setId( json.catalogBundle.categoryId ) );
				signageConfig.setLine( line.setId( json.catalogBundle.lineId ) );
			}

			for ( var item in thisConfig.items._data ) {
				var bean = super.bean( "signageConfigItem" );

				bean.setId( item.id );
				bean.setHeight( item.height );
				bean.setHeightInPixel( item.heightInPixel );
				bean.setCharCount( item.charCount );
				bean.setRowCount( item.rowCount );

				sizes.add( bean );
			}

			signageConfig.setItems( sizes );

			/*
			if ( thisConfig.keyExists( "id" ) AND thisConfig.id.len() ) {
				messageId = "signageConfig.updated";
				thisId    = super.fire( "signageConfig.update", [ signageConfig ] )
				updatedIds.add( thisId );
			} else {
				messageId = "signageConfig.created";
				thisId    = super.fire( "signageConfig.create", [ signageConfig ] )
				newIds.add( thisId );
			}
			*/


			// TODO: consider:
			// - implementing update logic
			// - set "id" to ''
			transaction {
				if ( thisConfig.keyExists( "id" ) AND Len( thisConfig.id ) ) {
					super.fire( "signageConfig.delete", [ thisConfig.id ] );
				}
				thisId = super.fire( "signageConfig.create", [ signageConfig ] );
			}

			messageId = "signageConfig.created";
			newIds.add( thisId );
		}

		var message = completeMessage( messageId );

		result.setData(
			{ "message" = message },
			{
				"payload" = { "updatedIds" = updatedIds, "newIds" = newIds }
			}
		);

		event.setValue( "result", result );
	}

}

