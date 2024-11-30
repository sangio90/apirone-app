<cfscript>

    model = server["wirebox-apirone"];

    svc = model.getInstance("AccountService");
    svc.setPassword( "c5ced30b-74a1-490b-a1eb-6ebbb7f8082d", "ScegliUnaPasswordStrong" );

</cfscript>