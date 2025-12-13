NM.util = NM.util || {};
NM.form = NM.form || {};

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
    // ele.handleUpdate();

    if ( onShow ) {
        onShow();
    }

    // sulle pagine molto lunghe posiziona la modale in alto quando viene redisegnata.
    // su initUpload ad esempio.
    // ele.css({ left: 0, top: 0 });
    // ele.offset( { left: currentLeft, top: currentTop } );

};


NM.util.ajax = function( setup ) {

    var defaults = {
        url: "",
        data: null,
        method: "GET",
        callback: {
            done: undefined,
            always: function( xhr, statusText ) {

                if ( statusText == "error" ) {

                    if ( xhr.status == 500 ) {
                        AP.widget.notify( "error", "Qualcosa è andato storto", "Ops!" );
                        return;
                    }

                    if ( xhr.status == 401 ) {
                        AP.widget.notify( "warning", "Accesso non consentito", "Ops!" );
                        return;
                    }

                    // voglio che i "400" arrivino sul client,
                    // usando done() non succederebbe
                    if ( xhr.status == 400 ) {
                        setup.callback.done.apply( null, [ xhr.responseJSON ] );
                        return;
                    }

                }

                if ( statusText == "success" ) {
                    setup.callback.done.apply( null, [ xhr ] );
                }

            },
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
		/*
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
            */
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

NM.util.copyText = function( text, onSuccess ) {

    return new Promise( ( resolve, reject ) => {

        // Prova prima l'API moderna
        if ( typeof window !== "undefined" && typeof window.navigator !== "undefined" && window.navigator.clipboard && window.navigator.clipboard.writeText ) {
            window.navigator.clipboard.writeText( text )
                .then( () => {
                    const result = { "result": "success", "text": text };
                    if ( onSuccess && typeof onSuccess === "function" ) {
                        onSuccess( result );
                    }
                    resolve( result );
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
                    const result = { "result": "success", "text": text };
                    if ( onSuccess && typeof onSuccess === "function" ) {
                        onSuccess( result );
                    }
                    resolve( result );
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


/*
    form utils
*/

NM.form.clearMessages = function( formElement ) {

    // remove single message
    formElement.find( "label.error" ).remove();

    // remove class from input
    formElement.find( "input.error, select.error, textarea.error" ).removeClass( "error" );

    // remove global status in form
    formElement.find( ".status" ).html( "" );
    formElement.find( ".errors-counter" ).html( "" );

};

NM.form.removeRules = function( formElement ) {

    var thisForm = formElement.get( 0 );
    $.removeData( thisForm, "validator" );

    NM.form.clearMessages( formElement );

};

NM.form.showMessages = function( errors ) {
    // Prendi il primo campo della struttura errors
    var firstField = Object.keys( errors )[0];

    // Trova il campo nel DOM
    var firstInput = $( "[name='" + firstField + "']" );

    // Trova il form contenitore di quell'input
    var formElement = firstInput.closest( "form" );

    // Conta il totale degli errori
    var errorCount = 0;

    // Se c'è un errore generale, mostra la notifica
    if ( errors.general ) {
        // Usa il primo messaggio del campo general, se presente
        var generalMessage = Array.isArray( errors.general ) && errors.general.length > 0
            ? errors.general.map( function( e ){ return e.message; } ).join( "\n" )
            : "Ops! Si è verificato un errore generale.";
        AP.widget.notify( "error", generalMessage, "Ops!" );
    }

    // Cicla su ogni campo della struttura degli errori
    $.each( errors, function( field, errorList ) {
        errorCount += errorList.length;

        // Seleziona il campo nel form (input, select, textarea)
        var thisField = formElement.find( "[name='" + field + "']" );

        // Assegna la classe "error" al campo
        thisField.addClass( "error" );

        // Costruisci il messaggio HTML (ogni errore su una riga)
        var messages = errorList.map( function( e ) { return e.message; } ).join( "<br>" );

        // Cerca se esiste già il label per questo campo
        var label = $( "#" + field + "-error" );
        if ( label.length === 0 ) {
            // Se non esiste, crealo dopo il campo
            label = $( "<label class=\"error\" id=\"" + field + "-error\"></label>" );
            thisField.after( label );
        }
        // Svuota il label prima di riempirlo
        label.html( "" );
        // Inserisci i messaggi nel label
        label.html( messages ).show();
    } );

    // Se esiste un div.status nel form, mostra il numero di errori
    var status = formElement.find( ".status" );
    if ( status.length ) {
        status.text( "Ci sono " + errorCount + " errori" );
    }
};

/*
    // form utils
*/
