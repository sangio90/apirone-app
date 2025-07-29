component extends="tests.utils.AbsSpec"{

    function setup(){

        variables.wirebox = new wirebox.system.ioc.Injector( "config.WireboxServices" );
        variables.svc = variables.wirebox.getInstance( "VatCodeService" );

        var cm = variables.wirebox.getInstance( "CacheManager" );

        cm.removeAll();

    }

    function teardown( currentMethod ) {

        StructDelete( variables, "wirebox" );

    }

    function get_test(){

        var id = 4;

        var bean = variables.svc.get( id );

        $assert.isTrue( bean.getId() == id );

    }

    function list_test(){

        //var id = 4;

        var records = variables.svc.list();

        dump(records);

        $assert.isTrue( true );

        //$assert.isArray( records );

    }

}