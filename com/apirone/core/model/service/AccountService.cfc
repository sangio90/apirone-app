component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="AccountDAO";
	property name="langService" inject="LangService";
	property name="statusService" inject="StatusService";
	property name="roleService" inject="RoleService";
	property name="lookupService" inject="LookupService";

	public com.apirone.core.model.bean.Account function get( required String accountId ){
		return build( arguments.accountId );
	}

	public String function create( required com.apirone.core.model.bean.Account account ){
		if ( !Len( arguments.account.getEmail() ) ) {
			Throw(
				type    = "apirone.accountService.EmailNotProvided",
				message = "Account [#arguments.account.getId()#] not exists"
			);
		};

		if ( !Len( arguments.account.getPwd() ) ) {
			Throw( type = "apirone.accountService.PasswordNotProvided", message = "Password is required" );
		};

		transaction {
			var id = getDao().insert( argumentCollection = arguments );

			updatePassword( id, arguments.account.getPwd() );
		}

		return id;
	}

	public String function update( required com.apirone.core.model.bean.Account account ){
		if ( !Len( arguments.account.getEmail() ) ) {
			Throw(
				type    = "apirone.accountService.EmailNotProvided",
				message = "Account [#arguments.account.getId()#] not exists"
			);
		};

		var id = getDao().update( argumentCollection = arguments );

		return id;
	}

	public String function updateLastLoggedUserId( required String accountId, required String userId ){
		var id = getDao().updateLastLoggedUserId( arguments.accountId, arguments.userId );

		return id;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String accountId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.accountId );

		outcome.setData( { accountId = arguments.accountId } );

		transaction {
			try {
				var result = getDao().delete( arguments.accountId );
				outcome.setData( { "deletedCount" = result } )
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.accountService.CannotDeleteAccount" );
				outcome.setMessage( "Cannot delete account [#arguments.accountId#]" );
			}
		}

		return outcome;
	}

	public Boolean function updatePassword( required String accountId, required String newPwd ){
		var obj = get( arguments.accountId );
		var StringUtil = new com.apirone.core.util.String();

		if ( IsNull( obj ) ) {
			Throw(
				type    = "ApirOne.errors.accountService.AccountNotExists",
				message = "AccountId [#arguments.accountId#] not exists"
			);
		}

		if ( !Len( arguments.newPwd ) ) {
			Throw( type = "ApirOne.errors.accountService.PasswordNotProvided", message = "Password is required" );
		};

		var pwd = createPassword( arguments.accountId, arguments.newPwd );

		getDao().updatePassword( arguments.accountId, pwd );

		super.logEvent(
			event   = "account.UPDATED",
			message = "Password for account [#arguments.accountId#] updated",
			payload = { "id" = arguments.accountId, "newPwd" = StringUtil.maskString( arguments.newPwd ) }
		);

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
			Throw( type = "apirone.EmailNotProvided", message = "Account email not provided" );
		};

		var accounts = search( email = arguments.email ).getData();

		if ( !IsNull( accounts[ 1 ] ) ) {
			return accounts[ 1 ];
		}

		return NullValue();
	}

	public com.apirone.core.model.bean.Result function search(
		String email,
		required Numeric limit  = 50,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "account.id", desc = "asc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments["orderBy"] = super.createOrderBy( arguments[ "orderby" ] );

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids = [];
		for ( var record in records ) {
			ids.append( record.account_id );
		}

		var beanMap = {};
		if ( ArrayLen( ids ) ) {
			var allRecords = getDao().readByIds( ids );

			allRecords.each( function( r ){
				beanMap[ r.account_id ] = buildFromRow( r );
			} );
		}

		// Ricostruisce le righe nell'ordine del find() originale
		for ( var record in records ) {
			rows.add( beanMap[ record.account_id ] );
		}

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public String function createPassword( required String accountId, required String pwd ){
		var token =
		"jbGM,xxJJaJX-ol@@5m88" &
		arguments.accountId &
		"HTt,Tgajiawsui7,9iR09" &
		arguments.pwd;

		return Hash( token, "SHA-512" );
	}

	public void function storeResetToken( required String accountId, required String hashedToken, required String expiresAt ){
		getDao().storeResetToken( arguments.accountId, arguments.hashedToken, arguments.expiresAt );
	}

	public com.apirone.core.model.bean.Account function findByResetToken( required String rawToken ){
		var hashedToken = Hash( arguments.rawToken, "SHA-512" );
		var record      = getDao().findByResetToken( hashedToken );
		if ( record.recordCount ) {
			return get( record.account_id );
		}
		return NullValue();
	}

	public void function clearResetToken( required String accountId ){
		getDao().clearResetToken( arguments.accountId );
	}


	/**
	 * @private
	 */

	private com.apirone.core.model.bean.Account function build( required String accountId ){
		var record = getDao().read( accountId = arguments.accountId );

		var account = NullValue();

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return account;
	}

	/**
	 * Costruisce un bean Account a partire da una riga della query.
	 * Utilizzato sia da build() (record singolo) che da search() (iterazione batch).
	 * La sub-entity Status è caricata con chiamata individuale.
	 */
	private com.apirone.core.model.bean.Account function buildFromRow( required Struct record ){
		var account = super.bean( "Account" );

		// Campi diretti dal record
		account.setId( arguments.record.account_id.toString() );
		account.setEmail( arguments.record.email );
		account.setName( arguments.record.account );
		account.setPwd( arguments.record.pwd );
		account.setSerial( arguments.record.serial );
		account.setLastLoggedUserId( arguments.record.last_logged_user_id );
		account.setCreatedAt( arguments.record.created_at );
		account.setUserCount( arguments.record.user_count );
		account.setIdUtenteVerticale( arguments.record.id_utente_verticale );
		account.setIdAgenteVerticale( arguments.record.id_agente_verticale );

		// Entity collegata (Status è un lookup leggero)
		account.setStatus( getStatusService().get( arguments.record.status_id ) );

		return account;
	}

}
