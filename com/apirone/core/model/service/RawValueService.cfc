component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="RawValueDAO";
	property name="textService" inject="TextService";
	property name="statusService" inject="statusService";

	public com.apirone.core.model.bean.RawValue function get( required String rawValueId ){
		return build( arguments.rawValueId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}


	public com.apirone.core.model.bean.Result function search(
		String str,
		required Numeric limit  = 20,
		required Numeric offset = 0
	){
		var rows   = [];
		var result = super.getResult();

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		if ( records.recordCount ) {
			// Raccoglie tutti gli ID e carica i record in blocco con una sola query
			var ids = [];
			for ( var record in records ) {
				ids.append( record.raw_value_id );
			}

			var loadedRecords = getDao().readByIds( ids );
			var recordMap = {};
			for ( var loadedRecord in loadedRecords ) {
				recordMap[ loadedRecord.raw_value_id ] = loadedRecord;
			}

			// Ricostruisce le righe nell'ordine del find() originale
			for ( var record in records ) {
				var fullRecord = recordMap[ record.raw_value_id ];
				if ( !IsNull( fullRecord ) ) {
					rows.add( buildFromRow( fullRecord ) );
				}
			}
		}

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public String function create( required com.apirone.core.model.bean.RawValue rawValue ){
		transaction {
			var newId = getDao().insert( arguments.rawValue );

			for ( var text in arguments.rawValue.getTexts() ) {
				var entity = super.bean( "Entity" );

				entity.setKey( "rawValue.id" );
				entity.setValue( newId );

				text.setEntity( entity );
			}

			getTextService().bulkCreate( arguments.rawValue.getTexts() );
		}

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.rawValue rawValue ){
		var id = arguments.rawValue.getId();

		getDao().update( arguments.rawValue );

		for ( var text in arguments.rawValue.getTexts() ) {
			var entity = super.bean( "Entity" )

			entity.setKey( "rawValue.id" );
			entity.setValue( id );

			text.setEntity( entity );

			if ( Len( text.getId() ) ) {
				getTextService().update( text );
			} else {
				getTextService().create( text );
			}
		}

		return id;
	}

	public Boolean function codeExists( required String code, String excludedId = "" ){
		var record = getDao().readByCode( arguments.code );

		if (
			record.recordCount
			&& record.raw_value_id != arguments.excludedId
		) {
			return record.code == arguments.code;
		}

		return false;
	}

	public com.apirone.core.model.bean.Outcome function delete( required Numeric rawValueId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.rawValueId );

		outcome.setData( { rawValueId = arguments.rawValueId } );

		transaction {
			try {
				var result = getDao().delete( arguments.rawValueId );
				outcome.setData( { "deletedCount" = result } )
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteRawValue" );
				outcome.setMessage( "Cannot delete rawValue [#arguments.rawValueId#]" );
			}
		}

		return outcome;
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.rawValue function buildFromRow( required any record ){
		var bean = super.bean( "rawValue" );

		// Campi diretti dal record
		bean.setId( record.raw_value_id );
		bean.setCode( record.code );
		bean.setCreatedAt( record.created_at );

		// Entity collegate (caricate singolarmente)
		bean.setStatus( getStatusService().get( record.status_id ) );
		bean.setTexts( getTextService().list( rawValueId = record.raw_value_id ) );

		return bean;
	}

	private com.apirone.core.model.bean.rawValue function build( required String rawValueId ){
		var record = getDao().read( arguments.rawValueId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

}
