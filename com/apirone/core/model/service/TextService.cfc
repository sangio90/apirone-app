component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="TextDAO";
	property name="langService" inject="LangService";
	property name="statusService" inject="StatusService";
	property name="lookupService" inject="LookupService";
	// property name="textKindService" inject="TextKindService";

	property name="cacheScope" type="String" default="Text.bean";

	public com.apirone.core.model.bean.Text function get( required String textId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.textId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.textId );

		cm.put( getCacheScope(), arguments.textId, bean );

		return bean;
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
		Numeric ProductCategoryId,
		String countryId,
		String langId,
		String productId,
		String finishId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "lang.orderBy", dir = "asc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( textId = record.text_id ) );
		} );

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

		getCacheManager().remove( getCacheScope(), id );

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
			entity.setValue( record.raw_value_id );

			return entity;
		}

		if ( Len( record.finish_id ) ) {
			entity.setKey( "finish.id" );
			entity.setValue( record.finish_id );

			return entity;
		}

		if ( Len( record.model_id ) ) {
			entity.setKey( "model.id" );
			entity.setValue( record.model_id );

			return entity;
		}

		if ( Len( record.product_category_id ) ) {
			entity.setKey( "productCategory.id" );
			entity.setValue( record.product_category_id );

			return entity;
		}

		if ( Len( record.product_id ) ) {
			entity.setKey( "product.id" );
			entity.setValue( record.product_id );

			return entity;
		}

		if ( Len( record.line_id ) ) {
			entity.setKey( "line.id" );
			entity.setValue( record.line_id );

			return entity;
		}

		if ( Len( record.font_id ) ) {
			entity.setKey( "font.id" );
			entity.setValue( record.font_id );

			return entity;
		}

		if ( Len( record.country_id ) ) {
			entity.setKey( "country.id" );
			entity.setValue( record.country_id );

			return entity;
		}

		getLogger().error( "No entity linked to this translation. Text Id: [#record.text_id#]" );

		/*
		dump( record );
		abort;


		Throw(
			type    = "apirone.error.textWithoutEntity",
			message = "No entity linked to this translation. Text Id: [#record.text_id#]"
		);
		*/
	}

	private com.apirone.core.model.bean.Text function build( required String textId ){
		var record = getDao().read( textId = arguments.textId );

		if ( record.RecordCount ) {
			var bean = super.bean( "Text" );

			bean.setId( record.text_id );
			bean.setName( record.text );
			bean.setLang( getLangService().get( record.lang_id ) );
			bean.setStatus( getStatusService().get( record.status_id ) );
			bean.setEntity( getEntity( record ) );

			bean.setKind( getLookupService().get( "textKind", record.text_kind_id ) );

			return bean;
		}

		return NullValue();
	}

}
