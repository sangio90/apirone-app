component extends="com.apirone.core.controller.AbsController" {

    function get( event, rc, prc ){
        
        var record = super.service("Product")
                            .get( rc.productId );

        var result = super.getResult();

        if ( isNull( record ) ) {
            super.setErrorResult( event );
            return
        }

        result.setData( record );

        event
            .getResponse()
            .setData( result )
        
    }

    function search( event, rc, prc ){

		param name="url.limit" default="10";
		param name="url.page" default="1";
        
        var params = {
            'limit': url.limit,
            'offset': url.limit * (url.page - 1)
        };
        
        var rows = super.service("Product")
                            .search(argumentCollection = arguments);

        var result = super.getResult();

        result.setTotal( rows.getTotal() );
        result.setCount( rows.getCount() );
        result.setData( rows.getData().map( (r) => getDM().convert(r, 'Product', true ) ) );

        event
            .getResponse()
            .setData( result )
        
    }

    function create( event, rc, prc ) {

        var product =  super.getDM().convert( DeserializeJSON( getHTTPRequestData().content ), 'Product'  ) 

        var validation = validateJson( product );
        var result = super.getResult();

        if ( Len( validation.getErrors() ) )  {
            super.setErrorResult( event, validation.getErrors() );
            return;
        }
        
        var productId = super.service("Product")
                                .create(  product );

        result.setData( {'productId': productId} )
       
        event
            .getResponse()
            .setData( result )
    
    }

    
    function modify( event, rc, prc ) {

        var product =  super.getDM().convert( DeserializeJSON( getHTTPRequestData().content ), 'Product'  ) 

        var validation = validateJson( product );
        
        if ( Len( validation.getErrors() ) )  {
            
            super.setErrorResult( event, validation.getErrors() );
            
            return;
        
        }
        
        var productId = super.service("Product")
                                .update( product );

        var result = super.getResult();
        result.setData( {'productId': productId} )
        
        event
            .getResponse()
            .setData( result )
    }


    function delete( event, rc, prc ) {
        
        super.service("Product")
                    .delete( rc.productId );

        var result = super.getResult();
        result.setData( {'deletedProductId': rc.productId} )
        
        event
            .getResponse()
            .setData( result )
    }

    private function validateJson(
        required com.apirone.core.model.bean.Product product
    ) {

        var validation = Validate( 
            target = product,
            constraints =  super.getConstraints(entity='product')
        );

        var productSvc = super.service('Product');

        if ( Len( product.getCode() ) ) {

            var codeExists = productSvc
                        .codeExists( code = product.getCode(), excludeId = product.getId() );

            if (codeExists) {
                validation.addError(
                    validation.newError(
                        message        = "CodeExists",
                        field          = 'code',
                        rejectedValue  = '#product.getCode()#'
                    )
                );
            }

        }
      
        return validation
    }

}
