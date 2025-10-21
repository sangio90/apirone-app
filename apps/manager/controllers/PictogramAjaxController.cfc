component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data = [];

		var result = super.getResult();
		var mm     = super.getMementify();
		var params = super.paramsFromUrl();

		var rows = super.fire( "pictogram.search", params );
		
		for ( var row in rows.getData() ) {
			var obj = mm.convert( row, "list" );
			data.add( obj );
		}

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( data );

		event.setValue( "result", result );
	}

	//TODO: è un duplicato di list
	function fontFamilyList( event, rc, prc ){
		var data = [];

		var result = super.getResult();
		var mm     = super.getMementify();
		var params = super.paramsFromUrl();

		var rows = super.fire( "Pictogram.search", { 'fontFamilyId' = rc.id } );
		for ( var row in rows.getData() ) {
			var obj = mm.convert( row, "list" );
			data.add( obj );
		}

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function fontFamilyExists( event, rc, prc ){
		param rc.id   = -1;
		param rc.code = "";
		param rc.fontFamilyId = -1;

		var result = super.fire( "pictogram.fontFamilyExists", { code = rc.code, fontFamilyId = rc.fontFamilyId, excludedId = rc.id } );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var result = super.getResult();
		var pictogram   = super.bean( "Pictogram" );
		var fontFamily   = super.bean( "FontFamily" );
		var text   = super.bean( "Text" );
		var lang   = super.bean( "Lang" );


		var thisId    = "";
		var messageId = "";
		var texts     = [];

		var json = DeserializeJSON( GetHTTPRequestData().content );
		transaction {
			pictogram.setCode( json.pictogram.id );
			pictogram.setFontFamily( fontFamily.setId( json.id ) );

			messageId = "pictogram.created";
			thisId    = super.fire( "pictogram.create", { pictogram = pictogram } )
			var entity = super.bean( "Entity" );
			entity.setKey( "pictogram.id" );
			entity.setValue( thisId );

			var tmpDir = getTempDir();
			fileName   = "pictogram_" & json.pictogram.name & "_font_family_" & json.name & ".png";
			filePath   = tmpDir & "/" & fileName;
			binaryData = ToBinary( json.pictogram.image );

			FileWrite( filePath, binaryData );

			var fileId = super.fire(
				"file.create",
				{
					filePath = filePath,
					typeId   = "default",
					kindId   = "pictogram",
					entity   = entity
				}
			);
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

	function get( event, rc, prc ){
		var result = super.getResult();

		var bean = super.fire( "pictogram.get", [ rc.id ] );
		var obj  = super.getMementify().convert( bean, "list" );

		result.setData( obj );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
		var result    = super.getResult();
		var content   = GetHTTPRequestData().content;
		var messageId = "pictogram.deletedAllRecords";

		var errors  = [];
		var payload = "";

		var id = rc.pictogramId

		var outcome = super.fire( "pictogram.delete", [ id ] );
		if ( outcome.getStatus() == "ERROR" ) {
			errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
		}

		if ( errors.len() ) {
			messageId = "pictogram.deletedNotAllRecords"
			payload   = { "errors" = errors };
		}

		var message = super.completeMessage( messageId );

		result.setData( { "message" = message, "payload" = payload } );

		event.setValue( "result", result );
	}


	function listDimensions( event, rc, prc ){

		param rc.id = -1;

		var data = [];

		var result = super.getResult();
		var memy   = super.getMementify();

		var pictogram = super.service("Pictogram").get(rc.id);
		var fontFamily = super.service("FontFamily").get( pictogram.getFontFamilyId() );

		
		var dimensions = super.service( "pictogramDimension").list( pictogramId = rc.id );

		var data = [];

		dump(fontFamily.getSizes().len());
		dump("===========");

		for( var size in fontFamily.getSizes() ){

			//var found = false;
			var row = {};

			for( var dimension in dimensions ) {

				if( size.getId() == dimension.getFontFamilySizeId() ) {
					dump("trovato");
					row = memy.convert( dimension );
					row["pictogram"]["id"] = rc.id;
					row["fontFamilySize"]["id"] = size.getId();
					row["fontFamilySize"]["name"] = size.getName();

					break;
				
				} 

			}

			if( !row.isEmpty() ) { 
				data.add( row )	
			} else {
				data.add( {
					"id" = "",
					"pictogram" = {
						"id" = rc.id,
					},
					"fontFamilySize" = {
						"id" = size.getId(),
						"name" = size.getName()
					},
					"width" = "",
					"height" = "",
				})	
			}

		}
		result.setData( data )

		event.setValue( "result", result );
	}

	function saveDimensions( event, rc, prc ){

		var items = DeserializeJSON( GetHTTPRequestData().content );

		var result = super.getResult();

		var modifiedIds = [];
		var createdIds = [];

		for( var item in items ) {
			
			var dimension  = super.bean( "PictogramDimension" );

			//dimension.setWidth( IsNumeric( item.width ) ? item.width : 0 );
			//dimension.setHeight( IsNumeric( item.height ) ? item.height : 0 );
			dimension.setWidth( IsNumeric( item.width ) ? item.width : 0 );
			dimension.setHeight( IsNumeric( item.height ) ? item.height : 0 );

			dump(item.fontFamilySize.id);
			//dump(dimension.getFontFamilySizeId());

			dimension.setFontFamilySizeId( item.fontFamilySize.id ) ;
			dimension.setPictogramId( item.pictogram.id ) ;

			if( !Len(item.id) ) {
				var newId = super.service( "pictogramDimension").create( dimension );
				//createdIds.add( createdIds )
			} else {
				dimension.setId( item.id );
				var thisId = super.service( "pictogramDimension").update( dimension );
				//modifiedIds.add( thisId );
			}
		}

		result.setData( { "message" = "Salvato", "payload" = { "modified" = modifiedIds, "created" = createdIds } } );

		event.setValue( "result", result );
	}


}
