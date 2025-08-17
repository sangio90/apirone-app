AP.productionTime = AP.productionTime || {};

AP.productionTime.fields = {
    listRoot: $( "#production-times-list-root" ),
    detailRoot: $( "#production-times-detail-modal" ),
    detailForm: $( "#production-times-detail-form" ),
    searchListForm: $( "#production-times-grid-search-form" ),
    productsRoot: $( "#production-times-products-root" )
};

$( document ).ready( function(){
    if ( AP.productionTime.fields.listRoot.length ) {
	    AP.productionTime.list.init();
    }

    if ( AP.productionTime.fields.detailRoot.length ) {
	    AP.productionTime.detail.init();
    }

} );

AP.productionTime.detail = ( function() {

    var pub = {};

    var fields = AP.productionTime.fields;

    var defaultDetailForm = {
        data: {
            id: "",
            code: "",
            name: "",
            category: {
                id: ""
            },
            thickness: {
                id: ""
            },
            status: {
                id: "ACT"
            }
        },

        statuses: AP.page.statuses,

        title: "Carica tempo di produzione"
    };


    var viewModel = kendo.observable( {
        statuses: AP.page.statuses,

        detailForm: defaultDetailForm,

        callback: {
            onCreate: undefined,
            onUpdate: undefined,
            onLoad: undefined
        },

        resetForm: function() {

            var detailForm = fields.detailForm;

            console.log( "resetForm", detailForm );

            // var validator = detailForm.validate();
            // validator.resetForm();

            detailForm.find( ".status" ).html( "" );

            viewModel.set( "detailForm", defaultDetailForm );
        },

        save: function( event ) {

            var detailForm = fields.detailForm;
            var status = detailForm.find( ".status" );

		    status.html( "<img src='assets/main/img/ajax-loading.svg' width=20 height=20>" );

            if( detailForm.valid() ) {

                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/production-times",
                    data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
                    callback: {
                        done: function( xhr ) {

                            if( xhr.status == "SUCCESS" ) {

                                NM.util.autoHideMessage( status, "<span class='green'>Record salvato</span>" );

                                setTimeout( () => $( "#production-times-detail-modal" ).modal( "hide" ), 1000 );

                                AP.util.fireCallback( "onSave", viewModel.get( "callback" ) );

                            }

                        }
                    }
                } );

            }

            return false;

        },

    } );

    pub.new = function( { onSave } ) {

        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        viewModel.resetForm();

        NM.util.openModal( fields.detailRoot );

    },

    pub.edit = function( { id, onSave } ) {

        console.log( "edit production time", id );

        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        viewModel.resetForm();

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/production-times/" + id,
            callback: {
                done: function( xhr ) {

                    if( xhr.status == "SUCCESS" ) {

                        viewModel.set( "detailForm.data", xhr.data );
                        viewModel.set( "detailForm.title", "Modifica tempo di produzione" );

                        NM.util.openModal( fields.detailRoot );

                    }

                }
            }
        } );

    },

    pub.init = function() {

        kendo.bind( fields.detailRoot, viewModel );

        var detailForm = fields.detailForm;

        detailForm.validate( {
            onfocusout: function( element ) {
                $( element ).valid();
            },
            rules: {
                code: {
                    required: true,
                    checkCode: true,
                    remote: {
                        url: "/manager/ajax/production-times/code-exists",
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
}() );


AP.productionTime.list = ( function() {

    var pub = {};

    var detailApp = AP.productionTime.detail;
    var fields = AP.productionTime.fields;

    var dataSources = {
        items: NM.kendo.dataSource( { url: "/manager/ajax/production-times" } )
    };

    var viewModel = kendo.observable( {
        rows: dataSources.items,

        search: function( event ) {

            var thisForm = fields.searchListForm;

            var params = thisForm.serializeJSON();

            viewModel.rows.read( params );

            return false;

        },

        new: function( event ) {

            console.log( "detailApp", detailApp );

            var onSave = function() {
                console.log( "onSave" );
                viewModel.get( "rows" ).read();
            };

            detailApp.new( { onSave: onSave } );

            return false;

        },

        edit: function( event ) {

            var onSave = function() {
                viewModel.get( "rows" ).read();
            };

            detailApp.edit( { id: event.data.id, onSave: onSave } );

            return false;

        },

        delete: function( event ) {

            var status = $( "#status-delete" );
            var checks = $( "#production-times-grid-form" ).find( "[name=selected]:checked" );

            console.log( "checks", checks );

            if ( checks.length ) {

                var values = [];

                checks.each( function(){
                    values.push( $( this ).val() );
                } );

                var ids = values.toString();

                NM.util.ajax( {
                    method: "DELETE",
                    url: "/manager/ajax/production-times",
                    data: ids,
                    callback: {
                        done: function( xhr ) {

                            if( xhr.data.payload.hasOwnProperty( "errors" ) ) {
                                AP.widget.notify( "error", "Non riesco a cancellare tutti i valori" );
                            } else {
                                AP.widget.notify( "success", "Cancellazione avvenuta con successo" );
                            }

                            var id = viewModel.get( "detailForm.data.id" );

                            viewModel.rows.read();

                        }
                    }
                } );

            } else {

                NM.util.autoHideMessage( status, "<span class='red'>Seleziona almeno un valore</span>" );

            }

        },

    } );

    pub.init = function() {

        kendo.bind( fields.listRoot, viewModel );

    };

    return pub;
}() );

