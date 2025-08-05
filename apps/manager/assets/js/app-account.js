AP.account = AP.account || {};

AP.account.fields = {
    listRoot: $( "#account-list-root" ),
    detailRoot: $( "#account-detail-modal" ),
    detailForm: $( "#account-detail-form" ),
    searchListForm: $( "#account-grid-search-form" ),
};

$( document ).ready( function() {
    if ( AP.account.fields.listRoot.length ) {
        AP.account.list.init();
    }

    if ( AP.account.fields.detailRoot.length ) {
        AP.account.detail.init();
    }
} );

AP.account.detail = ( function() {
    var pub = {};
    var fields = AP.account.fields;

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
            pwd: "",
        },

        roles: AP.page.roles,
        langs: AP.page.langs,
        statuses: AP.page.statuses,

        title: "Carica account",
    };

    var viewModel = kendo.observable( {
        detailForm: defaultDetailForm,

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
            var status = detailForm.find( ".status" );

            status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

            if ( detailForm.valid() ) {
                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/accounts",
                    data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.status == "SUCCESS" ) {
                                NM.util.autoHideMessage(
                                    status,
                                    "<span class='green'>Account salvato</span>",
                                );

                                setTimeout(
                                    () =>
                                        $( "#account-detail-modal" ).modal(
                                            "hide",
                                        ),
                                    1000,
                                );

                                AP.account.list.refresh();
                            }
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

    ( pub.new = function() {
        viewModel.resetForm();

        NM.util.openModal( fields.detailRoot );
    } ),
    ( pub.edit = function( event ) {
        viewModel.resetForm();

        viewModel.set( "detailForm.data", event.data );
        viewModel.set(
            "detailForm.title",
            "Modifica di < " + event.data.email + " >",
        );

        var selectedRoles = [];

        if ( event.data.roles ) {
            for ( var role of event?.data?.roles ) {
                selectedRoles.push( role );
            }
        }

        viewModel.set( "detailForm.data.selectedRoles", selectedRoles );

        NM.util.openModal( fields.detailRoot );
    } );

    pub.init = function() {
        console.log( "account:detail:init" );

        kendo.bind( fields.detailRoot, viewModel );

        var detailForm = fields.detailForm;

        detailForm.validate( {
            ignore: ".ignore", // for change action, skip password.
            onfocusout: function( element ) {
                $( element ).valid();
            },
            rules: {
                email: {
                    required: true,
                    email: true,
                    remote: {
                        url: "/manager/ajax/accounts/email-exists",
                        data: {
                            id: function() {
                                return viewModel.get( "detailForm.data.id" );
                            },
                        },
                        dataFilter: function( xhr ) {
                            var json = JSON.parse( xhr );
                            return json.data == false;
                        },
                    },
                },
            },
            messages: {
                email: {
                    required: "Email richiesta",
                    checkCode: "Email non valida",
                    remote: "L'email è già in uso",
                },
            },
        } );
    };

    return pub;
} () );

AP.account.list = ( function() {
    var pub = {};

    var fields = AP.account.fields;
    var detailApp = AP.account.detail;

    var dataSources = {
        items: NM.kendo.dataSource( { url: "/manager/ajax/accounts" } ),
    };

    var viewModel = kendo.observable( {
        rows: dataSources.items,

        getCreatedAt: function( event ) {
            return NM.kendo.formatDate( event.createdAt );
        },

        search: function( event ) {
            console.log( "search" );

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
            var checks = $( "#account-grid" ).find( "[name=selected]:checked" );

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
                                AP.widget.notify(
                                    "error",
                                    "Non riesco a cancellare tutti gli account",
                                );
                            } else {
                                AP.widget.notify(
                                    "success",
                                    "Cancellazione avvenuta con successo",
                                );
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

    ( pub.refresh = function() {
        viewModel.rows.read();
    } ),
    ( pub.init = function() {
        kendo.bind( fields.listRoot, viewModel );
    } );

    return pub;
} () );
