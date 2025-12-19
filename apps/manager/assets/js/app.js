AP.core = AP.core || {};

$( document ).ready( function() {

    /* dom inits */

    if ( $( "#sidebar-left" ).length ) {
        AP.core.init();
    }

    /* message */

    if ( AP.message ) {
        if ( Object.keys( AP.message ).length != 0 ) {
            AP.widget.notify( AP.message.type, AP.message.message );
        }
    }

} );

AP.core = ( function() {

    var pub = {};

    pub.init = function() { };

    pub.setSidebar = function() { };

    return pub;

}() );

AP.namespace = function( name ) {
    var parts = name.split( "." );
    var current = AP;

    for ( var i = 0; i < parts.length; i++ ) {
        if ( !current[parts[i]] ) {
            current[parts[i]] = {};
        }
        current = current[parts[i]];
    }

    current.fields = current.fields || {};

    return current;
};

/*
    for user pref
*/

AP.setUserPref = function( key, value ) {

    var user = AP.config.user.shortId;
    NM.storage.set( "apirOne:" + user + ":" + key, value );
};

AP.getUserPref = function( key, defaultValue ) {

    var user = AP.config.user.shortId;
    return NM.storage.get( "apirOne:" + user + ":" + key, defaultValue );
};

AP.deleteUserPref = function( key ) {
    var user = AP.config.user.shortId;
    NM.storage.delete( "apirOne:" + user + ":" + key );
};

AP.loading = {
    show: function() {
        $( "#global-loading-spinner" ).css( "display", "flex" );
    },
    hide: function() {
        $( "#global-loading-spinner" ).css( "display", "none" );
    }
};
