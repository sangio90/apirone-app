<cfscript>

    model = server['wirebox-zerobenefit'];

    svc = model.getInstance('AccountService');

    bean = new com.apirone.core.model.bean.Account();

    /*
    bean.setLogin( 'roberto@marzialetti.com' );
    bean.setPwd( 'Jaxo_8989' );
    */
    
    bean.setLogin( 'emailari84@gmail.com' );
    bean.setPwd( 'Edo2019@' );

    svc.create( bean );

</cfscript>