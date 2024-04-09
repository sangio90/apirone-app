component extends="testbox.system.BaseSpec"{

    function setup(){

        variables.wirebox = new wirebox.system.ioc.Injector( "config.WireboxServices" );
        variables.svc = variables.wirebox.getInstance( "MediaService" );
        var cm = variables.wirebox.getInstance( "CacheManager" );
        variables.helpers = new tests.utils.Helpers();

        cm.removeAll();

    }

    function teardown( currentMethod ) {

        StructDelete( variables, "wirebox" );

    }
    

    function save_resizes_test(){

        var file =ExpandPath('/tests/assets/house-horizontal.jpg');
        var result = svc.create(file);

        
                       
        result = svc.getVersions( "#result.directory#/#result.fileName#" );
 
        dump(result)
    }
  

        

}