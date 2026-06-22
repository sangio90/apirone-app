component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="FileDAO";
	property name="lookupService" inject="LookupService";
	property name="fileTypeService" inject="FileTypeService";

	public com.apirone.core.model.bean.file function get( required String fileId ){
		return build( arguments.fileId );
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
		String quotationZoneId,
		String quotationStatusHistoryId,
		String pictogramId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "file.createdAt", desc = "asc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments["orderBy"] = super.createOrderBy( arguments.orderBy );

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids     = [];
		records.each( function( r ){
			ids.append( r.file_id ); // file_id già castato a varchar dal find()
		} );

		// Costruisce tutti i bean in batch con getMany() ottimizzato (evita N+1)
		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( r ){
			rows.add( beanMap[ r.file_id ] );
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

		return id;
	}

	public void function delete( required String fileId ){
		getDao().delete( arguments.fileId );
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


	/*
    	private method
	*/

	/**
	 * Recupera in batch più File dato un array di ID.
	 * Restituisce uno Struct chiave = fileId, valore = bean File.
	 * Precarica i fileType e i lookup (fileKind) con cache locale per evitare il problema N+1.
	 *
	 * @ids Array di fileId
	 * @return Struct mappato per fileId -> File
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Raccoglie gli ID unici dei fileType per precaricarli in batch
		var typeIds = [];
		for ( var record in records ) {
			if ( !IsNull( record.type_id ) ) {
				typeIds.append( record.type_id );
			}
		}

		// Precarica i FileType in batch: FileTypeService legge da file JSON, cache locale
		var typeMap = {};
		for ( var tid in typeIds ) {
			if ( !StructKeyExists( typeMap, tid ) ) {
				typeMap[ tid ] = getFileTypeService().get( tid );
			}
		}

		// Cache locale per i lookup (fileKind è in-memory via LookupService)
		var kinds = {};

		for ( var record in records ) {
			var obj = super.bean( "File" );

			// Campi diretti dal record
			obj.setId( record.file_id.toString() );
			obj.setName( record.name );

			// FileType: dalla mappa pre-caricata
			if ( StructKeyExists( typeMap, record.type_id ) ) {
				obj.setType( typeMap[ record.type_id ] );
			} else {
				obj.setType( getFileTypeService().get( record.type_id ) );
			}

			// FileKind: LookupService in-memory, cached localmente
			if ( !StructKeyExists( kinds, record.kind_id ) ) {
				kinds[ record.kind_id ] = getLookupService().get( "fileKind", record.kind_id );

				if ( IsNull( kinds[ record.kind_id ] ) ) {
					Throw(
						type    = "apirone.error.file.kindNotFound",
						message = "File kind [#record.kind_id#] not found for fileId [#record.file_id#]"
					);
				}
			}
			obj.setKind( kinds[ record.kind_id ] );

			obj.setSize( record.size );
			obj.setWidth( record.width );
			obj.setHeight( record.height );
			obj.setAlt( record.alt );
			obj.setDescription( record.description );
			obj.setExtension( record.extension );
			obj.setDirectory( record.directory );

			map[ record.file_id ] = obj;
		}

		return map;
	}

	/**
	 * Costruisce un bean File a partire dall'ID, effettuando la lettura dal DB.
	 */
	private com.apirone.core.model.bean.File function build( required String fileId ){
		var record = getDao().read( fileId = arguments.fileId );

		if ( record.RecordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean File a partire da una riga della query.
	 * Utilizzato sia da build() (record singolo) che da search() (iterazione batch).
	 * Le sub-entity (type, kind) sono caricate con chiamate individuali.
	 */
	private com.apirone.core.model.bean.File function buildFromRow( required any record ){
		var obj = super.bean( "File" );

		// Campi diretti dal record
		obj.setId( record.file_id.toString() );
		obj.setName( record.name );

		// Entity collegate (caricate singolarmente)
		obj.setType( getFileTypeService().get( record.type_id ) );

		var kind = getLookupService().get( "fileKind", record.kind_id );

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

	/**
	 * Recupera in batch tutti i file collegati a una lista di entity.
	 * Restituisce uno Struct chiave = entityValue, valore = Array di bean File.
	 * Sostituisce chiamate ripetute a list() per ogni entity.
	 *
	 * @entityKey Chiave entità (es. "product.id", "quotationItem.id")
	 * @entityValues Array di valori entità
	 * @return Struct mappato per entityValue -> Array di File
	 */
	public Struct function listByEntityIds(
		required String entityKey,
		required Array entityValues
	){
		var records = getDao().findByEntityIds(
			entityKey    = arguments.entityKey,
			entityValues = arguments.entityValues
		);
		var map = {};

		// Raggruppa i risultati della query per entityValue
		for ( var record in records ) {
			var entityValue = record[ getEntityValueColumn( arguments.entityKey ) ];
			if ( !StructKeyExists( map, entityValue ) ) {
				map[ entityValue ] = [];
			}
			var bean = buildFromRow( record );
			ArrayAppend( map[ entityValue ], bean );
		}

		return map;
	}

	/**
	 * Restituisce il nome della colonna DB corrispondente alla entityKey.
	 */
	private String function getEntityValueColumn( required String entityKey ){
		var field = super.getDBField( arguments.entityKey );
		return field.name;
	}

}
