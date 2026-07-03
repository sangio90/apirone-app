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

		// Costruisce tutti i bean in batch con getMany() ottimizzato (evita N+1)
		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

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

	/**
	 * Recupera in batch più MetadataType dato un array di ID.
	 * Restituisce uno Struct chiave = metadataTypeId, valore = bean MetadataType.
	 * Precarica status, lookup e entities con cache locale per evitare il problema N+1.
	 *
	 * @ids Array di metadataTypeId
	 * @return Struct mappato per metadataTypeId -> MetadataType
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Cache locale per status
		var statuses = {};

		// Cache locali per i lookup (in-memory via LookupService)
		var measurementUnits = {};
		var dataTypes        = {};

		// Raccoglie tutti gli ID unici di entities dai JSONB di ogni record
		var allEntityIds = [];
		for ( var record in records ) {
			var entities = IsNull( record.entities ) ? [] : DeserializeJSON( record.entities );
			if ( !IsNull( entities ) && ArrayLen( entities ) ) {
				for ( var eid in entities ) {
					allEntityIds.append( eid );
				}
			}
		}

		// Precarica tutti gli entities bean da LookupService (in-memory) con cache locale
		var entityMap = {};
		for ( var eid in allEntityIds ) {
			if ( !StructKeyExists( entityMap, eid ) ) {
				entityMap[ eid ] = getLookupService().get( "entity", eid );
			}
		}

		for ( var record in records ) {
			var bean = super.bean( "MetadataType" );

			// Campi diretti dal record
			bean.setId( record.metadata_type_id );
			bean.setName( record.metadata_type );
			bean.setCode( record.code );
			bean.setCreatedAt( record.created_at );

			// Status: cached localmente
			if ( !StructKeyExists( statuses, record.status_id ) ) {
				statuses[ record.status_id ] = getStatusService().get( record.status_id );
			}
			bean.setStatus( statuses[ record.status_id ] );

			// MeasurementUnit: LookupService in-memory, cached localmente
			if ( !StructKeyExists( measurementUnits, record.unit_id ) ) {
				measurementUnits[ record.unit_id ] = getLookupService().get( "MeasurementUnit", record.unit_id );
			}
			bean.setMeasurementUnit( measurementUnits[ record.unit_id ] );

			// DataType: LookupService in-memory, cached localmente
			if ( !StructKeyExists( dataTypes, record.datatype_id ) ) {
				dataTypes[ record.datatype_id ] = getLookupService().get( "DataType", record.datatype_id );
			}
			bean.setDataType( dataTypes[ record.datatype_id ] );

			// Entities: dalla mappa pre-caricata
			var entities = IsNull( record.entities ) ? [] : DeserializeJSON( record.entities );
			var entityBeans = [];
			if ( !IsNull( entities ) && ArrayLen( entities ) ) {
				for ( var eid in entities ) {
					if ( StructKeyExists( entityMap, eid ) ) {
						entityBeans.append( entityMap[ eid ] );
					}
				}
			}
			bean.setEntities( ArrayLen( entityBeans ) ? entityBeans : NullValue() );

			map[ record.metadata_type_id ] = bean;
		}

		return map;
	}

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
