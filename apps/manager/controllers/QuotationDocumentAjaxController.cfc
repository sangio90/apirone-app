component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var result = super.getResult();
		var mm     = super.getMementify();
		var docs   = super.fire( "QuotationDocument.list", [ rc.quotationId ] );
		var data   = [];

		for ( var doc in docs ) {
			data.add( mm.convert( doc ) );
		}

		result.setData( data );
		event.setValue( "result", result );
	}

	function upload( event, rc, prc ){
		var result = super.getResult();
		var json   = DeserializeJSON( GetHTTPRequestData().content );

		var base64       = json.base64;
		var originalName = json.originalName;

		var extension  = getExtensionFromDataUrl( base64 );
		var storedName = buildStoredName( originalName, extension );
		var directory  = DateFormat( Now(), "yyyy/mm" );
		var destDir    = ExpandPath( "/../repository/public/media/quotation-documents/#directory#" );

		DirectoryCreate( destDir, true, true );

		var rawBase64  = ReReplaceNoCase( base64, "^data:[^;]+;base64,", "" );
		var binaryData = ToBinary( rawBase64 );
		FileWrite( "#destDir#/#storedName#", binaryData );

		var doc = super.bean( "QuotationDocument" );
		doc.setQuotationId( rc.quotationId );
		doc.setOriginalName( originalName );
		doc.setStoredName( storedName );
		doc.setDirectory( directory );

		var newId = super.fire( "QuotationDocument.create", [ doc ] );

		var saved = super.fire( "QuotationDocument.get", [ newId ] );

		result.setData( super.getMementify().convert( saved ) );
		event.setValue( "result", result );
	}

	function deleteDoc( event, rc, prc ){
		var result = super.getResult();
		var json   = DeserializeJSON( GetHTTPRequestData().content );
		var docId  = json.id;

		var doc = super.fire( "QuotationDocument.get", [ docId ] );

		super.fire( "QuotationDocument.delete", { quotationDocumentId = docId } );

		if ( !IsNull( doc ) ) {
			var filePath = ExpandPath( "/../repository/public/media/quotation-documents/#doc.getDirectory()#/#doc.getStoredName()#" );
			if ( FileExists( filePath ) ) {
				FileDelete( filePath );
			}
		}

		result.setData( { message = "Documento eliminato." } );
		event.setValue( "result", result );
	}

	function download( event, rc, prc ){
		var doc = super.fire( "QuotationDocument.get", [ rc.id ] );

		if ( IsNull( doc ) ) {
			cfheader( statusCode = 404, statusText = "Not Found" );
			abort;
		}

		var filePath = ExpandPath( "/../repository/public/media/quotation-documents/#doc.getDirectory()#/#doc.getStoredName()#" );

		if ( !FileExists( filePath ) ) {
			cfheader( statusCode = 404, statusText = "Not Found" );
			abort;
		}

		var mimeMap = {
			"pdf"  = "application/pdf",
			"jpg"  = "image/jpeg",
			"jpeg" = "image/jpeg",
			"png"  = "image/png",
			"gif"  = "image/gif",
			"webp" = "image/webp",
			"doc"  = "application/msword",
			"docx" = "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
			"xls"  = "application/vnd.ms-excel",
			"xlsx" = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
			"zip"  = "application/zip",
			"txt"  = "text/plain"
		};
		var ext      = LCase( ListLast( doc.getStoredName(), "." ) );
		var mimeType = StructKeyExists( mimeMap, ext ) ? mimeMap[ ext ] : "application/octet-stream";

		cfheader( name = "Content-Disposition", value = "attachment; filename=""#doc.getOriginalName()#""" );
		cfcontent( type = mimeType, file = filePath, deleteFile = false, reset = true );
		abort;
	}

	function reorder( event, rc, prc ){
		var result = super.getResult();
		var json   = DeserializeJSON( GetHTTPRequestData().content );

		for ( var item in json.items ) {
			super.fire( "QuotationDocument.updateSortOrder", [ item.id, item.sortOrder ] );
		}

		result.setData( { message = "Ordinamento salvato." } );
		event.setValue( "result", result );
	}

	/*
		private methods
	*/

	private String function getExtensionFromDataUrl( required String dataUrl ){
		var mime = ListFirst( arguments.dataUrl, "," );
		mime = REReplaceNoCase( mime, "^data:", "" );
		mime = ListFirst( mime, ";" );

		var mapping = {
			"application/pdf"                                                    = "pdf",
			"image/jpeg"                                                         = "jpg",
			"image/jpg"                                                          = "jpg",
			"image/png"                                                          = "png",
			"image/gif"                                                          = "gif",
			"image/webp"                                                         = "webp",
			"application/msword"                                                 = "doc",
			"application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "docx",
			"application/vnd.ms-excel"                                           = "xls",
			"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "xlsx",
			"application/zip"                                                    = "zip",
			"text/plain"                                                         = "txt"
		};

		return StructKeyExists( mapping, mime ) ? mapping[ mime ] : "bin";
	}

	private String function buildStoredName( required String originalName, required String extension ){
		var stem   = ListFirst( arguments.originalName, "." );
		stem       = ReReplaceNoCase( stem, "[^a-zA-Z0-9_\-]", "_", "ALL" );
		stem       = Left( stem, 60 );
		var unique = Left( LCase( Replace( CreateUUID(), "-", "", "ALL" ) ), 8 );
		return "#stem#_#unique#.#arguments.extension#";
	}


}
