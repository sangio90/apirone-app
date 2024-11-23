Remove cfabort
<cfabort>
<cfscript>

    model = server["wirebox-apirone"];

    svc = model.getInstance("AccountService");

    /*
    bean = new com.apirone.core.model.bean.Account();
    bean.setLogin( "test1@apirone.cc" );
    bean.setPwd( "jaUxx.hTa1q" );

    svc.create( bean );

    bean = new com.apirone.core.model.bean.Account();

    bean.setLogin( "test2@apirone.cc" );
    bean.setPwd( "xAUyy.hTacc" );

    svc.create( bean );


    bean = new com.apirone.core.model.bean.Account();

    bean.setLogin( "roberto@marzialetti.com" );
    bean.setPwd( "Jaxo_8989" );

    svc.create( bean );
    */

    account = new com.apirone.core.model.bean.Account();
    role = new com.apirone.core.model.bean.Role();
    status = new com.apirone.core.model.bean.Status();

    /*
    role.setId("MAN");

    account.setLogin( "guido.sangiovanni@gslabs.it" );
    account.setPwd( "Gta.ak12aQ" );
    account.setRole( role );
    */

    account.setEmail( "stanislav@nimesia.com" );
    account.setPwd( "JSA7!8fs:afn4K" );
    account.setRole( role.setId( "ADM" ) );
    account.setStatus( status.setId( "ACT" ) );

    svc.create( account );

</cfscript>