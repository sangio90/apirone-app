component extends="com.apirone.core.controller.AbsController" {

    function changePwd( event, rc, prc ){

        // current pasword is ok?
        var errors = [];
        var payload = {};
        var result = super.getResult();


        var login = super.fire( "auth.login",
             { 
                email =  session.user.getAccount().getEmail() , 
                pwd = rc.currentPwd 
            } );

        if( login.getStatus() ) {

            super.fire( "account.setPassword", 
                { 
                    accountId = session.user.getAccount().getId(),
                    newPwd = rc.newPwd
                } 
            )

            var messageId = "my.passwordChanged";
    
        } else {

            errors.add( { "message" = "La password corrente non è corretta" } )

            var messageId = "my.currentPasswordNotMatch";
            var payload = { "errors": errors } ;

        }

        var message = super.completeMessage( messageId );

        result.setData( { "message" = message, "payload" =  payload } );

        event.setValue("result", result);

    }

}
