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

        var result = super.getResult();
    
		var exist = super.fire( "AttributeValue.codeExists", { code = rc.code, excludedId = rc.id } );

        result.setData( exist );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
        
        var result = super.getResult();
        var list = GetHTTPRequestData().content;
        var messageId = "attributeValue.deletedAllRecords";

        var errors = [];
        var payload = "";

        var ids = ListToArray( list );

        for( var id in ids ) {
            var outcome = super.fire( "AttributeValue.delete", [ id ] );

            if( outcome.getStatus() == "ERROR"  ) {
                errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
            }

        }

        if( errors.len() ) {
            messageId = "attributeValue.deletedNotAllRecords"
            payload = { "errors": errors } ;
        }

        var message = super.completeMessage( messageId );

        result.setData( { "message" = message, "payload" =  payload } );
        
		event.setValue( "result", result );
	}

    function save( event, rc, prc ){

        var result = super.getResult();
    
        var json = DESerializeJSON( GetHTTPRequestData().content );

        var status = super.bean("Status");
        var bean = super.bean("AttributeValue");
        var value = super.bean("RawValue");

        bean.setStatus( status.setId( "ACT" ) );

        //bean.setId( json.value?.id );
        //bean.setTexts( [ text ] );
        bean.setAttributeId( json.attributeId );
        bean.setOrderBy( 100 );
        bean.setRawValue( value.setId( json.id ) );

        var messageId = "attributeValue.created";
        var thisId = super.fire( "attributeValue.create", [ bean ] )

        var message = super.completeMessage( messageId );

        result.setData( { "message" = message, "payload" = { id = thisId }  } );
        
        event.setValue( "result", result );
        
    }

    function order( event, rc, prc ){

        var json = DESerializeJSON( GetHTTPRequestData().content );
        var result = super.getResult();

        dump(json);
        abort;

        var service = super.service("AttributeValue")

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
