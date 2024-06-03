component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        param name="url.size" default="20";
        param name="url.total" default="0";

        //TODO: ad params
        var args = {};

        var user = prc.user;

        prc.title = "Catalogo";
        
        prc.categories = getAccessManager().exec( user, "productCategory.list", { statusId = 'ACT' } ).getData();
        prc.suppliers = getAccessManager().exec( user, "company.list", { type = 'P' } ).getData();
        
        prc.list = getAccessManager().exec( user, "product.search", args );

        event.setView('catalogue/list');

    }
    
    function product( event, rc, prc ){

        param name="rc.id" default="__";

        var user = prc.user;

        prc.product = super.service('Product').get( rc.id );

        prc.title = prc.product.getName();

        event.setView('catalogue/product');

    }

    
    function complete( event, rc, prc ){

        var user = prc.user;

        //rc.products = DESerializeJSON( FileRead( '/config/data/fake-cart.json' ) );

        prc.title = "Acquisto completato";

        event.setView('catalogue/complete');

    }    
    
}
