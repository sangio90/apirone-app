component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao"           type="com.apirone.core.model.dao.AccountDAO";
	property name="langService"   type="com.apirone.core.model.service.LangService";
	property name="statusService" type="com.apirone.core.model.service.StatusService";
	property name="lookupService" type="com.apirone.core.model.service.LookupService";

	property name="cacheScope" type="String" default="Account.bean";

	public com.apirone.core.model.bean.Account function get(
		required String accountId
	){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.accountId );

		if ( cache.status ) {
			return cache.data;
		}

		var account = build( arguments.accountId );
		cm.put( getCacheScope(), arguments.accountId, account );

		return account;
	}

	public String function create(
		required com.apirone.core.model.bean.Account account
	){
		if ( !len( arguments.account.getEmail() ) ) {
			throw( type = "apirone.accountService.EmailNotProvided", message = "Account [#arguments.accountId#] not exists" );
		};

		if ( !len( arguments.account.getPwd() ) ) {
			throw( type = "apirone.accountService.PasswordNotProvided", message = "Password is required" );
		};

		var id = getDao().insert( argumentCollection = arguments );

		setPassword( id, arguments.account.getPwd() );

		return id;
	}

	public String function update(
		required com.apirone.core.model.bean.Account account
	){
		if ( !len( arguments.account.getEmail() ) ) {
			throw( type = "apirone.accountService.EmailNotProvided", message = "Account [#arguments.accountId#] not exists" );
		};

		var id = getDao().update( argumentCollection = arguments );

		getCacheManager().remove( getCacheScope(), arguments.account.getId() );

		return id;
	}

	/*
	public Boolean function updatePassword(
		required String accountId,
		required String pwd
	){
		getDao().updatePassword( arguments.accountId, pwd );

		return true;
	}
	*/

	public com.apirone.core.model.bean.Outcome function delete(
		required String accountId
	){
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
	public Boolean function setPassword(
		required String accountId,
		required String newPwd
	){

		var obj = get( arguments.accountId )

		if( IsNull( obj ) ) {
			throw( type = "apirone.accountService.AccountNotExists", message = "Account id [#arguments.accountId#] not exists" );
		}

		if ( !len( arguments.newPwd ) ) {
			throw( type = "apirone.accountService.PasswordNotProvided", message = "Password is required" );
		};

		var pwd = createPassword( arguments.accountId, arguments.newPwd );

		getDao().updatePassword( arguments.accountId, pwd );

		getCacheManager().remove( getCacheScope(), arguments.accountId );

		return true;
	}

	public Boolean function emailExists(
		required String email,
		String excludedId = ""
	){
		var record = getDao().readByEmail( arguments.email );

		if (
			record.recordCount
			&& record.account_id != arguments.excludedId
		) {
			return record.email == arguments.email;
		}

		return false;
	}


	public com.apirone.core.model.bean.Account function getByEmail(
		required String email
	){
		if ( !len( arguments.email ) ) {
			throw( type = "apirone.EmailNotProvided", message = "Account [#arguments.accountId#] not exists" );
		};

		var accounts = search( email = arguments.email ).getData();

		if ( !isNull( accounts[ 1 ] ) ) {
			return get( accountId = accounts[ 1 ].getId() );
		}

		return nullValue();
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
		result.setCount( val( records.recordcount ) );
		result.setTotal( val( records.total ) );

		return result;
	}

	public String function createPassword(
		required String accountId,
		required String pwd
	){
		var token =
		"jbGM,xxJJaJX-ol@@5m88" &
		arguments.accountId &
		"HTt,Tgajiawsui7,9iR09" &
		arguments.pwd;

		return hash( token, "SHA-512" );
	}

	/**
	 * @private
	 */
	private com.apirone.core.model.bean.Account function build(
		required String accountId
	){
		var record = getDao().read( accountId = arguments.accountId );

		var account = nullValue();

		if ( record.RecordCount ) {

			var account = super.bean( "Account" );
			var roles = [];

			account.setId( record.account_id );
			account.setEmail( record.email );
			account.setName( record.account );
			account.setPwd( record.pwd );
			account.setSerial( record.serial );

			account.setApiKey( record.api_key );
			account.setCreatedAt( record.created_at );

			account.setStatus( getStatusService().get( record.status_id ) );
			account.setRole( getLookupService().get( "role", record.role_id ) );

			// INFO: 
			// roles::varchar converts null value to "null" word. I didn't find anything better.
			// I didn't want to bring the org.postgresql.util.PGobject object into the service.
	
			//if( !IsNull( record.roles ) AND IsJSON( record.roles.toString() != 'null' ) {

			var thisRoles = DeserializeJSON( record.roles );

			if( !IsNull( thisRoles ) ) {

				thisRoles.each( function( item ){
				
					var role = getLookupService().get( "role", item );
					roles.add( role );
				
				});
			
			}

			account.setRoles( roles );

			account.setLang( getLangService().get( record.lang_id ) );

		}

		return account;
	}

}
