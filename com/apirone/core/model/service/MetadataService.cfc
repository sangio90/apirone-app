component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="MetadataDAO";
	property name="metadataTypeService" inject="MetadataTypeService";

	public com.apirone.core.model.bean.Metadata function get( required String metadataId ){
		return build( arguments.metadataId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}


	public com.apirone.core.model.bean.Result function search(
		String rawValueId,
		String statusId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "metaData.id", desc = "asc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i bean in blocco con getMany()
		var ids = [];
		records.each( function( record ){
			ids.append( record.metadata_id );
		} );

		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.metadata_id ] );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	/**
	 * Recupera in batch più Metadata dato un array di ID.
	 * Restituisce uno Struct chiave = metadataId, valore = bean Metadata.
	 * Precarica i MetadataType in batch locale per evitare il problema N+1.
	 *
	 * @ids Array di metadataId
	 * @return Struct mappato per metadataId -> Metadata
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};
		var types   = {};

		for ( var record in records ) {
			var bean = super.bean( "Metadata" );

			// Campi diretti dal record
			bean.setId( record.metadata_id );
			bean.setCreatedAt( record.created_at );

			// MetadataType: cached localmente per evitare chiamate N+1
			if ( !StructKeyExists( types, record.metadata_type_id ) ) {
				types[ record.metadata_type_id ] = getMetadataTypeService().get( record.metadata_type_id );
			}
			bean.setType( types[ record.metadata_type_id ] );

			bean.setEntity( getEntity( record ) );
			bean.setValue( getValue( record ) );

			map[ bean.getId() ] = bean;
		}

		return map;
	}

	public Numeric function update( required com.apirone.core.model.bean.Metadata metadata ){
		getDao().update( arguments.metadata );

		return arguments.metadata.getId();
	}

	public Numeric function create( required com.apirone.core.model.bean.Metadata metadata ){
		var newId = getDao().insert( arguments.metadata );

		return newId;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String metadataId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.metadataId );

		outcome.setData( { metadataId = arguments.metadataId } );

		transaction {
			try {
				var result = getDao().delete( arguments.metadataId );
				outcome.setData( { "deletedCount" = result } )
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteMetadata" );
				outcome.setMessage( "Cannot delete metadata [#arguments.metadataId#]" );
			}
		}

		return outcome;
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.Metadata function build( required String metadataId ){
		var record = getDao().read( arguments.metadataId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean Metadata a partire da una riga della query, senza chiamata DB aggiuntiva
	 * per il record principale.
	 */
	public com.apirone.core.model.bean.Metadata function buildFromRow( required any record ){
		var bean = super.bean( "Metadata" );

		// Campi diretti dal record
		bean.setId( record.metadata_id );
		bean.setCreatedAt( record.created_at );

		// Entity collegate (caricate singolarmente)
		bean.setType( getMetadataTypeService().get( record.metadata_type_id ) );
		bean.setEntity( getEntity( record ) );
		bean.setValue( getValue( record ) );

		return bean;
	}

	private Any function getValue( required record ){
		if ( Len( record.value_text ) ) {
			return record.value_text;
		}

		if ( Len( record.value_char ) ) {
			return record.value_char;
		}

		if ( Len( record.value_integer ) ) {
			return record.value_integer;
		}

		if ( Len( record.value_decimal ) ) {
			return record.value_decimal;
		}

		if ( Len( record.value_boolean ) ) {
			return record.value_boolean;
		}

		// il valore potrebbe essere stato aggiornato come vuoto
		return NullValue();

		/*
		Throw(
			type    = "apirone.error.metadata.valueNotFound",
			message = "Value non found #SerializeJSON( record, "struct" )#"
		)
		*/
	}

	private com.apirone.core.model.bean.Entity function getEntity( required record ){
		var entity = super.bean( "Entity" );

		if ( Len( record.raw_value_id ) ) {

			entity.setKey( "rawValue.id" );
			entity.setValue( record.raw_value_id );

			return entity;
		}

		getLogger().error( "No entity linked to this metadata. Metadata id: [#record.metadata_id#]" );

		return NullValue();
	}

}
