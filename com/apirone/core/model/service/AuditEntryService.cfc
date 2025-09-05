component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="AuditEntryDAO";
	property name="accountService" inject="AccountService";

	property name="cacheScope" type="String" default="AuditEntry.bean";

	public com.apirone.core.model.bean.AuditEntry function get( required String auditEntryId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.auditEntryId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.auditEntryId );
		cm.put( getCacheScope(), arguments.auditEntryId, bean );

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}


	public com.apirone.core.model.bean.Result function search(
		String str,
		Date fromDate,
		Date toDate,
		String entityId,
		String actionId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "auditEntry.id", dir = "desc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( auditEntryId = record.audit_log_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.AuditEntry function build( required String auditEntryId ){
		var record = getDao().read( arguments.auditEntryId );

		if ( record.recordCount ) {
			//var bean = super.bean( "AuditEntry" ); // non è di tipo AbsBean
			var bean = new com.apirone.core.model.bean.AuditEntry();

			bean.setId( record.audit_log_id );
			bean.setMessage( record.message );
			bean.setAction( record.action );
			bean.setEntity( record.entity );
			bean.setSeverity( record.severity );
			bean.setAccount( getAccountService().get( record.account_id ) );
			bean.setCreatedAt( record.created_at );
			bean.setIpAddress( record.ip_address );
			bean.setUserAgent( record.user_agent );
			bean.setPayload( DeserializeJSON( record.payload.toString() ) );

			return bean;
		}

		return NullValue();
	}

}
