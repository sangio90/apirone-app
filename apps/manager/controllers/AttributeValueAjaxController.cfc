component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        param rc.attributeId="___";

        var data = [];
        var dm = getDataMapper();

        var rows = super.fire( "AttributeValue.list", [ rc.attributeId ] );

    }

	function deleteValues( event, rc, prc ){

        var result = super.getResult();
        var list = GetHTTPRequestData().content;
        var messageId = "attributeValue.deletedAllRecords";
        var payload   = "";

        // per ogni elemento: usato in preventivi in corso, bloccato; solo in
        // preventivi chiusi, eliminato logicamente; mai usato, cancellato
        var service = super.service( "AttributeValue" );
        var summary = super.service( "CatalogUsage" ).removeMany(
            "attributeValueIds",
            ListToArray( list ),
            function( id ){
                return service.delete( id );
            }
        );

        if ( summary.quotations.len() ) {
            result.setStatus( "INVALID" );
            result.setData( { "quotations" = summary.quotations } );
            event.setValue( "result", result );
            return;
        }

        if ( summary.errors.len() ) {
            messageId = "attributeValue.deletedNotAllRecords";
            payload   = { "errors" = summary.errors };
        }

        var message = super.completeMessage( messageId );

        result.setData( { "message" = message, "payload" =  payload } );
        
		event.setValue( "result", result );
	}

    function addValue( event, rc, prc ){

        var result = super.getResult();
    
        var json = DESerializeJSON( GetHTTPRequestData().content );

        var status = super.bean("Status");
        var bean = super.bean("AttributeValue");
        var value = super.bean("RawValue");

        bean.setStatus( status.setId( "ACT" ) );

        bean.setAttributeId( rc.id );
        bean.setOrderBy( getMaxOrderBy( rc.id ) + 10 );
        bean.setRawValue( value.setId( json.id ) );

        var messageId = "attributeValue.created";
        var thisId = super.fire( "attributeValue.create", [ bean ] )

        var message = super.completeMessage( messageId );

        result.setData( { "message" = message, "payload" = { "id" = thisId }  } );
        
        event.setValue( "result", result );
        
    }

    function sort( event, rc, prc ){

        var json = DESerializeJSON( GetHTTPRequestData().content );
        var result = super.getResult();

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

    private Numeric function getMaxOrderBy( attributeId ){

        var service = super.service("Attribute")

        var bean = service.get( attributeId );

        var max = 0;

        for( var thisValue in bean.getValues() ) {

            if( IsNumeric( thisValue.getOrderBy() ) && thisValue.getOrderBy() > max ) {
                max = thisValue.getOrderBy();
            }

        }   

        return max;
        
    }

}
