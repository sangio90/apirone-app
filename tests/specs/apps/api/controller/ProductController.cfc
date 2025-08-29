component extends="testbox.system.BaseSpec"{

    function setup(){

        variables.wirebox = new wirebox.system.ioc.Injector( "config.Wirebox" );
        variables.svc = variables.wirebox.getInstance( "AccountService" );

        var cm = variables.wirebox.getInstance( "CacheManager" );

        cm.removeAll();

    }

    function teardown( currentMethod ) {

        StructDelete( variables, "wirebox" );

    }

    function get(){
    }

    function update_test() {
    }

}