component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ProductCategoryDAO";
	property name="statusService" inject="StatusService";
	property name="textService" inject="TextService";
	property name="lookupService" inject="LookupService";
	property name="productCategoryTypeService" inject="ProductCategoryTypeService";

	property name="cacheScope" type="String" default="ProductCategory.bean";

	public com.apirone.core.model.bean.ProductCategory function get( required String productCategoryId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.productCategoryId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.productCategoryId );

		cm.put(
			getCacheScope(),
			arguments.productCategoryId,
			bean
		);

		return bean;
	}

	public Array function list(
		String str,
		String rawProductId,
		required Array orderBy = [ { field = "ProductCategory.code" } ]
	){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		String lineId,
		String modeId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "productCategory.id" } ]
	){
		var rows = [];

		var result = super.getResult()

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		for ( var record in records ) {
			rows.add( get( productCategoryId = record.product_category_id ) );
		}

		result.setTotal( records.total );
		result.setCount( records.recordCount() );
		result.setData( rows );

		return result;
	}

	public String function create( required com.apirone.core.model.bean.ProductCategory ProductCategory ){
		if ( !Len( arguments.ProductCategory.getCode() ) ) {
			Throw( type = "apirone.errors.codeNotProvided", message = "Code required" );
		};

		if ( !Len( arguments.ProductCategory.getTexts() ) ) {
			Throw( type = "apirone.errors.noTexsProvided", message = "At least one description required" );
		};

		transaction {
			var newId = getDao().insert( arguments.ProductCategory );

			for ( var text in arguments.ProductCategory.getTexts() ) {
				var entity = super.bean( "Entity" );

				entity.setKey( "ProductCategory.id" );
				entity.setValue( newId );

				text.setEntity( entity );
			}

			getTextService().bulkCreate( arguments.ProductCategory.getTexts() );
		}

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.ProductCategory ProductCategory ){
		if ( !Len( arguments.ProductCategory.getCode() ) ) {
			Throw( type = "apirone.errors.codeNotProvided", message = "Code required" );
		};

		if ( !Len( arguments.ProductCategory.getTexts() ) ) {
			Throw( type = "apirone.errors.noTexsProvided", message = "At least one description required" );
		};

		var cm = getCacheManager();

		var id = getDao().update( arguments.ProductCategory );

		for ( var text in arguments.ProductCategory.getTexts() ) {
			var entity = super.bean( "Entity" );

			entity.setKey( "ProductCategory.id" );
			entity.setValue( id );

			text.setEntity( entity );

			getTextService().update( text );
		}

		cm.remove( getCacheScope(), arguments.ProductCategory.getId() );

		return id;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String productCategoryId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.productCategoryId );

		outcome.setData( { productCategoryId = arguments.productCategoryId } );

		transaction {
			try {
				var result = getDao().delete( arguments.productCategoryId );
				outcome.setData( { "deletedCount" = result } )

				getCacheManager().remove( getCacheScope(), arguments.productCategoryId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteProductCategory" );
				outcome.setMessage( "Cannot delete product category [#arguments.productCategoryId#]" );
			}
		}

		return outcome;
	}

	public Boolean function codeExists( required String code, String excludedId = "" ){
		var record = getDao().readByCode( arguments.code );

		if (
			record.recordCount
			&& record.product_category_id != arguments.excludedId
		) {
			return record.code == arguments.code;
		}

		return false;
	}


	/*
    	private methods
	*/

	private com.apirone.core.model.bean.ProductCategory function build( required String ProductCategoryId ){
		var record = getDao().read( arguments.ProductCategoryId );

		if ( record.RecordCount ) {
			var bean = super.bean( "ProductCategory" );

			var texts = getTextService().list( productCategoryId = record.product_category_id );
			bean.setTexts( texts );

			// after setTexts()
			bean.setName( bean.getName() );

			bean.setId( record.product_category_id );
			bean.setCode( record.code );
			bean.setStatus( getStatusService().get( record.status_id ) );

			bean.setCreatedAt( record.created_at );

			bean.setType(
				getProductCategoryTypeService().get( productCategoryTypeId = record.product_category_type_id )
			);

			bean.setMode( getLookupService().get( "ProductCategoryMode", record.mode_id ) );


			return bean;
		}

		return NullValue();
	}

}
