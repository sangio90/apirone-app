component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="AttributeValueDAO";
	property name="textService" inject="TextService";
	property name="rawValueService" inject="RawValueService";
	property name="statusService" inject="statusService";
	property name="langService" inject="LangService";
	property name="componentService" inject="ComponentService";
	property name="FileService" inject="FileService";

	public com.apirone.core.model.bean.AttributeValue function get( required String attributeValueId ){
		return build( arguments.attributeValueId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}


	public com.apirone.core.model.bean.Result function search( required String attributeId ){
		var rows   = [];
		var result = super.getResult();

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids = [];
		for ( var record in records ) {
			ids.append( record.attribute_raw_value_id );
		}

		// Costruisce tutti i bean in batch con getMany() ottimizzato (evita N+1)
		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Ricostruisce le righe nell'ordine del find() originale
		for ( var record in records ) {
			rows.add( beanMap[ record.attribute_raw_value_id ] );
		}

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.recordcount ) );

		return result;
	}

	public Numeric function create( required com.apirone.core.model.bean.AttributeValue attributeValue ){
		var newId = getDao().insert( arguments.attributeValue );

		return newId;
	}


	public Numeric function update( required com.apirone.core.model.bean.AttributeValue attributeValue ){
		var id = arguments.attributeValue.getId();

		getDao().update( arguments.attributeValue );

		return id;
	}

	public com.apirone.core.model.bean.Outcome function delete( required Numeric attributeValueId ){
		var outcome = super.bean( "Outcome" );

		outcome.setData( { attributeValueId = arguments.attributeValueId } );

		transaction {
			try {
				var result = getDao().delete( arguments.attributeValueId );
				outcome.setData( { "deletedCount" = result } )
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteAttributeValue" );
				outcome.setMessage( "Cannot delete value [#arguments.attributeValueId#]" );
			}
		}

		return outcome;
	}


	/*
    	private method
	*/

	/**
	 * Recupera in batch più AttributeValue dato un array di ID.
	 * Restituisce uno Struct chiave = attributeRawValueId, valore = bean AttributeValue.
	 * Precarica status, rawValue e files in batch per evitare il problema N+1.
	 *
	 * @ids Array di attributeRawValueId
	 * @return Struct mappato per attributeRawValueId -> AttributeValue
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Raccoglie gli ID unici di rawValue da tutti i record
		var rawValueIds = [];
		for ( var record in records ) {
			if ( !IsNull( record.raw_value_id ) ) {
				rawValueIds.append( record.raw_value_id );
			}
		}

		// Precarica i RawValue in batch tramite RawValueDAO.readByIds
		var rawValueMap = {};
		if ( ArrayLen( rawValueIds ) ) {
			var uniqueRvIds = [];
			for ( var rvid in rawValueIds ) {
				if ( !IsNull( rvid ) && !ArrayContains( uniqueRvIds, rvid ) ) {
					uniqueRvIds.append( rvid );
				}
			}
			if ( ArrayLen( uniqueRvIds ) ) {
				var rvRecords = getRawValueService().getDao().readByIds( uniqueRvIds );
				for ( var rvr in rvRecords ) {
					var rvBean = super.bean( "RawValue" );
					rvBean.setId( rvr.raw_value_id );
				rvBean.setCode( rvr.code );
				rvBean.setCreatedAt( rvr.created_at );
					// Status: precaricato sotto con cache locale condivisa
					rawValueMap[ rvr.raw_value_id ] = rvBean;
				}
			}
		}

		// Precarica i file (images) in batch tramite FileService.listByEntityIds()
		var fileMap = getFileService().listByEntityIds( "attributeValue.id", arguments.ids );

		// Cache locale per status
		var statuses = {};

		for ( var record in records ) {
			var bean = super.bean( "AttributeValue" );

			// Campi diretti dal record
			bean.setId( record.attribute_raw_value_id );
			bean.setAttributeId( record.attribute_id.toString() );
			bean.setCreatedAt( record.created_at );
			bean.setOrderBy( record.orderby );
			bean.setAllowNote( record.allow_note ? true : false );
			bean.setAffectToImage( record.affect_to_image ? true : false );
			bean.setComponentCount( record.component_count );

			// Status: cached localmente
			if ( !StructKeyExists( statuses, record.status_id ) ) {
				statuses[ record.status_id ] = getStatusService().get( record.status_id );
			}
			bean.setStatus( statuses[ record.status_id ] );

			// RawValue: dalla mappa pre-caricata
			if ( !IsNull( record.raw_value_id ) && StructKeyExists( rawValueMap, record.raw_value_id ) ) {
				bean.setRawValue( rawValueMap[ record.raw_value_id ] );
				// Passa lo status al rawValue se non già impostato
				if ( IsNull( bean.getRawValue().getStatus() ) ) {
					if ( !StructKeyExists( statuses, record.status_id ) ) {
						statuses[ record.status_id ] = getStatusService().get( record.status_id );
					}
					bean.getRawValue().setStatus( statuses[ record.status_id ] );
				}
			}

			// Images: dalla mappa batch pre-caricata
			var idStr = record.attribute_raw_value_id.toString();
			if ( StructKeyExists( fileMap, idStr ) ) {
				var images = fileMap[ idStr ];
				if ( Len( images ) ) {
					bean.setImages( images );
				}
			}

			map[ record.attribute_raw_value_id ] = bean;
		}

		return map;
	}

	private com.apirone.core.model.bean.AttributeValue function build( required String attributeValueId ){
		var record = getDao().read( arguments.attributeValueId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean AttributeValue a partire da una riga del query.
	 * Le sub-entity (Status, RawValue, File/images) sono caricate con chiamate individuali.
	 */
	private com.apirone.core.model.bean.AttributeValue function buildFromRow( required any record ){
		var bean = super.bean( "AttributeValue" );

		// Campi diretti dal record
		bean.setId( record.attribute_raw_value_id );
		bean.setAttributeId( record.attribute_id.toString() );
		bean.setCreatedAt( record.created_at );
		bean.setOrderBy( record.orderby );
		bean.setAllowNote( record.allow_note ? true : false );
		bean.setAffectToImage( record.affect_to_image ? true : false );
		bean.setComponentCount( record.component_count );

		// Entity collegate (caricate singolarmente)
		bean.setStatus( getStatusService().get( record.status_id ) );
		bean.setRawValue( getRawValueService().get( record.raw_value_id ) );

		var images = getFileService().list( attributeValueId = record.attribute_raw_value_id );
		if ( Len( images ) ) {
			bean.setImages( images )
		}

		return bean;
	}

}
