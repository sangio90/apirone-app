component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ProductCategoryLineDAO";
	property name="lineService" inject="lineService";
	property name="productCategoryService" inject="productCategoryService";

	property name="cacheScope" type="String" default="ProductCategoryLine.bean";

	public com.apirone.core.model.bean.ProductCategoryLine function get( required String ProductCategoryLineId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.ProductCategoryLineId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.ProductCategoryLineId );
		cm.put(
			getCacheScope(),
			arguments.ProductCategoryLineId,
			bean
		);

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}


	public com.apirone.core.model.bean.Result function search(
		String categoryId,
		String lineId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "productCategoryLine.id", desc = "asc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( productCategoryLineId = record.product_category_line_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public Numeric function create( required com.apirone.core.model.bean.ProductCategoryLine productCategoryLine ){
		transaction {
			getDao().deleteByParams(
				lineId            = productCategoryLine.getLine().getId(),
				productCategoryId = productCategoryLine.getProductCategory().getId()
			);
			var newId = getDao().insert( arguments.productCategoryLine );
		}

		super.getCacheManager().remove( getCacheScope(), arguments.productCategoryLine.getId() );

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.ProductCategoryLine productCategoryLine ){
		getDao().update( arguments.productCategoryLine );

		super.getCacheManager().remove( getCacheScope(), arguments.productCategoryLine.getId() );

		return arguments.productCategoryLine.getId();
	}

	public com.apirone.core.model.bean.Outcome function delete( required String productCategoryLineId ){
		var outcome = super.bean( "Outcome" );

		outcome.setData( { productCategoryLineId = arguments.productCategoryLineId } );

		transaction {
			try {
				var result = getDao().delete( arguments.productCategoryLineId );
				outcome.setData( { "deletedCount" = result } )

				getCacheManager().remove( getCacheScope(), arguments.productCategoryLineId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.errors.CannotDeleteProductCategoryLine" );
				outcome.setMessage( "Cannot delete productCategoryLine id [#arguments.productCategoryLineId#]" );
			}
		}

		return outcome;
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.ProductCategoryLine function build( required String productCategoryLineId ){
		var record = getDao().read( arguments.productCategoryLineId );

		if ( record.recordCount ) {
			var bean = super.bean( "ProductCategoryLine" );

			bean.setId( record.product_category_line_id );
			bean.setCreatedAt( record.created_at );
			bean.setMarkup( record.markup );

			bean.setLine( getLineService().get( record.line_id ) );
			bean.setProductCategory( getProductCategoryService().get( record.product_category_id ) );

			return bean;
		}

		return NullValue();
	}

}
