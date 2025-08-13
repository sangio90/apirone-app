AP.my = AP.my || {};
AP.fields.my = AP.fields.my || {};

AP.fields.my.detail = {
    detailRoot: $( "#my-account-root" ),
    pwdForm: $( "#my-account-detail-form" ),
    settingsRoot: $( "#my-settings-root" ),
};

$( document ).ready( function() {
    if ( AP.fields.my.detail.detailRoot.length ) {
        AP.my.detail.init();
    }
    if ( AP.fields.my.detail.settingsRoot.length ) {
        AP.my.settings.init();
    }
} );

AP.my.detail = ( function() {
    var pub = {};
    var fields = AP.fields.my.detail;

    var viewModel = kendo.observable( {
        resetForm: function() {},

        save: function( event ) {
            var pwdForm = fields.pwdForm;
            var status = pwdForm.find( ".status" );

            if ( pwdForm.valid() ) {
                status.html( "<img src=/assets/main/img/ajax-loading.svg width=20 height=20>" );

                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/change-pwd",
                    data: pwdForm.serialize(),
                    callback: {
                        done: function( xhr ) {
                            console.log( "xhr.data", xhr.data );

                            if ( xhr.data.payload.hasOwnProperty( "errors" ) ) {
                                status.html( "<span class='red'>" + xhr.data.message.text + "</span>" );
                            } else {
                                status.html( "<span class='green'>" + xhr.data.message.text + "</span>" );
                            }

                        },
                    },
                } );
            }

            return false;
        },
    } );

    pub.init = function() {
        kendo.bind( fields.detailRoot, viewModel );

        var pwdForm = fields.pwdForm;

        pwdForm.validate( {
            onfocusout: function( element ) {
                $( element ).valid();
            },
        } );
    };

    return pub;
} () );

AP.my.settings = ( function() {
    var pub = {};

    var viewModel = kendo.observable( {
        items: undefined,
    } );

    function getUserSettings( accountId ) {
        const prefix = "apirOne:" + accountId + ":";
        const settings = [];

        for ( let i = 0; i < localStorage.length; i++ ) {
            const key = localStorage.key( i );
            if ( key.startsWith( prefix ) ) {
                const name = key.substring( prefix.length );
                const value = localStorage.getItem( key );
                settings.push( { name, value } );
            }
        }

        return settings;
    }


    pub.init = function() {

        var settings = getUserSettings( AP.config.account.shortId );

        viewModel.set( "items", settings );

        kendo.bind( AP.fields.my.detail.settingsRoot, viewModel );
    };

    return pub;
} () );