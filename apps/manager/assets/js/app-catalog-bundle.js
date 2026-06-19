AP.namespace( "catalogBundle" );

Object.assign( AP.catalogBundle.fields, {
    listRoot: $( "#catalog-bundle-list-root" ),
    searchForm: $( "#catalog-bundle-grid-search-form" ),
    detailRoot: $( "#catalog-bundle-detail-modal" ),
    detailForm: $( "#catalog-bundle-detail-form" ),
} );

$( document ).ready( function() {
    if ( AP.catalogBundle.fields.listRoot.length ) {
        AP.catalogBundle.list.init();
    }

} );

AP.catalogBundle.list = ( function() {
    var pub = {};

    var fields  = AP.catalogBundle.fields;

    var defaultDetailForm = {
        data: {
            id: "",
            markupValue: "",
            category: { id: "" },
            line: { id: "" },
            model: { id: "" },
        },
        title: "Carica bundle",
    };

    var viewModel = kendo.observable( {
        rows: NM.kendo.dataSource( { url: "/manager/ajax/catalog-bundles" } ),

        detailForm: JSON.parse( JSON.stringify( defaultDetailForm ) ),

        resetForm: function() {
            viewModel.set( "detailForm", JSON.parse( JSON.stringify( defaultDetailForm ) ) );
        },

        getCreatedAt: function( event ) {
            return NM.kendo.formatISODate( event.createdAt );
        },

        search: function( event ) {
            var thisForm = fields.searchForm;

            var params = thisForm.serializeJSON();
            params.page = 1;

            viewModel.rows.read( params );

            return false;
        },

        new: function( event ) {
            this.resetForm();

            NM.util.openModal( fields.detailRoot );

            return false;
        },

        edit: function( event ) {
            this.resetForm();

            viewModel.set( "detailForm.data.id", event.data.id );
            viewModel.set( "detailForm.data.markupValue", event.data.markupValue );
            viewModel.set( "detailForm.data.category.id", event.data.category.id );
            viewModel.set( "detailForm.data.line.id", event.data.line.id );
            viewModel.set( "detailForm.data.model.id", event.data.model.id );
            viewModel.set( "detailForm.title", "Modifica bundle < " + event.data.shortId + " >" );

            NM.util.openModal( fields.detailRoot );

            return false;
        },

        saveDetail: function( event ) {
            var thisForm = fields.detailForm;
            var status = thisForm.find( ".status" );

            if ( !thisForm.valid() ) {
                return false;
            }

            status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

            NM.util.ajax( {
                method: "POST",
                url: "/manager/ajax/catalog-bundles/detail",
                data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
                callback: {
                    done: function( xhr ) {
                        status.html( "" );

                        if ( xhr.data.payload && xhr.data.payload.hasOwnProperty( "errors" ) ) {
                            AP.widget.notify( "error", xhr.data.message.text );
                            return;
                        }

                        AP.widget.notify( "success", xhr.data.message.text );

                        setTimeout( () => fields.detailRoot.modal( "hide" ), 500 );

                        viewModel.rows.read();
                    },
                },
            } );

            return false;
        },

        save: function( event ) {
            var status = $( "#catalog-bindle-save-status" );

            status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

            NM.util.ajax( {
                method: "POST",
                url: "/manager/ajax/catalog-bundles",
                data: JSON.stringify( viewModel.get( "rows" ) ),
                callback: {
                    done: function( xhr ) {

                        status.html( "" );

                        if ( xhr.data.payload.hasOwnProperty( "errors" ) ) {
                            AP.widget.notify( "error", "Non riesco ad aggiornare tutti i bundle" );
                        } else {
                            AP.widget.notify( "success", "Salvataggio avvenuto con successo" );
                        }

                        viewModel.rows.read();
                    },
                },
            } );

            return false;
        },
    } );

    pub.init = function() {
        kendo.bind( fields.listRoot, viewModel );

        fields.detailForm.validate( {
            onfocusout: function( element ) {
                $( element ).valid();
            },
        } );
    };

    return pub;
} () );
