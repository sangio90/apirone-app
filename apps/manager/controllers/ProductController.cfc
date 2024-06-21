component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var user = prc.user;

        prc.title = "Prodotti";

        prc.list = DESerializeJSON( FileRead( '/config/data/fake/products.json.cfm' ) );
        prc.statusList = DESerializeJSON( FileRead( '/config/data/fake/status.json.cfm' ) );

        prc.jsScripts.add( 'app-product' );

        event.setView('product/list');

    }
    
    function edit( event, rc, prc ){

        //addCommonData( prc );

        //prc.title="Modifica prodotto < #obj.getName()# >";
        prc.title="";
        prc.edit=true;

        prc.units = DESerializeJSON( FileRead( '/config/data/fake/units.json.cfm' ) );
        prc.statusList = DESerializeJSON( FileRead( '/config/data/fake/status.json.cfm' ) );
        prc.priceLists = DESerializeJSON( FileRead( '/config/data/fake/pricelists.json.cfm' ) );

        prc.jsScripts.add( 'app-product' );

        event.setView('product/detail');

    }
    
    function components( event, rc, prc ){

        //addCommonData( prc );

        //prc.title="Modifica prodotto < #obj.getName()# >";
        prc.title="";
        prc.edit=true;

        prc.units        = DESerializeJSON( FileRead( '/config/data/fake/units.json.cfm' ) );
        prc.statusList   = DESerializeJSON( FileRead( '/config/data/fake/status.json.cfm' ) );
        prc.priceLists   = DESerializeJSON( FileRead( '/config/data/fake/pricelists.json.cfm' ) );
        prc.components   = DESerializeJSON( FileRead( '/config/data/fake/components.json.cfm' ) );
        prc.products     = DESerializeJSON( FileRead( '/config/data/fake/products.json.cfm' ) );
        prc.rawMaterials = DESerializeJSON( FileRead( '/config/data/fake/rawMaterials.json.cfm' ) );
        prc.colors       = DESerializeJSON( FileRead( '/config/data/fake/colors.json.cfm' ) );
        prc.variants     = DESerializeJSON( FileRead( '/config/data/fake/variants.json.cfm' ) );

        prc.jsScripts.add( "app-product-comp" );

        event.setView( "product/components" );

    }
    
    function new( event, rc, prc ){

        addCommonData( prc );

        prc.title="Nuovo prodotto";
        prc.edit=false;
        
        event.setView('product/detail');

    }
    
    function save( event, rc, prc ){

        param rc.categories = "";

        var product = super.bean("Product");
        var company = super.bean("Company");
        var status = super.bean("Status");
        var variantType = super.bean("VariantType");
        var variant = super.bean("ProductVariant");
        var price = super.bean("Price");

        var categories = [];
        
        var service = super.service("Product");
        /*
        var variantSvc = super.service("ProductVariant");
        var priceSvc = super.service("Price");
        */

        if ( Len( rc.categories ) ) {
            for( var item in rc.categories ) {
                var category = super.bean("ProductCategory");
                categories.add( category.setId( item ) )
            }
        }

        product.setId( rc.id );
        product.setName( rc.name );
        product.setCode( rc.code );
        product.setCompany( company.setId( rc.companyId ) );
        product.setStatus( status.setId( rc.statusId ) );
        product.setVariantType( variantType.setId( rc.variantTypeId ) );
        product.setCategories( categories );

        //dump(product.toStruct());
        //abort;
        /*
        dump(product.toStruct());
        */

        if ( rc.variantTypeId == getConfiguration().get('variantTypeDefault') ) {

            //variant.setProductId( newId );
            variant.setDescription( '' );
            variant.setWeight( rc.weight );
            variant.setAvailableQuantity( rc.availableQuantity );

            price.setValue( rc.price );
            price.setDiscount( rc.discountValue );
            price.setDiscountType( rc.discountType );

            variant.setPrice( price );
            variant.setStatus( status.setId( 'ACT' ) );

            product.setVariants( [ variant ] );

            //var variantId = variantSvc.create( variant );
            //price.setVaariantId( variantId );
            //priceSvc.create( price );

        }

        if ( len( rc.id ) ) {

            service.update( product );

        } else {
        
            var newId = service.create( product );

        }

        abort;


        //relocate( uri="/manager/products?msg=ok", addToken=false, postProcessExempt=false );

    }
    
    private function addCommonData( prc ){

        prc.companies = super.service("Company").search();
        prc.variantTypes = super.service("VariantType").list();
        prc.statusList = super.service("Status").list( "PRODUCT" );
        prc.categories = super.service("ProductCAtegory").list();

        prc.jsScripts.add( 'app-product' );

        return prc;

        //event.setView('product/detail');

    }

}
