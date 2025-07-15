component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.ProductDAO";
	property name="SizeService" type="com.apirone.core.model.service.SizeService";
	property name="LineService" type="com.apirone.core.model.service.LineService";
	property name="FinishService" type="com.apirone.core.model.service.FinishService";
	property name="StatusService" type="com.apirone.core.model.service.StatusService";
	property name="ProductCategoryService" type="com.apirone.core.model.service.ProductCategoryService";
	property name="TextService" type="com.apirone.core.model.service.TextService";
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
		required String sizeId
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
		required Array orderBy    = [ { field = "category.name" } ]
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
		result.setTotal( Val( records.recordcount ) );

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
		required String sizeId
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
				outcome.setType( "ApirOne.CannotDeleteProduct" );
				outcome.setMessage( "Cannot delete product [#productId#]" );
			}
		}

		return outcome;
	}


	public String function create( required com.apirone.core.model.bean.Product product ){
		var newId = getDao().insert( arguments.product );

		if ( !IsNull( arguments.product.getTexts() ) ) {
			transaction {
				for ( var text in arguments.product.getTexts() ) {
					var entity = super.bean( "Entity" );

					entity.setKey( "product.id" );
					entity.setValue( newId );

					text.setEntity( entity );
				}

				getTextService().bulkCreate( arguments.product.getTexts() );
			}
		}

		return newId;
	}


	public String function update( required com.apirone.core.model.bean.Product product ){
		getDao().update( arguments.product );

		var id = arguments.product.getId();

		if ( !IsNull( arguments.product.getTexts() ) ) {
			for ( var text in arguments.product.getTexts() ) {
				var entity = super.bean( "Entity" )

				entity.setKey( "product.id" );
				entity.setValue( id );

				text.setEntity( entity );

				if ( Len( text.getId() ) ) {
					getTextService().update( text );
				} else {
					getTextService().create( text );
				}
			}
		}

		super.getCacheManager().remove( getCacheScope(), arguments.product.getId() );

		return arguments.product.getId();
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.Product function build( required String productId ){
		var record = getDao().read( arguments.productId );

		if ( record.recordCount ) {
			var bean = super.bean( "Product" );

			bean.setId( record.product_id );
			bean.setName( "" );
			bean.setCreatedAt( record.created_at );
			bean.setCode( record.code );
			bean.setPositionCount( record.position_count );

			bean.setSize( !IsNull( record.size_id ) ? getSizeService().get( record.size_id ) : NullValue() );
			bean.setLine( !IsNull( record.line_id ) ? getLineService().get( record.line_id ) : NullValue() );
			bean.setFinish(
				!IsNull( record.finish_id ) ? getFinishService().get( record.finish_id ) : NullValue()
			);
			bean.setStatus( getStatusService().get( record.status_id ) );

			bean.setCategory( getProductCategoryService().get( record.product_category_id ) );
			bean.setTexts( getTextService().list( productId = record.product_id ) );

			return bean;
		}

		return NullValue();
	}

}
