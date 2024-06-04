component extends="testbox.system.BaseSpec"{

    function setup(){

        variables.wirebox = new wirebox.system.ioc.Injector( "config.WireboxServices" );
        variables.svc = variables.wirebox.getInstance( "CardService" );
        variables.employeeSvc = variables.wirebox.getInstance( "EmployeeService" );
        variables.companySvc = variables.wirebox.getInstance( "CompanyService" );
        variables.helpers = new tests.utils.Helpers();
        variables.random = new tests.utils.RandomData();

        var cm = variables.wirebox.getInstance( "CacheManager" );

        cm.removeAll();

    }

    function teardown( currentMethod ) {

        StructDelete( variables, "wirebox" );

    }

    function get_test(){

        var data = variables.helpers.createCard();
        var company = variables.helpers.createCompany();
        var companyId = variables.companySvc.create( company.obj );
        data.obj.setCompany( variables.companySvc.get( companyId ) );
        var id = variables.svc.create( data.obj );
        var card = variables.svc.get( id );

        $assert.isTrue( card.getEmissionAt() EQ data.raw.emissionAt );
        $assert.isTrue( card.getCompany().getId() EQ data.obj.getCompany().getId() );
        $assert.isTrue( card.getAmount() EQ data.raw.amount );
        $assert.isTrue( card.getEmail() EQ data.raw.email );
        $assert.isTrue( card.getPhone() EQ data.raw.phone );
        $assert.isTrue( card.getStatus().getId() EQ data.raw.status.id );

        variables.svc.delete( id );
        variables.companySvc.delete( companyId );

        
    }

    function assign_test(){

        var data = variables.helpers.createCard();
        var company = variables.helpers.createCompany();
        var employee = variables.helpers.createEmployee();
        var companyId = variables.companySvc.create( company.obj );
        var employeeId = variables.employeeSvc.create( employee.obj );

        data.obj.setCompany( variables.companySvc.get( companyId ) );
        var id = variables.svc.create( data.obj );
        id = variables.svc.assign(  employeeId = employeeId, cardId = id );

        var assignedCard = variables.svc.get( id );

        $assert.isTrue( assignedCard.getEmissionAt() EQ data.raw.emissionAt, 'return:#assignedCard.getEmissionAt()#, expected:#data.raw.emissionAt#'  );
        $assert.isTrue( assignedCard.getCompany().getId() EQ data.obj.getCompany().getId(), 'return:#assignedCard.getCompany().getId()#, expected:#data.obj.getCompany().getId()#'  );
        $assert.isTrue( assignedCard.getAmount() EQ data.raw.amount );
        $assert.isTrue( assignedCard.getEmail() EQ data.raw.email );
        $assert.isTrue( assignedCard.getPhone() EQ data.raw.phone );
        $assert.isTrue( assignedCard.getStatus().getId() EQ data.raw.status.id );
        $assert.isTrue( assignedCard.getEmployeeId() EQ employeeId , 'return:#assignedCard.getEmployeeId()#, expected:#employeeId#'  );

        variables.svc.delete( id );
        
        variables.companySvc.delete( companyId );
        variables.employeeSvc.delete( employeeId );


    }

}