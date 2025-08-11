AP.signConfig = AP.signConfig || {};

AP.signConfig.fields = {
    detailRoot: $( "#sign-config-root" ),
    selectedForm: $( "#sign-config-selected-form" ),
    detailForm: $( "#sign-detail-form" ),
};

$( document ).ready( function() {
    if ( AP.signConfig.fields.detailRoot.length ) {
        AP.signConfig.detail.init();
    }
} );

AP.signConfig.detail = ( function() {
    var pub = {};

    var defaultSizeRow = {
        id: "1",
        height: "",
        heightInPx: "",
        charCount: "",
        rowCount: ""
    };

    var defaultRow = {
        data: {
            id: "",
            code: "",
            directory: "",
            name: "",
            sizes: []
        }
    };

    var items = new kendo.data.DataSource();
    var selected = new kendo.data.DataSource();

    items.data( AP.page.fonts );
    selected.data( [] );

    var viewModel = kendo.observable( {
        fontList: items,
        fontSelected: selected,

        add: function( event ) {
            console.log( "add" );

            var selected = viewModel.get( "fontSelected" ).data();

            for( var item of selected  ) {
                if ( item.id == event.data.id ) {
                    AP.widget.notify( "warning", "Font già selezionato" );
                    return;
                }
            }

            var row = viewModel.get( "fontList" ).getByUid( event.data.uid );
            row.sizes.push( defaultSizeRow );


            // var row = event.data.sizes.da( defaultSizeRow );

            // row.add( defaultSizeRow );

            viewModel.get( "fontSelected" ).add( row );

        },

        showSelectedList: function( event ){
            return viewModel.get( "fontSelected" ).data().length > 0;
        },

        delete: function( event ) {

            console.log( "event", );

            return false;

            // return viewModel.get( "fontSelected" ).data().length > 0;
        },

        save: function( event ) {
            var selectedForm = AP.signConfig.fields.selectedForm;
            var status = selectedForm.find( ".status" );

            if ( selectedForm.valid() ) {

                status.html(
                    "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>",
                );

                if ( detailForm.valid() ) {
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
                                        () => $( "#sign-detail-modal" ).modal( "hide" ),
                                        1000,
                                    );

                                }
                            },
                        },
                    } );
                }

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
