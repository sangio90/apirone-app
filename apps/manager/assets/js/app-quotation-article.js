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
                note: "",
            },
            quantity: 1
        },
        articles: [],
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
        AP.loading.show();
        
        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/articles/",
            callback: {
                done: function( xhr ) {
                    if( xhr.status == "INVALID" ) {
                        AP.loading.hide();
                        NM.form.showMessages( xhr.data );
                        return;
                    }

                    if ( xhr.data.success == false ) {
                        AP.widget.notify( "error", xhr.data.error ? xhr.data.error : "Errore durante la lettura dei servizi." );
                        AP.loading.hide();
                        return;
                    }
                    if (xhr.data && xhr.data.length > 0) {
                        viewModel.set( "articles", xhr.data );
                    }
                    AP.loading.hide();
                }
            }
        } );

        
    };

    return pub;
} () );
