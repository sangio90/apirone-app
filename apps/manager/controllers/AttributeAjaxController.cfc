component extends="com.apirone.core.controller.AbsController" {

    function get( event, rc, prc ){

        var data = [];
        var result = super.getResult();
        var dm = getDataMapper();
        
        var obj = super.fire( "attribute.get", [ rc.id ] );


        var attr = dm.convert( obj, "attribute", true );

        //result.setTotal( obj.len() );
        result.setData( attr );

        event.setValue("result", result );
        
    }

    function list( event, rc, prc ){

        var data = [];
        //var result = super.getResult();
        var dm = getDataMapper();
        
        var rows = super.fire( "attribute.list" );

        /*
        for ( var row in rows ) {
            var obj = dm.convert( row, "Attri", true );
            data.add( obj );
        }
            */

        //result.setTotal( data.len() );
        //result.setData( data );

        event.setValue("result", rows );
        
    }

    function new( event, rc, prc ){

        var texts = [];
        var result = super.getResult();
        
        var langs = super.fire("lang.list");
        
        var attribute = super.bean( "Attribute" );

        attribute.setId("");

        for( var lang in langs ) {

            var text = super.bean( "Text" );
            
            text.setId( "" );
            text.setName( "" );
            
            text.setLang( lang );

            texts.add( text );

        }

        attribute.setTexts( texts );
        
        result.setCount( langs.len() )
        result.setTotal( langs.len() )

        result.setData( attribute );

        event.setValue("result", result );
        
    }

    function save( event, rc, prc ){

        var result = super.getResult();
        var attr = super.bean("Attribute");
        
        var thisId = "";
        var messageId = "";
        var texts = [];

        var json = DESerializeJSON( GetHTTPRequestData().content );

        attr.setId( json.id );

        for( var thisText in json.texts ) {

            var text = super.bean("Text");
            var lang = super.bean("Lang");

            text.setName( thisText.name )
            text.setLang( lang.setId( thisText.lang.id ) );

            texts.add( text );

        }

        attr.setTexts( texts );

        if( Len( json.action == "create"  ) ) {
            
            messageId = "attribute.created";
            thisId = super.fire( "attribute.create", [ attr ] )
            
        } else {

            messageId = "attribute.updated";
            thisId = super.fire( "attribute.update", [ attr ] )
            
        }

        var message = completeMessage( messageId );

        result.setData(  message, { payload = { id = thisId }  } );
        
        event.setValue( "result", result );
        
    }

    function idExists( event, rc, prc ){

        param rc.attrId="__";

        var result = getResult();

        var result = super.getResult();

        var check = super.fire( "attribute.idExists", [ rc.attrId ] );

        result.setData( check );

        event.setValue("result", result );

    }

}
