AP.util = AP.util || {};

AP.util.getTextItem = function( texts, langId="it", kindId = "NAME" ) {

    for( var thisText of texts ) {

        if ( thisText.lang.id == langId.toUpperCase() && thisText.kind.id == kindId.toUpperCase() ) {
            return thisText;
        }

    }

    return undefined;

};


AP.util.fireCallback = function( func, callbacks ) {

    var callbackList = callbacks;

    console.log( "callbackList", callbackList );

    var exists = callbackList?.hasOwnProperty( func );

    console.log( "callbackList:func", exists, func );

    if( exists ) {

        var thisCallback = callbackList[ func ];

        if( typeof thisCallback == "function" ) {

            console.log( "callbackList:exec", func );

            thisCallback();
        }
    }

};

AP.util.removeQueryString = function() {

    var uri = window.location.href.toString();

    if ( uri.indexOf( "?" ) > 0 ) {
        var clean_uri = uri.substring( 0, uri.indexOf( "?" ) );
        window.history.replaceState( {}, document.title, clean_uri );
    }

};
