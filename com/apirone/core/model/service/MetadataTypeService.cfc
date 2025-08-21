component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="MetadataTypeDAO";
	property name="statusService" inject="StatusService";
	property name="lookupService" inject="LookupService";

	property name="cacheScope" type="String" default="MetadataType.bean";

	public com.apirone.core.model.bean.MetadataType function get( required String metadataTypeId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.metadataTypeId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.metadataTypeId );
		cm.put(
			getCacheScope(),
			arguments.metadataTypeId,
			bean
		);

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}


	public com.apirone.core.model.bean.Result function search(
		String str,
		String categoryId,
		String statusId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "metaDataType.code", desc = "asc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( metadataTypeId = record.metadata_type_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public String function update( required com.apirone.core.model.bean.MetadataType metadataType ){
		getDao().update( arguments.metadataType );

		var id = arguments.metadataType.getId();

		super.getCacheManager().remove( getCacheScope(), arguments.metadataType.getId() );

		return arguments.metadataType.getId();
	}

	public Boolean function codeExists( required String code, String excludedId = "" ){
		var record = getDao().readByCode( arguments.code );

		if (
			record.recordCount
			&& record.metadataType_id != arguments.excludedId
		) {
			return record.code == arguments.code;
		}

		return false;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String metadataTypeId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.metadataTypeId );

		outcome.setData( { metadataTypeId = arguments.metadataTypeId } );

		transaction {
			try {
				var result = getDao().delete( arguments.metadataTypeId );
				outcome.setData( { "deletedCount" = result } )

				getCacheManager().remove( getCacheScope(), arguments.metadataTypeId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteMetadataType" );
				outcome.setMessage( "Cannot delete metadataType [#arguments.metadataTypeId#]" );
			}
		}

		return outcome;
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.MetadataType function build( required String metadataTypeId ){
		var record = getDao().read( arguments.metadataTypeId );

		if ( record.recordCount ) {
			var bean = super.bean( "MetadataType" );

			bean.setName( bean.metadata_type );

			bean.setId( record.metadata_type_id );
			bean.setCode( record.code );
			bean.setCreatedAt( record.created_at );

			bean.setStatus( getStatusService().get( record.status_id ) );
			bean.setMeasurementUnit( getLookupService().get( "MeasurementUnit", record.unit_id ) );
			bean.setDataType( getLookupService().get( "DataType", record.datatype_id ) );
			bean.setEntities( record.entities );

			return bean;
		}

		return NullValue();
	}

}
