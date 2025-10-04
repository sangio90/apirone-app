// This is an example structure of most of the ViewModels
var vm = ( function() {
    const pub = {};
    const priv = {
        container: null,
    };

    priv.vm = new kendo.data.ObservableObject( {
        // DATA
        observers: new kendo.data.DataSource(),
        // CONDITIONS
        // ACTIONS
        removeObservers: function() {
            this.get( "observers" ).data( [] );
        },
        someAction: function( event ) {
            const data = {};
            this.get( "observers" )
                .data()
                .forEach( function( o ) { o.trigger( "onSomeAction", data ); } );
            this.removeObservers();
        },
        // GETTERS
        // EVENTS
        // INITS
    } );
    priv.vm.bind( {
        // EVENTS OUTSIDE OF VM (OBSERVER-OBSERVABLE)
    } );

    // IF YOU NEED TO COMUNICATE SOME INTERNAL EVENTS TO OBSERVERS
    pub.subscribe = function( observer ) {
        if ( priv.vm.get( "observers" ).indexOf( observer ) == -1 ) {
            priv.vm.get( "observers" ).add( observer );
        }
    };

    pub.unSubscribe = function( observer ) {
        priv.vm.get( "observers" ).remove( observer );
    };

    pub.init = function( setup ) {
        priv.container = setup.container;
        kendo.bind( setup.container, priv.vm );
    };

    return pub;
}() );