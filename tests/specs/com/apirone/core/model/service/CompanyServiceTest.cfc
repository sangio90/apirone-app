component extends="testbox.system.BaseSpec"{

    function setup(){


        variables.wirebox = new wirebox.system.ioc.Injector( "config.WireboxServices" );
        variables.svc = variables.wirebox.getInstance( "CompanyService" );
        var cm = variables.wirebox.getInstance( "CacheManager" );
        variables.helpers = new tests.utils.Helpers();
        variables.random = new tests.utils.RandomData();

        cm.removeAll();

    }

    function teardown( currentMethod ) {

        StructDelete( variables, "wirebox" );

    }

    function get_test(){

        var data = variables.helpers.createCompany();

        var id = variables.svc.create( data.obj );

        var company = variables.svc.get( id );

        $assert.isTrue( company.getLocation().getPostalCode() EQ data.raw.location.postalCode ) 
        $assert.isTrue( company.getLocation().getCity().getId() EQ data.raw.location.city.id )
        $assert.isTrue( company.getLocation().getAddress() EQ data.raw.location.address )
        $assert.isTrue( company.getStatus().getId() EQ data.raw.status.id ) 
        $assert.isTrue( company.getAccount().getLogin() EQ data.raw.account.login );


        $assert.isTrue( 
            ( company.getId() EQ id ) 
            AND ( company.getName() EQ data.raw.name ) 
            AND ( company.getVat() EQ data.raw.vat ) 
            AND ( company.getContact() EQ data.raw.contact ) 
            AND ( company.getPhone() EQ data.raw.phone ) 
        );

        var i = 1;

        for (i; i < len(company.getTypes()); i++) {
          
            $assert.isTrue( company.getTypes()[i].getId() EQ data.raw.types[i].id )

        }

        variables.svc.delete( id );
                
    }

    function vat_exists_test(){

        var data = variables.helpers.createCompany().obj;

        var id = variables.svc.create( data );
        
        var vatExists = variables.svc.vatExists( vat = data.getVat() );

        $assert.isTrue( vatExists EQ true )

        variables.svc.delete( id );

        vatExists = variables.svc.vatExists( vat = data.getVat() );
        $assert.isTrue( vatExists EQ false )
                
    }

    function update_test(){

        var data = variables.helpers.createCompany();

        var id = variables.svc.create( data.obj );
        var company = variables.svc.get( id );

        var newName = 'Ciccio-update';
        var newVat = '13423432-update';
        var newContact = 'aprova@gail.com-update';
        var newPhone = '3324324-update';
        var newPostalCode = '134234u';
        var newCityId = variables.random.getCities( limit=1 ).city_id.toString();
        var newAddress = 'nuovoaddress-update';
        var newLogin = 'nuovaemail@gmail.com-update';

        var updateCompany = duplicate(company);
        updateCompany.setName(newName)
        updateCompany.setVat(newVat);
        updateCompany.setContact(newContact);
        updateCompany.setPhone(newPhone); 
        updateCompany.getLocation().setPostalCode(newPostalCode);
        updateCompany.getLocation().getCity().setId( newCityId );
        updateCompany.getLocation().setAddress(newAddress);

        // This property should not change
        updateCompany.getAccount().setLogin(newLogin)

        var newId = variables.svc.update( updateCompany );
        var newCompany = variables.svc.get( newId );

        $assert.isTrue( newCompany.getId() EQ id, 'return:#newCompany.getId()#, expected:#id#'  );
        $assert.isTrue( newCompany.getName() EQ newName, 'return:#newCompany.getName()#, expected:#newName#'  );
        $assert.isTrue( newCompany.getVat() EQ newVat, 'return:#newCompany.getVat()#, expected:#newVat#'  );
        $assert.isTrue( newCompany.getContact() EQ newContact, 'return:#newCompany.getContact()#, expected:#newContact#'  );
        $assert.isTrue( newCompany.getPhone() EQ newPhone, 'return:#newCompany.getPhone()#, expected:#newPhone#'  );
        $assert.isTrue( newCompany.getLocation().getPostalCode() EQ newPostalCode, 'return:#newCompany.getLocation().getPostalCode()#, expected:#newPostalCode#'  );
        $assert.isTrue( newCompany.getLocation().getCity().getId() EQ newCityId, 'return:#newCompany.getLocation().getCity().getId()#, expected:#newCityId#' );
        $assert.isTrue( newCompany.getLocation().getAddress() EQ newAddress,  'return:#newCompany.getLocation().getAddress()#, expected:#newAddress#' );
        $assert.isTrue( newCompany.getAccount().getLogin() NEQ newLogin, 'return:#newCompany.getAccount().getLogin()#, expected:#newLogin#' );

        variables.svc.delete( id );
                
    }

  
}