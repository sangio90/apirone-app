component extends="testbox.system.BaseSpec"{

    function setup(){

        variables.wirebox = new wirebox.system.ioc.Injector( "config.WireboxServices" );
        variables.security = variables.wirebox.getInstance( "Security" );

    }

    function teardown( currentMethod ) {

        StructDelete( variables, "wirebox" );

    }

    function encryptString_test(){

        var utilString = new com.apirone.core.util.String();

        var salt = utilString.createRandomCode( 10 )

        var start = "la mia stringa #salt#";

        var a = variables.security.encryptString( start );

        var b = variables.security.decryptString( a );

        $assert.isTrue( b == start );
        

    }
    
    function decryptString_test(){
    }
    
}