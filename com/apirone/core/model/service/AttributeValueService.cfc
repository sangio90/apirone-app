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

		var beanMap = {};
		if ( ArrayLen( ids ) ) {
			var allRecords = getDao().readByIds( ids );

			allRecords.each( function( r ){
				beanMap[ r.attribute_raw_value_id ] = buildFromRow( r );
			} );
		}

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
