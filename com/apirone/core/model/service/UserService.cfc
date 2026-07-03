component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="UserDAO";
	property name="langService" inject="LangService";
	property name="statusService" inject="StatusService";
	property name="roleService" inject="RoleService";
	property name="accountService" inject="AccountService";

	public com.apirone.core.model.bean.User function get( required String userId ){
		return build( arguments.userId );
	}

	public String function create( required com.apirone.core.model.bean.User user ){

		var id = getDao().insert( argumentCollection = arguments );

		return id;
	}

	public String function update( required com.apirone.core.model.bean.User user ){

		var id = getDao().update( argumentCollection = arguments );

		return id;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String userId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.userId );

		outcome.setData( { userId = arguments.userId } );

		transaction {
			try {
				var result = getDao().delete( arguments.userId );
				outcome.setData( { "deletedCount" = result } )

			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.UserService.CannotDeleteUser" );
				outcome.setMessage( "Cannot delete user [#arguments.userId#]" );
			}
		}

		return outcome;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String roleId,
		String statusId,
		String accountId,
		String langId,
		required Numeric limit  = 50,
		required Numeric offset = 0
	){
		var rows   = [];
		var result = super.getResult();

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		if ( records.recordCount ) {
			// Raccoglie tutti gli ID e carica i record in blocco con una sola query
			var ids = [];
			for ( var record in records ) {
				ids.append( record.user_id );
			}

			// Costruisce tutti i bean in batch con getMany() ottimizzato (evita N+1)
			var beanMap = getMany( ids );

			// Ricostruisce le righe nell'ordine del find() originale
			for ( var record in records ) {
				if ( StructKeyExists( beanMap, record.user_id ) ) {
					rows.add( beanMap[ record.user_id ] );
				}
			}
		}

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	/*
		private methods
	*/

	/**
	 * Recupera in batch più User dato un array di ID.
	 * Restituisce uno Struct chiave = userId, valore = bean User.
	 * Precarica account, role, status e lang in batch per evitare il problema N+1.
	 *
	 * @ids Array di userId
	 * @return Struct mappato per userId -> User
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Raccoglie gli ID unici di tutte le FK da tutti i record
		var accountIds = [];
		var roleIds    = [];
		for ( var record in records ) {
			if ( !IsNull( record.account_id ) ) {
				accountIds.append( record.account_id.toString() );
			}
			if ( !IsNull( record.role_id ) ) {
				roleIds.append( record.role_id );
			}
		}

		// Precarica gli account in batch tramite AccountDAO.readByIds (AccountService non ha getMany())
		var accountMap = {};
		if ( ArrayLen( accountIds ) ) {
			var uniqueAccountIds = [];
			for ( var aid in accountIds ) {
				if ( !IsNull( aid ) && !ArrayContains( uniqueAccountIds, aid ) ) {
					uniqueAccountIds.append( aid );
				}
			}
			if ( ArrayLen( uniqueAccountIds ) ) {
				var accRecords = getAccountService().getDao().readByIds( uniqueAccountIds );
				for ( var ar in accRecords ) {
					var accBean = super.bean( "Account" );
					accBean.setId( ar.account_id.toString() );
					accBean.setEmail( ar.email );
					accBean.setName( ar.account );
					accBean.setPwd( ar.pwd );
					accBean.setSerial( ar.serial );
					accBean.setLastLoggedUserId( ar.last_logged_user_id );
					accBean.setCreatedAt( ar.created_at );
					accBean.setUserCount( ar.user_count );
					accBean.setIdUtenteVerticale( ar.id_utente_verticale );
					accBean.setIdAgenteVerticale( ar.id_agente_verticale );
					accBean.setStatus( getStatusService().get( ar.status_id ) );
					accountMap[ ar.account_id.toString() ] = accBean;
				}
			}
		}

		// Precarica i role in batch tramite RoleDAO.readByIds (RoleService non ha getMany())
		var roleMap = {};
		if ( ArrayLen( roleIds ) ) {
			var uniqueRoleIds = [];
			for ( var rid in roleIds ) {
				if ( !IsNull( rid ) && !ArrayContains( uniqueRoleIds, rid ) ) {
					uniqueRoleIds.append( rid );
				}
			}
			if ( ArrayLen( uniqueRoleIds ) ) {
				var roleRecords = getRoleService().getDao().readByIds( uniqueRoleIds );
				for ( var rr in roleRecords ) {
					var roleBean = super.bean( "Role" );
					roleBean.setName( rr.role );
					roleBean.setId( rr.role_id );
					roleBean.setCreatedAt( rr.created_at );
					roleBean.setQuotationMaxDiscount( rr.quotation_max_discount );
					roleBean.setQuotationMaxAmount( rr.quotation_max_amount );
					// roleType e permissions non precaricati in batch (sono leggeri)
					roleMap[ rr.role_id ] = roleBean;
				}
			}
		}

		// Cache locali per status e lang
		var statuses = {};
		var langs    = {};

		for ( var record in records ) {
			var user = super.bean( "User" );

			// Campi diretti dal record
			user.setId( record.user_id );
			user.setName( record.user_name );
			user.setSerial( record.serial );
			user.setPhone( record.phone );
			user.setCreatedAt( record.created_at );

			// Account: dalla mappa pre-caricata
			if ( !IsNull( record.account_id ) && StructKeyExists( accountMap, record.account_id.toString() ) ) {
				user.setAccount( accountMap[ record.account_id.toString() ] );
			}

			// Status: cached localmente
			if ( !StructKeyExists( statuses, record.status_id ) ) {
				statuses[ record.status_id ] = getStatusService().get( record.status_id );
			}
			user.setStatus( statuses[ record.status_id ] );

			// Role: dalla mappa pre-caricata
			if ( !IsNull( record.role_id ) && StructKeyExists( roleMap, record.role_id ) ) {
				user.setRole( roleMap[ record.role_id ] );
			}

			// Lang: cached localmente
			if ( !StructKeyExists( langs, record.lang_id ) ) {
				langs[ record.lang_id ] = getLangService().get( record.lang_id );
			}
			user.setLang( langs[ record.lang_id ] );

			map[ record.user_id ] = user;
		}

		return map;
	}

	private com.apirone.core.model.bean.User function buildFromRow( required any record ){
		var user = super.bean( "User" );

		// Campi diretti dal record
		user.setId( record.user_id );
		user.setName( record.user_name );
		user.setSerial( record.serial );
		user.setPhone( record.phone );
		user.setCreatedAt( record.created_at );

		// Entity collegate (caricate singolarmente)
		user.setAccount( getAccountService().get( record.account_id.toString() ) );
		user.setStatus( getStatusService().get( record.status_id ) );
		user.setRole( getRoleService().get( record.role_id ) );
		user.setLang( getLangService().get( record.lang_id ) );

		return user;
	}

	private com.apirone.core.model.bean.User function build( required String userId ){
		var record = getDao().read( userId = arguments.userId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

}
