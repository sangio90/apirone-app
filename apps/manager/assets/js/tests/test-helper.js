AP.namespace( "test" );

AP.test.helper = ( function() {

    var pub = {};

    // Helper per attendere un certo tempo
    pub.wait = function( ms ) {
        return new Promise( resolve => setTimeout( resolve, ms ) );
    };

    pub.randRange = function( min, max ) {
        var min = Math.ceil( min );
        var max = Math.floor( max );
        return Math.floor( Math.random() * ( max - min + 1 ) ) + min;
    };

    return pub;
} () );
