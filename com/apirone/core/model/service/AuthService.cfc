component extends="AbsService" accessors="true" {

	property name="AccountService" inject="AccountService";
	// property name="PwdTokenService" inject="PwdTokenService";

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
			);
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

	/*
	public String function sendRecoveryPasswordEmail( required String email ){
		var emailUtil = new com.wineshipping.core.util.Email();

		var subject = "Cambia password";
		var key     = getPwdTokenService().createToken( account = getAccountService().getByEmail( arguments.email ) );

		emailUtil.send(
			to      = arguments.email,
			subject = subject,
			content = getRecoveryPwdEmailContent( key )
		);

		return emailUtil.obfuscate( arguments.email );
	}
	*/

	public String function getRecoveryPwdEmailContent( required String key ){
		return (
			"<h2>Clicca al link seguente per cambiare la password. </h2> 
            <p>
                <a href=""%client.url*/recover-password/#arguments.key#"">
                    Cambia password
                </a>
            </p>"
		)
	}

}
