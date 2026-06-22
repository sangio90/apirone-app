component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationPriceDAO";
	property name="QuotationService" inject="QuotationService";
	property name="quotationItemService" inject="QuotationItemService";
	property name="quotationPriceLineService" inject="QuotationPriceLineService";

	public com.apirone.core.model.bean.QuotationPrice function get( required String quotationPriceId ){
		return build( arguments.quotationPriceId );
	}

	public com.apirone.core.model.bean.QuotationPrice function getByQuotationId( required String quotationId ){

		var rows = list( quotationId = arguments.quotationId );

		var bean = "";
		if ( len( rows ) ) { bean = rows[ 1 ]; } else { bean = NullValue(); }

		return bean;

	}

	public com.apirone.core.model.bean.QuotationPrice function calculate( required String quotationId ){

		var totalItems = 0;
		var totalCosts = 0;
		var pricing = getByQuotationId( quotationId = arguments.quotationId );
		var quotation = getQuotationService().get( quotationId = arguments.quotationId );

		if ( IsNull( pricing ) ) {
			pricing = super.bean( "QuotationPrice" );
			pricing.setQuotationId( arguments.quotationId );
		}

		var items = getQuotationItemService().list( quotationId = arguments.quotationId );

		for( var item in items ) {
			var zone = item.getQuotationZone()
			var originZone = zone.getOrigin()
			var zoneQuantity = zone.getQuantity();
			if (!isNull(originZone)) {
				zoneQuantity *= originZone.getQuantity()
			}

			totalItems = totalItems + (item.getPrice().getTotal() * zoneQuantity);
			totalCosts = totalCosts + (item.getPrice().getCost() * item.getQuantity() * zoneQuantity);
		}

		pricing.setTotalGoods( totalItems );
		pricing.setCosts( totalCosts );
		pricing.setVatCode( quotation.getVatCode() );
		pricing.setCurrency( quotation.getCurrency() );

		return pricing;

	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String quotationId,
		required Numeric limit  = 15,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "quotationPrice.createdAt", dir = "desc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids = [];
		records.each( function( r ){
			ids.append( r.quotation_price_id );
		} );

		// Costruisce tutti i bean in batch con getMany() ottimizzato (evita N+1 + calcolo aggregato)
		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			if ( StructKeyExists( beanMap, record.quotation_price_id ) ) {
				rows.add( beanMap[ record.quotation_price_id ] );
			}
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public Struct function save( required com.apirone.core.model.bean.QuotationPrice quotationPrice ){

		var action = "";
		var rows = list( quotationId = arguments.quotationPrice.getQuotationId() );

		if( rows.len() ) {

			arguments.quotationPrice.setId( rows[1].getId() );

			var thisId = update( arguments.quotationPrice );
			action = "update";

		} else {
			var thisId = create( arguments.quotationPrice );
			action = "create";	
		}

		return { "action": action, "id": thisId };
	}

	public String function create( required com.apirone.core.model.bean.QuotationPrice quotationPrice ){
		var newId = getDao().insert( arguments.quotationPrice );

		for( var line in quotationPrice.getLines() ) {
			line.setQuotationPriceId( newId );
			getQuotationPriceLineService().create( line );
		}

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.QuotationPrice quotationPrice ){

		var bean = getByQuotationId( arguments.quotationPrice.getQuotationId() );

		arguments.quotationPrice.setId( bean.getId() );

		getDao().update( arguments.quotationPrice );

		return arguments.quotationPrice.getId();
	}

	/**
	 * Recupera in batch più QuotationPrice dato un array di ID.
	 * Restituisce uno Struct chiave = quotationPriceId, valore = bean QuotationPrice.
	 * precarica i QuotationItem per quotation_id univoco (con cache per evitare duplicati)
	 * e calcola il totalMultipliedByQuantity in batch.
	 *
	 * @ids Array di quotationPriceId
	 * @return Struct mappato per quotationPriceId -> QuotationPrice
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Raccoglie i quotation_id univoci
		var quotationIds = [];
		for ( var r in records ) {
			if ( !ArrayContains( quotationIds, r.quotation_id ) ) {
				quotationIds.append( r.quotation_id );
			}
		}

		// Precarica i QuotationItem in cache per quotation_id (list() ora usa getMany() internamente)
		var itemsCache = {};
		for ( var qid in quotationIds ) {
			itemsCache[ qid ] = getQuotationItemService().list( quotationId = qid );
		}

		// Costruisce i bean con l'aggregazione dai QuotationItem pre-caricati
		for ( var r in records ) {
			var bean = super.bean( "QuotationPrice" );

			// Campi diretti dal record
			bean.setId( r.quotation_price_id );
			bean.setQuotationId( r.quotation_id );
			bean.setDiscount1( r.discount1 );
			bean.setDiscount2( r.discount2 );
			bean.setShippingCost( r.shipment_cost );
			bean.setFlatDiscount( r.flat_discount );
			bean.setCreatedAt( r.created_at );

			// Aggregazione totalMultipliedByQuantity dai QuotationItem
			if ( StructKeyExists( itemsCache, r.quotation_id ) ) {
				itemsCache[ r.quotation_id ].each( function( item ){
					var zone         = item.getQuotationZone();
					var zoneQuantity = zone.getQuantity();
					if ( !IsNull( zone.getOrigin() ) ) {
						zoneQuantity *= zone.getOrigin().getQuantity();
					}
					bean.setTotalMultipliedByQuantity(
						bean.getTotalMultipliedByQuantity() +
						( item.getPrice().getTotal() * item.getQuantity() * zoneQuantity )
					);
				} );
			}

			map[ r.quotation_price_id ] = bean;
		}

		return map;
	}

	private com.apirone.core.model.bean.QuotationPrice function buildFromRow( required any record ){
		var bean = super.bean( "QuotationPrice" );

		// Campi diretti dal record
		bean.setId( record.quotation_price_id );
		bean.setQuotationId( record.quotation_id );
		bean.setDiscount1( record.discount1 );
		bean.setDiscount2( record.discount2 );
		bean.setShippingCost( record.shipment_cost );
		bean.setFlatDiscount( record.flat_discount );
		bean.setCreatedAt( record.created_at );

		// Entity collegate (caricate singolarmente)
		getQuotationItemService().list( quotationId = bean.getQuotationId() ).each( function( item ){
			var zone = item.getQuotationZone()
			var originZone = zone.getOrigin()
			var zoneQuantity = zone.getQuantity();
			if (!isNull(originZone)) {
				zoneQuantity *= originZone.getQuantity()
			}
			bean.setTotalMultipliedByQuantity( bean.getTotalMultipliedByQuantity() + ( item.getPrice().getTotal() * item.getQuantity() * zoneQuantity ) );
		} );

		return bean;
	}

	private com.apirone.core.model.bean.QuotationPrice function build( required String quotationPriceId ){
		var record = getDao().read( arguments.quotationPriceId );
		
		if ( record.recordCount ) {
			return buildFromRow( record );
		}
		
		return NullValue();
	}

	public com.apirone.core.model.bean.Outcome function delete( required Numeric quotationPriceId ){

		var outcome = super.bean( "Outcome" );

		outcome.setData( { quotationPriceId = arguments.quotationPriceId } );
		getDao().delete( arguments.quotationPriceId );

		return outcome;
	}

}
