component extends="com.apirone.core.controller.AbsController" {


    function save( event, rc, prc ){

        var docItems = [];

        var documentSvc = super.service('Document');
        //var variantSvc = super.service('ProductVariant');

        var document = super.bean("Document");
        var status = super.bean("Status");
        var employee = super.bean("Employee");

        var items = session.cart.getItems();

        document.setEmployee( employee.setId( '15930f6e-d690-4733-aeba-14352fc32bae' ) );
        document.setStatus( status.setId( 'NEW' ) );

        for( var item in items ) {
            var docItem = super.bean("DocumentItem");
            var productVariant = super.bean("ProductVariant");

            docItem.setQuantity( item.getQuantity() );
            docItem.setPrice( item.getPrice() );
            docItem.setProductVariant( productVariant.setId( item.getVariant().getId() ) );
            docItem.setStatus( status.setId( 'NEW' ) );

            docItems.add( docItem )

        }

        document.setItems( docItems );

        var lastId = documentSvc.create( document );

        setMessage("Ordine registrato con successo");
        relocate( uri="/manager/cart/complete", postProcessExempt=false, addToken=false );

    }


    function addProduct( event, rc, prc ){

        var items = [];

        var productSvc = super.service('Product');
        var variantSvc = super.service('ProductVariant');
        
        var item = super.bean('CartItem');

        var variant = variantSvc.get( rc.variantId );
        var product = productSvc.get( rc.productId );

        item.setVariant( variant );
        item.setProduct( product );
        item.setPrice( variant.getPrice().getFinalPrice() );
        item.setQuantity( 1 );

        var products = session.cart.getItems();

        products.add( item );
    
        setMessage("Articolo aggiungo al carrello");
        relocate( uri="/manager/cart", postProcessExempt=false, addToken=false );

    }


    function get( event, rc, prc ){

        prc.cart = prepare();

        prc.title = "Carrello";
        prc.total = session.cart.getTotal();

        event.setView('catalogue/cart');

    }       

    function deleteProduct( event, rc, prc ){

        var items = getCart().getItems();

        var i = 1;
        for ( var item in items ) {

            if (item.getVariant().getId() == rc.id ) {
                ArrayDeleteAt( items, i )
            }

            i++;
        }

        setMessage("Articolo rimosso al carrello");
        relocate( uri="/manager/cart", postProcessExempt=false, addToken=false );

    }    
    
    function empty( event, rc, prc ){

        //session.cart.init();
        StructDelete( session, "cart" );

        //event.setView('util/dashboard');

        //relocation("/dashboard");
        relocate( uri="/manager/dashboard", postProcessExempt=false, addToken=false );

    }

    function complete( event, rc, prc ){

        prc.title = "Ordine registrato";

        //StructDelete( session, "cart" );

        event.setView('catalogue/complete');

    }    
    
    private function getTotal( event, rc, prc ){

        var products = session.cart.getProducts();
        var total = 0;

        cfloop( query="#products#" ) {

            total = total + price;

        }

        return total;

    }



    private function prepare( event, rc, prc ){

        var ret = {}

        var items = session.cart.getItems();

        if ( !IsNull( items ) ) {
            
            for ( var item in items ) {

                var companyId = item.getProduct().getCompany().getId();
    
                if ( StructKeyExists( ret, companyId ) ){

                    ret[ companyId ].add( item );
                
                } else {
    
                    ret.insert( companyId, [ item ] );
                
                }
    
            }            

        }

        return ret;

    }

}
