component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ArticleDAO";
	property name="statusService" inject="StatusService";
	property name="lookupService" inject="LookupService";
	property name="textService" inject="TextService";
	property name="priceService" inject="PriceService";

	property name="cacheScope" type="String" default="Article.bean";

	public com.apirone.core.model.bean.Article function get( required String articleId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.articleId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.articleId );
		cm.put( getCacheScope(), arguments.articleId, bean );

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		String typeId,
		String statusId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "article.code", desc = "asc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( articleId = record.article_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );



		return result;
	}

	public String function create( required com.apirone.core.model.bean.Article article ){
		transaction {

			var newId = getDao().insert( arguments.article );

			for ( var text in arguments.article.getTexts() ) {
				var entity = super.bean( "Entity" );

				entity.setKey( "price.id" );
				entity.setValue( newId );

				text.setEntity( entity );
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

	public String function update( required com.apirone.core.model.bean.Article line ){
		getDao().update( arguments.line );

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

			var entity = super.bean( "Entity" );
			var price = arguments.article.getPrice();
			
			price.setEntity( entity.setKey( "article.id" ) );
			price.setEntity( entity.setValue( newId ) );

			savePrice( price );			
		}

		super.logEvent(
			event   = "article.updated",
			message = "Article [#arguments.article.getId()#] updated",
			payload = { "id" = arguments.article.getId() }
		);

		super.getCacheManager().remove( getCacheScope(), arguments.article.getId() );

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

				getCacheManager().remove( getCacheScope(), arguments.articleId );

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

	public Void function removeCache( required String articleId ){
		var cm = super.getCacheManager();

		cm.remove( getCacheScope(), arguments.articleId );
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
			var bean = super.bean( "Article" );

			bean.setTexts( getTextService().list( articleId = record.article_id ) );

			bean.setName( bean.getName() );
			
			bean.setId( record.article_id );
			bean.setCode( record.code );
			bean.setExternalId( record.external_id );

			var prices = getPriceService().list( articleId = record.article_id );
			bean.setPrice( prices.len() ? prices[1] : NullValue() );
			
			bean.setCreatedAt( record.created_at );
			
			bean.setStatus( getStatusService().get( record.status_id ) );
			bean.setType( getLookupService().get( "articleType", record.type_id ) );

			return bean;
		}

		return NullValue();
	}

}
