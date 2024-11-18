component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        param rc.attributeId="___";

        var data = [];
        var dm = getDataMapper();

        var rows = super.fire( "AttributeValue.list", [ rc.attributeId ] );

    }

	function codeExists( event, rc, prc ){
		param rc.id   = "_";
		param rc.code = "";

		var result = super.fire( "finish.codeExists", { code = rc.code, excludedId = rc.id } );

		event.setValue( "result", result );
	}

    function save( event, rc, prc ){

        var result = super.getResult();
    
        var thisId = "";
        var messageId = "";
        var texts = [];

        var json = DESerializeJSON( GetHTTPRequestData().content );

        var attrValue = super.bean("AttributeValue");
        
        var text = super.bean("Text");
        var lang = super.bean("Lang");
        var status = super.bean("Status");
        var valueStatus = super.bean("Status");

        text.setLang( lang.setId( json.value.mainText.lang.id ) );
        text.setStatus( status.setId( json.value.mainText.id ) );

        text.setId( json.value.mainText.id );
        text.setName( json.value.mainText.name );

        attrValue.setId( json.value?.id );
        attrValue.setTexts( [ text ] );
        attrValue.setStatus( valueStatus.setId( json.value.status.id ) );
        attrValue.setAttributeId( json.attributeId );
        attrValue.setOrderBy( json.value.orderBy );

        dump( DESerializeJSON (SerializeJSON( attrValue ) ) );
        abort;

        if( !Len( json.value.id ) ) {
            
            messageId = "attributeValue.created";
            thisId = super.fire( "attributeValue.create", [ attrValue ] )
            
        } else {

            messageId = "attributeValue.updated";
            thisId = super.fire( "attributeValue.update", [ attrValue ] )
            
        }

        var message = super.completeMessage( messageId );

        result.setData(  message, { payload = { id = thisId }  } );
        
        event.setValue( "result", result );
        
    }

    function order( event, rc, prc ){

        var result = super.getResult();

        var service = super.service("AttributeValue")
        var json = DESerializeJSON( GetHTTPRequestData().content );

        var message = super.completeMessage( "attributeValue.ordered" );

        for( var thisValue in json ) {

            var bean = service.get( thisValue.id );
            
            bean.setOrderBy( thisValue.orderBy );
            
            service.update( bean )

        }

        result.setData( message );

        event.setValue("result", result );
        
    }

}
