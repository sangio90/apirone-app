<cfscript>

    model = server["wirebox-apirone"];

    svc = model.getInstance("CategoriyService");

    role.setId("MAN");

    account.setLogin( "guido.sangiovanni@gslabs.it" );
    account.setPwd( "Gta.ak12aQ" );
    account.setRole( role );

    svc.create( account );

</cfscript>