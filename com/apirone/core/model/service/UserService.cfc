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

			var loadedRecords = getDao().readByIds( ids );
			var recordMap = {};
			for ( var loadedRecord in loadedRecords ) {
				recordMap[ loadedRecord.user_id ] = loadedRecord;
			}

			// Ricostruisce le righe nell'ordine del find() originale
			for ( var record in records ) {
				var fullRecord = recordMap[ record.user_id ];
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

	/*
		private methods
	*/

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
