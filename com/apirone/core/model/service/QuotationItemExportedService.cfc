component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemExportedDAO";

	public com.apirone.core.model.bean.QuotationItemExported function get( required String key ){
		return build( arguments.key );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		required Numeric limit  = 15,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "quotationItemExported.exportDate", dir = "DESC" } ]
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
				ids.append( record.AR_CHIAVE );
			}

			var loadedRecords = getDao().readByIds( ids );
			var recordMap = {};
			for ( var loadedRecord in loadedRecords ) {
				recordMap[ loadedRecord.AR_CHIAVE ] = loadedRecord;
			}

			// Ricostruisce le righe nell'ordine del find() originale
			for ( var record in records ) {
				var fullRecord = recordMap[ record.AR_CHIAVE ];
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

	public com.apirone.core.model.bean.Outcome function delete( required String key ){
		var outcome = super.bean( "Outcome" );
		var obj     = get( arguments.key );

		outcome.setData( { key = arguments.key } );

		transaction {
			try {
				getDao().delete( arguments.key );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteQuotationExported" );
				outcome.setMessage( "Cannot delete quotation exported [#arguments.key#]" );
			}
		}

		return outcome;
	}

	/*
		private method
	*/

	private com.apirone.core.model.bean.QuotationItemExported function buildFromRow( required any record ){
		var bean = super.bean( "QuotationItemExported" );

		// Campi diretti dal record
		bean.setKey( record.AR_CHIAVE );
		bean.setCode( record.ARCODART );
		bean.setDescription( record.ARDESART );
		bean.setUm( record.ARUNMIS1 );
		bean.setVariant( record.VARCOD );
		bean.setColor( record.CLCODICE );
		bean.setExportDate( record.ARDATCAR );
		bean.setNote( record.CLANNOTA );
		bean.setStatus( record.AR_STATO );

		return bean;
	}

	private com.apirone.core.model.bean.QuotationItemExported function build( required String key ){
		var record = getDao().read( arguments.key );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	//ROWS

	public com.apirone.core.model.bean.QuotationItemExportedRow function getRow( required String key, required Numeric rowNumber ){
		return buildRow( key = arguments.key, rowNumber = arguments.rowNumber );
	}

	public com.apirone.core.model.bean.Result function searchRows(
		required String key,
		required Numeric limit  = -1,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "quotationItemExportedRows.rowNumber" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		// Primo passaggio: il findRows() restituisce solo le chiavi (più il totale per paginazione)
		var records = getDao().findRows( argumentCollection = { key = arguments.key } );

		if ( records.recordCount ) {
			// Carica tutte le righe per questa chiave in una sola query
			var loadedRecords = getDao().readRowsByKey( arguments.key );
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

	public com.apirone.core.model.bean.Outcome function deleteRow( required String key, required Numeric rowNumber ){
		var outcome = super.bean( "Outcome" );
		var obj     = getRow( key = arguments.key, rowNumber = arguments.rowNumber );

		outcome.setData( { key = arguments.key, rowNumber = arguments.rowNumber } );
		
		transaction {
			try {
				getDao().deleteRow( key = arguments.key, rowNumber = arguments.rowNumber );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteQuotationExported" );
				outcome.setMessage( "Cannot delete quotation exported row [#arguments.key# row: #arguments.rowNumber#]" );
			}
		}

		return outcome;
	}

	private com.apirone.core.model.bean.QuotationItemExportedRow function buildRowFromRow( required any record ){
		var bean = super.bean( "QuotationItemExportedRow" );

		// Campi diretti dal record
		bean.setKey( record.DS_CHIAVE );
		bean.setRowNumber( record.CPROWNUM );
		bean.setCode( record.DSCODMAT );
		bean.setUm( record.DSUNMIS1 );
		bean.setVariant( record.DSVARMAT );
		bean.setColor( record.DSCOLMAT );
		bean.setQuantity( record.DSQTAMOV );
		bean.setNote( record.DSANNOTA );

		return bean;
	}

	private com.apirone.core.model.bean.QuotationItemExportedRow function buildRow( required String key, required Numeric rowNumber ){
		var record = getDao().readRow( key = arguments.key, rowNumber = arguments.rowNumber );

		if ( record.recordCount ) {
			return buildRowFromRow( record );
		}

		return NullValue();
	}

}
