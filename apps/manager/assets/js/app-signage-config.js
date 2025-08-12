AP.signConfig = AP.signConfig || {};

AP.signConfig.fields = {
    detailRoot: $( "#signage-config-root" ),
    selectedForm: $( "#signage-config-selected-form" ),
    detailForm: $( "#signage-detail-form" ),
};

$( document ).ready( function() {
    if ( AP.signConfig.fields.detailRoot.length ) {
        AP.signConfig.detail.init();
    }
} );


AP.signConfig.detail = ( function() {

    $.validator.addMethod( "findDuplicateHeights", function( value, element ) {

        const errors = [];

        // var data = viewModel.get( "fontSelected" ).data().toJSON();

        const fontConfigs = viewModel.get( "fontSelected" ).data();

        // Itera su ogni configurazione di font
        fontConfigs.forEach( fontConfig => {
            const seenHeights = new Set();
            const duplicateHeights = new Set();

            // Estrae l'array di dati dal DataSource 'sizes' nidificato
            const sizesData = fontConfig.items.data();

            // Itera su ogni 'size' per il font corrente
            sizesData.forEach( size => {
                // Accede alla proprietà 'height'. Usiamo .get() per sicurezza,
                // dato che 'size' è un ObservableObject.
                const heightValue = size.get( "height" );

                if ( seenHeights.has( heightValue ) ) {
                    // Se l'altezza è già nel Set, è un duplicato
                    duplicateHeights.add( heightValue );
                } else {
                    // Altrimenti, aggiungila al Set delle altezze viste
                    seenHeights.add( heightValue );
                }
            } );

            // Se sono stati trovati duplicati per questo font, aggiungili all'array degli errori
            if ( duplicateHeights.size > 0 ) {
                errors.push( {
                    fontId: fontConfig.font.id, // L'oggetto font non è un DataSource, si accede direttamente
                    duplicates: Array.from( duplicateHeights ) // Converte il Set in un array
                } );
            }
        } );

        return errors.length > 0 ? false : true;

    } );


    var pub = {};

    var defaultSizeRow = {
        id: "",
        height: "",
        heightInPx: "",
        charCount: "",
        rowCount: ""
    };

    var defaultRow = {
        font: {
            id: "",
            code: "",
            directory: "",
            name: "",
        },
        // sizes: new kendo.data.DataSource( { data: [] } )
        items: []
    };

    var items = new kendo.data.DataSource();
    var selected = new kendo.data.DataSource();
    // selected.sizes = new kendo.data.DataSource();

    items.data( AP.page.fonts );
    // selected.data( [] );

    var viewModel = kendo.observable( {
        fontList: items,
        fontSelected: selected,

        add: function( event ) {

            var selected = viewModel.get( "fontSelected" ).data();

            for ( var item of selected ) {
                console.log( "item", item );
                console.log( "event.data", event.data );
                if ( item.font.id == event.data.id ) {
                    AP.widget.notify( "warning", "Font già selezionato" );
                    return;
                }
            }

            var newRow = {
                font: event.data,
                items: new kendo.data.DataSource( { data: [ defaultSizeRow ] } )
            };

            viewModel.get( "fontSelected" ).add( newRow );

        },

        addItem: function( event ) {
            var row = viewModel.get( "fontSelected" ).getByUid( event.data.uid );
            row.items.add( defaultSizeRow ); // Usa il metodo del DataSource
            return false;
        },

        showSelectedList: function( event ){
            return viewModel.get( "fontSelected" ).data().length > 0;
        },

        delete: function( event ) {
            var row = event.data.parent().parent();
            var items = row.items; // DataSource delle sizes

            if ( items.data().length === 1 ) {
                // Se c'è solo una size, rimuovi tutto il font
                var dataItem = viewModel.get( "fontSelected" ).getByUid( row.uid );
                viewModel.get( "fontSelected" ).remove( dataItem );
            } else {
                // Rimuovi solo la size selezionata
                var sizeRow = items.getByUid( event.data.uid );
                items.remove( sizeRow );
            }
            return false;
        },

        save: function( event ) {
            var selectedForm = AP.signConfig.fields.selectedForm;
            var status = selectedForm.find( ".status" );

            if ( selectedForm.valid() ) {

                status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/signages/rows-config",
                    data: JSON.stringify( viewModel.get( "fontSelected" ).data() ),
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.status == "SUCCESS" ) {
                                NM.util.autoHideMessage( status, "<span class='green'>Font salvato</span>" );
                            }
                        },
                    },
                } );
            }

            return false;
        },
    } );

    pub.init = function() {
        kendo.bind( AP.signConfig.fields.detailRoot, viewModel );

        var selectedForm = AP.signConfig.fields.selectedForm;

        selectedForm.validate( {
            onfocusout: function( element ) {
                $( element ).valid();
            },
        } );
    };

    return pub;
} () );
