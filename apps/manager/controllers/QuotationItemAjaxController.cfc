component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var params = super.paramsFromUrl();
		var rows = super.fire( "QuotationItem.search", params );
		var imageConfigs = getConfiguration().get( "imagesConfig" );

		for ( var row in rows.getData() ) {
			var params = { quotationItemId = row.getId() }
			var config = imageConfigs[ "quotationItem" ];
			params.put( "typeId", 'default' );
			var images = super.fire( "file.list", params );
			
			var file = super.bean( "File" );

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
				var type = super.fire( "fileType.get", [ 'default' ] );

				file.setType( type );

				file.setId( "" );
				file.setName( "" );
				file.setDirectory( "" );

				var json = super.getMementify().convert( file );

				json[ "complete" ] = false;
				json[ "uri" ]      = "";
				json[ "shortId" ]  = "";
			}

			// dump(json);abort;
			//row.add( json );
		}

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( rows.getData() );

		event.setValue( "result", result );
	}

	function editSignage( event, rc, prc ){
		var data   = {}
		var result = super.getResult();
		var params = super.paramsFromUrl();
		var mm     = super.getMementify();

		params[ "quotationItemId" ] = rc.id;

		var quotationItem = super.fire( "QuotationItem.get", { quotationItemId = rc.id } );

		var parsedQuotationItemData = mm.convert( quotationItem, "edit" );

		var signageConfig = super.fire(
			"SignageConfig.get",
			{
				signageConfigId = quotationItem.getSignageConfigItem().getSignageConfigId()
			}
		);
		var parsedSignageConfigData = ( mm.convert( signageConfig ) );

		data.append( {
			"quotationItem" = parsedQuotationItemData,
			"signageConfig" = parsedSignageConfigData
		} );

		result.setData( data );
		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var json      = DeserializeJSON( GetHTTPRequestData().content );
		var thisId    = "";
		var messageId = "";
		var texts     = [];

		var result = super.getResult();

		transaction {
			var tmpDir = getTempDir();
			fileName = "preview_segnaletica_id_" & json.quotationItem.id & ".png";
			filePath = tmpDir & fileName;
			binaryData = ToBinary(json.imageBase64);

			fileWrite(filePath, binaryData);

			var id = json.quotationItem.id;
			try {
				if ( !Len( id ) ) {
					var quotationItemSignageBean = super.bean( "QuotationItemSignage" );
				} else {
					var quotationItemSignageBean = super.fire( "QuotationItem.get", { quotationItemId = id } );
					if ( IsNull( quotationItemSignageBean ) ) {
						var quotationItemSignageBean = super.bean( "QuotationItemSignage" );
					}
				}
				quotationItemSignageBean.setSignageConfigItem(
					super.service( "SignageConfigItem" ).get( json.quotationItem.signageConfigItem.id )
				);
				quotationItemSignageBean.setQuotation( super.service( "Quotation" ).get( json.quotationId ) );
				quotationItemSignageBean.setQuotationZone(
					super.service( "QuotationZone" ).get( json.quotationItem.quotationZone.id )
				);
				quotationItemSignageBean.setPrice( 20.1 );
				quotationItemSignageBean.setQuantity( json.quotationItem.quantity );
				var product = super
					.fire(
						"Product.search",
						{
							lineId     = json.signageConfig.catalogBundle.line.id,
							modelId    = json.signageConfig.catalogBundle.model.id,
							categoryId = json.signageConfig.catalogBundle.category.id,
							finishId   = json.quotationItem.product.finish.id
						}
					)
					.getData();
				if ( !Len( product ) || Len( product ) > 1 ) {
					var message = "Prodotto non valido.";
					result.setData( { "error" = e.message } );
					result.setStatus( "ERRORE" );
					event.setValue( "result", result );
					return;
				}
				product = product[ 1 ];
				quotationItemSignageBean.setProduct(
					super.fire( "Product.get", { "productId" = product.getId() } )
				);
				if ( !Len( id ) ) {
					messageId = "quotationItem.created";
					thisId    = super.fire( "quotationItem.create", [ quotationItemSignageBean ] )
				} else {
					messageId = "quotationItem.updated";
					thisId    = super.fire( "quotationItem.update", [ quotationItemSignageBean ] )
				}
				for ( signageRow in json.quotationItem.signageRows._data ) {
					var signageRowBean = super.fire(
						"QuotationItemSignageRow.get",
						{ quotationItemSignageRowId = signageRow.id }
					);

					if ( !Len( signageRowBean ) ) {
						var signageRowBean = super.bean( "QuotationItemSignageRow" );
						var messaggiId     = "QuotationItemSignageRow.create";
					} else {
						var messaggiId = "QuotationItemSignageRow.update";
					}
					signageRowBean.setQuotationItemId( thisId );
					signageRowBean.setTextAlign( signageRow.textAlign );
					signageRowBean.setContent( signageRow.content );
					signageRowBean.setCharCount( signageRow.charCount );
					signageRowBean.setOrderby( signageRow.index );

					super.fire( messaggiId, [ signageRowBean ] );
				}

				var files = super.fire('File.search', { quotationItemId: id });
				if (Len(files)) {
					for (file in files.getData()) {
						super.fire('File.delete', { fileId: file.getId() });
					}
				}
				
				var entity = super.bean( "Entity" );
		
				var kindId = "quotationItem";
				entity.setKey( "quotationItem.id" );
				entity.setValue( id );

				var fileId = super.fire(
					"file.create",
					{
						filePath = filePath,
						typeId = 'default',
						kindId = 'quotationItem',
						entity = entity
					}
				);

				var message = completeMessage( messageId );
			} catch ( any e ) {
				var message = "Errore nella creazione/aggiornamento della riga di preventivo: #e.message#";
				result.setData( { "error" = e.message } );
				result.setStatus( "ERRORE" );
				event.setValue( "result", result );
				return;
			}
		}

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

}
