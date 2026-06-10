component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemProductItemDAO";
	property name="QuotationItemService" inject="QuotationItemService";
	property name="ProductItemService" inject="ProductItemService";

	public com.apirone.core.model.bean.QuotationItemProductItem function get( required String productItemId ){
		return build( arguments.productItemId );
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

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		if ( records.recordCount ) {
			// Raccoglie tutti gli ID e carica i record in blocco con una sola query
			var ids = [];
			for ( var record in records ) {
				ids.append( record.quotation_item_product_item_id );
			}

			var loadedRecords = getDao().readByIds( ids );
			var recordMap = {};
			for ( var loadedRecord in loadedRecords ) {
				recordMap[ loadedRecord.quotation_item_product_item_id ] = loadedRecord;
			}

			// Ricostruisce le righe nell'ordine del find() originale
			for ( var record in records ) {
				var fullRecord = recordMap[ record.quotation_item_product_item_id ];
				if ( !IsNull( fullRecord ) ) {
					rows.add( buildFromRow( fullRecord ) );
				}
			}
		}

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String productItemId ){
		var outcome = super.bean( "Outcome" );
		var obj     = get( arguments.productItemId );

		outcome.setData( { productItemId = arguments.productItemId } );

		transaction {
			try {
				getDao().delete( arguments.productItemId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteQuotationItemProductItem" );
				outcome.setMessage( "Cannot delete product item [#arguments.productItemId#]" );
			}
		}

		return outcome;
	}

	public com.apirone.core.model.bean.Outcome function deleteByQuotationItemFruitId( required String quotationItemFruitId ){
		var outcome = super.bean( "Outcome" );

		outcome.setData( { quotationItemFruitId = arguments.quotationItemFruitId } );

		transaction {
			try {
				getDao().deleteByQuotationItemFruitId( arguments.quotationItemFruitId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteQuotationItemProductItem" );
				outcome.setMessage( "Cannot delete product item by quotation item fruit id: [#arguments.quotationItemFruitId#]" );
			}
		}

		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.QuotationItemProductItem productItem ){
		var newId = getDao().insert( arguments.productItem );

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.QuotationItemProductItem productItem ){
		getDao().update( arguments.productItem );

		return arguments.productItem.getId();
	}

	private com.apirone.core.model.bean.QuotationItemProductItem function buildFromRow( required any record ){
		var bean = super.bean( "QuotationItemProductItem" );
		
		// Campi diretti dal record
		bean.setId( record.quotation_item_product_item_id );
		bean.setQuotationItemId( record.quotation_item_id );
		bean.setLevel( record.level );
		bean.setNote( record.note );

		// Entity collegate (caricate singolarmente)
		bean.setProductItem( getProductItemService().get( record.product_item_id ) );

		if ( !IsNull( record.origin_id ) ) {
			bean.setOrigin( getProductItemService().get( record.origin_id ) );
		}

		return bean;
	}

	private com.apirone.core.model.bean.QuotationItemProductItem function build( required String productItemId ){
		var record = getDao().read( arguments.productItemId );
		if ( record.recordCount ) {
			return buildFromRow( record );
		}
		return NullValue();
	}

}
