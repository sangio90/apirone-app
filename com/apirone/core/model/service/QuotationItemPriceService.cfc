component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemPriceDAO";
	property name="quotationItemPriceLineService" inject="QuotationItemPriceLineService";

	public com.apirone.core.model.bean.QuotationItemPrice function get( required Numeric quotationItemPriceId ){
		return build( arguments.quotationItemPriceId );
	}

	public com.apirone.core.model.bean.QuotationItemPrice function getByQuotationItemId( required String quotationItemId ){

		var rows = list( quotationItemId = arguments.quotationItemId );

		if( rows.len() EQ 0 ){
			return NullValue();
		}

		return rows[1];

	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String quotationitemId,
		required Numeric limit  = 15,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "quotationItemPrice.id" } ]
	){

		arguments[ "orderby" ] = super.createOrderBy( arguments.orderBy );

		var rows    = [];
		var result  = super.getResult();

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids = [];
		for ( var record in records ) {
			ids.append( record.quotation_item_price_id );
		}

		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Ricostruisce le righe nell'ordine del find() originale
		for ( var record in records ) {
			rows.append( beanMap[ record.quotation_item_price_id ] );
		}

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String quotationItemPriceId ){

		var outcome = super.bean( "Outcome" );

		outcome.setData( { quotationItemPriceId = arguments.quotationItemPriceId } );

		getDao().delete( arguments.quotationItemPriceId );

		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.QuotationItemPrice quotationItemPrice ){
		var newId = getDao().insert( arguments.quotationItemPrice );

		cffile( action="append", file="#ExpandPath('/debug.log')#", output="quotationItemPriceService: newId:#newId#, lines: #quotationItemPrice.getLines().len()#");

		if( !IsNull( quotationItemPrice.getLines() ) ) {

			cffile( action="append", file="#ExpandPath('/debug.log')#", output="QuotationItemPriceService: if !null before loop on lines newId:#newId#, lines: #quotationItemPrice.getLines().len()#");
			
			for( var line in quotationItemPrice.getLines() ) {
				cffile( action="append", file="#ExpandPath('/debug.log')#", output="QuotationItemPriceService: line newId:#newId#, lines: #quotationItemPrice.getLines().len()#");

				line.setQuotationItemPriceId( newId );
				getQuotationItemPriceLineService().create( line );
			}
		}

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.QuotationItemPrice quotationItemPrice ){
		getDao().update( arguments.quotationItemPrice );

		//cancello le righe esistenti
		getQuotationItemPriceLineService().deleteByQuotationItemPriceId( quotationItemPriceId = arguments.quotationItemPrice.getId() )

		if( !IsNull( quotationItemPrice.getLines() ) ) {

			cffile( action="append", file="#ExpandPath('/debug.log')#", output="QuotationItemPriceService: if !null before loop on lines newId:#quotationItemPrice.getId()#, lines: #quotationItemPrice.getLines().len()#");
			
			for( var line in quotationItemPrice.getLines() ) {
				cffile( action="append", file="#ExpandPath('/debug.log')#", output="QuotationItemPriceService: line newId:#quotationItemPrice.getId()#, lines: #quotationItemPrice.getLines().len()#");

				line.setQuotationItemPriceId( quotationItemPrice.getId() );
				getQuotationItemPriceLineService().create( line );
			}
		}

		return arguments.quotationItemPrice.getId();
	}

	/**
	 * Recupera in batch più QuotationItemPrice dato un array di ID.
	 * Restituisce uno Struct chiave = quotationItemPriceId, valore = bean QuotationItemPrice.
	 * Precarica le QuotationItemPriceLine in batch per evitare il problema N+1.
	 *
	 * @ids Array di quotationItemPriceId
	 * @return Struct mappato per quotationItemPriceId -> QuotationItemPrice
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Precarica le QuotationItemPriceLine in batch per tutti i price_id
		var lineMap = {};
		if ( ArrayLen( arguments.ids ) ) {
			var idsList = ArrayToList( arguments.ids );
			var lineRecords = QueryExecute(
				"SELECT * FROM quotation_item_price_lines WHERE quotation_item_price_id IN ( :ids )",
				{ ids: { value: idsList, list: true, cfsqltype: "integer" } },
				{ datasource: "apirone" }
			);
			for ( var lr in lineRecords ) {
				var priceId = lr.quotation_item_price_id;
				if ( !StructKeyExists( lineMap, priceId ) ) {
					lineMap[ priceId ] = [];
				}
				var lineBean = super.bean( "QuotationItemPriceLine" );
				lineBean.setId( lr.quotation_item_price_line_id );
				lineBean.setAmount( lr.amount );
				lineBean.setCost( lr.cost );
				lineBean.setQuotationItemPriceId( lr.quotation_item_price_id );
				lineBean.setName( lr.name );
				lineBean.setCreatedAt( lr.created_at );
				ArrayAppend( lineMap[ priceId ], lineBean );
			}
		}

		for ( var record in records ) {
			var bean   = super.bean( "QuotationItemPrice" );
			var method = super.bean( "PriceMethod" );

			// Campi diretti dal record
			bean.setDiscount1( record.discount1 );
			bean.setDiscount2( record.discount2 );
			bean.setAmount( record.amount );
			bean.setId( record.quotation_item_price_id );

			// Method (PriceMethod è un bean semplice senza FK)
			bean.setMethod( method.setId( record.price_method_id ) );

			// Lines: dalla mappa pre-caricata
			if ( StructKeyExists( lineMap, record.quotation_item_price_id ) ) {
				bean.setLines( lineMap[ record.quotation_item_price_id ] );
			}

			map[ record.quotation_item_price_id ] = bean;
		}

		return map;
	}

	private com.apirone.core.model.bean.QuotationItemPrice function build( required String quotationItemPriceId ){
		var record = getDao().read( arguments.quotationItemPriceId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean QuotationItemPrice a partire da una riga del query.
	 * Le sub-entity (PriceMethod, QuotationItemPriceLine) sono caricate con chiamate individuali.
	 */
	private com.apirone.core.model.bean.QuotationItemPrice function buildFromRow( required any record ){
		var bean = super.bean( "QuotationItemPrice" );
		var method = super.bean( "PriceMethod" );

		// Campi diretti dal record
		bean.setDiscount1( record.discount1 );
		bean.setDiscount2( record.discount2 );
		bean.setAmount( record.amount );
		bean.setId( record.quotation_item_price_id );

		// Entity collegate (caricate singolarmente)
		bean.setMethod( method.setId( record.price_method_id ) );
		bean.setLines( getQuotationItemPriceLineService().list( quotationItemPriceId = record.quotation_item_price_id ) );

		return bean;
	}

}
