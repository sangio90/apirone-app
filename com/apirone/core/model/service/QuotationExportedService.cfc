component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationExportedDAO";
	property name="cacheScope" type="String" default="QuotationExported.bean";
	property name="rowCacheScope" type="String" default="QuotationExported.bean";

	public com.apirone.core.model.bean.QuotationExported function get( required String quotationSerial ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.quotationSerial );
		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.quotationSerial );
		cm.put( getCacheScope(), arguments.quotationSerial, bean );

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		String quotationSerial, 
		required Numeric limit  = 15,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "quotationExported.shippingDate", dir = "desc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( record.MMSERIAL ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String quotationSerial ){
		var outcome = super.bean( "Outcome" );
		var obj     = get( arguments.quotationSerial );

		outcome.setData( { quotationSerial = arguments.quotationSerial } );

		transaction {
			try {
				var cm = getCacheManager();

				getDao().delete( arguments.quotationSerial );

				cm.remove( getCacheScope(), arguments.quotationSerial );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteQuotationExported" );
				outcome.setMessage( "Cannot delete quotation exported [#arguments.quotationSerial#]" );
			}
		}

		return outcome;
	}

	/*
		private method
	*/

	private com.apirone.core.model.bean.QuotationExported function build( required String quotationSerial ){
		var record = getDao().read( arguments.quotationSerial );

		if ( record.recordCount ) {
			var bean = super.bean( "QuotationExported" );

			//testa
			bean.setKey( record.CF_IDCLI );
			bean.setCompany( record.CFDESCR1 );
			bean.setQuotationSerial( record.MMSERIAL );
			bean.setQuotationCode( record.MMNUMDOC );
			bean.setBillingStreet( record.CFINDIRI );
			bean.setBillingCity( record.CFLOCALI );
			bean.setBillingState( record.CFPROVIN );
			bean.setBillingCountry( record.CFSTAISO );
			bean.setVatNumber( record.CFPARIVA );
			bean.setShippingStreet( record.DEINDMER );
			bean.setShippingCity( record.DELOCMER );
			bean.setShippingState( record.DEPROMER );
			bean.setShippingCountry( record.DENAZMER );
			bean.setShippingDate( record.MMDATEVA );
			bean.setOpportunity( record.MMRIFORD );
			bean.setPricelist( record.MMNUMLIS );
			bean.setAgent( record.MMCODAGE );
			bean.setNotes( record.MMANNTES );
			//riga
			bean.setRowNumber( record.CPROWNUM );
			bean.setProductCode( record.MMCODART );
			bean.setVariantCode( record.MMCODVAR );
			bean.setColorCode( record.MMCODCOL );
			<!--- bean.setUm( record.MMUNIMIS ); ---->
			bean.setQuantity( record.MMQTAMOV );
			bean.setPrice( record.MMVALUNI );
			bean.setDiscount1( record.MMSCOAR1 );
			bean.setDiscount2( record.MMSCOAR2 );

			return bean;
		}

		return NullValue();
	}

	//ROWS

	public com.apirone.core.model.bean.QuotationExported function getRow( required String quotationSerial, required Numeric rowNumber ){
		var cm = getCacheManager();

		var cache = cm.get( getRowCacheScope(), arguments.quotationSerial & '_' & arguments.rowNumber );
		if ( cache.status ) {
			return cache.data;
		}

		var bean = buildRow( quotationSerial = arguments.quotationSerial, rowNumber = arguments.rowNumber );
		cm.put( getRowCacheScope(), arguments.quotationSerial & '_' & arguments.rowNumber, bean );

		return bean;
	}

	public com.apirone.core.model.bean.Result function searchRows(
		required Numeric limit  = -1,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "quotationExported.rowNumber" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().findRows( argumentCollection = { quotationSerial = arguments.quotationSerial } );

		records.each( function( record ){
			rows.add( getRow( key = record.MMSERIAL, rowNumber = records.CPROWNUM ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function deleteRow( required String quotationSerial, required Numeric rowNumber ){
		var outcome = super.bean( "Outcome" );
		var obj     = getRow( quotationSerial = arguments.quotationSerial, rowNumber = arguments.rowNumber );

		outcome.setData( { quotationSerial = arguments.quotationSerial, rowNumber = arguments.rowNumber } );
		
		transaction {
			try {
				var cm = getCacheManager();
				
				getDao().deleteRow( quotationSerial = arguments.quotationSerial, rowNumber = arguments.rowNumber );

				cm.remove( getCacheScope(), arguments.quotationSerial & '_' & arguments.rowNumber );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteQuotationExported" );
				outcome.setMessage( "Cannot delete exported quotation with serial [#arguments.quotationSerial# and row: #arguments.rowNumber#]" );
			}
		}

		return outcome;
	}

	private com.apirone.core.model.bean.QuotationExported function buildRow( required String quotationSerial, required Numeric rowNumber ){
		var record = getDao().readRow( quotationSerial = arguments.quotationSerial, rowNumber = arguments.rowNumber );

		if ( record.recordCount ) {
			var bean = super.bean( "QuotationExported" );

			//testa
			bean.setKey( record.CF_IDCLI );
			bean.setCompany( record.CFDESCR1 );
			bean.setQuotationSerial( record.MMSERIAL );
			bean.setQuotationCode( record.MMNUMDOC );
			bean.setBillingStreet( record.CFINDIRI );
			bean.setBillingCity( record.CFLOCALI );
			bean.setBillingState( record.CFPROVIN );
			bean.setBillingCountry( record.CFSTAISO );
			bean.setVatNumber( record.CFPARIVA );
			bean.setShippingStreet( record.DEINDMER );
			bean.setShippingCity( record.DELOCMER );
			bean.setShippingState( record.DEPROMER );
			bean.setShippingCountry( record.DENAZMER );
			bean.setShippingDate( record.MMDATEVA );
			bean.setOpportunity( record.MMRIFORD );
			bean.setPricelist( record.MMNUMLIS );
			bean.setAgent( record.MMCODAGE );
			bean.setNotes( record.MMANNTES );
			//riga
			bean.setRowNumber( record.CPROWNUM );
			bean.setProductCode( record.MMCODART );
			bean.setVariantCode( record.MMCODVAR );
			bean.setColorCode( record.MMCODCOL );
			bean.setUm( record.MMUNIMIS );
			bean.setQuantity( record.MMQTAMOV );
			bean.setPrice( record.MMVALUNI );
			bean.setDiscount1( record.MMSCOAR1 );
			bean.setDiscount2( record.MMSCOAR2 );

			return bean;
		}

		return NullValue();
	}

}
