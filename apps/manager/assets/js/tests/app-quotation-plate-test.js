$( document ).ready( async function() {

    if ( AP.config.user.id == "a3c69ebc-b06e-49b0-ac97-5e7004cd1cf8" ) { // Roberto

        var helper = AP.test.helper;

        const lineId = "56906918-8a2a-4652-80fe-adc1ededacd1"; // linea: Square
        const modelId = "1ac1104f-0208-4a0c-bdca-7ba50df4756f"; // modello: 2X2
        const finishId = "7357f125-e556-467c-ba37-2a1e17abc6cf"; // finitura: Acciaio lucido

        const plateEle = $( "#plate-line" );
        const modelEle = $( "#plate-model" );
        const finishEle = $( "#plate-finish" );
        const fruitSuggest = $( "#plate-fruit-suggest" );
        const autocomplete = fruitSuggest.data( "kendoAutoComplete" );

        // Sequenza asincrona
        await helper.wait( 600 );
        $( "body" ).find( "#nav-products-tab" ).click();

        await helper.wait( 600 );
        $( "body" ).find( "button[data-bind='click:addPlate']" ).click();

        await helper.wait( 600 );
        plateEle.val( lineId ).trigger( "change" );

        await helper.wait( 600 );
        modelEle.val( modelId ).trigger( "change" );

        await helper.wait( 800 );
        finishEle.val( finishId ).trigger( "change" );

        // switch to fruits tab
        await helper.wait( 200 );
        $( ".nav-tabs a[href='#plate-fruit-product-items-tab']" ).tab( "show" );

        // interaction with suggest
        // var terms = [ "schu", "CONNETTORE VIDEO RCA" ];
        var terms = [ "schu", "CONNETTORE RJ11" ];

        for ( var term of terms ) {


            // 1. Imposta il valore nell'input (opzionale, ma pulito)
            fruitSuggest.val( term );

            // 2. Chiama il metodo search() del widget Kendo
            autocomplete.search( term );

            await helper.wait( 1200 );

            autocomplete.list.find( "li:first" ).click();

        }

        return;

    }

} );
