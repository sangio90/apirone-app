component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="AuditEntryDAO";
	property name="userService" inject="UserService";

	public com.apirone.core.model.bean.AuditEntry function get( required String auditEntryId ){
		return build( arguments.auditEntryId );
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

		// Raccoglie gli ID restituiti dalla find per un caricamento batch
		var ids = [];
		for ( var record in records ) {
			ids.add( record.audit_log_id );
		}

		// Carica i bean in blocco con getMany()
		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Itera i record originali per preservare l'ordinamento della find
		for ( var record in records ) {
			rows.add( beanMap[ record.audit_log_id ] );
		}

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	/**
	 * Recupera in batch più AuditEntry dato un array di ID.
	 * Restituisce uno Struct chiave = auditLogId, valore = bean AuditEntry.
	 * Precarica gli User in batch locale per evitare il problema N+1.
	 *
	 * @ids Array di auditLogId
	 * @return Struct mappato per auditLogId -> AuditEntry
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};
		var users   = {};

		for ( var record in records ) {
			var bean = new com.apirone.core.model.bean.AuditEntry();

			// Campi diretti dal record
			bean.setId( record.audit_log_id );
			bean.setMessage( record.message );
			bean.setAction( record.action );
			bean.setEntity( record.entity );
			bean.setSeverity( record.severity );
			bean.setCreatedAt( record.created_at );
			bean.setIpAddress( record.ip_address );
			bean.setUserAgent( record.user_agent );
			bean.setPayload( DeserializeJSON( record.payload.toString() ) );

			// User: cached localmente per evitare chiamate N+1
			if ( !StructKeyExists( users, record.user_id ) ) {
				users[ record.user_id ] = getUserService().get( record.user_id );
			}
			bean.setUser( users[ record.user_id ] );

			map[ bean.getId() ] = bean;
		}

		return map;
	}


	/**
	 * Costruisce un bean AuditEntry a partire da una riga della query.
	 */
	private com.apirone.core.model.bean.AuditEntry function buildFromRow( required any record ){
		// AuditEntry non estende AbsBean: istanziazione diretta
		var bean = new com.apirone.core.model.bean.AuditEntry();

		bean.setId( record.audit_log_id );
		bean.setMessage( record.message );
		bean.setAction( record.action );
		bean.setEntity( record.entity );
		bean.setSeverity( record.severity );
		// Entity collegata (User è un lookup leggero)
		bean.setUser( getUserService().get( record.user_id ) );
		bean.setCreatedAt( record.created_at );
		bean.setIpAddress( record.ip_address );
		bean.setUserAgent( record.user_agent );
		bean.setPayload( DeserializeJSON( record.payload.toString() ) );

		return bean;
	}

	private com.apirone.core.model.bean.AuditEntry function build( required String auditEntryId ){
		var record = getDao().read( arguments.auditEntryId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

}
