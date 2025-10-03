AP.account = AP.account || {};

AP.account.fields = {
    listRoot: $( "#account-list-root" ),
    detailRoot: $( "#account-detail-modal" ),
    detailForm: $( "#account-detail-form" ),
    passwordForm: $( "#account-password-form" ),
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
        buttonLabel: "Salva"
    };

    var viewModel = kendo.observable( {
        detailForm: defaultDetailForm,

        showPassword: function() {
            setTimeout( function() {
                viewModel.set( "detailForm.buttonLabel", "Modifica password" );
            }, 150 );

        },

        togglePassword: function() {

            var thisForm = fields.passwordForm;

            var pwd = thisForm.find( "input[name=newPwd]" );
            var label = thisForm.find( "#label-change-type" );

            var type = pwd.prop( "type" );

            if ( type == "password" ) {

                pwd.prop( "type", "text" );
                label.html( "Nascondi" );

            } else {

                pwd.prop( "type", "password" );
                label.html( "Mostra password" );

            }

        },

        showDetail: function() {
            setTimeout( function() {
                viewModel.set( "detailForm.buttonLabel", "Salva" );
            }, 150 );
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
            var passwordForm = fields.passwordForm;
            var status = $( ".errors-counter" );

            status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

            // update general
            if ( detailForm.is( ":visible" ) ) {

                if ( detailForm.validate() ) {

                    NM.util.ajax( {
                        method: "POST",
                        url: "/manager/ajax/accounts",
                        data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
                        callback: {
                            done: function( xhr ) {

                                AP.widget.notify( "success", "Account salvato con successo" );
                                status.html( "" );

                                setTimeout( () => {

                                    $( "#account-detail-modal" ).modal( "hide" );
                                    AP.account.list.refresh();
                                }, 1000 );

                            },
                        },
                    } );
                }

            // update password
            } else {

                var valid = passwordForm.valid();

                if ( valid ) {

                    var data = JSON.stringify( { pwd: $( "#newPwd" ).val(), accountId: viewModel.detailForm.data.id } );

                    NM.util.ajax( {
                        method: "POST",
                        url: "/manager/ajax/accounts/pwd",
                        data: data,
                        callback: {
                            done: function() {
                                AP.widget.notify( "success", "Password aggiornata con successo" );
                                status.html( "" );

                                setTimeout( () => {
                                    $( "#account-detail-modal" ).modal( "hide" );
                                    AP.account.list.refresh();
                                }, 1000 );

                            }
                        }
                    } );

                    setTimeout( () => {
                        fields.detailRoot.modal( "hide" );
                    }, 1000 );

                }

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
        // viewModel.resetForm();

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
    };

    pub.init = function() {
        console.log( "account:detail:init" );

        kendo.bind( fields.detailRoot, viewModel );

        var detailForm = fields.detailForm;
        var passwordForm = fields.passwordForm;

        detailForm.validate( {
            ignore: ".ignore", // for change action, skip password.
            onfocusout: function( element ) {
                $( element ).valid();
            },
            rules: {
                pwd: {
                    required: function() {
                        return viewModel.isUpdate() ? false : true;
                    },
                    pwdRule: function() {
                        return viewModel.isUpdate() ? false : true;
                    }
                },
                pwd2: {
                    required: function() {
                        return viewModel.isUpdate() ? false : true;
                    },
                    equalTo: "#pwd"
                },
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
                pwd: {
                    required: "Password richiesta",
                    pwdRule: "Almeno otto caratteri con almeno una lettera, un numero e un carattere speciale",
                },
                pwd2: {
                    required: "Password di conferma richiesta",
                    pwdRule: "Le password non coincidono",
                },
                email: {
                    required: "Email richiesta",
                    checkCode: "Email non valida",
                    remote: "L'email è già in uso",
                },
            },
        } );

        passwordForm.validate( {
            onfocusout: function( element ) {
                $( element ).valid();
            },
            rules: {
                newPwd: {
                    required: true,
                    pwdRule: true
                },
                newPwd2: {
                    required: true,
                    equalTo: "#newPwd"
                },

            },
            messages: {
                newPwd: {
                    required: "Password richiesta",
                    pwdRule: "Almeno otto caratteri con almeno una lettera, un numero e un carattere speciale",
                },
                newPwd2: {
                    required: "Password di conferma richiesta",
                    pwdRule: "Le password non coincidono",
                }
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
