component extends="com.apirone.core.controller.AbsController" {

    function get( event, rc, prc ){

        prc.title = "Sistema";

        var tokens = FileRead( "/.env" );

        prc.keys = []

        prc.keys.add( { key ="environment", value = getSetting('environment') } ); //TODO: set che correct env

        cfloop( file="/.env", item="item" ) {

            var key = ListFirst( item, "=" )
            var value = ListRest( item, "=" )

            if( key CONTAINS "pwd" OR key CONTAINS "password" ) {
                //value = "***************";
            }

            var row = {
                key = key,
                value = value
            }

            prc.keys.add( row );

        }

        event.setView("system/detail");

    }
    
}
