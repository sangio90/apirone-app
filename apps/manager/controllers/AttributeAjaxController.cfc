component extends="com.apirone.core.controller.AbsController" {

    function get( event, rc, prc ){

        var data = [];
        var result = super.getResult();
        var dm = getDataMapper();
        
        var obj = super.fire( "attribute.get", [ rc.id ] );

        var attr = dm.convert( obj, "attribute", true );
        
        result.setData( attr );

        event.setValue("result", result );
        
    }

    function list( event, rc, prc ){

        var data = [];
        var dm = getDataMapper();
        var result = super.getResult();

        var params = super.paramsFromUrl();

        var rows = super.fire( "attribute.search", params );

        for ( var row in rows.getData() ) {

            var obj = dm.convert( row, "Attribute", true );
            data.add( obj );
        
        }

        result.setCount( rows.getCount() );
        result.setTotal( rows.getTotal() );
        result.setData( data );

        event.setValue("result", result );
        
    }

    function get( event, rc, prc ){

        var result = super.getResult();
        
        var row = super.fire( "attribute.get", [ rc.id ] );

        var obj = getDataMapper().convert( row, "Attribute", true );

        result.setTotal( 1 );
        result.setData( 1 );

        event.setValue("result", obj );
        
    }

    function save( event, rc, prc ){

        var attr = super.bean("Attribute");

        var text = super.bean("Text");
        var lang = super.bean("Lang");
        var status = super.bean("Status");
        
        var thisId = "";
        var messageId = "";
        var texts = [];

        var json = DESerializeJSON( GetHTTPRequestData().content );

        var categories = [];

        for( var thisCategory in json.selectedCategories ) {

            var category = super.bean("ProductCategory");
            
            category.setId( thisCategory.id )
            categories.add( category );

        }

        text.setMemento( json.mainText )

        texts.add( text );
    
        attr.setId( json.id );
        attr.setTexts( texts );
        attr.setStatus( status.setId( json.status.id ) );
        attr.setCategories( categories );

        if( !Len( json.id )  ) {

            messageId = "attribute.created";
            thisId = super.fire( "attribute.create", [ attr ] )
            
        } else {

            messageId = "attribute.updated";
            thisId = super.fire( "attribute.update", [ attr ] )
            
        }

        var message = completeMessage( messageId );

        event.setValue( "result", { "message": message, "payload" = { "id" = thisId }  } );
        
    }

    function idExists( event, rc, prc ){

        param rc.attrId="__";

        var result = getResult();

        var result = super.getResult();

        var check = super.fire( "attribute.idExists", [ rc.attrId ] );

        result.setData( check );

        event.setValue("result", result );

    }

	function delete( event, rc, prc ){
        
        var result = super.getResult();
        var list = GetHTTPRequestData().content;
        var messageId = "attribute.deletedAllRecords";

        var errors = [];
        var payload = "";

        var ids = ListToArray( list );

        for( var id in ids ) {
            var outcome = super.fire( "attribute.delete", [ id ] );

            if( outcome.getStatus() == "ERROR"  ) {
                errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
            }

        }

        if( errors.len() ) {
            messageId = "attribute.deletedNotAllRecords"
            payload = { "errors": errors } ;
        }

        var message = super.completeMessage( messageId );

        result.setData( { "message" = message, "payload" =  payload } );
        
		event.setValue( "result", result );
	}        

}
