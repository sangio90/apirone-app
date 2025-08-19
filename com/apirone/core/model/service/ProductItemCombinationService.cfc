component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ProductItemProductDAO";
	property name="statusService" inject="StatusService";
	property name="productItemService" inject="ProductItemService";

	property name="cacheScope" type="String" default="ProductItemProduct.bean";

	public com.apirone.core.model.bean.ProductItemProduct function get( required String productItemProductId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.productItemProductId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.productItemProductId );
		cm.put(
			getCacheScope(),
			arguments.productItemProductId,
			bean
		);

		return bean;
	}

	private Array function convertTree( required Array items ){
		var result = [];

		for ( thisItem in items ) {
			var row = super.getDataMapper().convert( thisItem, "ProductItemTree", true );

			if ( !IsNull( thisItem?.getChildren() ) ) {
				row[ "children" ] = convertTree( items = thisItem.getChildren() );
			}

			ArrayAppend( result, row );
		}

		return result;
	}


	public com.apirone.core.model.bean.ProductItemProduct(){
		var result = [];

		var baseTree = getProductItemService().getTree(
			productId = arguments.productId,
			fruitId   = arguments.fruitId
		);

		var baseAttributes = {};

		// dump(DESerializeJSON( SerializeJSON(baseTree)));

		var data = []

		for ( var item in baseTree ) {
			// var data = [];

			var key = item.getAttribute().getId();
			data.add( item.getId() );

			if ( !baseAttributes.keyExists( key ) ) {
				baseAttributes[ key ] = {
					"attribute" = { "id" = key, "name" = item.getAttribute().getName() },
					"values"    = []
				};
			}

			var values = getRecursiveValues( item.getChildren(), data );

			baseAttributes[ key ].values = values.data;
		}

		dump( baseAttributes );
		abort;

		return result;
	}

	private Struct function getRecursiveValues( required Array items, data = [] ){
		var result = [];

		for ( var thisItem in arguments.items ) {
			var item    = {};
			item.id     = thisItem.getId();
			item.values = [];

			data.add( item.id ); // se ha un figlio lo aggiungo

			var itemRows = getRecursiveValues( thisItem.getChildren(), data ).result;

			// data.add( itemRows )

			if ( ArrayLen( itemRows ) ) {
				item.values = itemRows;
			}

			ArrayAppend( result, item );
		}

		return { "result" = result, "data" = data };
	}

	private Numeric function getChildCount( required Array items, required Numeric parentId ){
		var result = 0;

		for ( var item in items ) {
			if ( item?.getParent()?.getId() == arguments.parentId ) {
				result++;
			}
		}

		return result;
	}


	private Struct function getBaseAttributes( required String productId, required String fruitId ){
		var items = getProductItemService().getFlatTree(
			productId = arguments.productId,
			fruitId   = arguments.fruitId
		);

		// dump( DESerializeJSON( SerializeJSON( items ) ) );

		var baseAttributes = {};

		for ( var item in items ) {
			var attrId = item.getAttribute().getId();
			// var key = item.getAttribute().getId() & "__" & item.getAttribute().getName();

			if ( !baseAttributes.keyExists( attrId ) ) {
				baseAttributes[ attrId ] = {
					"attribute" = { "id" = attrId, "name" = item.getAttribute().getName() },
					"values"    = []
				};
			}

			var childCount = getChildCount( data = items, parentId = item.getId() );

			baseAttributes[ attrId ].values.add( {
				"id"         = item.getId(),
				"name"       = item.getAttributeValue().getName(),
				"childCount" = childCount
			} );

			// result.add( item );
		}

		return baseAttributes
	}


	/*
	public com.apirone.core.model.bean.ProductItem[] function list(
         	String fruitId,
         	String productId
    ) {
		arguments["limit"] = -1;

		return search(argumentCollection = arguments).getData();

	}
	*/

	public com.apirone.core.model.bean.Result function search( String fruitId, String productId ){
		// dump( arguments );

		// solo uno dei due
		if ( !( IsNull( arguments.productId ) XOR IsNull( arguments.fruitId ) ) ) {
			Throw(
				type    = "ApirOne.errors.AtLeastOneParameterIsRequired",
				message = "At least one parameter is required: productId or fruitId"
			);
		}

		var rows   = [];
		var result = super.getResult();

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( record.product_item_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.recordcount ) );

		return result;
	}

	public com.smartvillage.core.model.bean.Outcome function delete(
		String productId,
		String attributeId,
		String fruitId
	){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.productId );

		outcome.setData( { productId = arguments.productId } );

		transaction {
			try {
				var cm = getCacheManager();

				getDao().delete( arguments.productId );

				cm.remove( getCacheScope(), obj.getId() );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteEvent" );
				outcome.setMessage( "Cannot delete product [#arguments.productId#]" );
			}
		}

		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.ProductItem productItem ){
		var newId = getDao().insert( arguments.productItem );

		return newId;
	}



	/*
    	private method
	*/

	private com.apirone.core.model.bean.ProductItemProduct function build( required String productItemProductId ){
		var record = getDao().read( arguments.productItemProductId );

		if ( record.recordCount ) {
			var bean = super.bean( "ProductItemProduct" );

			/*
            bean.setId( record.product_item_id );
            bean.setProductId( record.product_id );
			bean.setCreatedAt( record.created_at );
			bean.setParent( get( record.parent_id ) );
			bean.setOrderBy( record.orderby );

            bean.setStatus( getStatusService().get( record.status_id ) );

			var attributeValue = getAttributeValueService().get( record.attribute_raw_value_id );

			bean.setAttributeValue( attributeValue );
            bean.setAttribute( getAttributeService().get( attributeValue.getAttributeId() ) );
			*/

			return bean;
		}

		return NullValue();
	}

}
