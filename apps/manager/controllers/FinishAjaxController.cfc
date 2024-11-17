component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var data = [];
        var result = super.getResult();
        var dm = getDataMapper();

        var params = super.paramsFromUrl();

        var rows = super.fire( "finish.list", params );

        for ( var row in rows ) {
            var obj = dm.convert( row, "Finish", true );
            data.add( obj );
        }

        result.setTotal( data.len() );
        result.setCount( data.len() );
        result.setData( data );

        event.setValue("result", result);

    }

    function codeExists( event, rc, prc ){

        param rc.id = "_";
        param rc.code = "";

        var result = super.fire( "finish.codeExists", { code = rc.code, excludedId = rc.id } );

        event.setValue("result", result);

    }

    function save( event, rc, prc ){

        var result = super.getResult();
        var finish = super.bean("Finish");
        var category = super.bean("LineCategory");
        var status = super.bean("Status");
        var categories = [];
        
        var thisId = "";
        var messageId = "";
        var texts = [];

        var json = DESerializeJSON( GetHTTPRequestData().content );

        finish.setId( json.id );
        finish.setCode( json.code );

        for( var thisCategory in json.categories ) {
            category.setId( thisCategory.id );
            categories.add( category );
        }

        finish.setCategories( categories );
        finish.setStatus( status.setId( json.status.id ) );

        /*
        for( var thisText in json.texts ) {

            var text = super.bean("Text");
            var lang = super.bean("Lang");

            text.setName( thisText.name )
            text.setLang( lang.setId( thisText.lang.id ) );

            texts.add( text );

        }
        */

        //finish.setCode( texts );

        if( !Len( json.id ) ) {
            
            messageId = "finish.created";
            thisId = super.fire( "finish.create", [ finish ] )
            
        } else {

            messageId = "finish.updated";
            thisId = super.fire( "finish.update", [ finish ] )
            
        }

        var message = completeMessage( messageId );

        result.setData( { "message" = message }, { "payload" = { id = thisId }  } );
        
        event.setValue( "result", result );
        
    }


}
