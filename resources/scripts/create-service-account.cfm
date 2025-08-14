
<cfscript>

    model = server["wirebox-apirone"];

    svc = model.getInstance("AccountService");

    account = new com.apirone.core.model.bean.Account();
    role = new com.apirone.core.model.bean.Role();
    status = new com.apirone.core.model.bean.Status();

    role.setId("MAN");

    account.setEmail( "apirone.serviceaccount@apir.com" );
    account.setName( "Service account" );
    account.setPwd( "BB!Ga1r@ae1W1z" );
    account.setRoles( [role.setId( "ADM" )] );
    account.setStatus( status.setId( "ACT" ) );

    svc.create( account );

</cfscript>