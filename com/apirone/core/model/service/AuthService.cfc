component extends="AbsService" accessors="true" {

	property name="AccountService" inject="AccountService";

	public com.apirone.core.model.bean.LoginResult function login( required String email, required String pwd ){
		
		var result   = super.bean( "LoginResult" );
		var error    = super.getError();
		var hasError = false;

		result.setStatus( false );

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

	public String function getRecoveryPwdEmailContent( required String resetUrl ){
		return "
			<h2>Recupero password</h2>
			<p>Clicca sul link seguente per impostare una nuova password. Il link è valido per 1 ora.</p>
			<p><a href=""#arguments.resetUrl#"">Cambia password</a></p>
			<p>Se non hai richiesto il recupero della password, ignora questa email.</p>
		";
	}

}
