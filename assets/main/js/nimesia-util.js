NM.util = NM.util || {};

NM.util.openModal = function( ele ) {

    var dialogs = $(".modal");
    var currentId = ele.attr("id");

    var currentTop = 0;
    var currentLeft = 0;

    var n=1;

    for ( var dialog of dialogs ) {
        
        var $dialog = $(dialog)
        var modal = $dialog.find(".modal-dialog");

        if( currentId !=  $dialog.attr("id") ) {

            var top = modal.offset().top;
            var left = modal.offset().left;
    
            currentTop = 20*n;
            currentLeft = 20*n;

            n++;

        }

    }

    ele.modal("show");

    ele.offset({ left: currentLeft, top: currentTop });

};


NM.util.ajax = function( setup ) {

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
				location.href = '/';
			}
			
		} )
		.fail( settings.callback.fail )
		.always( settings.callback.always );

	return data;

};

NM.util.checkAll = function( button ) {

	var thisForm = $( button.closest("form") );
	console.log("thisForm", thisForm)

	var checks = thisForm.find("input[name=selected]:checkbox");

	var value = button.checked ? true : false;

	checks.each(function() {
		this.checked = value;
	});

};

NM.util.autoHideMessage = function( ele, message ) {

	ele.html( message );

	setTimeout(function() {
		ele.html("")
	}, 2000 )

};