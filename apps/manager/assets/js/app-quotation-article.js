AP.namespace( "article" );

Object.assign( AP.quotation.fields, {
    articleModalRoot: $( "#article-modal-root" ),
} );

$( document ).ready( function() {
    if ( AP.quotation.fields.articleModalRoot.length ) {
        AP.article.modal.init();
    }
} );

AP.article.modal = ( function() {

    var pub = {};
    var fields = AP.quotation.fields;

    var defaultDetailForm = {
        data: {
            id: "",
            article: {
                id: "",
                price: 0,
            },
            quantity: 1
        },
        title: "Carica servizio",
    };

    var viewModel = kendo.observable( {
        detailForm: defaultDetailForm,

        resetForm: function() {
            viewModel.set( "detailForm", defaultDetailForm );
        },

        callback: {
            onCreate: undefined,
            onUpdate: undefined,
            onLoad: undefined,
        },

        save: function( event ) {

            NM.util.ajax( {
                method: "POST",
                url: "/manager/ajax/quotation-items/article",
                data: JSON.stringify( parsedData ),
                callback: {
                    done: function( xhr ) {
                        $( "#signage-modal" ).hide();
                        AP.widget.notify( "success", "Segnaletica salvata nel preventivo." );
                        viewModel.set( "detailForm", defaultDetailForm );

                        setTimeout( function() {
                            // AP.loading.hide();
                            window.location.reload();
                        }, 1000 );
                    },
                }
            } );

            return false;
        },
    } );

    pub.new = function( onSave ) {
        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        viewModel.resetForm();

        NM.util.openModal( fields.articleModalRoot );

    };

    pub.edit = function( id, onSave ) {
        viewModel.resetForm();

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/quotation-items/article/" + id,
            callback: {
                done: function( xhr ) {

                    viewModel.set( "detailForm.data.id", xhr.data.quotationItem.id );
                    viewModel.set( "detailForm.data.quotationZone", xhr.data.quotationItem.quotationZone );

                },
            },
        } );

    };

    pub.init = function() {
        kendo.bind( fields.articleModalRoot, viewModel );
    };

    return pub;
} () );
