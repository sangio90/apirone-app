AP.core = AP.core || {};

$( document ).ready( function(){

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

    pub.init = function() {};

    pub.setSidebar = function(){};

    return pub;

}() );

AP.setUserPref = function( key, value ) {
    var user = AP.config.account.shortId;
    NM.storage.set( key + "_" + user, value );
};

AP.getUserPref = function( key, defaultValue ) {
    var user = AP.config.account.shortId;
    return NM.storage.get( key + "_" + user, defaultValue );
};

AP.deleteUserPref = function( key ) {
    var user = AP.config.account.shortId;
    NM.storage.remove( key + "_" + user );
};