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

        const fontConfigs = viewModel.get( "selectedFonts" ).data();

        fontConfigs.forEach( fontConfig => {
            const seenHeights = new Set();
            const duplicateHeights = new Set();

            const sizesData = fontConfig.items.data();

            sizesData.forEach( size => {
                const heightValue = size.get( "height" );

                if ( seenHeights.has( heightValue ) ) {
                    duplicateHeights.add( heightValue );
                } else {
                    seenHeights.add( heightValue );
                }
            } );

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

    var componentApp = AP.component.modal;

    var defaultSizeRow = {
        id: "",
        height: "",
        heightInPx: "",
        size: { "id": null, "name": "-- Seleziona Font Size" },
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

    var items = new kendo.data.DataSource( { data: AP.page.availableFonts } );
    var selected = new kendo.data.DataSource();

    var viewModel = kendo.observable( {
        fontList: items,
        selectedFonts: selected,

        add: function( event ) {

            var selected = viewModel.get( "selectedFonts" ).data();

            for ( var item of selected ) {
                if ( item.font.id == event.data.id ) {
                    AP.widget.notify( "warning", "Font già selezionato" );
                    return;
                }
            }

            var newRow = {
                font: event.data,
                items: new kendo.data.DataSource( { data: [ defaultSizeRow ] } )
            };

            viewModel.get( "selectedFonts" ).add( newRow );

        },

        addItem: function( event ) {
            var row = viewModel.get( "selectedFonts" ).getByUid( event.data.uid );
            row.items.add( defaultSizeRow ); // Usa il metodo del DataSource
            return false;
        },

        showSelectedList: function( event ){
            return viewModel.get( "selectedFonts" ).data().length > 0;
        },

        showComponentButton: function( event ) {
            return event.id > 0;
        },

        openComponentsList: function( event ) {

            var value = {
                type: "signageConfigItem",
                signageConfigItem: {
                    id: event.data.id,
                },
            };

            componentApp.open( value );

            return false;
        },

        delete: function( event ) {
            var row = event.data.parent().parent();
            var items = row.items; // DataSource delle sizes

            if ( items.data().length === 1 ) {
                // Se c'è solo una size, rimuovi tutto il font
                var dataItem = viewModel.get( "selectedFonts" ).getByUid( row.uid );
                viewModel.get( "selectedFonts" ).remove( dataItem );
            } else {
                // Rimuovi solo la size selezionata
                var sizeRow = items.getByUid( event.data.uid );
                items.remove( sizeRow );
            }
            return false;
        },

        getFamilySizes: function(event) {
            var selectedFont = viewModel.get("selectedFonts").getByUid( event.parent().parent().uid );
            return selectedFont?.font?.fontFamily?.sizes || [];
        },

        save: function( event ) {
            var selectedForm = AP.signConfig.fields.selectedForm;
            var status = selectedForm.find( ".status" );

            if ( selectedForm.valid() ) {

                status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/signages/rows-config",
                    data: JSON.stringify( { configs: viewModel.get( "selectedFonts" ).data(), catalogBundle: AP.page.catalogBundle } ),

                    callback: {
                        done: function( xhr ) {
                            if ( xhr.status == "SUCCESS" ) {
                                // viewModel.get( "selectedFonts" ).read();
                                AP.widget.notify( "success", "Configurazione salvata correttamente" );
                                setTimeout( function() {
                                    window.location.reload();
                                }, 1000 );
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

        var selected = new kendo.data.DataSource();

        for ( var font of AP.page.selectedFonts ) {
            var newRow = {
                id: font.id,
                font: font.font,
                items: new kendo.data.DataSource( { data: font.items } )
            };

            selected.add( newRow );
        }

        viewModel.set( "selectedFonts", selected );

        var selectedForm = AP.signConfig.fields.selectedForm;

        selectedForm.validate( {
            onfocusout: function( element ) {
                $( element ).valid();
            },
        } );
    };

    return pub;
} () );
