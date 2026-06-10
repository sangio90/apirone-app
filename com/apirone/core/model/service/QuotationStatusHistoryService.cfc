component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationStatusHistoryDAO";
	property name="QuotationService" inject="QuotationService";
	property name="UserService" inject="UserService";
	property name="StatusService" inject="StatusService";
	property name="FileService" inject="FileService";

	public com.apirone.core.model.bean.QuotationStatusHistory function get( required String quotationStatusHistoryId ){
		return build( arguments.quotationStatusHistoryId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		String quotationId,
		required Numeric limit  = 15,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "createdAt", dir = "desc" } ]
	){
		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var rows    = [];
		var result  = super.getResult();

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		if ( records.recordCount ) {
			// Raccoglie tutti gli ID e carica i record in blocco con una sola query
			var ids = [];
			for ( var record in records ) {
				ids.append( record.quotation_status_history_id );
			}

			var loadedRecords = getDao().readByIds( ids );
			var recordMap = {};
			for ( var loadedRecord in loadedRecords ) {
				recordMap[ loadedRecord.quotation_status_history_id ] = loadedRecord;
			}

			// Ricostruisce le righe nell'ordine del find() originale
			for ( var record in records ) {
				var fullRecord = recordMap[ record.quotation_status_history_id ];
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

	public com.apirone.core.model.bean.Outcome function delete( required String quotationStatusHistoryId ){
		var outcome = super.bean( "Outcome" );
		var obj     = get( arguments.quotationStatusHistoryId );

		outcome.setData( { quotationStatusHistoryId = arguments.quotationStatusHistoryId } );
		
		transaction {
			try {
				getDao().delete( arguments.quotationStatusHistoryId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.errors.QuotationStatusHistoryService.CannotDeleteQuotationStatusHistory" );
				outcome.setMessage( "Cannot delete quotation status history [#arguments.quotationStatusHistoryId#]" );
			}
		}
		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.QuotationStatusHistory quotationStatusHistory ){
		var newId = getDao().insert( arguments.quotationStatusHistory );

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.QuotationStatusHistory quotationStatusHistory ){
		getDao().update( arguments.quotationStatusHistory );

		return arguments.quotationStatusHistory.getId();
	}

	private com.apirone.core.model.bean.QuotationStatusHistory function buildFromRow( required any record ){
		var bean = super.bean( "QuotationStatusHistory" );

		// Campi diretti dal record
		bean.setId( record.quotation_status_history_id );
		bean.setQuotationId( record.quotation_id );
		bean.setCreatedAt( record.created_at );

		// Entity collegate (caricate singolarmente)
		bean.setUser( getUserService().get( record.user_id ) );
		bean.setStatus( getStatusService().get( record.status_id ) );

		var params = {
			quotationStatusHistoryId = record.quotation_status_history_id,
			orderBy  = [ { field = "file.createdAt", dir = "desc" } ]
		}

		var files = getFileService().list( argumentCollection = params );

		if ( Len( files ) ) {
			bean.setFile( files[ 1 ] );
		}

		return bean;
	}

	private com.apirone.core.model.bean.QuotationStatusHistory function build( required String quotationStatusHistoryId ){
		var record = getDao().read( arguments.quotationStatusHistoryId );
		if ( record.recordCount ) {
			return buildFromRow( record );
		}
		return NullValue();
	}

}
