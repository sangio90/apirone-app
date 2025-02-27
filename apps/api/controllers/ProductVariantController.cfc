
component extends="com.apirone.core.controller.AbsController" {


    function get( event, rc, prc ){
        
        var record = super.service("ProductVariant")
                            .get( rc.productVariantId );

                            
        if ( isNull( record ) ) {
            super.setErrorResult( event );
            return
        }
        
        var result = super.getResult();
        result.setData( super.getDM().convert( record, 'ProductVariant', true ) );

        event
            .getResponse()
            .setData( result )
        
    }

    function create( event, rc, prc ) {

        var data = DeserializeJSON( getHTTPRequestData().content );

        var productVariant =  super.getDM().convert( data, 'ProductVariant' );

        var validation = Validate(     
                            target = productVariant,
                            constraints =  super.getConstraints(entity='productVariant', profile="create")
                        );

        if ( Len( validation.getErrors() ) )  {
            super.setErrorResult( event, validation.getErrors() );
            return;
        }      
        
        var result = super.getResult();

        var product = super.service('Product').get( rc.rawProductId );

        var prevVariants = !isNull( product.getVariants() ) ? product.getVariants() : [];
        prevVariants.push( productVariant );
        product.setVariants( prevVariants );

        var rawProductId = super.service("RawProduct")
                                .update(  product );

        result.setData( {'rawProductId': rawProductId} )
       
        event
            .getResponse()
            .setData( result )
    
    }

    function modify( event, rc, prc ) {

        var productVariant =  super.getDM().convert( DeserializeJSON( getHTTPRequestData().content ), 'ProductVariant'  ) 

        var validation = Validate(     
            target = productVariant,
            constraints =  super.getConstraints( entity='productVariant', profile="modify" );
        );

        if ( Len( validation.getErrors() ) )  {
            super.setErrorResult( event, validation.getErrors() );
            return;
        }      

        var result = super.getResult();

        var product = super.service('Product').get( rc.rawProductId );
        var prevVariants = !isNull( product.getVariants() ) ? product.getVariants() : [];
    
        product.setVariants( prevVariants.map( (variant ) => {
            if (  variant.getId() EQ productVariant.getId() ) {
                return productVariant
            }
            return variant
        })) 

        var rawProductId = super.service("RawProduct")
                                .update(  product );

        result.setData( {'rawProductId': rawProductId} )
       
        event
            .getResponse()
            .setData( result )
    
    }


    function delete( event, rc, prc ) {

        var result = super.getResult();

        var rawProductId = super.service("RawProduct")
                                .delete( rc.productVariantId );

        result.setData( {'DeletedVariantId': rc.productVariantId} )
       
        event
            .getResponse()
            .setData( result )
    
    }


  
}
