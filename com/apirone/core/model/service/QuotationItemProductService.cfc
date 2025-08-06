component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemProductDAO";
	property name="QuotationItemService" inject="QuotationItemService";
	property name="ProductService" inject="ProductService";
	property name="QuotationItemProductService" inject="QuotationItemProductService";
	property name="cacheScope" type="String" default="QuotationItemProduct.bean";

	public com.apirone.core.model.bean.QuotationItemProduct function get( required String productId ){
		var cm    = getCacheManager();
		var cache = cm.get( getCacheScope(), arguments.productId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.productId );
		cm.put( getCacheScope(), arguments.productId, bean );

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		required Numeric limit  = 15,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "quotationItemProduct.id" } ]
	){
		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var rows    = [];
		var result  = super.getResult();
		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( productId = record.quotation_item_product_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String productId ){
		var outcome = super.bean( "Outcome" );
		var obj     = get( arguments.productId );

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
				outcome.setType( "ApirOne.CannotDeleteQuotationItemProduct" );
				outcome.setMessage( "Cannot delete product [#arguments.productId#]" );
			}
		}

		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.QuotationItemProduct product ){
		var newId = getDao().insert( arguments.product );

		transaction {
			for ( var text in arguments.product.getTexts() ) {
				var entity = super.bean( "Entity" );

				entity.setKey( "quotationItemProduct.id" );
				entity.setValue( newId );

				text.setEntity( entity );
			}

			getTextService().bulkCreate( arguments.product.getTexts() );
		}

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.QuotationItemProduct product ){
		getDao().update( arguments.product );

		var id = arguments.line.getId();

		for ( var text in arguments.product.getTexts() ) {
			var entity = super.bean( "Entity" )

			entity.setKey( "quotationItemProduct.id" );
			entity.setValue( id );

			text.setEntity( entity );

			if ( Len( text.getId() ) ) {
				getTextService().update( text );
			} else {
				getTextService().create( text );
			}
		}

		super.getCacheManager().remove( getCacheScope(), arguments.product.getId() );
		return arguments.product.getId();
	}

	private com.apirone.core.model.bean.QuotationItemProduct function build( required String productId ){
		var record = getDao().read( arguments.productId );
		if ( record.recordCount ) {
			var bean = super.bean( "QuotationItemProduct" );
			bean.setId( record.quotation_item_product_id );
			bean.setQuotationItem( getQuotationItemService().get( record.quotation_item_id ) );
			bean.setProduct( getProductService().get( record.product_id ) );

			bean.setParent(
				IsNull( record.parent_id ) ? NullValue() : getQuotationItemProductService().get( record.parent_id )
			);
			bean.setTexts( getTextService().list( productId = record.quotation_item_product_id ) );
			return bean;
		}
		return NullValue();
	}

}
