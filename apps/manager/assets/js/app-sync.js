AP.namespace( "sync" );

$( document ).ready( function(){

    if ( $( "#sync-widget" ).length ) {
        AP.sync.widget.init();
    }

} );

AP.sync.widget = ( function() {

    var pub = {};

    var sources = {
        verticale: {
            label: "Verticale",
            runUrl: "/manager/ajax/verticale-sync/run",
            statusUrl: "/manager/ajax/verticale-sync/status",
            statusEl: null,
            pollTimer: null
        },
        crm: {
            label: "CRM",
            runUrl: "/manager/ajax/crm-sync/run",
            statusUrl: "/manager/ajax/crm-sync/status",
            statusEl: null,
            pollTimer: null
        }
    };

    // Le chiavi degli struct CFML annidati dentro AjaxResult.data arrivano in MAIUSCOLO
    // dal serializzatore JSON di ColdBox/Lucee (solo le property di primo livello del
    // bean AjaxResult - uuid/status/data/count/total - mantengono il case dichiarato).
    var lowerCaseKeys = function( obj ) {
        var result = {};
        for ( var key in obj ) {
            result[ key.toLowerCase() ] = obj[ key ];
        }
        return result;
    };

    var formatLabel = function( source, lastCompletedAt ) {
        if ( !lastCompletedAt ) {
            return source.label + ": nessuna sincronizzazione ancora eseguita";
        }

        var date = new Date( lastCompletedAt );

        var pad = function( n ) { return ( n < 10 ? "0" : "" ) + n; };

        var day  = pad( date.getDate() ) + "/" + pad( date.getMonth() + 1 ) + "/" + date.getFullYear();
        var time = pad( date.getHours() ) + ":" + pad( date.getMinutes() );

        return source.label + ": Ultima sync. " + day + " " + time;
    };

    var applyStatus = function( key, status ) {
        var source = sources[ key ];

        source.statusEl.text( formatLabel( source, status.lastcompletedat ) );

        if ( status.running ) {
            startPolling( key );
        } else {
            stopPolling( key );
        }
    };

    // NM.util.ajax calcola l'opzione "cache" ma non la inoltra al vero $.ajax():
    // il bypass va fatto qui aggiungendo noi lo stesso il parametro anti-cache,
    // altrimenti il browser può servire una risposta GET cacheata.
    var fetchStatus = function( key, onDone ) {
        var source = sources[ key ];

        NM.util.ajax( {
            method: "GET",
            url: source.statusUrl + "?_=" + Date.now(),
            callback: {
                done: function( xhr ) {
                    if ( onDone ) {
                        onDone( lowerCaseKeys( xhr.data ) );
                    }
                },
            },
        } );
    };

    var startPolling = function( key ) {
        var source = sources[ key ];

        if ( source.pollTimer ) {
            return;
        }

        source.pollTimer = setInterval( function() {
            fetchStatus( key, function( status ) {
                if ( !status.running ) {
                    AP.widget.notify( "success", "Sincronizzazione " + source.label + " completata." );
                }

                applyStatus( key, status );
            } );
        }, 3000 );
    };

    var stopPolling = function( key ) {
        var source = sources[ key ];

        if ( source.pollTimer ) {
            clearInterval( source.pollTimer );
            source.pollTimer = null;
        }
    };

    var runSync = function( key ) {
        var source = sources[ key ];

        NM.util.ajax( {
            method: "POST",
            url: source.runUrl,
            callback: {
                done: function( xhr ) {
                    var runResult = lowerCaseKeys( xhr.data );

                    if ( runResult.alreadyrunning ) {
                        AP.widget.notify( "info", "Una sincronizzazione " + source.label + " è già in corso." );
                        fetchStatus( key, function( status ) { applyStatus( key, status ); } );
                        return;
                    }

                    // Con sync veloci il job può già essere finito quando arriva questa
                    // risposta: senza questo controllo l'utente non vedrebbe nessuna
                    // conferma, perché il polling (che notifica il completamento) non
                    // partirebbe mai.
                    fetchStatus( key, function( status ) {
                        applyStatus( key, status );

                        if ( !status.running ) {
                            AP.widget.notify( "success", "Sincronizzazione " + source.label + " completata." );
                        }
                    } );
                },
            },
        } );
    };

    pub.init = function() {
        sources.verticale.statusEl = $( "#sync-status-verticale" );
        sources.crm.statusEl       = $( "#sync-status-crm" );

        $( "#sync-widget" ).on( "click", "[data-sync-source]", function( e ) {
            e.preventDefault();
            runSync( $( this ).data( "sync-source" ) );
        } );

        Object.keys( sources ).forEach( function( key ) {
            fetchStatus( key, function( status ) {
                applyStatus( key, status );
            } );
        } );
    };

    return pub;

}() );
