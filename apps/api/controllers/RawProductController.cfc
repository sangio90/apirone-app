component extends="com.apirone.core.controller.AbsController" {

    function notifyChange( event, rc, prc ){

        var content = GetHttpRequestData().content;
        var result = super.getResult();

        var record = super.service("RawProduct").get( rc.rawProductId );

        if ( !IsJSON( content ) ) {

            result.setStatus( "ERROR" );
            result.setData( { "message": "Content is not JSON", "type": "ContentNotJSON" } );

        } else {

            var json = DeserializeJSON( content );

            if( !json.keyExists("action") ) {

                result.setStatus( "ERROR" );
                result.setData( { "message": "The key 'action' not exists in JSON", "type": "ActionKeyNotExists" } );

            } else {

                if( json.action != "update" AND json.action != "delete" ) {

                    result.setStatus( "ERROR" );
                    result.setData( { "message": "The value [#json.action#] for 'action' key not allowed. Are allowed only: 'update' or 'delete'", "type": "ActionValueNotAllowed" } );
                
                } else {

                    if( json.keyExists("date") AND Len(json.date) AND !IsDate(json.date) ) { 

                        result.setStatus( "ERROR" );
                        result.setData( { "message": "Value [#json.date#] is not a valid date", "type": "DateValueNotAllowed" } );

                    } else {

                        result.setData( { "message": "Notify registered for [#rc.rawProductId#] product", "type": "NotifyRegistered" } );
                    
                    }

                }

            }

        }

        event.setValue( "result",  result );
        
    }

}
