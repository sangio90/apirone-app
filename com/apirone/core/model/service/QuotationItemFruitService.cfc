
component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemFruitDAO";
	property name="productService" inject="ProductService";
	property name="quotationItemProductItemService" inject="QuotationItemProductItemService";
	property name="quotationItemFruitPositionService" inject="QuotationItemFruitPositionService";

	public com.apirone.core.model.bean.QuotationItemFruit function get( required Numeric quotationItemFruitId ){
		return build( arguments.quotationItemFruitId );
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

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		if ( records.recordCount ) {
			// Raccoglie tutti gli ID e carica i record in blocco con una sola query
			var ids = [];
			for ( var record in records ) {
				ids.append( record.quotation_item_fruit_id );
			}

			var loadedRecords = getDao().readByIds( ids );
			var recordMap = {};
			for ( var loadedRecord in loadedRecords ) {
				recordMap[ loadedRecord.quotation_item_fruit_id ] = loadedRecord;
			}

			// Ricostruisce le righe nell'ordine del find() originale
			for ( var record in records ) {
				var fullRecord = recordMap[ record.quotation_item_fruit_id ];
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

	public com.apirone.core.model.bean.Outcome function delete( required Numeric quotationItemFruitId ){
		var outcome = super.bean( "Outcome" );

		outcome.setData( { quotationItemFruitId = arguments.quotationItemFruitId } );

		transaction {
			try {
				getDao().delete( arguments.quotationItemFruitId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.error.CannotDeleteQuotationItemFruit" );
				outcome.setMessage( "Cannot delete quotation item fruit [#arguments.quotationItemFruitId#]" );
			}
		}

		return outcome;
	}

	public Numeric function create( required com.apirone.core.model.bean.QuotationItemFruit quotationItemFruit ){
		var newId = getDao().insert( arguments.quotationItemFruit );

		// 01 items
		if( !IsNull( arguments.quotationItemFruit.getItems() ) ){
			for( var item in arguments.quotationItemFruit.getItems() ){
				item.setQuotationItemFruitId( newId );
				getQuotationItemProductItemService().create( item );
			}
		}

		// 02 positions
		for( var position in arguments.quotationItemFruit?.getPositions() ){
			getQuotationItemFruitPositionService().create( newId, position.id, position.order );
		}

		return newId;
	}

	public Numeric function update( required com.apirone.core.model.bean.QuotationItemFruit quotationItemFruit ){
		getDao().update( arguments.quotationItemFruit );

		cffile( action="append", file="#ExpandPath('/debug.log')#", output="update quotationItemFruit: #arguments.quotationItemFruit.getId()#" );

		// 01 items
		getQuotationItemProductItemService().deleteByQuotationItemFruitId( arguments.quotationItemFruit.getId() );

		if( !IsNull( arguments.quotationItemFruit.getItems() ) ){
			for( var item in arguments.quotationItemFruit?.getItems() ){
				item.setQuotationItemFruitId( arguments.quotationItemFruit.getId() );
				getQuotationItemProductItemService().create( item );
			}
		}

		// 02 positions
		getQuotationItemFruitPositionService().deleteByQuotationItemFruitId( arguments.quotationItemFruit.getId() );
		cffile( action="append", file="#ExpandPath('/debug.log')#", output="delete positions: #arguments.quotationItemFruit.getId()#, #SerializeJSON(arguments.quotationItemFruit.getPositions())#" );

		for( var position in arguments.quotationItemFruit?.getPositions() ){
			if (!StructKeyExists(position, 'id') && StructKeyExists(position, 'position')) {
				position['id'] = position.position;
			}
			getQuotationItemFruitPositionService().create( arguments.quotationItemFruit.getId(), position.id, position.order );
		}

		return arguments.quotationItemFruit.getId();
	}


	/*
		private methods
	*/

	private com.apirone.core.model.bean.QuotationItemFruit function buildFromRow( required any record ){
		var bean = super.bean( "QuotationItemFruit" );

		// Campi diretti dal record
		bean.setId( record.quotation_item_fruit_id );
		bean.setCreatedAt( record.created_at );
		bean.setNote( record.note );

		// Entity collegate (caricate singolarmente)
		bean.setFruit( getProductService().get( record.fruit_id ) );

		var items = getQuotationItemProductItemService().list( quotationItemFruitId = record.quotation_item_fruit_id );

		if ( Len( items ) ) {
			bean.setItems( items );
		}

		var positions = getQuotationItemFruitPositionService().list( quotationItemFruitId = record.quotation_item_fruit_id );

		if ( Len( positions ) ) {
			bean.setPositions( positions );
		}

		return bean;
	}

	private com.apirone.core.model.bean.QuotationItemFruit function build( required Numeric quotationItemFruitId ){
		var record = getDao().read( arguments.quotationItemFruitId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

}
