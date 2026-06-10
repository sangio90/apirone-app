component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemSignageRowDAO";
	property name="QuotationItemService" inject="QuotationItemService";

	public com.apirone.core.model.bean.QuotationItemSignageRow function get( required String quotationItemSignageRowId ){
		return build( arguments.quotationItemSignageRowId );
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

		// Il find() ora restituisce tutte le colonne: si possono costruire i bean direttamente
		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( buildFromFindRow( record ) );
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

		transaction {
			try {
				getDao().delete( arguments.quotationItemSignageRowId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteQuotationItemSignageRow" );
				outcome.setMessage( "Cannot delete Signage Row [#arguments.quotationItemSignageRowId#]" );
			}
		}
		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.QuotationItemSignageRow quotationItemSignageRow ){
		var newId = getDao().insert( arguments.quotationItemSignageRow );

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.QuotationItemSignageRow quotationItemSignageRow ){
		getDao().update( arguments.quotationItemSignageRow );

		return arguments.quotationItemSignageRow.getId();
	}

	private com.apirone.core.model.bean.QuotationItemSignageRow function build( required String quotationItemSignageRowId ){
		var record = getDao().read( arguments.quotationItemSignageRowId );
		if ( record.recordCount ) {
			return buildFromFindRow( record );
		}
		return NullValue();
	}

	/**
	 * Costruisce un bean QuotationItemSignageRow a partire da una riga della query.
	 */
	private com.apirone.core.model.bean.QuotationItemSignageRow function buildFromFindRow( required any record ){
		var bean = super.bean( "QuotationItemSignageRow" );

		// Campi diretti dal record (QuotationItemSignageRow non ha sub-entity)
		bean.setId( record.quotation_item_signage_row_id );
		bean.setTextAlign( record.text_align );
		bean.setContent( record.content );
		bean.setCharCount( record.char_count );
		bean.setOrderBy( record.orderby );
		bean.setQuotationItemId( record.quotation_item_id );

		return bean;
	}

}
