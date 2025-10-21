AP.country = AP.country || {};

AP.country.fields = {
    listRoot: $( "#country-list-root" ),
    detailForm: $( "#country-detail-form" ),
    searchListForm: $( "#country-grid-search-form" ),
};

$( document ).ready( function() {
    if ( AP.country.fields.listRoot.length ) {
        AP.country.list.init();
    }
} );

AP.country.list = ( function() {
    var pub = {};

    var dataSources = {
        items: NM.kendo.dataSource( { url: "/manager/ajax/countries" } ),
    };

    var defaultDetailForm = {
        data: {
            id: "",
            code: "",
            name: "",
            nameItem: {
                id: "",
                name: ""
            }
        },

        title: "Carica Nazione"
    };

    var viewModel = kendo.observable( {
        rows: dataSources.items,
        detailForm: defaultDetailForm,
        
        resetForm: function() {
            viewModel.set( "detailForm", defaultDetailForm );
        },

        search: function( event ) {
            var thisForm = AP.country.fields.searchListForm;

            var params = thisForm.serializeJSON();

            viewModel.rows.read( params );

            return false;
        },

        save: function( event ) {

            var thisForm = AP.country.fields.detailForm;
            var status = thisForm.find( ".status" );

            status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

            if( thisForm.valid() ) {

                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/countries",
                    data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
                    callback: {
                        done: function( xhr ) {

                            NM.util.autoHideMessage( status, "<span class='green'>Nazione salvata</span>" );

                            setTimeout( () => $( "#country-detail-modal" ).modal( "hide" ), 1000 );

                            viewModel.rows.read();

                        }
                    }
                } );

            }

            return false;

        },

        new: function( event ) {

            this.resetForm();

            NM.util.openModal( $( "#country-detail-modal" ) );

        },
        
        delete: function( event ) {

            var checks = $( "#country-grid" ).find( "[name=selected]:checked" );

            if ( checks.length ) {

                var values = [];

                checks.each( function(){
                    values.push( $( this ).val() );
                } );

                var ids = values.toString();

                NM.util.ajax( {
                    method: "DELETE",
                    url: "/manager/ajax/countries",
                    data: ids,
                    callback: {
                        done: function( xhr ) {

                            if( xhr.data.payload.hasOwnProperty( "errors" ) ) {
                                AP.widget.notify( "error", "Non riesco a cancellare tutti i valori" );
                            } else {
                                AP.widget.notify( "success", "Cancellazione avvenuta con successo" );
                            }

                            viewModel.rows.read();

                        }
                    }
                } );

            } else {

                AP.widget.notify( "warning", "Seleziona almeno un valore" );

            }

        },
    } );

    pub.init = function() {
        kendo.bind( AP.country.fields.listRoot, viewModel );
        
        var detailForm = AP.country.fields.detailForm;

        detailForm.validate( {
            onfocusout: function( element ) {
                $( element ).valid();
            },
            rules: {
                code: {
                    required: true,
                    checkCode: true,
                    remote: {
                        url: "/manager/ajax/countries/code-exists",
                        data: { id: function() { return  viewModel.get( "detailForm.data.id" ); } },
                        dataFilter: function( xhr ) {
                            var json = JSON.parse( xhr );
                            return json.data == false;
                        }
                    }
                }
            },
            messages: {
                code: {
                    required: "Codice richiesto",
                    checkCode: "Solo numeri, lettere, trattino o trattino basso",
                    remote: "Il codice esiste"
                }
            },

        } );
    };

    return pub;
} () );
