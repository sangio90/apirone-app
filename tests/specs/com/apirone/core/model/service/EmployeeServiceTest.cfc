component extends="testbox.system.BaseSpec"{

    function setup(){


        variables.wirebox = new wirebox.system.ioc.Injector( "config.WireboxServices" );
        variables.svc = variables.wirebox.getInstance( "EmployeeService" );
        variables.cardSvc = variables.wirebox.getInstance( "CardService" );
        variables.companySvc = variables.wirebox.getInstance( "CompanyService" );
        var cm = variables.wirebox.getInstance( "CacheManager" );
        variables.helpers = new tests.utils.Helpers();
        variables.random = new tests.utils.RandomData();

        cm.removeAll();

    }

    function teardown( currentMethod ) {

        StructDelete( variables, "wirebox" );

    }

    function get_test(){

        var data = variables.helpers.createEmployee();

        var id = variables.svc.create( data.obj );

        var employee = variables.svc.get( id );

        $assert.isTrue( employee.getLocation().getPostalCode() EQ data.raw.location.postalCode ); 
        $assert.isTrue( employee.getLocation().getCity().getId() EQ data.raw.location.city.id );
        $assert.isTrue( employee.getLocation().getAddress() EQ data.raw.location.address );
        $assert.isTrue( employee.getStatus().getId() EQ data.raw.status.id );
        $assert.isTrue( employee.getAccount().getLogin() EQ data.raw.account.login ); 

        $assert.isTrue( 
            ( employee.getId() EQ id ) 
            AND ( employee.getName() EQ data.raw.name )
            AND ( employee.getSurname() EQ data.raw.surname )
            AND ( employee.getFiscalCode() EQ data.raw.fiscalCode )
            AND ( employee.getPhone() EQ data.raw.phone )
        );

        variables.svc.delete( id );
                
    }

    function update_test() {
        var util = new com.apirone.core.util.String();

        var data = variables.helpers.createEmployee();

        var id = variables.svc.create( data.obj );

        var employee = variables.svc.get( id );

        var newName = 'Ciccio-update';
        var newSurname = 'Pasticcio-update';
        var newFiscalCode = UCase( util.createRandomCode( 16 ) );
        var newCityId = variables.random.getCities(limit=1).city_id.toString();
        var newAddress = 'address-update';
        var newPostalCode = '123p';

        employee.setName(newName);
        employee.setSurname(newSurname);
        employee.setFiscalCode(newFiscalCode);
        employee.getLocation().getCity().setId( newCityId );
        employee.getLocation().setPostalCode( newPostalCode );
        employee.getLocation().setAddress(newAddress);

        id = variables.svc.update( employee );

        var newEmployee = variables.svc.get(id);

        $assert.isTrue( newEmployee.getLocation().getPostalCode() EQ newPostalCode ); 
        $assert.isTrue( newEmployee.getLocation().getCity().getId() EQ newCityId );
        $assert.isTrue( newEmployee.getName() EQ newName );
        $assert.isTrue( newEmployee.getSurname() EQ newSurname );
        $assert.isTrue( newEmployee.getFiscalCode() EQ newFiscalCode );

        variables.svc.delete( id );


    }

    function employee_with_cards_test() {

        var employee = variables.helpers.createEmployee();
        var employeeId = variables.svc.create( employee.obj );
        var cards = [];

        var companyIds = [];

        for (var i = 0; i < 10; i++) {

            var data = variables.helpers.createCard();
            var company = variables.helpers.createCompany();

            dump(company.obj.getVat())

            var companyId = variables.companySvc.create( company.obj );
            companyIds.push(companyId);
    
            data.obj.setCompany( variables.companySvc.get( companyId ) );
            var cardId = variables.cardSvc.create( data.obj );

            cards.add( cardId );
    
            variables.cardSvc.assign(  employeeId = employeeId, cardId = cardId );

        }
        
        employee = variables.svc.get( employeeId );

        var sum = 0;

        for (var card in employee.getWallet().getCards() ) {
            sum += card.getAmount()
        }

        $assert.isTrue( employee.getWallet().getTotalAmount() EQ sum ); 

        for ( var cardId in cards ) {
            variables.cardSvc.delete( cardId );
        }

        for ( var companyId in companyIds ) {
            variables.companySvc.delete( companyId );
        }

    }

}