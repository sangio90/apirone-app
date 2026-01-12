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

	function saveFile( event, rc, prc ){

		var result = super.getResult();
		var json   = DeserializeJSON( GetHTTPRequestData().content );

		super.fire( "file.delete", [ json.statusHistory.file.currentId ] );

		var fileId = storeFile( json.statusHistory.file.newFileBase64, json.statusHistory.id );

		// TODO: move to fileService
		// 		 create a method for remove cache by entity 
		super.fire( "QuotationStatusHistory.removeCache", [ json.statusHistory.id ] );

		var message = getMessage( "QuotationStatusHistory.fileSaved" );

		result.setData( { "message" = message }, { "payload" = { id = fileId } } );

		event.setValue( "result", result );
	}	

	function save( event, rc, prc ){

		var result = super.getResult();
		var json   = DeserializeJSON( GetHTTPRequestData().content );
		
		var bean = super.bean( "QuotationStatusHistory" );
		
		bean.setQuotationId( json.quotation.id );
		bean.setStatus( super.service( "Status" ).get( json.newStatus.id ) );
		bean.setUser( super.service( "User" ).get( session.user.getId() ) );

		if ( !Len( json.id ) ) {
			messageId = "quotationStatusHistory.created";
			thisId    = super.fire( "quotationStatusHistory.create", [ bean ] )
		} else {
			messageId = "quotationStatusHistory.updated";
			thisId    = super.fire( "quotationStatusHistory.update", [ bean ] );
		}

		if( Len( json.statusFile.base64 ) AND ( json.newStatus.id == "CCN" ) ) {

			var fileId = storeFile( json.statusFile.base64, thisId );

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

	/*
		private methods
	*/

	private String function storeFile( base64String, quotationStatusHistoryId ){
		var tmpDir = getTempDir();
		var entity = super.bean( "Entity" );

		entity.setKey( "quotationStatusHistory.id" );
		entity.setValue( quotationStatusHistoryId );

		var extension  = super.fire( "file.getExtensionFromDataUrl", [ arguments.base64String ] );

		var base64String = ReReplaceNoCase(
			arguments.base64String,
			"^data:[^;]+;base64,",
			""
		);

		var fileName   = "quotation_status_history_" & quotationStatusHistoryId & "." & extension;
		var filePath   = tmpDir & "/" & fileName;
		var binaryData = ToBinary( base64String );

		FileWrite( filePath, binaryData );

		var fileId = super.fire(
			"file.create",
			{
				filePath = filePath,
				typeId   = "default",
				kindId   = "quotationStatusHistory",
				entity   = entity
			}
		);

		return fileId;
	}

}
