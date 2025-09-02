$( document ).ready( function() {

    setTimeout( function() {
        $( "body" ).find( "button[data-bind='click:addSignage']" ).click();
        console.log( "test-signage:load" );

    }, 1000 );

    setTimeout( function() {
        $( "#signangeProductCategory" ).val( 20 ).trigger( "change" );

        setTimeout( function() {
            $( "#signageLine" ).val( '294b930e-d224-42ff-bf8a-896cff4f3222' ).trigger( "change" );
        }, 2000 );
    }, 3000 );

} );
