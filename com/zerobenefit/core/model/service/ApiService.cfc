component extends="AbsService" accessors="true"{
    
    property name="accountService" type="com.apirone.core.model.service.AccountService";

    public com.apirone.core.model.bean.ApiLogin function login( 
            required String accountId,
            required String apiKey
        ){

        var result = super.bean('ApiLogin');

        result.setStatus('AUTH');
        result.setMessage('Authorized');

        var account = getAccountService().get( arguments.accountId ); 

        if ( IsNull( account ) ) {

            result.setStatus('ACCOUNT_NOT_FOUND');
            result.setMessage('Account [#arguments.accountId#] not found');


        } else {

            if ( account.getApiKey() NEQ arguments.apiKey ) {

                result.setStatus('APIKEY_NOT_VALID');
                result.setMessage('ApiKey [#arguments.apiKey#] not valid in account');
    
            }

        }


        return result;    
    
    }

}