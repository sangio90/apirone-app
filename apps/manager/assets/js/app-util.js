AP.util = AP.util || {};

AP.util.getText = function( key, values ) {

	var text = ZB.data.texts[ key ];

	if ( text ) {
		return text;
	} else {
		return "** token not found **";
	}

};


AP.util.ajax = function( setup ) {

	var defaults = {
		url: '',
		data: null,
		method: 'GET',
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
		
		config.cache = settings.cache;
		
		if ( !settings.cache ) {
			config.headers = {
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
				location.href = '/';
			}
			
		} )
		.fail( settings.callback.fail )
		.always( settings.callback.always );

	return data;

};

AP.util.checkAll = function( button ) {

    if(button.checked) {
        // Iterate each checkbox
        $('input[name=selected]:checkbox').each(function() {
            this.checked = true;                        
        });
    } else {
        $('input[name=selected]:checkbox').each(function() {
            this.checked = false;                       
        });
    }

};
