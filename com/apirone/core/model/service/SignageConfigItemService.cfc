component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="SignageConfigItemDAO";
	property name="fontFamilySizeService" inject="FontFamilySizeService";

	public com.apirone.core.model.bean.SignageConfigItem function get( required Numeric signageConfigItemId ){
		return build( arguments.signageConfigItemId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}


	public com.apirone.core.model.bean.Result function search(
		String signageConfigId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "SignageConfigItem.id", desc = "desc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		// Il find() restituisce tutte le colonne: si raccolgono gli ID per getMany()
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie gli ID e carica i bean in blocco con getMany()
		var ids = [];
		records.each( function( record ){
			ids.append( record.signage_config_item_id );
		} );

		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.signage_config_item_id ] );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	/**
	 * Recupera in batch più SignageConfigItem dato un array di ID.
	 * Restituisce uno Struct chiave = signageConfigItemId, valore = bean SignageConfigItem.
	 * Precarica i FontFamilySize in batch locale per evitare il problema N+1.
	 *
	 * @ids Array di signageConfigItemId
	 * @return Struct mappato per signageConfigItemId -> SignageConfigItem
	 */
	public Struct function getMany( required Array ids ){
		var records  = getDao().readByIds( ids = arguments.ids );
		var map      = {};
		var sizes    = {};

		for ( var record in records ) {
			var bean = super.bean( "SignageConfigItem" );

			// Campi diretti dal record
			bean.setId( record.signage_config_item_id );
			bean.setSignageConfigId( record.signage_config_id );
			bean.setCreatedAt( record.created_at );
			bean.setHeight( record.height );
			bean.setHeightInPixel( record.height_in_pixel );
			bean.setRowCount( record.row_count );
			bean.setCharCount( record.char_count );

			// PostgreSQL JDBC restituisce le colonne JSONB come PGobject: vanno deserializzate
			bean.setLineHeights( isNull( record.line_heights ) ? [] : deserializeJSON( record.line_heights.toString() ) );

			// FontFamilySize: cached localmente per evitare chiamate N+1 (FK opzionale)
			if ( !IsNull( record.font_family_size_id ) ) {
				if ( !StructKeyExists( sizes, record.font_family_size_id ) ) {
					sizes[ record.font_family_size_id ] = getFontFamilySizeService().get( record.font_family_size_id );
				}
				bean.setSize( sizes[ record.font_family_size_id ] );
			}

			map[ bean.getId() ] = bean;
		}

		return map;
	}

	public Numeric function create( required com.apirone.core.model.bean.SignageConfigItem signageConfigItem ){
		var newId = getDao().insert( arguments.signageConfigItem );

		return newId;
	}

	public Numeric function update( required com.apirone.core.model.bean.SignageConfigItem signageConfigItem ){
		var newId = getDao().update( arguments.signageConfigItem );

		return newId;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String signageConfigItemId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.signageConfigItemId );

		outcome.setData( { signageConfigItemId = arguments.signageConfigItemId } );

		transaction {
			try {
				var result = getDao().delete( arguments.signageConfigItemId );
				outcome.setData( { "deletedCount" = result } )
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.error.CannotDeleteSignageConfigItem" );
				outcome.setMessage( "Cannot delete SignageConfigItem [#arguments.signageConfigItemId#]" );
			}
		}

		return outcome;
	}


	/*
    	private method
	*/

	/**
	 * Costruisce un bean SignageConfigItem a partire dall'ID. Delega a buildFromFindRow() dopo la lettura del record.
	 */
	private com.apirone.core.model.bean.SignageConfigItem function build( required String signageConfigItemId ){
		var record = getDao().read( arguments.signageConfigItemId );

		if ( record.recordCount ) {
			return buildFromFindRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean SignageConfigItem a partire da una riga della query.
	 */
	private com.apirone.core.model.bean.SignageConfigItem function buildFromFindRow( required any record ){
		var bean = super.bean( "SignageConfigItem" );
		bean.setSignageConfigId( record.signage_config_id );

		// Campi diretti dal record
		bean.setId( record.signage_config_item_id );
		bean.setCreatedAt( record.created_at );
		bean.setHeight( record.height );
		bean.setHeightInPixel( record.height_in_pixel );
		bean.setRowCount( record.row_count );
		bean.setCharCount( record.char_count );

		// PostgreSQL JDBC restituisce le colonne JSONB come PGobject: vanno deserializzate
		bean.setLineHeights( isNull( record.line_heights ) ? [] : deserializeJSON( record.line_heights.toString() ) );

		// Entity collegata (FontFamilySize è un lookup leggero)
		if ( !IsNull( record.font_family_size_id ) ) {
			bean.setSize( getFontFamilySizeService().get( record.font_family_size_id ) )
		}

		return bean;
	}

}
