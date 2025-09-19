$( document ).ready( function() {

    if ( AP.config.user.id == "a3c69ebc-b06e-49b0-ac97-5e7004cd1cf8" ) { // Roberto
        setTimeout( function() {
            $( "body" ).find( "button[data-bind='click:addPlate']" ).click();

            setTimeout( function() {
                $( "#plateLineId" ).trigger( "change" );

                setTimeout( function() {
                    $( "#plateModelId" ).trigger( "change" );

                }, 500 );

            }, 500 );

        }, 500 );

    }

} );
