component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationPriceLineDAO";

	public com.apirone.core.model.bean.QuotationPriceLine function get( required String quotationPriceLineId ){
		return build( arguments.quotationPriceLineId );
	}

	public Array function list(
		required String quotationPriceId,
	){

		arguments[ "orderby" ] = super.createOrderBy( [ { field = "quotationPriceLine.id" } ] );

		var rows    = [];

		// Il find() ora restituisce tutte le colonne: si possono costruire i bean direttamente
		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			var bean = buildFromFindRow( record );
			rows.append( bean );
		} );

		return rows;
	}

	public com.apirone.core.model.bean.Outcome function delete( required Numeric quotationPriceLineId ){

		var outcome = super.bean( "Outcome" );

		outcome.setData( { quotationPriceLineId = arguments.quotationPriceLineId } );
		getDao().delete( arguments.quotationPriceLineId );

		return outcome;
	}

	public com.apirone.core.model.bean.Outcome function deleteByQuotationPriceId( required Numeric quotationPriceId ){

		var outcome = super.bean( "Outcome" );

		outcome.setData( { quotationPriceId = arguments.quotationPriceId } );
		getDao().deleteByQuotationPriceId( arguments.quotationPriceId );

		return outcome;
	}

	public Numeric function create( required QuotationPriceLine ){
		var newId = getDao().insert( arguments.QuotationPriceLine );

		return newId;
	}

	private com.apirone.core.model.bean.QuotationPriceLine function build( required Numeric quotationPriceLineId ){
		var record = getDao().read( arguments.quotationPriceLineId );

		if ( record.recordCount ) {
			return buildFromFindRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean QuotationPriceLine a partire da una riga della query.
	 */
	private com.apirone.core.model.bean.QuotationPriceLine function buildFromFindRow( required any record ){
		var bean = super.bean( "QuotationPriceLine" );

		// Campi diretti dal record (QuotationPriceLine non ha sub-entity)
		bean.setId( record.quotation_price_line_id );
		bean.setAmount( record.price );
		bean.setQuotationPriceId( record.quotation_price_id );

		return bean;
	}

}
