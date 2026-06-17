component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="FinishDAO";
	property name="statusService" inject="StatusService";
	property name="ProductCategoryService" inject="ProductCategoryService";
	property name="textService" inject="TextService";

	public com.apirone.core.model.bean.Finish function get( required String finishId ){
		return build( arguments.finishId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String lineId,
		required Array orderBy = [ { field = "finish.code" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments.orderby, "finish" );

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids     = [];
		records.each( function( r ){
			ids.append( r.finish_id ); // finish_id già castato a varchar dal find()
		} );

		// Costruisce tutti i bean in batch con getMany() ottimizzato (evita N+1)
		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( r ){
			rows.add( beanMap[ r.finish_id ] );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public String function create( required com.apirone.core.model.bean.Finish finish ){
		transaction {
			var newId = getDao().insert( arguments.finish );

			for ( var text in arguments.finish.getTexts() ) {
				var entity = super.bean( "Entity" );

				entity.setKey( "finish.id" );
				entity.setValue( newId );

				text.setEntity( entity );
			}

			getTextService().bulkCreate( arguments.finish.getTexts() );
		}

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.Finish finish ){
		getDao().update( arguments.finish );

		var id = arguments.finish.getId();

		for ( var text in arguments.finish.getTexts() ) {
			var entity = super.bean( "Entity" )

			entity.setKey( "finish.id" );
			entity.setValue( id );

			text.setEntity( entity );

			if ( Len( text.getId() ) ) {
				getTextService().update( text );
			} else {
				getTextService().create( text );
			}
		}

		return arguments.finish.getId();
	}

	public Boolean function codeExists( required String code, String excludedId = "" ){
		var record = getDao().readByCode( arguments.code );

		if (
			record.recordCount
			&& record.finish_id != arguments.excludedId
		) {
			return record.code == arguments.code;
		}

		return false;
	}

	/**
	 * Recupera in batch più Finish dato un array di ID.
	 * Restituisce uno Struct chiave = finishId, valore = bean Finish.
	 * Precarica i testi in batch per evitare il problema N+1.
	 *
	 * @ids Array di finishId
	 * @return Struct mappato per finishId -> Finish
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Precarica i testi in batch per tutte le finiture (1 query invece di N)
		var textMap = getTextService().listByEntityIds( "finish.id", arguments.ids );

		// Raccoglie tutti i category_id dai JSONB categories di ogni finitura
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

		// Cache locali per status
		var statuses = {};

		for ( var record in records ) {
			var bean = super.bean( "Finish" );

			// Campi diretti dal record
			bean.setId( record.finish_id );
			bean.setCode( record.code );
			bean.setCreatedAt( record.created_at );

			// Status: cached localmente (StatusService ha cache interna)
			if ( !StructKeyExists( statuses, record.status_id ) ) {
				statuses[ record.status_id ] = getStatusService().get( record.status_id );
			}
			bean.setStatus( statuses[ record.status_id ] );

			// Testi: dalla mappa pre-caricata
			if ( StructKeyExists( textMap, record.finish_id ) ) {
				bean.setTexts( textMap[ record.finish_id ] );
			}

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

			map[ record.finish_id ] = bean;
		}

		return map;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String finishId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.finishId );

		outcome.setData( { finishId = arguments.finishId } );

		transaction {
			try {
				var result = getDao().delete( arguments.finishId );
				outcome.setData( { "deletedCount" = result } )
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteFinish" );
				outcome.setMessage( "Cannot delete finish [#arguments.finishId#]" );
			}
		}

		return outcome;
	}

	/*
    	private method
	*/

	/**
	 * Costruisce un bean Finish a partire dall'ID, effettuando la lettura dal DB.
	 */
	private com.apirone.core.model.bean.Finish function build( required String finishId ){
		var record = getDao().read( arguments.finishId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean Finish a partire da una riga della query.
	 * Utilizzato sia da build() (record singolo) che da search() (iterazione batch).
	 * Le sub-entity (status, texts, categories) sono caricate con chiamate individuali.
	 */
	private com.apirone.core.model.bean.Finish function buildFromRow( required any record ){
		var bean = super.bean( "Finish" );

		// Campi diretti dal record
		bean.setId( record.finish_id );
		bean.setCode( record.code );
		bean.setCreatedAt( record.created_at );

		// Entity collegate (caricate singolarmente)
		bean.setStatus( getStatusService().get( record.status_id ) );
		bean.setTexts( getTextService().list( finishId = record.finish_id ) );

		var categories = getCategoriesBeanByIds( record.categories )

		bean.setCategories( categories );

		return bean;
	}

}
