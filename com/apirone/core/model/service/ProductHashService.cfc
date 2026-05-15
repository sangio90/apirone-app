component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ProductHashDAO";
	property name="ProductItemService" inject="ProductItemService";
	property name="QuotationItemService" inject="QuotationItemService";
	property name="cacheScope" type="String" default="ProductHash.bean";

	public com.apirone.core.model.bean.ProductHash function get( required Numeric productHashId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.productHashId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.productHashId );
		cm.put( getCacheScope(), arguments.productHashId, bean );

		return bean;
	}

	public com.apirone.core.model.bean.ProductHash function getByHash( required String hash ){
		var cm = getCacheManager();

		var record = getDao().find( argumentCollection = arguments );

		if (Len(record)) {
			var bean = build( record.product_hash_id );

			return bean;
		}

		return NullValue();
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		Numeric productHashId,
		String hash,
		String jsonData,
	){
		var rows   = [];
		var result = super.getResult();
		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( record.product_hash_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String productHashId ){
		var outcome = super.bean( "Outcome" );
		var obj = get( arguments.productHashId );

		outcome.setData( { productHashId = arguments.productHashId } );

		transaction {
			try {
				var cm = getCacheManager();
				getDao().delete( arguments.productHashId );
				cm.remove( getCacheScope(), arguments.productHashId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteProductHash" );
				outcome.setMessage( "Cannot delete product item [#arguments.productHashId#]" );
			}
		}

		return outcome;
	}


	public Numeric function create( required com.apirone.core.model.bean.ProductHash productHash ){
		var id = getDao().insert( arguments.productHash );

		return id;
	}

	public Numeric function update( required com.apirone.core.model.bean.ProductHash productHash ){
		getDao().update( arguments.productHash );
		super.getCacheManager().remove( getCacheScope(), productHash.getId() );

		return arguments.productHash.getId();
	}

	private com.apirone.core.model.bean.ProductHash function build( required Numeric productHashId ){
		var record = getDao().read( arguments.productHashId );

		if ( record.recordCount ) {
			var bean = super.bean( "ProductHash" );

			bean.setId( record.product_hash_id );

			bean.setHash( record.hash );
			bean.setJsonData( record.json_data );

			return bean;
		}

		return NullValue();
	}

	public String function createHash( required String quotationItemId ){
		var quotationItem = getQuotationItemService().get( quotationItemId );

		var jsonData = prepareQuotationItemJson( quotationItem );

		if (IsInstanceOf( quotationItem, "com.apirone.core.model.bean.QuotationItemSignage")) {
			jsonData = prepareQuotationItemSignageJson( quotationItem, jsonData );

		} elseif (IsInstanceOf( quotationItem, "com.apirone.core.model.bean.QuotationItemPlate")) {
			jsonData = prepareQuotationItemPlateJson( quotationItem, jsonData );
		}

		var bean = prepareBean(jsonData);
		
		if (IsNull( bean.getId() ) or Trim(bean.getId()) == '') {
			create( bean );
		}

		return bean.getHash();
	}

	private function prepareQuotationItemJson( required com.apirone.core.model.bean.QuotationItem quotationItem ){
		var categoryId = quotationItem.getProduct().getCategory().getId();
		var lineId = quotationItem.getProduct().getLine().getId();
		var modelId = quotationItem.getProduct().getModel().getId();
		var finishId = quotationItem.getProduct().getFinish().getId();
		var note = quotationItem.getNote();
		var special = quotationItem.getSpecial();
		var items = quotationItem.getItems();

		var productItems = [];
		if (!isNull(items)) {
			ArraySort( items, function(a, b) {
				return compare(a.getProductItem().getOrderBy(), b.getProductItem().getOrderBy());
			});

			for (var item in items) {
				productItems.append( { "productItemId" = item.getProductItem().getId(), "note" = Trim( item.getNote() ) } );
			}
		}

		var jsonData = {
			"categoryId": categoryId,
			"lineId": lineId,
			"modelId": modelId,
			"productId": quotationItem.getProduct().getId(),
			"finishId": finishId,
			"note": note,
			"special": special,
			"productItems": productItems
		};

		return jsonData;
	}

	private function prepareQuotationItemSignageJson( required com.apirone.core.model.bean.QuotationItemSignage quotationItem, jsonData ){
		jsonData['signageConfigItemId'] = quotationItem.getSignageConfigItem().getId()
		var rows = quotationItem.getSignageRows();

		arraySort(rows, function(a, b) {
			return compare(a.getOrderBy(), b.getOrderBy());
		});

		var signageRows = [];
		for (var row in rows) {
			signageRows.append( { 'text-align' = Trim( row.getTextAlign() ), 'content' = Trim( row.getContent() ) } );
		}
		jsonData['signageRows'] = signageRows;

		return jsonData;
	}

	private function prepareQuotationItemPlateJson( required com.apirone.core.model.bean.QuotationItemPlate quotationItem, jsonData ){
		var rows = quotationItem.getFruits();

		arraySort(rows, function(a, b) {
			return compare(a.getPositions()[1].order, b.getPositions()[1].order);
		});

		var quotationItemFruits = [];
		for (var row in rows) {
			var fruit = row.getFruit()
			var fruitRows = row.getItems();
			var fruitItems = [];

			if ( !isNull( fruitRows ) && fruitRows.len() ) {
				arraySort(fruitRows, function(a, b) {
					return compare(a.getProductItem().getOrderBy(), b.getProductItem().getOrderBy());
				});

				for (var fruitRow in fruitRows) {
					fruitItems.append({ "productItemId" = fruitRow.getProductItem().getId(), "note" = Trim( fruitRow.getNote() ) });
				}
			}

			quotationItemFruits.append( { 'position' = Trim( row.getPositions()[1].order ), 'product' = row.getFruit().getId(), 'productItems' = fruitItems } );
		}
		jsonData['fruits'] = quotationItemFruits;

		return jsonData;
	}

	private function prepareBean( jsonData ){
		var sorted = sortTopLevelStruct(jsonData);
		var jsonData = serializeJson( sorted );
		
		var hashValue = hash(jsonData, "MD5");

		var existProductHash = search( jsonData = jsonData );
		
		if ( existProductHash.getCount() > 0 ) {
			return existProductHash.getData()[1]
		}
		
		var bean = super.bean( "ProductHash" );
		bean.setHash( hashValue );
		bean.setJsonData( jsonData );

		return bean;
	}

	function sortTopLevelStruct(s) {
		var result = structNew("ordered");

		var keys = structKeyArray(s);
		arraySort(keys, "textnocase");

		for (var k in keys) {
			result[k] = s[k];
		}

		return result;
	}
}
