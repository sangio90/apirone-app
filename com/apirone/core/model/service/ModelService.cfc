component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ModelDAO";
	property name="statusService" inject="StatusService";
	property name="textService" inject="TextService";
	property name="lookupService" inject="lookupService";
	property name="ProductCategoryService" inject="ProductCategoryService";

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

		// Costruisce tutti i bean in batch con getMany() ottimizzato (evita N+1)
		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

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


	/**
	 * Recupera in batch più Model dato un array di ID.
	 * Restituisce uno Struct chiave = modelId, valore = bean Model.
	 * Precarica i testi in batch per evitare il problema N+1.
	 *
	 * @ids Array di modelId
	 * @return Struct mappato per modelId -> Model
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Precarica i testi in batch per tutti i modelli (1 query invece di N)
		var textMap = getTextService().listByEntityIds( "model.id", arguments.ids );

		// Raccoglie tutti i category_id dai JSONB categories di ogni modello
		var allCatIds = [];
		for ( var record in records ) {
			var cats = IsNull( record.categories ) ? [] : DeserializeJSON( record.categories );
			if ( !IsNull( cats ) && ArrayLen( cats ) ) {
				for ( var cid in cats ) {
					allCatIds.append( cid );
				}
			}
		}
		var allCatMap = {};
		if ( ArrayLen( allCatIds ) ) {
			allCatMap = getProductCategoryService().getMany( allCatIds );
		}

		// Cache locali per type e status
		var types    = {};
		var statuses = {};

		for ( var record in records ) {
			var bean = super.bean( "Model" );

			// Campi diretti dal record
			bean.setId( record.model_id );
			bean.setName( record.model );
			bean.setCode( record.code );
			bean.setFruitsCount( record.fruits_count );
			bean.setCreatedAt( record.created_at );

			// Type: LookupService in-memory, cached localmente
			if ( !StructKeyExists( types, record.model_type_id ) ) {
				types[ record.model_type_id ] = getLookupService().get( "modelType", record.model_type_id );
			}
			bean.setType( types[ record.model_type_id ] );

			// Status: cached localmente (StatusService ha cache interna)
			if ( !StructKeyExists( statuses, record.status_id ) ) {
				statuses[ record.status_id ] = getStatusService().get( record.status_id );
			}
			bean.setStatus( statuses[ record.status_id ] );

			// Categorie: dalla mappa pre-caricata
			var cats = IsNull( record.categories ) ? [] : DeserializeJSON( record.categories );
			var catBeans = [];
			if ( !IsNull( cats ) && ArrayLen( cats ) ) {
				for ( var cid in cats ) {
					if ( StructKeyExists( allCatMap, cid ) ) {
						catBeans.append( allCatMap[ cid ] );
					}
				}
			}
			bean.setCategories( ArrayLen( catBeans ) ? catBeans : NullValue() );

			// Testi: dalla mappa pre-caricata
			if ( StructKeyExists( textMap, record.model_id ) ) {
				bean.setTexts( textMap[ record.model_id ] );
			}

			map[ record.model_id ] = bean;
		}

		return map;
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
	private com.apirone.core.model.bean.Model function buildFromRow( required any record ){
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
