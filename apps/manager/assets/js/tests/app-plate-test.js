$( document ).ready( function() {

    setTimeout( function() {
        $( "body" ).find( "button[data-bind='click:addPlate']" ).click();
        console.log( "test-plate:load" );

    }, 1000 );

} );
