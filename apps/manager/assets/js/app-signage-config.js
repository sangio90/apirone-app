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
        sizes: []
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
                sizes: new kendo.data.DataSource( { data: [ defaultSizeRow ] } )
            };

            viewModel.get( "fontSelected" ).add( newRow );

        },

        addSize: function( event ) {
            var row = viewModel.get( "fontSelected" ).getByUid( event.data.uid );
            row.sizes.add( defaultSizeRow ); // Usa il metodo del DataSource
            return false;
        },

        showSelectedList: function( event ){
            return viewModel.get( "fontSelected" ).data().length > 0;
        },

        delete: function( event ) {
            var row = event.data.parent().parent();
            var sizes = row.sizes; // DataSource delle sizes

            if ( sizes.data().length === 1 ) {
                // Se c'è solo una size, rimuovi tutto il font
                var dataItem = viewModel.get( "fontSelected" ).getByUid( row.uid );
                viewModel.get( "fontSelected" ).remove( dataItem );
            } else {
                // Rimuovi solo la size selezionata
                var sizeRow = sizes.getByUid( event.data.uid );
                sizes.remove( sizeRow );
            }
            return false;
        },

        save: function( event ) {
            var selectedForm = AP.signConfig.fields.selectedForm;
            var status = selectedForm.find( ".status" );

            if ( selectedForm.valid() ) {

                status.html(
                    "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>",
                );

                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/fonts",
                    data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.status == "SUCCESS" ) {
                                NM.util.autoHideMessage(
                                    status,
                                    "<span class='green'>Font salvato</span>",
                                );

                                setTimeout(
                                    () => $( "#signage-detail-modal" ).modal( "hide" ),
                                    1000,
                                );

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
