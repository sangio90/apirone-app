component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        param rc.attributeId="___";

        var data = [];
        var dm = getDataMapper();

        var rows = super.fire( "AttributeValue.list", [ rc.attributeId ] );

        event.setValue("result", rows );
        
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

}
