component extends="AbsService" accessors="true" {

	property name="AccountService" inject="AccountService";
	property name="AccountRememberTokenDAO" inject="AccountRememberTokenDAO";
	property name="AuthAttemptDAO" inject="AuthAttemptDAO";

	/*
		Rate limit (tabella auth_attempts). Tre contatori per finestra:
		- account+IP: il caso normale di chi sbaglia/indovina la password di un account;
		- IP: un IP che prova molti account diversi (l'ufficio condivide un solo IP: soglia larga);
		- account: un account attaccato da più IP. Soglia larga perché un attaccante può usarla
		  per bloccare il legittimo proprietario: il blocco dura al massimo la finestra.
		I tentativi respinti dal limite non vengono contati, così il blocco scade comunque.
	*/
	variables.LOGIN_LIMITS   = { minutes = 15, byPair = 5, byIp = 30, byIdentifier = 30 };
	variables.RECOVER_LIMITS = { minutes = 60, byPair = 3, byIp = 10, byIdentifier = 3 };

	public com.apirone.core.model.bean.LoginResult function login( required String email, required String pwd ){
		
		var result   = super.bean( "LoginResult" );
		var error    = super.getError();
		var hasError = false;

		result.setStatus( false );

		var identifier = attemptIdentifier( arguments.email );
		var ipAddress  = new com.apirone.core.util.ClientIP().get();

		if ( isThrottled( "LOGIN", identifier, ipAddress, variables.LOGIN_LIMITS ) ) {
			error.setType( "TooManyAttempts" );
			error.setMessage( "Too many failed attempts" );
			result.setError( error );

			super.logEvent(
				payload = {
					"email" = arguments.email,
					"error" = { "type" = error.getType(), "message" = error.getMessage() }
				},
				event          = "auth.failed",
				message        = "Email [#arguments.email#] failed to log in. Type: [#error.getType()#] message: #error.getMessage()#",
				severity       = "WARNING",
				allowAnonymous = true
			);

			return result;
		}

		var account = getAccountService().getByEmail( arguments.email );

		if ( IsNull( account ) ) {
			hasError = true;

			error.setType( "AccountNotExists" );
			error.setMessage( "Account with email [#arguments.email#] not exists" );
		} else {
			if ( account.getStatus().getId() NEQ "ACT" ) {
				hasError = true;

				error.setType( "AccountNotEnabled" );
				error.setMessage( "Account not enabled" );
			}

			var hashedPwd = getAccountService().createPassword( account.getId(), arguments.pwd );

			if ( hashedPwd NEQ account.getPwd() ) {
				hasError = true;

				error.setType( "PasswordNotMatch" );
				error.setMessage( "Password not match" );
			}
		}

		if ( hasError ) {
			result.setError( error )

			getAuthAttemptDAO().insert( "LOGIN", identifier, ipAddress );

			super.logEvent(
				payload = {
					"email" = arguments.email,
					"error" = { "type" = error.getType(), "message" = error.getMessage() }
				},
				event          = "auth.failed",
				message        = "Email [#arguments.email#] failed to log in. Type: [#error.getType()#] message: #error.getMessage()#",
				allowAnonymous = true
			)

		} else {
			result.setAccount( account );
			result.setStatus( true );

			getAuthAttemptDAO().deleteByIdentifier( "LOGIN", identifier );

			super.logEvent(
				payload = {
					"accountId" = account.getId(),
					"email"     = account.getEmail()
				},
				event     = "auth.login",
				accountId = account.getId(),
				message   = "Account [#account.getId()#] email [#account.getEmail()#] logged in"
			);

		}

		return result;
	}

	public Struct function apiLogin( required String accountId, required String apiKey ){
		var result = { "message" = "Not Authorized", status = "NOT_AUTH" };

		var result = false;

		var account = getAccountService().get( arguments.accountId );

		if ( IsNull( account ) ) {
			return { "message" = "Not Authorized", status = "NOT_AUTH" };
		}

		if ( !IsNull( account ) AND account.getApiKey() EQ arguments.apiKey ) {
			result = true;
		}

		return result;
	}

	public void function sendRecoveryEmail( required String email ){
		// Ogni richiesta conta, anche per email non registrate: il controller risponde comunque
		// con lo stesso messaggio generico, quindi il blocco non rivela se l'account esiste.
		var identifier = attemptIdentifier( arguments.email );
		var ipAddress  = new com.apirone.core.util.ClientIP().get();

		if ( isThrottled( "RECOVER", identifier, ipAddress, variables.RECOVER_LIMITS ) ) return;

		getAuthAttemptDAO().insert( "RECOVER", identifier, ipAddress );

		var account = getAccountService().getByEmail( arguments.email );
		if ( isNull( account ) ) return;

		var sys        = createObject( "java", "java.lang.System" );
		var rawToken   = lCase( createUUID() ) & lCase( createUUID() );
		var expiresAt  = DateFormat( DateAdd( "h", 1, Now() ), "yyyy-mm-dd" ) & " " & TimeFormat( DateAdd( "h", 1, Now() ), "HH:mm:ss" );

		getAccountService().storeResetToken(
			accountId   = account.getId(),
			hashedToken = Hash( rawToken, "SHA-512" ),
			expiresAt   = expiresAt
		);

		var siteMain  = sys.getProperty( "site.main" );
		var fromEmail = sys.getProperty( "email.from" );
		var mailHost  = sys.getProperty( "mailserver.host" );
		var mailPort  = Val( sys.getProperty( "mailserver.port" ) );
		var mailUser  = sys.getProperty( "mailserver.username" );
		var mailPwd   = sys.getProperty( "mailserver.pwd" );
		var resetUrl  = "#siteMain#/manager/login/reset-password?token=#rawToken#";
		var body      = getRecoveryPwdEmailContent( resetUrl );

		try {
			cfmail(
				to       = account.getEmail(),
				from     = fromEmail,
				subject  = "Recupero password",
				type     = "html",
				server   = mailHost,
				port     = mailPort,
				username = mailUser,
				password = mailPwd
			) {
				writeOutput( body );
			}
		} catch ( any e ) {
			super.logEvent( event = "auth.RECOVERY_EMAIL_FAILED", message = e.message, payload = { accountId = account.getId() } );
		}
	}

	/*
		"Ricordami": token persistente che sopravvive a un riavvio del server (le sessioni
		Lucee sono in memoria). Emesso ad ogni login riuscito, senza opt-in: il problema che
		risolve (tutti gli utenti costretti a rifare il login ad ogni riavvio di CommandBox)
		riguarda tutti gli utenti, non solo chi spunta una casella.
	*/
	public String function createRememberToken( required String accountId ){
		var rawToken  = lCase( createUUID() ) & lCase( createUUID() );
		var expiresAt = DateAdd( "d", 30, Now() );

		getAccountRememberTokenDAO().insert(
			accountId   = arguments.accountId,
			hashedToken = Hash( rawToken, "SHA-512" ),
			expiresAt   = DateFormat( expiresAt, "yyyy-mm-dd" ) & " " & TimeFormat( expiresAt, "HH:mm:ss" )
		);

		return rawToken;
	}

	public Any function getAccountByRememberToken( required String rawToken ){
		var found = getAccountRememberTokenDAO().findValidByToken( Hash( arguments.rawToken, "SHA-512" ) );

		if ( found.recordCount == 0 ) {
			return;
		}

		return getAccountService().get( found.account_id );
	}

	public void function revokeRememberToken( required String rawToken ){
		getAccountRememberTokenDAO().deleteByToken( Hash( arguments.rawToken, "SHA-512" ) );
	}

	public String function getRecoveryPwdEmailContent( required String resetUrl ){
		return "
			<h2>Recupero password</h2>
			<p>Clicca sul link seguente per impostare una nuova password. Il link è valido per 1 ora.</p>
			<p><a href=""#arguments.resetUrl#"">Cambia password</a></p>
			<p>Se non hai richiesto il recupero della password, ignora questa email.</p>
		";
	}

	private Boolean function isThrottled( required String kind, required String identifier, required String ipAddress, required Struct limits ){
		var counts = getAuthAttemptDAO().countRecent(
			kind       = arguments.kind,
			identifier = arguments.identifier,
			ipAddress  = arguments.ipAddress,
			minutes    = arguments.limits.minutes
		);

		return counts.by_pair >= arguments.limits.byPair
			|| counts.by_ip >= arguments.limits.byIp
			|| counts.by_identifier >= arguments.limits.byIdentifier;
	}

	private String function attemptIdentifier( required String email ){
		return Hash( LCase( Trim( arguments.email ) ), "SHA-256" );
	}

}
