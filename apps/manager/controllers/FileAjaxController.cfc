component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		param rc.by = "____";
		var data    = [];
		var item    = {};

		var imageConfigs = getConfiguration().get( "imagesConfig" );

		var file = super.bean( "File" );

		if ( rc.by == "products" ) {
			var params = { productId = rc.id }
			var config = imageConfigs[ "product" ];
		}

		if ( rc.by == "product-items" ) {
			var params = { productItemId = rc.id }
			var config = imageConfigs[ "productItem" ];
		}

		if ( rc.by == "combinations" ) {
			var params = { combinationId = rc.id }
			var config = imageConfigs[ "combination" ];
		}

		if ( rc.by == "attributes-values" ) {
			var params = { attributeValueId = rc.id }
			var config = imageConfigs[ "attributeValue" ];
		}

		for ( var typeId in config.types ) {
			params.put( "typeId", typeId );

			var images = super.fire( "file.list", params );

			// esiste l'immagine la servo
			if ( images.len() ) {
				var image = images[ 1 ];

				// var json = image.toStruct();
				var json = super.getMementify().convert( image, "list" );

				json[ "complete" ] = true;
				json[ "uri" ]      = image.getUri();
				json[ "shortId" ]  = Right( image.getId(), 5 );

				// se non esiste, servo un'immagine vuota
			} else {
				var type = super.fire( "fileType.get", [ typeId ] );

				//var json = super.getMementify().convert( file );

				json[ "id" ]        = "";
				json[ "name" ]      = "";
				json[ "shortId" ]   = "";
				json[ "type" ]      = super.getMementify().convert( type );
				json[ "complete" ]  = false;
				json[ "uri" ]       = "";
				json[ "directory" ] = "";
			}

			data.add( json );
		}

		event.setValue( "result", data );
	}

	function upload( event, rc, prc ){
		var tmpDir = getTempDir();
		var entity = super.bean( "Entity" );

		if ( rc.by == "product-items" ) {
			entity.setKey( "productItem.id" );
			var kindId = "productItem";
		}

		if ( rc.by == "products" ) {
			entity.setKey( "product.id" );
			var kindId = "product";
		}

		if ( rc.by == "combinations" ) {
			entity.setKey( "combination.id" );
			var kindId = "combination";
		}

		if ( rc.by == "attributes-values" ) {
			entity.setKey( "attributeValue.id" );
			var kindId = "attributeValue";
		}

		entity.setValue( rc.id );

		cffile(
			filefield    = rc.files[ 1 ],
			nameconflict = "MAKEUNIQUE",
			destination  = tmpDir,
			action       = "UPLOAD"
		);

		if ( Len( rc.fileId ) ) {
			super.fire( "file.delete", { fileId = rc.fileId } );
		}

		var fileId = super.fire(
			"file.create",
			{
				filePath = "#tmpDir#/#cffile.ServerFile#",
				entity   = entity,
				typeId   = rc.typeId,
				kindId   = kindId // product, productItem, combination, attributeValue [signage]
			}
		);

		var result = super.getResult();

		var file = super.fire( "file.get", [ fileId ] );

		var message = super.completeMessage( "file.imageCreated" );

		result.setData( {
			"message" = message,
			"payload" = { "imageId" = file.getId() }
		} );

		event.setValue( "result", result );
	}


	function delete( event, rc, prc ){
		var result = super.getResult();

		super.fire( "file.delete", { fileId = rc.id } );

		var message = super.completeMessage( "file.imageDeleted" );

		result.setData( { "message" = message, "payload" = { "imageId" = rc.id } } );

		event.setValue( "result", result );
	}

}
