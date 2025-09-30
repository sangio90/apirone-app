$( document ).ready( async function() {

    if ( AP.config.user.id == "a3c69ebc-b06e-49b0-ac97-5e7004cd1cf8" ) { // Roberto

        console.log( "price management:test" );

        var helper = AP.test.helper;

        await helper.wait( 300 );
        $( "select[name=categoryId]" ).val( 171 );
        $( "select[name=lineId]" ).val( "326cccdd-9704-45e2-9ea4-4c7651f6be32" );
        $( "select[name=modelId]" ).val( "a42fabb7-4de3-4c20-903e-6d6b060ee2ff" );
        $( "select[name=finishId]" ).val( "28db1469-a6b6-47ea-9482-5554d8c93376" );
        $( "select[name=statusId]" ).val( "ACT" );

        $( "select[name=typeId]" ).val( "PRICE" );
        $( "select[name=newMethodId]" ).val( "F" );
        $( "input[name=newAmount]" ).val( helper.randRange( 5, 20 ) );

        await helper.wait( 300 );
        // $( "button[data-bind='click:save']:first" ).click();

    }

} );
