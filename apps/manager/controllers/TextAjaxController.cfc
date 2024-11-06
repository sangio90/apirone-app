component extends="com.apirone.core.controller.AbsController" {

    function get( event, rc, prc ){

        var data = [];
        var result = super.getResult();
        var dm = getDataMapper();
        
        var obj = super.fire( "text.get", [ rc.id ] );

        var bean = dm.convert( obj, "Text", true );
        
        result.setData( bean );

        event.setValue("result", result );
        
    }

    function list( event, rc, prc ){

        var data = [];
        var result = super.getResult();
        var dm = getDataMapper();
        
        var rows = super.fire( "text.list" );

        for ( var row in rows ) {
            var obj = dm.convert( row, "Text", true );
            data.add( obj );
        }

        result.setTotal( data.len() );
        result.setData( data );

        event.setValue("result", rows );
        
    }

    function save( event, rc, prc ){

        var result = super.getResult();
        var attr = super.bean("Attribute");

        var text = super.bean("Text");
        var lang = super.bean("Lang");
        var status = super.bean("Status");
        
        var thisId = "";
        var messageId = "";
        var texts = [];

        var json = DESerializeJSON( GetHTTPRequestData().content );

        var mainText = json.data.mainText;

        text.setId( mainText.id )
        text.setName( mainText.name )
        text.setLang( lang.setId( mainText.lang.id ) );

        texts.add( text );
    
        attr.setId( json.data.id );
        attr.setTexts( texts );
        attr.setStatus( status.setId( json.data.status.id ) );

        if( json.action == "create"  ) {

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

}
