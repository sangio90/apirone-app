NM.util = NM.util || {};

NM.util.openModal = function( ele, onShow ) {

    var dialogs = $( ".modal.show" ); // opened dialog
    var currentId = ele.attr( "id" );

    var currentTop = 0;
    var currentLeft = 0;

    var n=1;

    for ( var dialog of dialogs ) {

        var $dialog = $( dialog );

        if( currentId !=  $dialog.attr( "id" ) ) {

            currentTop = 20*n;
            currentLeft = 20*n;

            n++;

        }

    }

    ele.modal( "show" );

    if ( onShow ) {
        onShow();
    }

    ele.css( { left: 0, top: 0 } );
    ele.offset( { left: currentLeft, top: currentTop } );

};


NM.util.ajax = function( setup ) {

    var defaults = {
        url: "",
        data: null,
        method: "GET",
        callback: {
            done: undefined,
            always: undefined,
            fail: function( xhr ) {
                AP.widget.notify( "error", "Qualcosa è andato storto", "Ops!" );
            }
        }
    };

    var settings = $.extend( true, defaults, setup );

    if ( settings.hasOwnProperty( "cache" ) ) {

        settings.cache = settings.cache;

        if ( !settings.cache ) {
            settings.headers = {
                "cache-control": "no-cache"
            };
        }
    }

    var data =
		$.ajax( {
		    url: settings.url,
		    method: settings.method,
		    data: settings.data
		} )
		    .done( function( xhr ) {

		        if ( xhr.error === undefined ) { // dal proxy
		            if ( settings.callback.done !== undefined ) {
		                settings.callback.done.apply( null, [ xhr ] );
		            }
		        } else {
		            window.location.href = "/";
		        }

		    } )
		    .fail( settings.callback.fail )
		    .always( settings.callback.always );

    return data;

};

NM.util.checkAll = function( button ) {

    var value = true;
    var thisForm = $( button.closest( "form" ) );

    var checks = thisForm.find( "input[name=selected]:checkbox" );

    if( button.checked == undefined ) {
        value = true;
    } else {
        value = button.checked;
    }

    checks.each( function() {
        $( this ).prop( "checked", value );
    } );

};

NM.util.autoHideMessage = function( ele, message ) {

    ele.html( message );

    setTimeout( function() {
        ele.html( "" );
    }, 1500 );

};

NM.util.copyText = function( text ) {

    return new Promise( ( resolve, reject ) => {

        // Prova prima l'API moderna
        if ( typeof window !== "undefined" && typeof window.navigator !== "undefined" && window.navigator.clipboard && window.navigator.clipboard.writeText ) {
            window.navigator.clipboard.writeText( text )
                .then( () => {
                    resolve( { "result": "success", "text": text } );
                } )
                .catch( ( err ) => {
                    console.error( "Errore API moderna:", err );
                    // Fallback a execCommand se l'API moderna fallisce
                    fallbackCopyToClipboard( text, resolve, reject );
                } );
        } else {
            // Fallback diretto se l'API moderna non è disponibile
            fallbackCopyToClipboard( text, resolve, reject );
        }

        function fallbackCopyToClipboard( text, resolve, reject ) {

            const textArea = document.createElement( "textarea" );

            textArea.value = text;
            textArea.style.position = "fixed";
            textArea.style.left = "-999999px";
            textArea.style.top = "-999999px";

            document.body.appendChild( textArea );

            textArea.focus();
            textArea.select();

            try {
                const success = document.execCommand( "copy" );
                document.body.removeChild( textArea );

                if ( success ) {
                    resolve( { "result": "success", "text": text } );
                } else {
                    reject( { "result": "error" } );
                }
            } catch ( err ) {
                console.error( "Fallback copy failed:", err );
                document.body.removeChild( textArea );
                reject( { "result": "error" } );
            }
        }

    } );

};

// Funzione per generare UUID semplice
NM.util.uuid = function() {
    return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace( /[xy]/g, function( c ) {
        var r = Math.random() * 16 | 0;
        var v = c == "x" ? r : ( r & 0x3 ) | 0x8;
        return v.toString( 16 );
    } );
};

NM.storage = {

    /*
        Naming:
            key: product.items.showUnlinked
            value: true | 123 | miaStringa | { id: 123, name: "pippo" }
    */

    set: function( key, value ) {
        localStorage.setItem( key, JSON.stringify( value ) );
    },

    get: function( key, defaultValue ) {
        var value = localStorage.getItem( key );
        return value ? JSON.parse( value ) : defaultValue;
    },

    delete: function( key ) {
        localStorage.removeItem( key );
    }

};