component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="FileDAO";
	property name="lookupService" inject="LookupService";
	property name="fileTypeService" inject="FileTypeService";
	property name="cacheScope" type="String" default="File.bean";

	public com.apirone.core.model.bean.file function get( required String fileId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.fileId );

		if ( cache.status ) {
			return cache.data;
		}

		var obj = build( arguments.fileId );

		cm.put( getCacheScope(), arguments.fileId, obj );

		return obj;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments ).getData();
	}


	public com.apirone.core.model.bean.Result function search(
		String typeId,
		String productId,
		String productItemId,
		String combinationId,
		String quotationItemId,
		String quotationStatusHistoryId,
		String pictogramId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "file.createdAt", desc = "asc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments["orderBy"] = super.createOrderBy( arguments.orderBy );

		var records = getDao().find( argumentCollection = arguments );
		
		records.each( function( record ){
			rows.add( get( fileId = record.file_id ) );
		} );
		
		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public String function update(
		required com.apirone.core.model.bean.File file,
		required com.apirone.core.model.bean.Entity entity
	){
		var id = getDao().update( file = arguments.file, entity = arguments.entity ).toString();

		getCacheManager().remove( getCacheScope(), arguments.fileId );

		return id;
	}

	public void function delete( required String fileId ){
		getDao().delete( arguments.fileId );

		getCacheManager().remove( getCacheScope(), arguments.fileId );
	}

	public String function create(
		required String filePath, // full path of file, from /tmp for example
		required String typeId, // configurated in Configuration.imagesConfig
		required String kindId, // entities: product, productItem, combination
		Struct entity
	){
		var thisFile = "";

		var config = super.getConfiguration().get( "imagesConfig" )[ arguments.kindId ];

		var bean = super.bean( "File" );
		var type = super.bean( "FileType" );
		var kind = super.bean( "FileKind" );

		var root = ExpandPath( "/../repository/public/media/" );

		var dayPath     = DateFormat( Now(), "yyyy/mm" )
		var destination = root & "/#config.path#/" & "_ori/" & dayPath;

		DirectoryCreate( destination, true, true );

		var fileName = ListFirst( ListLast( arguments.filePath, "/" ), "." );
		var fileExt  = ListLast( arguments.filePath, "." );

		var unique = Left( LCase( Replace( CreateUUID(), "-", "", "ALL" ) ), 5 );
		var name   = prettyString( fileName ) & "_" & unique & "." & LCase( fileExt );

		cffile(
			source      = "#arguments.filePath#",
			destination = "#destination#/#name#",
			action      = "RENAME"
		);

		var fileInfo = FileInfo( "#destination#/#name#" );
		bean.setName( name );
		bean.setDescription( "" );
		bean.setDirectory( dayPath );
		bean.setSize( fileInfo.size );

		bean.setType( type.setId( arguments.typeId ) );
		bean.setKind( kind.setId( arguments.kindId ) );

		if ( IsImageFile( "#destination#/#name#" ) ) {
			var info = ImageInfo( "#destination#/#name#" );

			bean.setHeight( info.height );
			bean.setWidth( info.width );
			bean.setAlt( "" );
			bean.setExtension( "" );
		}

		var newId = getDao().insert( file = bean, entity = arguments.entity ).toString();

		var imageType = config.types[ typeId ];

		if ( imageType.keyExists( "sizes" ) ) {
			var thisFile = get( newId );

			if ( fileExt != "pdf" ) {
				for ( var size in imageType.sizes ) {
					resize( thisFile.getPath(), size.width );
				}
			}
		}

		return newId;
	}

	public function duplicate( required String fileId, required entity ){
		var file = get( arguments.fileId );

		var entity    = super.bean( "Entity" );
		entity.setKey( "quotationItem.id" );
		entity.setValue( arguments.entity.getId() );

		var newFileId = getDao().insert( file = file, entity = entity );

		return newFileId;
	}

	public Void function resize( required String filePath, required Numeric size ){
		var sizePath = Replace( filePath, "_ori", size );

		var directory = GetDirectoryFromPath( sizePath );

		var file = ImageNew( arguments.filePath );

		DirectoryCreate( directory, true, true );
		ImageResize( file, size );

		file.write( sizePath, true );
	}


	/**
	 * @private
	 */
	private com.apirone.core.model.bean.File function build( required String fileId ){
		var record = getDao().read( fileId = arguments.fileId );

		if ( record.RecordCount ) {
			var obj = super.bean( "File" );

			obj.setId( record.file_id.toString() );
			obj.setName( record.name );

			obj.setType( getFileTypeService().get( record.type_id ) );

			var kind = getLookupService().get( "fileKind", record.kind_id );

			// TODO add arguments "throwOnNull" to lookup.get()
			if ( IsNull( kind ) ) {
				Throw(
					type    = "apirone.error.file.kindNotFound",
					message = "File kind [#record.kind_id#] not found for fileId [#record.file_id#]"
				);
			}

			obj.setKind( kind );
			obj.setSize( record.size );
			obj.setWidth( record.width );
			obj.setHeight( record.height );
			obj.setAlt( record.alt );
			obj.setDescription( record.description );
			obj.setExtension( record.extension );
			obj.setDirectory( record.directory );

			return obj;
		}

		return NullValue();
	}

	public String function getExtensionFromDataUrl( required String dataUrl ) {
		var mime = listGetAt(dataUrl, 1, ",");         // "data:application/pdf;base64"
		    mime = replace(mime, "data:", "", "one");  // "application/pdf"
		    mime = listGetAt(mime, 1, ";");            // "application/pdf"

		var mapping = {
			"application/pdf": "pdf",
			"image/jpeg"     : "jpg",
			"image/jpg"      : "jpg",
			"image/png"      : "png",
			"image/gif"      : "gif",
			"image/webp"     : "webp"
		};

		return mapping[ mime ] ?: null;
	}

}
