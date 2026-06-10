component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ModelDAO";
	property name="statusService" inject="StatusService";
	property name="textService" inject="TextService";
	property name="lookupService" inject="lookupService";

	public com.apirone.core.model.bean.Model function get( required String modelId ){
		return build( arguments.modelId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		String lineId,
		required Numeric limit  = 20,
		required Numeric offset = 0
	){
		var rows   = [];
		var result = super.getResult();

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids = [];
		records.each( function( record ){
			ids.append( record.model_id );
		} );

		var beanMap = {};
		if ( ArrayLen( ids ) ) {
			var allRecords = getDao().readByIds( ids );
			allRecords.each( function( record ){
				beanMap[ record.model_id ] = buildFromRow( record );
			} );
		}

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.model_id ] );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	/**
	 * @auditEvent model.created
	 * @auditMessage Model [@return@] created
	 * @auditPayload { "id": "@return@" }
	 */
	public String function create( required com.apirone.core.model.bean.Model model ){
		var newId = getDao().insert( arguments.model );

		transaction {
			for ( var text in arguments.model.getTexts() ) {
				var entity = super.bean( "Entity" );

				entity.setKey( "model.id" );
				entity.setValue( newId );

				text.setEntity( entity );
			}

			getTextService().bulkCreate( arguments.model.getTexts() );
		}

		return newId;
	}

	/**
	 * @auditEvent model.updated
	 * @auditMessage Model [@model.id@] updated
	 * @auditPayload { "id": "@model.id@" }
	 */
	public String function update( required com.apirone.core.model.bean.Model model ){
		var id = arguments.model.getId();

		transaction {
			getDao().update( arguments.model );

			for ( var text in arguments.model.getTexts() ) {
				var entity = super.bean( "Entity" )

				entity.setKey( "model.id" );
				entity.setValue( id );

				text.setEntity( entity );

				if ( Len( text.getId() ) ) {
					getTextService().update( text );
				} else {
					getTextService().create( text );
				}
			}
		}

		return arguments.model.getId();
	}


	public Boolean function codeExists( required String code, String excludedId = "" ){
		var record = getDao().readByCode( arguments.code );

		if (
			record.recordCount
			&& record.model_id != arguments.excludedId
		) {
			return record.code == arguments.code;
		}

		return false;
	}


	public com.apirone.core.model.bean.Outcome function delete( required String modelId ){
		var outcome = super.bean( "Outcome" );

		outcome.setData( { modelId = arguments.modelId } );

		transaction {
			try {
				var result = getDao().delete( arguments.modelId );
				outcome.setData( { "deletedCount" = result } )

				super.logEvent( event = "MODEL.DELETED", message = "Model [#arguments.modelId#] deleted" );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteModel" );
				outcome.setMessage( "Cannot delete model [#arguments.modelId#]" );
			}
		}

		return outcome;
	}



	/*
    	private method
	*/

	private com.apirone.core.model.bean.Model function build( required String modelId ){
		var record = getDao().read( arguments.modelId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean Model a partire da una riga della query, senza chiamata DB aggiuntiva
	 * per il record principale.
	 */
	public com.apirone.core.model.bean.Model function buildFromRow( required any record ){
		var bean = super.bean( "Model" );

		// Campi diretti dal record
		bean.setId( record.model_id );
		bean.setName( record.model );
		bean.setCode( record.code );
		bean.setFruitsCount( record.fruits_count );
		bean.setCreatedAt( record.created_at );

		// Entity collegate (caricate singolarmente)
		bean.setType( getLookupService().get( "modelType", record.model_type_id ) );
		bean.setCategories( getCategoriesBeanByIds( record.categories ) );
		bean.setStatus( getStatusService().get( record.status_id ) );
		bean.setTexts( getTextService().list( modelId = record.model_id ) );

		return bean;
	}

}
