component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationStatusHistoryDAO";
	property name="QuotationService" inject="QuotationService";
	property name="AccountService" inject="AccountService";
	property name="StatusService" inject="StatusService";
	property name="FileService" inject="FileService";
	property name="cacheScope" type="String" default="QuotationStatusHistory.bean";

	public com.apirone.core.model.bean.QuotationStatusHistory function get( required String quotationStatusHistoryId ){
		var cm    = getCacheManager();
		var cache = cm.get( getCacheScope(), arguments.quotationStatusHistoryId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.quotationStatusHistoryId );
		cm.put( getCacheScope(), arguments.quotationStatusHistoryId, bean );

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
		required Array orderBy  = [ { field = "createdAt", dir = "desc" } ]
	){
		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var rows    = [];
		var result  = super.getResult();
		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( quotationStatusHistoryId = record.quotation_status_history_id ) );
		} );
		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String quotationStatusHistoryId ){
		var outcome = super.bean( "Outcome" );
		var obj     = get( arguments.quotationStatusHistoryId );

		outcome.setData( { quotationStatusHistoryId = arguments.quotationStatusHistoryId } );
		
		var cm = getCacheManager();
		
		transaction {
			try {
				getDao().delete( arguments.quotationStatusHistoryId );
				cm.remove( getCacheScope(), arguments.quotationStatusHistoryId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteQuotationStatusHistory" );
				outcome.setMessage( "Cannot delete Quotation Status History [#arguments.quotationStatusHistoryId#]" );
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
		super.getCacheManager().remove( getCacheScope(), arguments.quotationStatusHistory.getId() );

		return arguments.quotationStatusHistory.getId();
	}

	private com.apirone.core.model.bean.QuotationStatusHistory function build( required String quotationStatusHistoryId ){
		var record = getDao().read( arguments.quotationStatusHistoryId );
		if ( record.recordCount ) {

			var bean = super.bean( "QuotationStatusHistory" );

			bean.setId( record.quotation_status_history_id );
			bean.setQuotationId( record.quotation_id );
			bean.setAccount( getAccountService().get( record.account_id ) );
			bean.setStatus( getStatusService().get( record.status_id ) );

			var files = getFileService().list( quotationStatusHistoryId = record.quotation_status_history_id );

			if ( Len( files ) ) {
				bean.setFile( files[ 1 ] );
			}
			
			bean.setCreatedAt( record.created_at );

			return bean;
		}
		return NullValue();
	}

}
