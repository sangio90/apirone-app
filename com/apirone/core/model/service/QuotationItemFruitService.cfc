component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemFruitDAO";
	property name="productService" inject="ProductService";
	property name="quotationItemProductItemService" inject="QuotationItemProductItemService";
	property name="cacheScope" type="String" default="QuotationItemFruit.bean";

	public com.apirone.core.model.bean.QuotationItemFruit function get( required Numeric quotationItemFruitId ){
		var cm    = getCacheManager();
		var cache = cm.get( getCacheScope(), arguments.quotationItemFruitId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.quotationItemFruitId );

		cm.put(
			getCacheScope(),
			arguments.quotationItemFruitId,
			bean
		);

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
		required Array orderBy  = [ { field = "quotationItemFruit.id" } ]
	){
		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var rows    = [];
		var result  = super.getResult();
		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( record.quotation_item_fruit_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required Numeric quotationItemFruitId ){
		var outcome = super.bean( "Outcome" );

		outcome.setData( { quotationItemFruitId = arguments.quotationItemFruitId } );
		getDao().delete( arguments.quotationItemFruitId );

		transaction {
			try {
				var cm = getCacheManager();
				getDao().delete( arguments.quotationItemFruitId );
				cm.remove( getCacheScope(), arguments.quotationItemFruitId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.error.CannotDeleteQuotationItemFruit" );
				outcome.setMessage( "Cannot delete quotation item fruit [#arguments.quotationItemFruitId#]" );
			}
		}

		return outcome;
	}

	public Numeric function create( required quotationItemFruit ){
		var newId = getDao().insert( arguments.quotationItemFruit );

		return newId;
	}

	public Numeric function update( required com.apirone.core.model.bean.QuotationItemFruit quotationItemFruit ){
		getDao().update( arguments.quotationItemFruit );
		super.getCacheManager().remove( getCacheScope(), arguments.quotationItemFruit.getId() );

		return arguments.quotationItemFruit.getId();
	}

	private com.apirone.core.model.bean.QuotationItemFruit function build( required Numeric quotationItemFruitId ){
		var record = getDao().read( arguments.quotationItemFruitId );

		if ( record.recordCount ) {
			var bean = super.bean( "quotationItemFruit" );

			bean.setId( record.quotation_item_fruit_id );
			bean.setPosition( record.position );
			bean.setFruit( getProductService().get( record.fruit_id ) );

			var items = getQuotationItemProductItemService().list( quotationItemFruitId = quotationItemFruitId );

			if ( Len( items ) ) {
				bean.setItems( items );
			}

			bean.setNote( record.note );

			return bean;
		}

		return NullValue();
	}

}
