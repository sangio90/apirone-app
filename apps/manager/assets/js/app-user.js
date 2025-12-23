AP.namespace( "user" );

Object.assign( AP.user.fields, {
    listRoot: $( "#user-list-root" ),
    detailRoot: $( "#user-detail-modal" ),
    detailForm: $( "#user-detail-form" ),
    searchListForm: $( "#user-grid-search-form" )
} );

$( document ).ready( function() {
    if ( AP.user.fields.listRoot.length ) {
        AP.user.list.init();
    }

    if ( AP.user.fields.detailRoot.length ) {
        AP.user.detail.init();
    }
} );

AP.user.detail = ( function() {
    var pub = {};
    var fields = AP.user.fields;

    var defaultDetailForm = {
        data: {
            id: "",
            name: "",
            phone: "",
            email: "",
            status: {
                id: "ACT",
            },
            lang: {
                id: "IT",
            },
            selectedRoles: [],
            account: {
                id: ""
            }
        },

        roles: AP.page.roles,
        langs: AP.page.langs,
        statuses: AP.page.statuses,
        accounts: undefined,


        title: "Carica utente",
        buttonLabel: "Salva"
    };

    var loadAccounts = function() {
        NM.util.ajax( {
            url: "/manager/ajax/accounts",
            callback: {
                done: function( xhr ) {

                    xhr.data.unshift( {
                        id: "",
                        email: "-- Seleziona un account",
                    } );

                    console.log( "xhr.data", xhr.data );

                    viewModel.set( "detailForm.accounts", xhr.data );
                },
            },
        } );
    };

    var viewModel = kendo.observable( {
        detailForm: defaultDetailForm,

        isNewAccount: function() {

            var action = viewModel.get( "detailForm.data.accountAction" );

            if( action == "NEW" ) {
                return true;
            }

            return false;

        },

        resetForm: function() {
            var detailForm = fields.detailForm;

            var validator = detailForm.validate();
            validator.resetForm();

            detailForm.find( ".status" ).html( "" );

            viewModel.set( "detailForm", defaultDetailForm );
        },

        getCreatedAt: function( event ) {
            return NM.kendo.formatDate( event.createdAt );
        },

        isUpdate: function() {
            return viewModel.get( "detailForm.data.id" ).length > 0;
        },

        save: function( event ) {
            var detailForm = fields.detailForm;
            var status = $( ".errors-counter" );

            status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

            if ( detailForm.validate() ) {

                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/users",
                    data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
                    callback: {
                        done: function( xhr ) {

                            status.html( "" );
                            AP.widget.notify( "success", "Utente salvato con successo" );

                            setTimeout( () => {
                                $( "#user-detail-modal" ).modal( "hide" );
                                AP.user.list.refresh();
                            }, 1000 );

                        },
                    },
                } );
            }

            return false;
        },

        print: function( item ) {
            window.open( "/manager/account/print", "_blank" );

            return false;
        },
    } );

    pub.new = function() {
        viewModel.resetForm();

        NM.util.openModal( fields.detailRoot );
    };

    pub.edit = function( event ) {

        loadAccounts();

        viewModel.set( "detailForm.data", event.data );
        viewModel.set( "detailForm.title", "Modifica utente < " + event.data.name + " >" );

        NM.util.openModal( fields.detailRoot );
    };

    pub.init = function() {

        var detailForm = fields.detailForm;

        AP.page.roles.unshift( { id: "", name: "-- Seleziona un ruolo" } );

        viewModel.set( "detailForm.roles", AP.page.roles );

        AP.page.langs.unshift( { id: "", name: "-- Seleziona una lingua" } );

        viewModel.set( "detailForm.langs", AP.page.langs );

        AP.page.statuses.unshift( { id: "", name: "-- Seleziona uno stato" } );

        viewModel.set( "detailForm.statuses", AP.page.statuses );

        kendo.bind( fields.detailRoot, viewModel );

        detailForm.validate( {
            onfocusout: function( element ) {
                $( element ).valid();
            },
            rules: {
                name: {
                    required: true
                },
                roleId: {
                    required: true
                },
                langId: {
                    required: true
                },
                accountId: {
                    required: true
                },
            },
            messages: {
                name: {
                    required: "Nome richiesto",
                },
                roleId: {
                    required: "Ruolo richiesto",
                },
                langId: {
                    required: "Lingua richiesta",
                },
                accountId: {
                    required: "Account richiesto",
                },
            }
        } );
    };

    return pub;
} () );

AP.user.list = ( function() {
    var pub = {};

    var fields = AP.user.fields;
    var detailApp = AP.user.detail;

    var dataSources = {
        items: NM.kendo.dataSource( { url: "/manager/ajax/users" } ),
    };

    var viewModel = kendo.observable( {
        rows: dataSources.items,

        getCreatedAt: function( event ) {
            return NM.kendo.formatISODate( event.createdAt );
        },

        search: function( event ) {

            var thisForm = fields.searchListForm;

            var params = thisForm.serializeJSON();

            viewModel.rows.read( params );

            return false;
        },

        new: function() {
            detailApp.new();
        },

        edit: function( event ) {
            detailApp.edit( event );
        },

        print: function( item ) {
            window.open( "/manager/accounts/print", "_blank" );

            return false;
        },

        delete: function( event ) {
            var checks = $( "#user-grid" ).find( "[name=selected]:checked" );

            if ( checks.length ) {
                var values = [];

                checks.each( function() {
                    values.push( $( this ).val() );
                } );

                var ids = values.toString();

                NM.util.ajax( {
                    method: "DELETE",
                    url: "/manager/ajax/accounts",
                    data: ids,
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.data.payload.hasOwnProperty( "errors" ) ) {
                                AP.widget.notify( "error", "Non riesco a cancellare tutti gli account" );
                            } else {
                                AP.widget.notify( "success", "Cancellazione avvenuta con successo" );
                            }

                            viewModel.rows.read();
                        },
                    },
                } );
            } else {
                AP.widget.notify( "warning", "Seleziona almeno un account" );
            }
        },
    } );

    pub.refresh = function() {
        viewModel.rows.read();
    };

    pub.init = function() {
        kendo.bind( fields.listRoot, viewModel );
    };

    return pub;
} () );
