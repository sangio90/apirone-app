AP.namespace( "test" );

AP.test.helper = ( function() {

    var pub = {};

    // Helper per attendere un certo tempo
    pub.wait = function( ms ) {
        return new Promise( resolve => setTimeout( resolve, ms ) );
    };

    return pub;
} () );
