component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var user = prc.user;
        var service = super.service("Company");

        prc.title = "Aziende";

        //prc.list = DESerializeJSON( FileRead( '/config/data/fake-companies.json' ) );

        prc.list = service.search();

        event.setView('company/list');

    }
    
    function new( event, rc, prc ){

        var user = prc.user;

        prc.title = "Nuova azienda";

        event.setView('company/detail');

    }

    function edit( event, rc, prc ){

        var user = prc.user;
        var service = super.service("Company");
        var categorySvc = super.service("ProductCategory");

        prc.company = service.get( rc.companyId );
        prc.categories = categorySvc.list();

        prc.title = "Modifica azienda #prc.company.getName()#";

        event.setView('company/detail');

    }

    function save( event, rc, prc ){

        var user = prc.user;

        var company  = super.bean("Company");
        var type     = super.bean("CompanyType");
        var account  = super.bean("Account");
        var status   = super.bean("Status");
        var location = super.bean("Location");
        var city     = super.bean("City");

        var companySvc = super.service("Company");
        var accountSvc = super.service("Account");

        type.setId( "C" );
        city.setId( '63baa957-9d41-412f-86ab-cc52f3eab817' ) //TODO: fix. This is Montegiorgio

        company.setCode( Right( CreateUUID(), 4 ) );
        company.setName( rc.fullname );
        company.setPhone( rc.phone );
        company.setVat( rc.vat );
        company.setTypes( [ type ] );
        company.setLocation( location.setCity( city ) );

        if ( Len( rc.id ) )  {
            
            companySvc.update( company )
        
        } else {
            
            account.setLogin( rc.email ) //TODO: check email
            account.setPwd( rc.pwd );

            /*
            var id = accountSvc.create( account );
            var accountNew = accountSvc.get( id );
            */

            status.setId("ACT");

            company.setAccount( account );
            company.setStatus( status );
            
            companySvc.create( company );
        
        }

        
        flash.put("message", "Azienda salvata con successo");   
        
        relocate( uri="/manager/companies?msg=ok", addToken=false, postProcessExempt=false );
        
    }    
    
}
