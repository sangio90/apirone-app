component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationExportedDAO";

	public com.apirone.core.model.bean.QuotationExported function get( required String quotationSerial ){
		return build( arguments.quotationSerial );
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

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		if ( records.recordCount ) {
			// Raccoglie tutti gli ID e carica i record in blocco con una sola query
			var ids = [];
			for ( var record in records ) {
				ids.append( record.MMSERIAL );
			}

			var loadedRecords = getDao().readByIds( ids );
			var recordMap = {};
			for ( var loadedRecord in loadedRecords ) {
				recordMap[ loadedRecord.MMSERIAL ] = loadedRecord;
			}

			// Ricostruisce le righe nell'ordine del find() originale
			for ( var record in records ) {
				var fullRecord = recordMap[ record.MMSERIAL ];
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

	public com.apirone.core.model.bean.Outcome function delete( required String quotationSerial ){
		var outcome = super.bean( "Outcome" );
		var obj     = get( arguments.quotationSerial );

		outcome.setData( { quotationSerial = arguments.quotationSerial } );

		transaction {
			try {
				getDao().delete( arguments.quotationSerial );
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

	private com.apirone.core.model.bean.QuotationExported function buildFromRow( required any record ){
		var bean = super.bean( "QuotationExported" );

		// Campi diretti dal record - testa
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
		bean.setNote( record.MMANNTES );
		// Campi diretti dal record - riga
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

	private com.apirone.core.model.bean.QuotationExported function build( required String quotationSerial ){
		var record = getDao().read( arguments.quotationSerial );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	//ROWS

	public com.apirone.core.model.bean.QuotationExported function getRow( required String quotationSerial, required Numeric rowNumber ){
		return buildRow( quotationSerial = arguments.quotationSerial, rowNumber = arguments.rowNumber );
	}

	public com.apirone.core.model.bean.Result function searchRows(
		required String quotationSerial,
		required Numeric limit  = -1,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "quotationExported.rowNumber" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		// Primo passaggio: il findRows() restituisce solo le chiavi (più il totale per paginazione)
		var records = getDao().findRows( argumentCollection = { quotationSerial = arguments.quotationSerial } );

		if ( records.recordCount ) {
			// Carica tutte le righe per questo serial in una sola query
			var loadedRecords = getDao().readRowsBySerial( arguments.quotationSerial );
			var recordMap = {};
			for ( var loadedRecord in loadedRecords ) {
				recordMap[ loadedRecord.CPROWNUM ] = loadedRecord;
			}

			// Ricostruisce le righe nell'ordine del findRows() originale
			for ( var record in records ) {
				var fullRecord = recordMap[ record.CPROWNUM ];
				if ( !IsNull( fullRecord ) ) {
					rows.add( buildRowFromRow( fullRecord ) );
				}
			}
		}

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
				getDao().deleteRow( quotationSerial = arguments.quotationSerial, rowNumber = arguments.rowNumber );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteQuotationExported" );
				outcome.setMessage( "Cannot delete exported quotation with serial [#arguments.quotationSerial# and row: #arguments.rowNumber#]" );
			}
		}

		return outcome;
	}

	private com.apirone.core.model.bean.QuotationExported function buildRowFromRow( required any record ){
		var bean = super.bean( "QuotationExported" );

		// Campi diretti dal record: testa
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
		bean.setNote( record.MMANNTES );
		// Campi diretti dal record: riga
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

	private com.apirone.core.model.bean.QuotationExported function buildRow( required String quotationSerial, required Numeric rowNumber ){
		var record = getDao().readRow( quotationSerial = arguments.quotationSerial, rowNumber = arguments.rowNumber );

		if ( record.recordCount ) {
			return buildRowFromRow( record );
		}

		return NullValue();
	}

}
