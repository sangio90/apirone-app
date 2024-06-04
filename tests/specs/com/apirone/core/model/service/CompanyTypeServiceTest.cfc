component extends="testbox.system.BaseSpec"{

    function setup(){

        variables.startStrings = [ "_F", "_D", "*H", "*K" ];

        variables.wirebox = new wirebox.system.ioc.Injector( "config.WireboxServices" );
        variables.svc = variables.wirebox.getInstance( "CompanyTypeService" );
        var cm = variables.wirebox.getInstance( "CacheManager" );
        variables.random = new tests.utils.RandomData();

        cm.removeAll();

    }

    function teardown( currentMethod ) {

        StructDelete( variables, "wirebox" );

    }

    function get_test(){

        var data = variables.random.getCompanyTypes( limit = 1);

        var type = variables.svc.get( data.company_type_id );

        $assert.isTrue( 
            ( type.getId() EQ data.company_type_id ) 
            AND ( type.getName() EQ data.company_type ) 
        );
                
    }
    
}