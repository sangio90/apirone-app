component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ArticleDAO";
	property name="statusService" inject="StatusService";
	property name="lookupService" inject="LookupService";
	property name="textService" inject="TextService";
	property name="priceService" inject="PriceService";

	public com.apirone.core.model.bean.Article function get( required String articleId ){
		return build( arguments.articleId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		String statusId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "article.code", desc = "asc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids = [];
		records.each( function( r ){
			ids.append( r.article_id );
		} );

		var beanMap = {};
		if ( ArrayLen( ids ) ) {
			var allRecords = getDao().readByIds( ids );

			allRecords.each( function( r ){
				beanMap[ r.article_id ] = buildFromRow( r );
			} );
		}

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.article_id ] );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public String function create( required com.apirone.core.model.bean.Article article ){
		transaction {

			var newId = getDao().insert( arguments.article );

			for( var text in arguments.article.getTexts() ) {
				var entity = super.bean( "Entity" )

				entity.setKey( "article.id" );
				entity.setValue( newId );

				text.setEntity( entity );

				getTextService().create( text );
			}

			var entity = super.bean( "Entity" );
			var price = arguments.article.getPrice();

			price.setEntity( entity.setKey( "article.id" ) );
			price.setEntity( entity.setValue( newId ) );

			savePrice( price );

		}

		super.logEvent(
			event   = "article.created",
			message = "Article [#newId#] created",
			payload = { "id" = newId }
		);

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.Article article ){
		getDao().update( arguments.article );

		var id = arguments.article.getId();

		for ( var text in arguments.article.getTexts() ) {
			var entity = super.bean( "Entity" )

			entity.setKey( "article.id" );
			entity.setValue( id );

			text.setEntity( entity );

			if ( Len( text.getId() ) ) {
				getTextService().update( text );
			} else {
				getTextService().create( text );
			}

		}

		var entity = super.bean( "Entity" );
		var price = arguments.article.getPrice();

		price.setEntity( entity.setKey( "article.id" ) );
		price.setEntity( entity.setValue( id ) );

		savePrice( price );

		super.logEvent(
			event   = "article.updated",
			message = "Article [#arguments.article.getId()#] updated",
			payload = { "id" = arguments.article.getId() }
		);

		return arguments.article.getId();
	}

	public Boolean function codeExists( required String code, String excludedId = "" ){
		var record = getDao().readByCode( arguments.code );

		if (
			record.recordCount
			&& record.article_id != arguments.excludedId
		) {
			return record.code == arguments.code;
		}

		return false;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String articleId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.articleId );

		outcome.setData( { articleId = arguments.articleId } );

		transaction {
			try {
				var result = getDao().delete( arguments.articleId );
				outcome.setData( { "deletedCount" = result } )

				// super.logAction( type = "article.DELETED", message = "Article [#arguments.articleId#] deleted" );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteArticle" );
				outcome.setMessage( "Cannot delete line [#arguments.articleId#]" );
			}
		}

		super.logEvent(
			event   = "article.deleted",
			message = "Article [#arguments.articleId#] deleted",
			payload = { "id" = arguments.articleId }
		);

		return outcome;
	}

	/*
    	private method
	*/

	public Numeric  function savePrice( required com.apirone.core.model.bean.Price price ){

		var type =  super.bean( "PriceType" );
		var method =  super.bean( "PriceMethod" );

		price.setType( type.setId( "SERVICE_PRICE" ) );
		price.setMethod( method.setId( "F" ) );

		if ( !Len( price.getId() ) ) {
			var thisId = getPriceService().create( price );
		} else {
			var thisId = getPriceService().update( price );
		}

		return thisId;
	}

	private com.apirone.core.model.bean.Article function build( required String articleId ){
		var record = getDao().read( arguments.articleId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean Article a partire da una riga della query.
	 * Le sub-entity (Texts, Price, Status) sono caricate con chiamate individuali.
	 */
	private com.apirone.core.model.bean.Article function buildFromRow( required Struct record ){
		var bean = super.bean( "Article" );

		// Testi e nome (setName va chiamato dopo setTexts)
		bean.setTexts( getTextService().list( articleId = arguments.record.article_id ) );
		bean.setName( bean.getName() );

		// Campi diretti dal record
		bean.setId( arguments.record.article_id );
		bean.setCode( arguments.record.code );
		bean.setExternalId( arguments.record.external_id );
		bean.setCreatedAt( arguments.record.created_at );

		// Sub-entity (caricate singolarmente)
		var prices = getPriceService().list( articleId = arguments.record.article_id );
		bean.setPrice( prices.len() ? prices[ 1 ] : NullValue() );
		bean.setStatus( getStatusService().get( arguments.record.status_id ) );

		return bean;
	}

}
