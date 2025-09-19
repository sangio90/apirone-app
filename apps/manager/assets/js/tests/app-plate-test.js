$( document ).ready( async function() {

    if ( AP.config.user.id == "a3c69ebc-b06e-49b0-ac97-5e7004cd1cf8" ) { // Roberto

        var helper = AP.test.helper;

        const lineId = "56906918-8a2a-4652-80fe-adc1ededacd1";
        const modelId = "9d3266f5-db0d-4044-a120-22bd400d899c";
        const finishId = "7357f125-e556-467c-ba37-2a1e17abc6cf";

        const plateEle = $( "#plateLineId" );
        const modelEle = $( "#plateModelId" );
        const finishEle = $( "#plateFinishId" );

        // Sequenza asincrona
        await helper.wait( 300 );
        $( "body" ).find( "button[data-bind='click:addPlate']" ).click();

        await helper.wait( 300 );
        plateEle.val( lineId ).trigger( "change" );

        await helper.wait( 300 );
        modelEle.val( modelId ).trigger( "change" );

        await helper.wait( 300 );
        finishEle.val( finishId ).trigger( "change" );
    }

} );
