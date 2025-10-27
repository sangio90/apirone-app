component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="AccountDAO";
	property name="langService" inject="LangService";
	property name="statusService" inject="StatusService";
	property name="roleService" inject="RoleService";
	property name="lookupService" inject="LookupService";

	property name="cacheScope" type="String" default="Account.bean";

	public com.apirone.core.model.bean.Account function get( required String accountId ){
		// var cm = getCacheManager();

		// var cache = cm.get( getCacheScope(), arguments.accountId );

		// if ( cache.status ) {
		// 	return cache.data;
		// }

		var account = build( arguments.accountId );
		// cm.put( getCacheScope(), arguments.accountId, account );

		return account;
	}

	public String function create( required com.apirone.core.model.bean.Account account ){
		if ( !Len( arguments.account.getEmail() ) ) {
			Throw(
				type    = "apirone.accountService.EmailNotProvided",
				message = "Account [#arguments.accountId#] not exists"
			);
		};

		if ( !Len( arguments.account.getPwd() ) ) {
			Throw( type = "apirone.accountService.PasswordNotProvided", message = "Password is required" );
		};

		var id = getDao().insert( argumentCollection = arguments );

		setPassword( id, arguments.account.getPwd() );

		return id;
	}

	public String function update( required com.apirone.core.model.bean.Account account ){
		if ( !Len( arguments.account.getEmail() ) ) {
			Throw(
				type    = "apirone.accountService.EmailNotProvided",
				message = "Account [#arguments.accountId#] not exists"
			);
		};

		var id = getDao().update( argumentCollection = arguments );

		getCacheManager().remove( getCacheScope(), arguments.account.getId() );

		return id;
	}

	public Boolean function updatePassword(
		required String accountId,
		required String pwd
	){
		getDao().updatePassword( arguments.accountId, pwd );

		return true;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String accountId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.accountId );

		outcome.setData( { accountId = arguments.accountId } );

		transaction {
			try {
				var result = getDao().delete( arguments.accountId );
				outcome.setData( { "deletedCount" = result } )

				getCacheManager().remove( getCacheScope(), arguments.accountId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.accountService.CannotDeleteAccount" );
				outcome.setMessage( "Cannot delete account [#arguments.accountId#]" );
			}
		}

		return outcome;
	}

	/*
		TODO: replace name with updatePassword
	*/
	public Boolean function setPassword( required String accountId, required String newPwd ){
		var obj = get( arguments.accountId )

		if ( IsNull( obj ) ) {
			Throw(
				type    = "apirone.accountService.AccountNotExists",
				message = "AccountId [#arguments.accountId#] not exists"
			);
		}

		if ( !Len( arguments.newPwd ) ) {
			Throw( type = "apirone.accountService.PasswordNotProvided", message = "Password is required" );
		};

		var pwd = createPassword( arguments.accountId, arguments.newPwd );

		getDao().updatePassword( arguments.accountId, pwd );

		getCacheManager().remove( getCacheScope(), arguments.accountId );

		return true;
	}

	public Boolean function emailExists( required String email, String excludedId = "" ){
		var record = getDao().readByEmail( arguments.email );

		if (
			record.recordCount
			&& record.account_id != arguments.excludedId
		) {
			return record.email == arguments.email;
		}

		return false;
	}


	public com.apirone.core.model.bean.Account function getByEmail( required String email ){
		if ( !Len( arguments.email ) ) {
			Throw( type = "apirone.EmailNotProvided", message = "Account [#arguments.accountId#] not exists" );
		};
		
		var accounts = search( email = arguments.email ).getData();

		if ( !IsNull( accounts[ 1 ] ) ) {
			return get( accountId = accounts[ 1 ].getId() );
		}

		return NullValue();
	}

	public com.apirone.core.model.bean.Result function search(
		String email,
		required Numeric limit  = 50,
		required Numeric offset = 0
	){
		var rows   = [];
		var result = super.getResult();

		var records = getDao().find( argumentCollection = arguments );

		for ( var record in records ) {
			rows.add( get( accountId = record.account_id ) )
		}

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public String function createPassword( required String accountId, required String pwd ){
		var token =
		"jbGM,xxJJaJX-ol@@5m88" &
		arguments.accountId &
		"HTt,Tgajiawsui7,9iR09" &
		arguments.pwd;

		return Hash( token, "SHA-512" );
	}

	/**
	 * @private
	 */
	private com.apirone.core.model.bean.Account function build( required String accountId ){
		var record = getDao().read( accountId = arguments.accountId );

		var account = NullValue();

		if ( record.RecordCount ) {
			var account = super.bean( "Account" );
			var roles   = [];

			account.setId( record.account_id );
			account.setEmail( record.email );
			account.setName( record.account );
			account.setPwd( record.pwd );
			account.setSerial( record.serial );

			account.setApiKey( record.api_key );
			account.setCreatedAt( record.created_at );

			account.setStatus( getStatusService().get( record.status_id ) );
			account.setRole( getRoleService().get( record.role_id ) );

			// INFO:
			// roles::varchar converts null value to "null" word. I didn't find anything better.
			// I didn't want to bring the org.postgresql.util.PGobject object into the service.

			// if( !IsNull( record.roles ) AND IsJSON( record.roles.toString() != 'null' ) {

			var thisRoles = DeserializeJSON( record.roles );

			if ( !IsNull( thisRoles ) ) {
				thisRoles.each( function( item ){
					var role = getRoleService().get( item );
					roles.add( role );
				} );
			}

			account.setRoles( roles );

			account.setLang( getLangService().get( record.lang_id ) );
		}

		return account;
	}

}
