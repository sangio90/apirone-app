component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ProductItemDAO";
	property name="statusService" inject="StatusService";
	property name="attributeService" inject="AttributeService";
	property name="attributeValueService" inject="AttributeValueService";
	property name="FileService" inject="FileService";
	property name="componentService" inject="ComponentService";
	property name="priceService" inject="PriceService";

	property name="cacheScope" default="ProductItem.bean";

	public com.apirone.core.model.bean.ProductItem function get( required productItemId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.productItemId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.productItemId );
		cm.put( getCacheScope(), arguments.productItemId, bean );

		return bean;
	}

	public Array function getTree( required String productId ){
		var result = [];

		var productId = arguments.productId;

		var baseItems = list( productId = arguments.productId );

		for ( var item in baseItems ) {
			var rows = getRecursiveTree( originId = item.getId(), rows = [] )
			item.setChildren( rows );

			result.add( item );
		}

		return result;
	}

	public Array function list( String productId, Numeric originId ){
		var result = [];
		var rows   = [];

		var productId = arguments.productId;

		var items = list( productId = arguments.productId, originId = arguments.originId );

		if ( arguments.includeMissingValues ) {
			rows = listWithMissingValues( items );
		} else {
			rows = items;
		}

		var thisLevel            = arguments.level;
		var includeMissingValues = arguments.includeMissingValues;

		var n = 1;

		for ( var row in rows ) {
			var thisOrderBy = "#arguments.orderBy#.#n#";
			var originId    = row.getId();

			row.setLevel( arguments.level );

			result.add( row );

			var rows = getFlatTree(
				productId,
				originId,
				thisLevel + 1,
				thisOrderBy,
				includeMissingValues
			);

			result = result.merge( rows );

			n++;
		}

		return result;
	}


	public Array function list( String productId, Numeric originId ){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}


	public Array function listComponents( required Numeric productItemId ){
		var result = getProductComponentService().list( productItemId = productItemId );

		return result;
	}

	public Boolean function addComponent(
		required Numeric productItemId,
		required com.apirone.core.model.bean.ProductComponent productComponent
	){
		transaction {
			getDao().deleteComponent( argumentCollection = arguments );
			getDao().insertComponent( argumentCollection = arguments );
		}

		return true;
	}

	public com.apirone.core.model.bean.Result function search( String productId, Numeric originId ){
		var rows   = [];
		var result = super.getResult();

		var records = getDao().findComplete( argumentCollection = arguments );
	
		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.recordcount ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete(
		Numeric productItemId,
		String productId,
		String attributeId
	){
		if ( IsNull( arguments.productItemId ) && IsNull( arguments.productId ) && IsNull( arguments.attributeId ) ) {
			Throw( message = "At least one parameter is required to delete", type = "apirone.error.NoArgumentsPassed" );
		}

		var outcome = super.bean( "Outcome" );

		outcome.setData( arguments );

		transaction {
			try {
				getDao().delete( argumentCollection = arguments );

				cm.removeByScope( "product.bean" );
				cm.removeByScope( "productItem.bean" );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteProductItem" );
				outcome.setMessage( "Cannot delete product items by [#SerializeJSON( arguments )#]" );
			}
		}

		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.ProductItem ProductItem ){
		var newId = getDao().insert( arguments.ProductItem );

		return newId;
	}


	public String function update( required com.apirone.core.model.bean.ProductItem productItem ){
		var newId = getDao().update( arguments.productItem );

		// super.getCacheManager().remove( getCacheScope(), arguments.productItem.getId() );

		removeCache( arguments.productItem.getId() );

		return newId;
	}

	public Array function getFlatTree(
		required String productId,
		required Numeric originId             = NullValue(),
		required String level                 = 1,
		required String orderBy               = "",
		required Boolean includeMissingValues = true
	){
		var result = [];
		var rows   = [];

		var productId = arguments.productId;

		var items = list( productId = arguments.productId, originId = arguments.originId );

		if ( arguments.includeMissingValues ) {
			rows = listWithMissingValues( items );
		} else {
			rows = items;
		}

		var thisLevel            = arguments.level;
		var includeMissingValues = arguments.includeMissingValues;

		var n = 1;

		for ( var row in rows ) {
			var thisOrderBy = "#arguments.orderBy#.#n#";
			var originId    = row.getId();

			row.setLevel( arguments.level );

			result.add( row );

			var rows = getFlatTree(
				productId,
				originId,
				thisLevel + 1,
				thisOrderBy,
				includeMissingValues
			);

			result = result.merge( rows );

			n++;
		}

		return result;
	}

	public Void function removeCache( required Numeric productItemId ){
		super.getCacheManager().remove( getCacheScope(), arguments.productItemId );
	}


	/*
    	private method
	*/

	private Void function printTree( required array items, numeric level = "0" ){
		for ( var item in arguments.items ) {
			var indent = RepeatString( "&nbsp;&nbsp;&nbsp;&nbsp;", arguments.level );

			//  Stampa il nome della categoria con l'indentazione
			Echo( "#indent# - #item.id# #item.attributeValue.texts[ 1 ].name# <br>" );

			//  Se la categoria ha dei figli, chiama ricorsivamente la funzione
			if ( StructKeyExists( item, "items" ) && ArrayLen( item.items ) > 0 ) {
				printTree( item.items, arguments.level + 1 );
			}
		}
	}

	private Array function getRecursiveTree( required Numeric originId ){
		var result = [];

		var items = list( originId = arguments.originId );

		for ( var item in items ) {
			var itemRows = getRecursiveTree( originId = item.getId() );

			if ( ArrayLen( itemRows ) ) {
				item.setChildren( itemRows );
			}

			ArrayAppend( result, item );
		}

		return result;
	}

	private Array function calcultateAttributes( required Array rows ){
		var attrs = [];

		Boolean function exists( required attributeId, required attrs ){
			for ( var attr in arguments.attrs ) {
				if ( attr.getId() == arguments.attributeId ) {
					return true;
				}
			}

			return false
		}

		for ( var row in rows ) {
			if ( !exists( row.getAttribute().getId(), attrs ) ) {
				// attribute with all values
				attrs.add( getAttributeService().get( row.getAttribute().getId() ) );
			}
		}

		return attrs;
	}

	private Array function listWithMissingValues( required Array productItems ){
		var values = [];

		var items = Duplicate( arguments.productItems );

		// 1. calcolo gli attributi dei valori recuperati
		var attrs = calcultateAttributes( arguments.productItems );

		for ( var thisAttr in attrs ) {
			for ( var thisValue in thisAttr.getValues() ) {
				// 2. cerco i valori mancanti per ogni attributo

				var found   = false;
				var index   = 1;
				var payload = { found = false, parent = NullValue() };

				for ( var thisProduct in arguments.productItems ) {
					payload.parent = thisProduct.getOrigin();

					if ( thisAttr.getId() == thisProduct.getAttribute().getId() ) {
						if (
							thisValue.getRawValue().getId() == thisProduct
								.getAttributeValue()
								.getRawValue()
								.getId()
						) {
							payload.found = true;
						}

						var lastOrderby   = thisProduct.getOrderBy();
						var lastAttribute = thisAttr;

						index++;
					}
				}

				if ( !payload.found ) {
					var bean = super.bean( "ProductItem" );

					bean.setId( -1 );
					bean.setAttributeValue( thisValue );
					bean.setAttribute( lastAttribute );
					bean.setStatus( getStatusService().get( "DEA" ) );
					bean.setOrigin( payload.parent );

					// attributeValue
					bean.setOrderBy( lastOrderby + 10 );

					items.insertAt( index, bean );
				}
			}
		}

		return items;
	}

	private com.apirone.core.model.bean.ProductItem function build( required String productItemId ){
		var record = getDao().read( arguments.productItemId );

		if ( record.recordCount ) {
			var bean = super.bean( "ProductItem" );

			bean.setId( record.product_item_id );
			bean.setProductId( record.product_id );
			bean.setCreatedAt( record.created_at );
			bean.setImportant( record.important );

			bean.setOrigin( IsNull( record.origin_id ) ? NullValue() : get( record.origin_id ) );

			bean.setOrderBy( record.orderby );

			bean.setStatus( getStatusService().get( record.status_id ) );

			var attributeValue = getAttributeValueService().get( record.attribute_raw_value_id );

			bean.setAttributeValue( attributeValue );

			bean.setAttribute( getAttributeService().get( attributeValue.getAttributeId() ) );
			//bean.setComponentCount( getComponentService().count( productItemId = record.product_item_id ) );
			bean.setComponentCount( 0 )

			bean.setChildren( [] );

			bean.setPrices( getPriceService().list( productItemId = record.product_item_id ) );

			var images = getFileService().list( productItemId = record.product_item_id );

			if ( Len( images ) ) {
				bean.setImages( images )
			} else {
				var images = getFileService().list( attributeValueId = record.attribute_raw_value_id );
				if ( Len( images ) ) {
					bean.setImages( images )
				}
			}

			return bean;
		}

		return NullValue();
	}

}
