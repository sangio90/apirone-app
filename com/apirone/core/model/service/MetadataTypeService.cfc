component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="MetadataTypeDAO";
	property name="statusService" inject="StatusService";
	property name="lookupService" inject="LookupService";

	public com.apirone.core.model.bean.MetadataType function get( required String metadataTypeId ){
		return build( arguments.metadataTypeId );
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

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids = [];
		records.each( function( r ){
			ids.append( r.metadata_type_id );
		} );

		var beanMap = {};
		if ( ArrayLen( ids ) ) {
			var allRecords = getDao().readByIds( ids );

			allRecords.each( function( r ){
				beanMap[ r.metadata_type_id ] = buildFromRow( r );
			} );
		}

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.metadata_type_id ] );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public Numeric function update( required com.apirone.core.model.bean.MetadataType metadataType ){
		getDao().update( arguments.metadataType );

		return arguments.metadataType.getId();
	}

	public Numeric function create( required com.apirone.core.model.bean.MetadataType metadataType ){
		var newId = getDao().insert( arguments.metadataType );

		return newId;
	}

	public Boolean function codeExists( required String code, String excludedId = "" ){
		var record = getDao().readByCode( arguments.code );

		if (
			record.recordCount
			&& record.metadata_type_id != arguments.excludedId
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
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean MetadataType a partire da una riga della query.
	 * Le sub-entity (Status, MeasurementUnit, DataType, entities) sono caricate con chiamate individuali.
	 */
	private com.apirone.core.model.bean.MetadataType function buildFromRow( required any row ){
		var bean = super.bean( "MetadataType" );

		// Campi diretti dal record
		bean.setId( arguments.row.metadata_type_id );
		bean.setName( arguments.row.metadata_type );
		bean.setCode( arguments.row.code );
		bean.setCreatedAt( arguments.row.created_at );

		// Entity collegate (caricate singolarmente)
		bean.setStatus( getStatusService().get( arguments.row.status_id ) );
		bean.setMeasurementUnit( getLookupService().get( "MeasurementUnit", arguments.row.unit_id ) );
		bean.setDataType( getLookupService().get( "DataType", arguments.row.datatype_id ) );
		bean.setEntities( super.getEntitiesBeanByIds( arguments.row.entities ) );

		return bean;
	}

}
