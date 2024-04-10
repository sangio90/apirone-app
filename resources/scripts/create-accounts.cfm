<cfscript>

    model = server['wirebox-apirone'];

    svc = model.getInstance('AccountService');

    bean = new com.apirone.core.model.bean.Account();

    /*
    bean.setLogin( 'roberto@marzialetti.com' );
    bean.setPwd( 'Jaxo_8989' );
    */
    
    bean.setLogin( 'test1@apirone.cc' );
    bean.setPwd( 'jaUxx.hTa1q' );

    svc.create( bean );


    bean = new com.apirone.core.model.bean.Account();

    /*
    bean.setLogin( 'roberto@marzialetti.com' );
    bean.setPwd( 'Jaxo_8989' );
    */
    
    bean.setLogin( 'test2@apirone.cc' );
    bean.setPwd( 'xAUyy.hTacc' );

    svc.create( bean );


    bean = new com.apirone.core.model.bean.Account();

    /*
    bean.setLogin( 'roberto@marzialetti.com' );
    bean.setPwd( 'Jaxo_8989' );
    */
    
    bean.setLogin( 'roberto@marzialetti.com' );
    bean.setPwd( 'Jaxo_8989' );

    svc.create( bean );

</cfscript>