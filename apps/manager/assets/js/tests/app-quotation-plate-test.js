AP.test = AP.test || {};
AP.test.quotation = {};

$( document ).ready( async function() {

    // if ( AP.config.user.id == "88d5709f-902c-490d-854d-0ab0fb2f7981_" ) { // Roberto (admin)

    AP.test.quotation = ( function() {

        var pub = {};

        var helper = AP.test.helper;

        //console.log("helper", helper);

        pub.new = async function() {

            await helper.wait( 2000 );

            console.log( "test:new" );

            const lineId = "56906918-8a2a-4652-80fe-adc1ededacd1"; // linea: Square
            const modelId = "1ac1104f-0208-4a0c-bdca-7ba50df4756f"; // modello: 2X2
            const finishId = "7357f125-e556-467c-ba37-2a1e17abc6cf"; // finitura: Acciaio lucido

            var fruits = []; // Default: nessun fruit
            var fruits = [ "schu", "CONNETTORE RJ11" ];
            //var fruits = [ "PULSANTE SINGOLO INF", "schu" ];
            // var fruits = [ "P40", "CONNETTORE RJ11" ];
            // var fruits = [ "schu" ];
            // var fruits = [ "schu", "PULSANTE SINGOLO INF" ];

            const lineEle = $( "#plate-line" );
            const modelEle = $( "#plate-model" );
            const finishEle = $( "#plate-finish" );
            const fruitSuggest = $( "#plate-fruit-suggest" );
            const autocomplete = fruitSuggest.data( "kendoAutoComplete" );

            // first item, if editing existing item
            //$( "body" ).find( ".quotation-item:first" ).click();

            // Sequenza asincrona
            //await helper.wait( 600 );
            //$( "body" ).find( "#nav-products-tab" ).click();

            await helper.wait( 600 );
            $( "body" ).find( "button[data-bind='click:addPlate']" ).click();

            await helper.wait( 500 );
            lineEle.val( lineId ).trigger( "change" );

            await helper.wait( 500 );
            modelEle.val( modelId ).trigger( "change" );

            await helper.wait( 600 );
            finishEle.val( finishId ).trigger( "change" );

            // switch to fruits tab
            await helper.wait( 600 );
            $( ".nav-tabs a[href='#plate-fruit-product-items-tab']" ).tab( "show" );

            // interaction with suggest
            // var terms = [ "schu", "CONNETTORE VIDEO RCA" ];

            for ( var term of fruits ) {

                // 1. Imposta il valore nell'input (opzionale, ma pulito)
                fruitSuggest.val( term );

                // 2. Chiama il metodo search() del widget Kendo
                autocomplete.search( term );

                await helper.wait( 1200 );

                autocomplete.list.find( "li:first" ).click();

            }

            return;

        };

        pub.edit = async function() {

            console.log( "test:edit" );

            await helper.wait( 600 );
            $( "body" ).find( ".quotation-item" ).eq( 1 ).click();

        };

        return pub;

    }() );

    // fire correct test here:
    AP.test.quotation.new();

} );
