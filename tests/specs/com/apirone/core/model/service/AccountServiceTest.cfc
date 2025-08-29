component extends="tests.utils.AbsSpec"{

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

        var account = new com.apirone.core.model.bean.Account();

        var data = {
            'login' = 'roberto@marzialetti.com',
            'pwd' = 'Jaxo_8989a',
        }

        account.setLogin( data.login );
        account.setPwd( data.pwd );

        var id = variables.svc.create( account );

        var account = variables.svc.get( id );

        $assert.isTrue( account.getLogin() EQ data.login );
        $assert.isTrue( account.getId() EQ id );

        variables.svc.delete( id );

    }

    function update_test() {
    }

}