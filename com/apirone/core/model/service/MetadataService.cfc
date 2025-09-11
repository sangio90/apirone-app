component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="MetadataDAO";
	property name="metadataTypeService" inject="MetadataTypeService";
	property name="cacheScope" type="String" default="Metadata.bean";

	public com.apirone.core.model.bean.Metadata function get( required String metadataId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.metadataId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.metadataId );
		cm.put( getCacheScope(), arguments.metadataId, bean );

		return bean;
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

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( metadataId = record.metadata_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public Numeric function update( required com.apirone.core.model.bean.Metadata metadata ){
		getDao().update( arguments.metadata );

		var id = arguments.metadata.getId();

		super.getCacheManager().remove( getCacheScope(), arguments.metadata.getId() );

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

				getCacheManager().remove( getCacheScope(), arguments.metadataId );
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
			var bean = super.bean( "Metadata" );

			// MetadataType first
			bean.setType( getMetadataTypeService().get( record.metadata_type_id ) )

			bean.setId( record.metadata_id );
			bean.setEntity( getEntity( record ) );
			bean.setValue( getValue( record ) );
			bean.setCreatedAt( record.created_at );

			return bean;
		}

		return NullValue();
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
	}

}
