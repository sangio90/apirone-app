component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemSignageRowDAO";
	property name="QuotationItemService" inject="QuotationItemService";
	property name="cacheScope" type="String" default="QuotationItemSignageRow.bean";

	public com.apirone.core.model.bean.QuotationItemSignageRow function get( required String quotationItemSignageRowId ){
		var cm    = getCacheManager();
		var cache = cm.get( getCacheScope(), arguments.quotationItemSignageRowId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.quotationItemSignageRowId );
		cm.put( getCacheScope(), arguments.quotationItemSignageRowId, bean );

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
		required Array orderBy  = [ { field = "quotationItemSignageRow.orderby" } ]
	){
		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var rows    = [];
		var result  = super.getResult();
		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( quotationItemSignageRowId = record.quotation_item_signage_row_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String quotationItemSignageRowId ){
		var outcome = super.bean( "Outcome" );
		var obj     = get( arguments.quotationItemSignageRowId );

		outcome.setData( { quotationItemSignageRowId = arguments.quotationItemSignageRowId } );
		getDao().delete( arguments.quotationItemSignageRowId );

		transaction {
			try {
				getDao().delete( arguments.quotationItemSignageRowId );
				removeCache(obj)
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteQuotationItemSignageRow" );
				outcome.setMessage( "Cannot delete Signage Row [#arguments.quotationItemSignageRowId#]" );
			}
		}
		return outcome;
	}

	private Void function removeCache( required com.apirone.core.model.bean.QuotationItemSignageRow quotationItemSignageRow ){
		var cm = super.getCacheManager();
		cm.remove( getCacheScope(), arguments.quotationItemSignageRow.getId() );

		if ( !Len( arguments.quotationItemSignageRow.getQuotationItemId() ) ) {
			Throw( type = "apirone.error.QuotationItemSignageRow.InvalidSaveType", message = "Missing Quotation Item ID" );
			return;
		}
		cm.remove( "QuotationItem.bean", arguments.quotationItemSignageRow.getQuotationItemId() );
	}

	public String function create( required com.apirone.core.model.bean.QuotationItemSignageRow quotationItemSignageRow ){
		var newId = getDao().insert( arguments.quotationItemSignageRow );

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.QuotationItemSignageRow quotationItemSignageRow ){
		getDao().update( arguments.quotationItemSignageRow );
		super.getCacheManager().remove( getCacheScope(), arguments.quotationItemSignageRow.getId() );

		return arguments.quotationItemSignageRow.getId();
	}

	private com.apirone.core.model.bean.QuotationItemSignageRow function build( required String quotationItemSignageRowId ){
		var record = getDao().read( arguments.quotationItemSignageRowId );
		if ( record.recordCount ) {
			var bean = super.bean( "QuotationItemSignageRow" );
			bean.setId( record.quotation_item_signage_row_id );
			bean.setTextAlign( record.text_align );
			bean.setContent( record.content );
			bean.setCharCount( record.char_count );
			bean.setOrderBy( record.orderby );
			bean.setQuotationItemId( record.quotation_item_id );

			return bean;
		}
		return NullValue();
	}

}
