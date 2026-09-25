component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data = [];

		var result = super.getResult();
		var mm     = super.getMementify();
		var params = super.paramsFromUrl();

		var rows = super.fire( "fontFamily.search", params );

		for ( var row in rows.getData() ) {
			var obj = mm.convert( row, "list" );
			data.add( obj );
		}

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function codeExists( event, rc, prc ){
		param rc.id   = -1;
		param rc.code = "";

		var result = super.fire( "fontFamily.codeExists", { code = rc.code, excludedId = rc.id } );

		event.setValue( "result", result );
	}

	function getBySignageConfigId( event, rc, prc ){

		var fontFamily = super.fire( "fontFamily.getFontFamilyBySignageConfigId", { signageConfigId = rc.signageConfigId } );

		// Include i pittogrammi caricati (con l'immagine): l'anteprima segnaletica li usa
		// al posto degli SVG statici in /assets/main/pictograms/.
		var result = super.getResult();
		result.setData( super.getMementify().convert( target = fontFamily, includes = "pictograms" ) );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var result     = super.getResult();
		var fontFamily = super.bean( "FontFamily" );

		var messageId = "";
		var thisId = 0;

		var json = DeserializeJSON( GetHTTPRequestData().content );

		fontFamily.setId( json.id );
		fontFamily.setCode( json.code );
		fontFamily.setName( json.name );

		var fontFamilyId = json.id;

		if ( !Len( json.id ) ) {
			var fontFamilyId = super.service( "fontFamily" ).create( fontfamily );
			// var fontFamily = super.service("FontFamily").get( thisId );
		}

		if ( json.sizes._data.len() > 0 ) {
			var sizes = [];

			for ( var size in json.sizes._data ) {
				
				var fontFamilySize = super.bean( "FontFamilySize" );

				fontFamilySize.setId( size.id );
				fontFamilySize.setName( size.name );
				fontFamilySize.setFontFamilyId( fontFamilyId );
				fontFamilySize.setEnabledPictograms( size.enabledPictograms ?: false );

				if ( !Len( size.id ) ) {
					super.service( "fontFamilySize" ).create( fontFamilySize );
				} else {
					super.service( "fontFamilySize" ).update( fontFamilySize );
				}
			}
		}

		if ( !Len( json.id ) ) {
			messageId = "fontFamily.created";
		} else {
			messageId = "fontFamily.updated";
			thisId    = super.fire( "fontFamily.update", [ fontfamily ] )
		}

		// File del font: nuovo upload (sostituisce il precedente) oppure rimozione
		if ( StructKeyExists( json, "fontFileUpload" ) && IsStruct( json.fontFileUpload ) && Len( json.fontFileUpload.content ?: "" ) ) {
			var uploadError = saveFontFile( fontFamilyId, json.fontFileUpload );
			if ( Len( uploadError ) ) {
				result.setStatus( "INVALID" );
				result.setData( { "general" = [ { "message" = uploadError } ] } );
				event.setValue( "result", result );
				return;
			}
		} else if ( ( json.removeFontFile ?: false ) == true ) {
			deleteFontFiles( fontFamilyId );
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

	/*
		Salva il file del font (data URL base64) della font family, soft-eliminando quello
		precedente. Restituisce "" se ok, altrimenti il messaggio d'errore per l'utente.
	*/
	private String function saveFontFile( required fontFamilyId, required Struct upload ){
		var allowed = "woff2,woff,ttf,otf";
		var ext     = LCase( ListLast( arguments.upload.fileName ?: "", "." ) );

		if ( !ListFind( allowed, ext ) ) {
			return "Formato del font non supportato: usare #Replace( allowed, ",", ", ", "all" )#.";
		}

		// "data:font/woff2;base64,AAAA..." -> solo la parte base64
		var base64 = ListRest( arguments.upload.content, "," );
		if ( !Len( base64 ) ) {
			return "Il file del font è vuoto.";
		}

		var util     = new com.apirone.core.util.Udf();
		var baseName = util.prettyString( ListDeleteAt( arguments.upload.fileName, ListLen( arguments.upload.fileName, "." ), "." ) );
		var filePath = GetTempDirectory() & "font_family_" & arguments.fontFamilyId & "_" & baseName & "." & ext;
		FileWrite( filePath, ToBinary( base64 ) );

		deleteFontFiles( arguments.fontFamilyId );

		var entity = super.bean( "Entity" );
		entity.setKey( "fontFamily.id" );
		entity.setValue( arguments.fontFamilyId );

		super.fire( "file.create", {
			filePath = filePath,
			typeId   = "default",
			kindId   = "fontFamily",
			entity   = entity
		} );

		return "";
	}

	// Soft-elimina i file del font della famiglia (normalmente uno)
	private void function deleteFontFiles( required fontFamilyId ){
		var fileSvc = super.service( "File" );
		var files   = fileSvc.listByEntityIds( "fontFamily.id", [ arguments.fontFamilyId ] );
		if ( StructKeyExists( files, arguments.fontFamilyId ) ) {
			for ( var f in files[ arguments.fontFamilyId ] ) {
				fileSvc.delete( f.getId() );
			}
		}
	}

	function get( event, rc, prc ){
		var result = super.getResult();

		var bean = super.fire( "fontFamily.get", [ rc.id ] );

		var obj = super.getMementify().convert( bean, "detail" );

		result.setData( obj );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
		var result    = super.getResult();
		var content   = GetHTTPRequestData().content;
		var messageId = "fontFamily.deletedAllRecords";

		var errors  = [];
		var payload = "";

		var ids = ListToArray( content );

		for ( var id in ids ) {
			var outcome = super.fire( "fontFamily.delete", [ id ] );
			if ( outcome.getStatus() == "ERROR" ) {
				errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
			}
		}

		if ( errors.len() ) {
			messageId = "fontFamily.deletedNotAllRecords"
			payload   = { "errors" = errors };
		}

		var message = super.completeMessage( messageId );

		result.setData( { "message" = message, "payload" = payload } );

		event.setValue( "result", result );
	}

}
