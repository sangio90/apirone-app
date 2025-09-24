$( document ).ready( async function() {

    if ( AP.config.user.id == "a3c69ebc-b06e-49b0-ac97-5e7004cd1cf8" ) { // Roberto

        console.log( "qui" );

        var helper = AP.test.helper;

        // Sequenza asincrona
        await helper.wait( 400 );
        $( "#frame-grid" ).find( "button[data-bind='click:edit']:first" ).click();
        $( "#frame-nav-grid-but" ).tab( "show" );

    }

} );
