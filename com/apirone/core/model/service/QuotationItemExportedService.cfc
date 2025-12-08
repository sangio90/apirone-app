component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemExportedDAO";
	property name="cacheScope" type="String" default="QuotationItemExported.bean";
	property name="rowCacheScope" type="String" default="QuotationItemExportedRow.bean";

	public com.apirone.core.model.bean.QuotationItemExported function get( required String key ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.key );
		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.key );
		cm.put( getCacheScope(), arguments.key, bean );

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
		required Array orderBy  = [ { field = "quotationItemExported.exportDate", dir = "DESC" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( key = record.AR_CHIAVE ) );
		} );

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
				var cm = getCacheManager();

				getDao().delete( arguments.key );

				cm.remove( getCacheScope(), arguments.key );
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

	private com.apirone.core.model.bean.QuotationItemExported function build( required String key ){
		var record = getDao().read( arguments.key );

		if ( record.recordCount ) {
			var bean = super.bean( "QuotationItemExported" );

			bean.setKey( record.AR_CHIAVE );
			bean.setCode( record.ARCODART );
			bean.setDescription( record.ARDESART );
			bean.setUm( record.ARUNMIS1 );
			bean.setVariant( record.VARCOD );
			bean.setColor( record.CLCODICE );
			bean.setExportDate( record.ARDATCAR );
			bean.setNotes( record.CLANNOTA );
			bean.setStatus( record.AR_STATO );

			return bean;
		}

		return NullValue();
	}

	//ROWS

	public com.apirone.core.model.bean.QuotationItemExportedRow function getRow( required String key, required Numeric rowNumber ){
		var cm = getCacheManager();

		var cache = cm.get( getRowCacheScope(), arguments.key & '_' & arguments.rowNumber );
		if ( cache.status ) {
			return cache.data;
		}

		var bean = buildRow( key = arguments.key, rowNumber = arguments.rowNumber );
		cm.put( getRowCacheScope(), arguments.key & '_' & arguments.rowNumber, bean );

		return bean;
	}

	public com.apirone.core.model.bean.Result function searchRows(
		required Numeric limit  = -1,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "quotationItemExportedRows.rowNumber" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().findRows( argumentCollection = { key = arguments.key } );

		records.each( function( record ){
			rows.add( getRow( key = record.DS_CHIAVE, rowNumber = records.CPROWNUM ) );
		} );

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
				var cm = getCacheManager();
				
				getDao().deleteRow( key = arguments.key, rowNumber = arguments.rowNumber );

				cm.remove( getCacheScope(), arguments.key & '_' & arguments.rowNumber );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteQuotationExported" );
				outcome.setMessage( "Cannot delete quotation exported row [#arguments.key# row: #arguments.rowNumber#]" );
			}
		}

		return outcome;
	}

	private com.apirone.core.model.bean.QuotationItemExportedRow function buildRow( required String key, required Numeric rowNumber ){
		var record = getDao().readRow( key = arguments.key, rowNumber = arguments.rowNumber );

		if ( record.recordCount ) {
			var bean = super.bean( "QuotationItemExportedRow" );

			bean.setKey( record.DS_CHIAVE );
			bean.setRowNumber( record.CPROWNUM );
			bean.setCode( record.DSCODMAT );
			bean.setUm( record.DSUNMIS1 );
			bean.setVariant( record.DSVARMAT );
			bean.setColor( record.DSCOLMAT );
			bean.setQuantity( record.DSQTAMOV );
			bean.setNotes( record.DSANNOTA );

			return bean;
		}

		return NullValue();
	}

}
