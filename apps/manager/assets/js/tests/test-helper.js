AP.namespace( "test" );

AP.test.helper = ( function() {

    var pub = {};

    // Helper per attendere un certo tempo
    pub.wait = function( ms ) {
        return new Promise( resolve => setTimeout( resolve, ms ) );
    };

    // Helper per attendere che una condizione diventi vera
    pub.waitUntil = function( condition, timeout = 5000, interval = 100 ) {
        return new Promise( ( resolve, reject ) => {
            const startTime = Date.now();
            
            const checkCondition = () => {
                if ( condition() ) {
                    resolve();
                } else if ( Date.now() - startTime >= timeout ) {
                    reject( new Error( "waitUntil timeout exceeded" ) );
                } else {
                    setTimeout( checkCondition, interval );
                }
            };
            
            checkCondition();
        } );
    };

    pub.randRange = function( min, max ) {
        var min = Math.ceil( min );
        var max = Math.floor( max );
        return Math.floor( Math.random() * ( max - min + 1 ) ) + min;
    };

    return pub;
} () );
