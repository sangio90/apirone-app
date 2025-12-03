component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var params = super.paramsFromUrl();
		var mm     = super.getMementify();

		params[ "quotationId" ] = rc.quotationId;

		var rows = super.fire( "QuotationStatusHistory.search", params );

		for ( var row in rows.getData() ) {
			var obj = mm.convert( row );
			data.add( obj );
		}

		result.setCount( rows.getCount() );
		result.setTotal( rows.getTotal() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );
		
		var result = super.getResult();

		transaction {
			var tmpDir = getTempDir();
			var extension = super.fire( "File.getExtensionFromDataUrl", [ json.statusFile ] );
			if (IsNull(extension)) {
				return "Formato File non valido.";
			}
			fileName   = "quotation_status_history_" & json.id & "_" & json.status.id & extension;
			filePath   = tmpDir & "/" & fileName;
			binaryData = ToBinary( json.fileBase64 );

			FileWrite( filePath, binaryData );

			var quotationStatusHistory = super.bean( "QuotationStatusHistory" );

			quotationStatusHistory.setQuotation( super.service( "Quotation" ).get( json.quotation.id ) );
			quotationStatusHistory.setAccount( super.service( "Account" ).get( json.account.id ) );
			quotationStatusHistory.setStatus( super.service( "Status" ).get( json.status.id ) );

			if ( !Len( json.id ) ) {
				messageId = "quotationStatusHistory.created";
				thisId    = super.fire( "quotationStatusHistory.create", [ quotationStatusHistory ] )
			} else {
				messageId = "quotationStatusHistory.updated";
				thisId    = super.fire( "quotationStatusHistory.update", [ quotationStatusHistory ] )
			}

			var files = super.fire( "File.search", { quotationStatusHistoryId = thisId } );
			if ( Len( files.getData() ) ) {
				for ( var file in files.getData() ) {
					super.fire( "File.delete", { fileId = file.getId() } );
				}
			}

			var entity = super.bean( "Entity" );

			var kindId = "quotationStatusHistory";
			entity.setKey( "quotationStatusHistory.id" );
			entity.setValue( thisId );

			var fileId = super.fire(
				"file.create",
				{
					filePath = filePath,
					typeId   = "default",
					kindId   = kindId,
					entity   = entity
				}
			);

		}
		
		var message = getMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
		var json       = DeserializeJSON( GetHTTPRequestData().content );
		
		var validation = super.getValidationResult();
		var result     = super.getResult();
		
		var payload    = {};

		transaction {
			var files = super.fire( "File.search", { quotationStatusHistoryId = json.quotationStatusHistoryId } );
			if ( Len( files.getData() ) ) {
				for ( var file in files.getData() ) {
					super.fire( "File.delete", { fileId = file.getId() } );
				}
			}
			var outcome = super.fire( "quotationStatusHistory.delete", [ json.quotationStatusHistoryId ] );
		}

		result.setData( { "message" = getMessage( "quotationStatusHistory.deleted" )  } );

		event.setValue( "result", result );
	}

}
