AP.rawValue = AP.rawValue || {};
AP.fields.rawValue = AP.fields.rawValue || {};

AP.fields.rawValue = {
    listRoot: $( "#raw-value-list-root" ),
    detailRoot: $( "#raw-value-detail-modal" ),
    detailForm: $( "#raw-value-detail-form" )
};

$( document ).ready( function(){

    if ( AP.fields.rawValue.detailRoot.length ) {

        AP.rawValue.detail.init();

    }

    if ( AP.fields.rawValue.listRoot.length ) {

        AP.rawValue.list.init();

    }

} );

/*
	detail
*/

AP.rawValue.detail = ( function() {

    var pub = {};

    var fields = AP.fields.rawValue;

    var defaults = {

        detailForm: {
            data: {
                status: {
                    id: "ACT"
                },
                id: "",
                nameItem: {
                    id: "",
                    name: "",
                    lang: {
                        id: "IT"
                    }
                }
            },
            title: "Carica valore",
            action: "create"
        },

    };

    var viewModel = kendo.observable( {

        detailForm: defaults.detailForm,

        statusList: AP.page.statusList,

        callback: {
            onCreate: undefined,
            onUpdate: undefined,
            onLoad: undefined,
        },

        getTitleForm: function( event ) {

            var data = viewModel.get( "detailForm.data" );

            if( this.isUpdate() ) {
    			return "Modifica valore < " + data.name + " >";
            }

    		return "Carica nuovo valore";

        },

        isUpdate: function() {

            return viewModel.get( "detailForm.data.id" ).toString().length;

        },

        resetForm: function() {

            var thisForm = $( "#raw-value-detail-form" );

            viewModel.set( "detailForm", defaults.detailForm );

            thisForm.find( ".status" ).html( "" );
            thisForm.data( "validator" ).resetForm();

        },

        save: function() {

            var thisForm = fields.detailForm;
            var status = thisForm.find( ".status" );

            if( thisForm.valid() ) {

                var data = viewModel.get( "detailForm.data" );

                status.html( "<img src='/assets/main/img/ajax-loading.svg' width=20 height=20>" );

                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/raw-values",
                    data: JSON.stringify( data ),
                    callback: {
                        done: function( xhr ) {

                            var callback = viewModel.isUpdate() ? "onUpdate" : "onCreate";

                            NM.util.autoHideMessage( status, "<span class='green'>" + xhr.data.message.text + "</span>" );

                            setTimeout( () => {

                                AP.util.fireCallback( callback, viewModel.get( "callback" ) );

                                $( "#raw-value-detail-modal" ).modal( "hide" );

                            }, 700 );

                        }
                    }
                } );

            }

            return false;

        },

    } );

    pub.new = function( onCreate ) {

        if( onCreate ) {
            viewModel.set( "callback.onCreate", onCreate );
        }

        viewModel.resetForm();

        $( "#raw-value-nav-values-but" ).addClass( "disabled" );

        NM.util.openModal( $( "#raw-value-detail-modal" ) );

        return;

    };


    pub.edit = function( id, onUpdate ) {

        if( onUpdate ) {
            viewModel.set( "callback.onUpdate", onUpdate );
        }

        loadValue( id );

    };

    pub.init = function() {

        kendo.bind( fields.detailRoot, viewModel );

        var detailForm = fields.detailForm;

        detailForm.validate( {
            onfocusout: function( element ) {
                $( element ).valid();
            },
            rules: {
                rawValueName: {
                    required: true,
                },
                code: {
                    checkCode: true,
                    required: true,
                    maxlength: 5,
                    remote: {
                        url: "/manager/ajax/raw-values/code-exists",
                        data: { id: function() { return  viewModel.get( "detailForm.data.id" ); } },
                        dataFilter: function( xhr ) {
                            var json = JSON.parse( xhr );
                            return json.data == false;
                        }
                    }
                },
                rawValueStatusId: {
                    required: true
                }
            },
            messages: {
                rawValueName: {
                    required: "Descrizione richiesta",
                },
                rawValueStatusId: {
                    required: "Stato richoesto",
                },
                code: {
                    required: "Codice richiesto",
                    checkCode: "Solo numeri, lettere, trattino o trattino basso",
                    remote: "Il codice esiste",
                    max: "Al massimo 5 caratteri"
                },
            },

        } );

    };

    var loadValue = function( id ) {

        // var thisForm = fields.detailForm;

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/raw-values/" + id,
            callback: {
                done: function( xhr ) {

                    viewModel.set( "detailForm.data", xhr.data );

                    NM.util.openModal( fields.detailRoot );

                    if ( viewModel.get( "callback.onLoad" ) ) {
                        viewModel.get( "callback.onLoad" )( xhr.data );
                    }

                }
            }
        } );

    };

    return pub;

}() );


AP.rawValue.list = ( function() {

    var pub = {};

    var fields = AP.fields.rawValue;
    var detailApp = AP.rawValue.detail;
    var metadataApp = AP.metadata.detail;

    var dataSources = {
        items: NM.kendo.dataSource( { url: "/manager/ajax/raw-values" } )
    };

    var viewModel = kendo.observable( {
        rows: dataSources.items,

        getCreatedAt: function( event ) {

            return NM.kendo.formatDate( event.createdAt );

        },

        search: function( event ) {

            var thisForm = fields.listRoot.find( "#raw-value-grid-search-form" );

            var params = thisForm.serializeJSON();

            viewModel.rows.read( params );

            return false;

        },

        new: function() {

            var onCreate = function( data ) {
                viewModel.rows.read();
            };

            detailApp.new( onCreate );

        },

        edit: function( event ) {

            var onUpdate = function( data ) {
                viewModel.rows.read();
            };

            detailApp.edit( event.data.id, onUpdate );

        },

        delete: function( event ) {

            var checks = $( "#raw-value-grid-form" ).find( "[name=selected]:checked" );

            if ( checks.length ) {

                var values = [];

                checks.each( function(){
                    values.push( $( this ).val() );
                } );

                var ids = values.toString();

                NM.util.ajax( {
                    method: "DELETE",
                    url: "/manager/ajax/raw-values",
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

        metadata: function( event ) {

            var value = {
                entity: "rawValue",
                value: event.data.id
            };

            metadataApp.open( value );

            return false;
        },

    } );

    pub.refresh = function() {

        viewModel.rows.read();

    },

    pub.init = function() {

        kendo.bind( fields.listRoot, viewModel );

    };

    return pub;
}() );