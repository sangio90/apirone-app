component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemPriceLineDAO";

	public com.apirone.core.model.bean.QuotationItemPriceLine function get( required String quotationItemPriceLineId ){
		return build( arguments.quotationItemPriceLineId );
	}

	public Array function list(
		required String quotationItemPriceId,
		required Array orderBy  = [ { field = "quotationItemPriceLine.id", desc = "asc" } ]
	){

		arguments[ "orderby" ] = super.createOrderBy( arguments.orderBy );

		var rows    = [];

		// Il find() ora restituisce tutte le colonne: si possono costruire i bean direttamente
		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			var bean = buildFromFindRow( record );
			rows.append( bean );
		} );

		return rows;
	}


	public Numeric function create( required com.apirone.core.model.bean.QuotationItemPriceLine quotationItemPriceLine ){
		var newId = getDao().insert( arguments.quotationItemPriceLine );

		return newId;
	}

	/**
	 * Inserisce più righe di prezzo con una sola INSERT multi-riga (vedi
	 * QuotationItemPriceLineDAO.insertMany): le righe devono già avere
	 * quotationItemPriceId valorizzato.
	 *
	 * @param lines  array di bean QuotationItemPriceLine completi
	 * @returns      array degli id generati, nell'ordine delle righe
	 */
	public Array function createMany( required Array lines ){
		if ( !ArrayLen( arguments.lines ) ) {
			return [];
		}
		return getDao().insertMany( arguments.lines );
	}

	public com.apirone.core.model.bean.Outcome function delete( required Numeric quotationItemPriceLineId ){

		var outcome = super.bean( "Outcome" );

		outcome.setData( { quotationItemPriceLineId = arguments.quotationItemPriceLineId } );

		getDao().delete( arguments.quotationItemPriceLineId );

		return outcome;
	}

	public com.apirone.core.model.bean.Outcome function deleteByQuotationItemPriceId( required Numeric quotationItemPriceId ){

		var outcome = super.bean( "Outcome" );

		outcome.setData( { quotationItemPriceId = arguments.quotationItemPriceId } );

		getDao().deleteByQuotationItemPriceId( arguments.quotationItemPriceId );

		return outcome;
	}


	/*
		PRIVATE METHODS
	*/

	/**
	 * Costruisce un bean QuotationItemPriceLine a partire dall'ID. Delega a buildFromFindRow() dopo la lettura del record.
	 */
	private com.apirone.core.model.bean.QuotationItemPriceLine function build( required Numeric quotationItemPriceLineId ){
		var record = getDao().read( arguments.quotationItemPriceLineId );

		if ( record.recordCount ) {
			return buildFromFindRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean QuotationItemPriceLine a partire da una riga della query.
	 */
	private com.apirone.core.model.bean.QuotationItemPriceLine function buildFromFindRow( required any record ){
		var bean = super.bean( "QuotationItemPriceLine" );

		// Campi diretti dal record (QuotationItemPriceLine non ha sub-entity)
		bean.setId( record.quotation_item_price_line_id );
		bean.setAmount( record.amount );
		bean.setCost( record.cost );
		bean.setQuotationItemPriceId( record.quotation_item_price_id );
		bean.setName( record.name ); //TODO: rename this field to quotation_item_price_line
		bean.setCreatedAt( record.created_at );

		return bean;
	}

}
