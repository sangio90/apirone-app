component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="TextDAO";
	property name="langService" inject="LangService";
	property name="statusService" inject="StatusService";
	property name="lookupService" inject="LookupService";
	// property name="textKindService" inject="TextKindService";

	public com.apirone.core.model.bean.Text function get( required String textId ){
		return build( arguments.textId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments ).getData()
	}

	public com.apirone.core.model.bean.Result function search(
		String statusId,
		String lineId,
		String attributeId,
		Numeric attributeValueId,
		Numeric productCategoryId,
		String countryId,
		String langId,
		String productId,
		String finishId,
		String articleId,
		String kind,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "lang.orderBy", dir = "asc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		if ( records.recordCount ) {
			// Raccoglie tutti gli ID e carica i record in blocco con una sola query
			var ids = [];
			for ( var record in records ) {
				ids.append( record.text_id );
			}

			var loadedRecords = getDao().readByIds( ids );
			var recordMap = {};
			for ( var loadedRecord in loadedRecords ) {
				recordMap[ loadedRecord.text_id ] = loadedRecord;
			}

			// Ricostruisce le righe nell'ordine del find() originale
			for ( var record in records ) {
				var fullRecord = recordMap[ record.text_id ];
				if ( !IsNull( fullRecord ) ) {
					rows.add( buildFromResultRow( fullRecord ) );
				}
			}
		}

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public String function create( required com.apirone.core.model.bean.Text text ){
		var newId = getDao().insert( arguments.text );

		return newId;
	}


	public array function bulkCreate( required com.apirone.core.model.bean.Text[] texts ){
		// all translations of a same entity

		if ( !ArrayLen( arguments.texts ) ) return [];

		var langs = getLangService().list( statusId = "ACT" );
		var kinds = [];
		var ids   = [];

		// Raccogli tutti i kind presenti nei texts
		for ( var t in arguments.texts ) {
			kinds.append( t.getKind().getId() );
		}

		kinds = ListToArray( ListRemoveDuplicates( ArrayToList( kinds ) ) );

		// Raccogli l'entità (assumo che sia uguale per tutti)
		var entity = arguments.texts[ 1 ].getEntity();

		// Inserisci i texts già presenti
		var done = [];
		for ( var thisText in arguments.texts ) {
			var status = super.bean( "Status" );
			thisText.setStatus( status.setId( "TRA" ) );
			var newId = getDao().insert( thisText );
			done.append( thisText.getKind().getId() & "|" & thisText.getLang().getId() );
			ids.append( newId );
		}

		// Per ogni kind e lingua, se manca, crea placeholder
		for ( var kindId in kinds ) {
			for ( var langBean in langs ) {
				var key = kindId & "|" & langBean.getId();
				if ( !ArrayFind( done, key ) ) {
					var text   = super.bean( "Text" );
					var lang   = super.bean( "Lang" );
					var status = super.bean( "Status" );
					var kind   = super.bean( "TextKind" );

					text.setName( "** To translate" );
					lang.setId( langBean.getId() );
					status.setId( "TOT" );
					kind.setId( kindId );

					text.setStatus( status );
					text.setLang( lang );
					text.setEntity( entity );
					text.setKind( kind );

					var newId = getDao().insert( text );
					ids.append( newId );
				}
			}
		}

		return ids;
	}

	public Numeric function update( required com.apirone.core.model.bean.Text text ){
		var id = getDao().update( arguments.text );

		return id;
	}

	/**
	 * @private
	 */

	private com.apirone.core.model.bean.Entity function getEntity( required record ){
		var entity = super.bean( "Entity" );

		if ( Len( record.attribute_id ) ) {
			entity.setKey( "attribute.id" );
			entity.setValue( record.attribute_id.toString() );

			return entity;
		}

		if ( Len( record.raw_value_id ) ) {
			entity.setKey( "rawValue.id" );
			entity.setValue( record.raw_value_id.toString() );

			return entity;
		}

		if ( Len( record.finish_id ) ) {
			entity.setKey( "finish.id" );
			entity.setValue( record.finish_id.toString() );

			return entity;
		}

		if ( Len( record.model_id ) ) {
			entity.setKey( "model.id" );
			entity.setValue( record.model_id.toString() );

			return entity;
		}

		if ( Len( record.product_category_id ) ) {
			entity.setKey( "productCategory.id" );
			entity.setValue( record.product_category_id.toString() );

			return entity;
		}

		if ( Len( record.product_id ) ) {
			entity.setKey( "product.id" );
			entity.setValue( record.product_id.toString() );

			return entity;
		}

		if ( Len( record.line_id ) ) {
			entity.setKey( "line.id" );
			entity.setValue( record.line_id.toString() );

			return entity;
		}

		if ( Len( record.font_id ) ) {
			entity.setKey( "font.id" );
			entity.setValue( record.font_id.toString() );

			return entity;
		}

		if ( Len( record.country_id ) ) {
			entity.setKey( "country.id" );
			entity.setValue( record.country_id.toString() );

			return entity;
		}

		if ( Len( record.article_id ) ) {
			entity.setKey( "article.id" );
			entity.setValue( record.article_id.toString() );

			return entity;
		}

		/*
		if( record.text_id == 1782 ) {
			dump( entity );
			abort;
		}
		*/

		getLogger().error( "No entity linked to this translation. Text Id: [#record.text_id#]" );

		return entity;

	}

	private com.apirone.core.model.bean.Text function build( required String textId ){
		var record = getDao().read( textId = arguments.textId );

		if ( record.RecordCount ) {
			return buildFromResultRow( record );
		}

		return NullValue();
	}

	/**
	 * Recupera in batch tutti i testi collegati a una lista di entity.
	 * Restituisce uno Struct chiave = entityValue, valore = Array di bean Text.
	 *
	 * @entityKey Chiave entità (es. "product.id", "finish.id")
	 * @entityValues Array di valori entità
	 * @return Struct mappato per entityValue -> Array di Text
	 */
	public Struct function listByEntityIds(
		required String entityKey,
		required Array entityValues
	) {
		var records = getDao().findByEntityIds(
			entityKey    = arguments.entityKey,
			entityValues = arguments.entityValues
		);
		var map = {};

		// Raggruppa i risultati della query per entityValue
		for ( var record in records ) {
			var entityValue = record[ getEntityValueColumn( arguments.entityKey ) ];
			if ( !StructKeyExists( map, entityValue ) ) {
				map[ entityValue ] = [];
			}
			var bean = buildFromResultRow( record );
			ArrayAppend( map[ entityValue ], bean );
		}

		return map;
	}

	/**
	 * Costruisce un bean Text a partire da una riga della query, senza chiamata DB aggiuntiva.
	 * Utilizzato da listByEntityIds() per assemblare i bean in batch.
	 */
	private com.apirone.core.model.bean.Text function buildFromResultRow( required any record ){
		var bean = super.bean( "Text" );

		// Campi diretti dal record
		bean.setId( record.text_id );
		bean.setName( record.text );

		// Entity collegate (caricate singolarmente)
		bean.setLang( getLangService().get( record.lang_id ) );
		bean.setStatus( getStatusService().get( record.status_id ) );
		bean.setEntity( getEntity( record ) );
		bean.setKind( getLookupService().get( "textKind", record.text_kind_id ) );

		return bean;
	}

	/**
	 * Restituisce il nome della colonna DB corrispondente alla entityKey.
	 */
	private String function getEntityValueColumn( required String entityKey ){
		var field = super.getDBField( arguments.entityKey );
		return field.name;
	}

}
