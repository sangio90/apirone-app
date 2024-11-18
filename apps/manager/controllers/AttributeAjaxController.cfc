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


    function list( event, rc, prc ){

        var data = [];
        var dm = getDataMapper();
        var result = super.getResult();
        
        var rows = super.fire( "attribute.list" );

        for ( var row in rows ) {

            var obj = dm.convert( row, "Attribute", true );
            data.add( obj );
        
        }

        result.setTotal( data.len() );
        result.setData( data );

        event.setValue("result", data );
        
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
            var category = super.bean("lineCategory");
            
            categories.add( category );
            category.setId( thisCategory.id )

        }

        //var mainText = json.data.mainText;

        text.setMemento( json.mainText )
        //text.setName( mainText.name )
        //text.setLang( lang.setId( mainText.lang.id ) );

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

    function saveValue( event, rc, prc ){

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


    function idExists( event, rc, prc ){

        param rc.attrId="__";

        var result = getResult();

        var result = super.getResult();

        var check = super.fire( "attribute.idExists", [ rc.attrId ] );

        result.setData( check );

        event.setValue("result", result );

    }

}
