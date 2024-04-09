component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var user = arguments.event.getValue( "User" );

        prc.list = DESerializeJSON( FileRead( '/config/data/fake-financial-data.json' ) );

        rc.title = "Situazione finanziaria";

        event.setView('main/financial');

    }
    
}
