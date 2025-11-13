component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ProductDAO";
	property name="ModelService" inject="ModelService";
	property name="LineService" inject="LineService";
	property name="FinishService" inject="FinishService";
	property name="StatusService" inject="StatusService";
	property name="ProductCategoryService" inject="ProductCategoryService";
	property name="CatalogBundleService" inject="CatalogBundleService";
	property name="PriceService" inject="PriceService";
	property name="TextService" inject="TextService";
	property name="FileService" inject="FileService";
	property name="ProductItemService" inject="ProductItemService";

	property name="cacheScope" type="String" default="Product.bean";

	public com.apirone.core.model.bean.Product function get( required String productId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.productId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.productId );
		cm.put( getCacheScope(), arguments.productId, bean );

		return bean;
	}

	public com.apirone.core.model.bean.Product function getByParams(
		required String lineId,
		required String finishId,
		required String modelId
	){
		var record = getDao().find( argumentCollection = arguments );

		if ( record.recordcount == 1 ) {
			return get( record.product_id );
		}

		return NullValue();
	}

	public Array function list(){
		// TODO: check formatter
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public Boolean function codeExists( required String code, String excludedId = "" ){
		var record = getDao().readByCode( arguments.code );

		if (
			record.recordCount
			&& record.product_id != arguments.excludedId
		) {
			return record.code == arguments.code;
		}

		return false;
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		String lineId,
		Array excludedCategoryIds = [],
		required Numeric limit    = 15,
		required Numeric offset   = 0,
		required Array orderBy    = [ { field = "product.id" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( productId = record.Product_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String productId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.productId );

		outcome.setData( { productId = arguments.productId } );
		getDao().delete( arguments.productId );

		transaction {
			try {
				var cm = getCacheManager();

				getDao().delete( arguments.productId );

				cm.remove( getCacheScope(), arguments.productId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteProduct" );
				outcome.setMessage( "Cannot delete product [#arguments.productId#]" );
			}
		}

		return outcome;
	}

	public com.apirone.core.model.bean.Outcome function deleteByParams(
		required String lineId,
		required String finishId,
		required String modelId
	){
		var outcome = super.bean( "Outcome" );

		var obj = getByParams( argumentCollection = arguments );

		var productId = obj.getId()

		outcome.setData( { productId = productId } );

		transaction {
			try {
				var cm = getCacheManager();

				getDao().delete( obj.getId() );

				cm.remove( getCacheScope(), arguments.obj.getId() );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.error.CannotDeleteProduct" );
				outcome.setMessage( "Cannot delete product [#productId#]" );
			}
		}


		return outcome;
	}

	public com.apirone.core.model.bean.Outcome function deleteAllByParams(
		required String lineId,
		required String categoryId
	){
		var outcome = super.bean( "Outcome" );

		outcome.setData( arguments );

		transaction {
			// try {
			getDao().deleteAllByParams( lineId = arguments.lineId, categoryId = arguments.categoryId );
			/*
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteProduct" );
				outcome.setMessage( "Cannot delete product by lineId [#arguments.lineId#] and categoryId [#arguments.categoryId#]" );
			}
				*/
		}

		getCacheManager().removeAll();

		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.Product product ){
		var product = this.handleCatalogBundle( arguments.product );

		var newId = getDao().insert( product );

		if ( !IsNull( product.getTexts() ) AND product.getTexts().len() ) {
			transaction {
				for ( var text in product.getTexts() ) {
					var entity = super.bean( "Entity" );
					entity.setKey( "product.id" );
					entity.setValue( newId );
					text.setEntity( entity );
				}
				getTextService().bulkCreate( product.getTexts() );
			}
		}

		return newId;
	}

	public String function updateDetail( required com.apirone.core.model.bean.Product product ){

		getDao().updateDetail( product );

		super.getCacheManager().remove( getCacheScope(), product.getId() );

		return product.getId();
	}

	public Boolean function updateImportants( required com.apirone.core.model.bean.Product product,  required Numeric[] ids ){

		var itemService = getProductItemService();

		```
		<cfquery datasource="apirone">
			UPDATE product_items
			SET important = false
			WHERE product_id = '#product.getId()#'
		</cfquery>
		```

		var allItems = itemService.getFlatTree( productId = product.getId() );

		for( var item in allItems ) {
			if ( ArrayContains( ids, item.getId() ) ) {

				var value = true;

				//item.setImportant( true );
			} else {
				var value = false;
			}

			```
			<cfquery datasource="apirone">
				UPDATE product_items
				SET important = #value#
				WHERE product_item_id = '#item.getId()#'
			</cfquery>
			```

			itemService.removeCache( item.getId() );

		}


		return true;
	}	


	public Void function removeCache( required String productId ){
		var cm = super.getCacheManager();

		cm.remove( getCacheScope(), arguments.productId );
	}


	/*
    	private method
	*/

	// normalize data  for catalogBundle
	private com.apirone.core.model.bean.Product function handleCatalogBundle(
		required com.apirone.core.model.bean.Product product
	){
		if ( IsInstanceOf( product, "com.apirone.core.model.bean.ProductComplex" ) ) {
			var bundle = super.bean( "CatalogBundle" );
			bundle.setLine( product.getLine() );
			bundle.setModel( product.getModel() );
			bundle.setCategory( product.getCategory() );

			var catalogBundle = getCatalogBundleService().getOrCreate( bundle );
			product.setCatalogBundle( catalogBundle );
		}

		return product;
	}

	private com.apirone.core.model.bean.Product function build( required String productId ){
		var record = getDao().read( arguments.productId );

		if ( record.recordCount ) {

			if ( IsNull( record.catalog_bundle_id ) ) {
				var bean = super.bean( "ProductBase" );
				
				bean.setCode( record.code );
				bean.setCategory( getProductCategoryService().get( record.product_category_id ) );
				bean.setPositionCount( record.position_count );
				var lines = super.getLinesBeanByIds( record.lines );
				bean.setLines( lines );
			
			} else {
				
				var bean = super.bean( "ProductComplex" );
				bean.setCatalogBundle( getCatalogBundleService().get( record.catalog_bundle_id ) );

				bean.setLine( bean.getCatalogBundle().getLine() );
				bean.setModel( bean.getCatalogBundle().getModel() );
				bean.setCategory( bean.getCatalogBundle().getCategory() );
				bean.setFinish( getFinishService().get(  record.finish_id ) );

			}

			bean.setId( record.product_id );
			bean.setSerial( record.serial );
			bean.setCreatedAt( record.created_at );
			bean.setStatus( getStatusService().get( record.status_id ) );
			bean.setSpecial( BooleanFormat( record.special ) );
			bean.setMinQuantity( record.min_quantity );
			bean.setMaxQuantity( record.max_quantity );
			bean.setTexts( getTextService().list( productId = record.product_id ) );

			bean.setPrices( getPriceService().list( productId = record.product_id ) );
			var images = getFileService().list( productId = record.product_id );

			if ( Len( images ) ) {
				bean.setImages( images )
			}

			return bean;
		}

		return NullValue();
	}

}
