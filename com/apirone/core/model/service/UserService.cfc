component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="UserDAO";
	property name="langService" inject="LangService";
	property name="statusService" inject="StatusService";
	property name="roleService" inject="RoleService";
	property name="accountService" inject="AccountService";

	property name="cacheScope" type="String" default="User.bean";

	public com.apirone.core.model.bean.User function get( required String userId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.userId );

		if ( cache.status ) {
			return cache.data;
		}

		var user = build( arguments.userId );
		cm.put( getCacheScope(), arguments.userId, user );

		return user;
	}

	public String function create( required com.apirone.core.model.bean.User user ){

		var id = getDao().insert( argumentCollection = arguments );

		getAccountService().removeCache( arguments.user.getAccount().getId() );

		return id;
	}

	public String function update( required com.apirone.core.model.bean.User user ){

		var id = getDao().update( argumentCollection = arguments );

		removeCache( id );

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

				removeCache( arguments.userId );

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

		var records = getDao().find( argumentCollection = arguments );

		for ( var record in records ) {
			rows.add( get( userId = record.user_id ) )
		}

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	/*
		private methods
	*/

	public Void function removeCache( required String id ){

		var cm = super.getCacheManager();

		var bean = get( arguments.id );

		getCacheManager().remove( getCacheScope(), arguments.id );

		getAccountService().removeCache( bean.getAccount().getId() )

	}

	private com.apirone.core.model.bean.User function build( required String userId ){
		var record = getDao().read( userId = arguments.userId );

		if ( record.RecordCount ) {
			var user = super.bean( "User" );

			user.setId( record.user_id );
			user.setName( record.user_name );
			user.setSerial( record.serial );
			user.setPhone( record.phone );
			//user.setApiKey( record.api_key );
			user.setCreatedAt( record.created_at );
			
			user.setAccount( getAccountService().get( record.account_id ) );
			user.setStatus( getStatusService().get( record.status_id ) );
			user.setRole( getRoleService().get( record.role_id ) );
			user.setLang( getLangService().get( record.lang_id ) );

			return user;
		}

		return NullValue();
	}

}
