component extends="testbox.system.BaseSpec"{

    function setup(){

        variables.wirebox = new coldbox.system.ioc.Injector( "config.WireboxServices" );
        variables.svc = variables.wirebox.getInstance( "CombinationService" );
        var cm = variables.wirebox.getInstance( "CacheManager" );
        variables.helpers = new tests.utils.Helpers();
        variables.random = new tests.utils.RandomData();

        cm.removeAll();

    }

    function teardown( currentMethod ) {

        StructDelete( variables, "wirebox" );

    }

    function calculateCombinations_test(){

        var rows = variables.svc.calculateCombinations( productId = "67860a46-44e8-4c8e-9582-c62e24c5bfcb" );
        $assert.isTrue( isArray( rows ), "rows is an array" );
        console(rows.len()); 
                
    }
  
}