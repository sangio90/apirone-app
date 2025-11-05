$( document ).ready( async function() {

    if ( AP.config.user.id == "a3c69ebc-b06e-49b0-ac97-5e7004cd1cf8" ) { // Roberto

        var helper = AP.test.helper;

        const lineId = "56906918-8a2a-4652-80fe-adc1ededacd1"; // linea: Square
        const modelId = "9d3266f5-db0d-4044-a120-22bd400d899c"; // modello: 54x82 (1x2)
        const finishId = "7357f125-e556-467c-ba37-2a1e17abc6cf"; // finitura: Acciaio lucido

        const plateEle = $( "#plate-line" );
        const modelEle = $( "#plate-model" );
        const finishEle = $( "#plate-finish" );

        // Sequenza asincrona
        await helper.wait( 500 );
        $( "body" ).find( "button[data-bind='click:addPlate']" ).click();

        await helper.wait( 500 );
        plateEle.val( lineId ).trigger( "change" );

        await helper.wait( 500 );
        modelEle.val( modelId ).trigger( "change" );

        await helper.wait( 500 );
        finishEle.val( finishId ).trigger( "change" );
    }

} );
