component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemProductItemDAO";
	property name="QuotationItemProductService" inject="QuotationItemProductService";
	property name="QuotationItemProductItemService" inject="QuotationItemProductItemService";
	property name="ProductItemService" inject="ProductItemService";
	property name="cacheScope" type="String" default="QuotationItemProductItem.bean";

	public com.apirone.core.model.bean.QuotationItemProductItem function get( required String productItemId ){
		var cm    = getCacheManager();
		var cache = cm.get( getCacheScope(), arguments.productItemId );
		if ( cache.status ) {
			return cache.data;
		}
		var bean = build( arguments.productItemId );
		cm.put( getCacheScope(), arguments.productItemId, bean );
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
		required Array orderBy  = [ { field = "quotationItemProductItem.id" } ]
	){
		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var rows    = [];
		var result  = super.getResult();
		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( productItemId = record.quotation_item_product_item_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String productItemId ){
		var outcome = super.bean( "Outcome" );
		var obj     = get( arguments.productItemId );

		outcome.setData( { productItemId = arguments.productItemId } );
		getDao().delete( arguments.productItemId );

		transaction {
			try {
				var cm = getCacheManager();
				getDao().delete( arguments.productItemId );
				cm.remove( getCacheScope(), arguments.productItemId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteQuotationItemProductItem" );
				outcome.setMessage( "Cannot delete product item [#arguments.productItemId#]" );
			}
		}

		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.QuotationItemProductItem productItem ){
		var newId = getDao().insert( arguments.productItem );

		transaction {
			for ( var text in arguments.productItem.getTexts() ) {
				var entity = super.bean( "Entity" );

				entity.setKey( "quotationItemProductItem.id" );
				entity.setValue( newId );

				text.setEntity( entity );
			}

			getTextService().bulkCreate( arguments.productItem.getTexts() );
		}

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.QuotationItemProductItem productItem ){
		getDao().update( arguments.productItem );

		var id = arguments.line.getId();

		for ( var text in arguments.productItem.getTexts() ) {
			var entity = super.bean( "Entity" )

			entity.setKey( "quotationItemProductItem.id" );
			entity.setValue( id );

			text.setEntity( entity );

			if ( Len( text.getId() ) ) {
				getTextService().update( text );
			} else {
				getTextService().create( text );
			}
		}

		super.getCacheManager().remove( getCacheScope(), arguments.productItem.getId() );
		return arguments.productItem.getId();
	}

	private com.apirone.core.model.bean.QuotationItemProductItem function build( required String productItemId ){
		var record = getDao().read( arguments.productItemId );
		if ( record.recordCount ) {
			var bean = super.bean( "QuotationItemProductItem" );
			bean.setId( record.quotation_item_product_item_id );
			bean.setQuotationItemProduct(
				getQuotationItemProductService().get( record.quotation_item_product_id )
			);
			bean.setProductItem( getProductItemService().get( record.product_item_id ) );

			bean.setParent(
				IsNull( record.parent_id ) ? NullValue() : getQuotationItemProductItemService().get(
					record.parent_id
				)
			);
			bean.setTexts( getTextService().list( productItemId = record.quotation_item_product_item_id ) );
			return bean;
		}
		return NullValue();
	}

}
