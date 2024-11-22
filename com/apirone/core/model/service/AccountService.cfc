component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao"           type="com.apirone.core.model.dao.AccountDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";
	property name="lookupService" type="com.apirone.core.model.service.LookupService";
	property name="langService"   type="com.apirone.core.model.service.LangService";

	public com.apirone.core.model.bean.Account function get(
		required String accountId
	){
		var cm = getCacheManager();

		var key = getCacheKey( arguments.accountId );

		var cache = cm.get( key );

		if ( cache.status ) {
			return cache.data;
		}

		var account = build( arguments.accountId );
		cm.put( key, account );

		return account;
	}

	public Boolean function loginExists(
		required String login
	){
		var records = getDao().find( argumentCollection = arguments );

		return booleanFormat( records.RecordCount );
	}

	public String function create(
		required com.apirone.core.model.bean.Account account
	){
		if ( !len( arguments.account.getLogin() ) ) {
			throw( type = "apirone.LoginNotProvided", message = "Login required" );
		};

		if ( !len( arguments.account.getPwd() ) ) {
			throw( type = "apirone.PasswordNotProvided", message = "Password required" );
		};

		var id = getDao().insert( argumentCollection = arguments );

		setPassword( id, arguments.account.getPwd() );

		return id;
	}

	public Boolean function updatePassword(
		required String pwd,
		required String accountId
	){
		getDao().updatePassword( arguments.accountId, pwd );

		return true;
	}

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

				getCacheManager().remove( getCacheKey( arguments.accountId ) );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteAccount" );
				outcome.setMessage( "Cannot delete account [#arguments.accountId#]" );
			}
		}

		return outcome;
	}

	public Boolean function setPassword(
		required String accountId,
		required String newPwd
	){
		var pwd = createPassword( arguments.accountId, arguments.newPwd );

		getDao().updatePassword( arguments.accountId, pwd );

		getCacheManager().remove( getCacheKey( arguments.accountId ) );

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
			throw( type = "apirone.EmailNotProvided", message = "Email required" );
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

	private String function getCacheKey(
		required String id
	){
		return "Account_#arguments.id#";
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

			account.setId( record.account_id.toString() );
			account.setEmail( record.email );
			account.setName( record.name );
			account.setPwd( record.pwd );
			account.setSerial( record.serial );

			account.setApiKey( record.api_key );
			account.setCreatedAt( record.created_at );

			account.setStatus( getStatusService().get( record.status_id ) );
			account.setRole( getLookupService().get( "role", record.role_id ) );

			account.setLang( getLangService().get( record.lang_id ) );
		}

		return account;
	}

}
