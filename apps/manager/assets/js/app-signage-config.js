AP.signageConfig = AP.signageConfig || {};

AP.signageConfig.fields = {
    detailRoot: $( "#signage-config-root" ),
    selectedForm: $( "#signage-config-selected-form" ),
    detailForm: $( "#signage-detail-form" ),
};

$( document ).ready( function() {
    if ( AP.signageConfig.fields.detailRoot.length ) {
        AP.signageConfig.detail.init();
    }
} );

AP.signageConfig.detail = ( function() {

    $.validator.addMethod( "findDuplicateHeights", function( value, element ) {

        const errors = [];

        const fontConfigs = viewModel.get( "selectedFonts" ).data();

        fontConfigs.forEach( fontConfig => {
            const seenHeights = new Set();
            const duplicateHeights = new Set();

            const items = fontConfig.items.data();

            items.forEach( item => {
                const heightValue = item.get( "size.id" );

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
    var fields = AP.signageConfig.fields;

    var defaultSizeRow = {
        id: "",
        height: "",
        heightInPx: "",
        deleted: false,
        size: { "id": "", "name": "-- Seleziona Font Size" },
        charCount: "",
        rowCount: ""
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
            row.get( "items" ).add( defaultSizeRow ); // Usa il metodo del DataSource
            return false;
        },

        showSelectedList: function( event ){
            return viewModel.get( "selectedFonts" ).data().length > 0;
        },

        showComponentButton: function( event ) {
            return event.id > 0;
        },

        openComponentWithItems: function( event ) {

            window.open( "/manager/signages/rows-config-item/" + event.data.id, "_blank" );

            return false;
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
            // var items = row.items; // DataSource delle sizes
            var rowSize = row.items.getByUid( event.data.uid );

            var deleted = rowSize.get( "deleted" );

            var newValue = false;

            if ( !deleted ) {
                newValue = true;
            }

            rowSize.set( "deleted", newValue );

            return false;
        },

        isDeleted: function( row ) {
            return row.get( "deleted" ) ?? false;
        },


        getFontFamilySizes: function( event ) {

            var parent = event.parent().parent();
            var sizes = parent.font.fontFamily.sizes.toJSON();

            var dataSource = new kendo.data.DataSource();

            sizes.unshift( { "id": "", "name": "-- Seleziona" } );

            dataSource.data( sizes );

            return dataSource;

        },

        save: function( event ) {

            var selectedForm = AP.signageConfig.fields.selectedForm;
            var status = selectedForm.find( ".status" );

            if ( selectedForm.valid() ) {

                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/signages/rows-config",
                    data: JSON.stringify( { configs: viewModel.get( "selectedFonts" ).data(), catalogBundle: AP.page.catalogBundle } ),

                    callback: {
                        done: function( xhr ) {
                            if ( xhr.status == "SUCCESS" ) {
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

        kendo.bind( AP.signageConfig.fields.detailRoot, viewModel );

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

        var selectedForm = AP.signageConfig.fields.selectedForm;

        selectedForm.validate( {
            onfocusout: function( element ) {
                $( element ).valid();
            },
        } );
    };

    return pub;
}() );
