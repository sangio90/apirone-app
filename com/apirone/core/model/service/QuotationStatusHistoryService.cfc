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

			// Costruisce tutti i bean in batch con getMany() ottimizzato (evita N+1)
			var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

			// Ricostruisce le righe nell'ordine del find() originale
			for ( var record in records ) {
				if ( StructKeyExists( beanMap, record.quotation_status_history_id ) ) {
					rows.add( beanMap[ record.quotation_status_history_id ] );
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

	/**
	 * Recupera in batch più QuotationStatusHistory dato un array di ID.
	 * Restituisce uno Struct chiave = quotationStatusHistoryId, valore = bean QuotationStatusHistory.
	 * Precarica User, Status e File in batch per evitare il problema N+1.
	 *
	 * @ids Array di quotationStatusHistoryId
	 * @return Struct mappato per quotationStatusHistoryId -> QuotationStatusHistory
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Raccoglie tutti gli user_id per precaricarli in batch
		var userIds = [];
		for ( var record in records ) {
			if ( !IsNull( record.user_id ) ) {
				userIds.append( record.user_id );
			}
		}

		// Precarica gli User in batch (via readByIds del DAO, senza getMany pubblico)
		var userMap = {};
		if ( ArrayLen( userIds ) ) {
			var userRecords = getUserService().getDao().readByIds( userIds );
			for ( var ur in userRecords ) {
				var userBean = super.bean( "User" );
				userBean.setId( ur.user_id );
				userBean.setName( ur.user_name );
				userBean.setSerial( ur.serial );
				userBean.setPhone( ur.phone );
				userBean.setCreatedAt( ur.created_at );
				userMap[ ur.user_id ] = userBean;
			}
		}

		// Precarica i File in batch per tutti gli history_id
		var fileMap = getFileService().listByEntityIds( "quotationStatusHistory.id", arguments.ids );

		// Cache locale per status
		var statuses = {};

		for ( var record in records ) {
			var bean = super.bean( "QuotationStatusHistory" );

			// Campi diretti dal record
			bean.setId( record.quotation_status_history_id );
			bean.setQuotationId( record.quotation_id );
			bean.setCreatedAt( record.created_at );

			// User: dalla mappa pre-caricata
			if ( StructKeyExists( userMap, record.user_id ) ) {
				bean.setUser( userMap[ record.user_id ] );
			}

			// Status: cached localmente
			if ( !StructKeyExists( statuses, record.status_id ) ) {
				statuses[ record.status_id ] = getStatusService().get( record.status_id );
			}
			bean.setStatus( statuses[ record.status_id ] );

			// File: dalla mappa pre-caricata (prende il primo)
			if ( StructKeyExists( fileMap, record.quotation_status_history_id ) && ArrayLen( fileMap[ record.quotation_status_history_id ] ) ) {
				bean.setFile( fileMap[ record.quotation_status_history_id ][ 1 ] );
			}

			map[ record.quotation_status_history_id ] = bean;
		}

		return map;
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
