component extends="testbox.system.BaseSpec"{

    function setup(){

        variables.wirebox = new wirebox.system.ioc.Injector( "config.WireboxServices" );
        variables.svc = variables.wirebox.getInstance( "RawProductService" );
        variables.variantTypeSvc = variables.wirebox.getInstance( "VariantTypeService" );
        variables.productCategorySvc = variables.wirebox.getInstance( "ProductCategoryService" );
        var cm = variables.wirebox.getInstance( "CacheManager" );
        variables.helpers = new tests.utils.Helpers();
        variables.random = new tests.utils.RandomData();

        cm.removeAll();

    }

    function teardown( currentMethod ) {

        StructDelete( variables, "wirebox" );

    }

    function get_test(){

        var data = variables.helpers.createProduct();
        var categories = [];
        var variantTypeId =  variables.variantTypeSvc.create(  variables.helpers.createVariantType().obj );
        
        var i = 1;

        for (i; i<10; i++) {
            
            var productCategoryId =  variables.productCategorySvc.create(  variables.helpers.createProductCategory().obj );
            categories.push( variables.productCategorySvc.get( productCategoryId ) );

        }
        
        var variantType = variables.variantTypeSvc.get( variantTypeId );
        data.obj.setCategories( categories );
        data.obj.setVariantType( variantType );


        var id = variables.svc.create( data.obj );
        var product = variables.svc.get( id );

        $assert.isTrue( product.getCode() EQ data.raw.code, "code: #product.getCode()# EQ codeRaw: #data.raw.code#" ); 
        $assert.isTrue( product.getStatus().getId() EQ data.raw.status.id );
        $assert.isTrue( product.getDescription() EQ data.raw.description );
        $assert.isTrue( product.getExpirationAt() EQ data.raw.expirationAt );
        $assert.isTrue( product.getVariantType().getId() EQ variantType.getId() );
        
        i = 1;

        var variants = product.getVariants();

        for (i; i < len(variants); i++) {
            
            $assert.isTrue( variants[i].getName() EQ data.raw.variants[i].name, "return: #variants[i].getName()#  expected: #data.raw.variants[i].name#" ); 
            $assert.isTrue( variants[i].getPrice().getDiscount() EQ data.raw.variants[i].price.discount )
            $assert.isTrue( variants[i].getPrice().getDiscountType() EQ data.raw.variants[i].price.discountType )
            $assert.isTrue( variants[i].getPrice().getVariantId() EQ variants[i].getId()  )

        }

        var categories = product.getCategories();

        for (i; i < len(categories); i++) {

            $assert.isTrue( categories[i].getId() EQ data.obj.getCategories()[i].getId(), "return: #categories[i].getId()#  expected: #data.obj.getCategories()[i].getId()#" ); 
            $assert.isTrue( categories[i].getName() EQ data.obj.getCategories()[i].getName(), "return: #categories[i].getId()#  expected: #data.obj.getCategories()[i].getName()#" ); 

        }

        variables.svc.delete( id );
                
    }

    function update_test(){

        var data = variables.helpers.createProduct();
        var categories = [];
        var variantTypeId =  variables.variantTypeSvc.create(  variables.helpers.createVariantType().obj );
        
        var i = 1;

        for (i; i<10; i++) {
            
            var productCategoryId =  variables.productCategorySvc.create(  variables.helpers.createProductCategory().obj );
            categories.push( variables.productCategorySvc.get( productCategoryId ) );

        }
        
        var variantType = variables.variantTypeSvc.get( variantTypeId );
        data.obj.setCategories( categories );
        data.obj.setVariantType( variantType );

        var id = variables.svc.create( data.obj );
        var product = variables.svc.get( id );

        var updateProduct = duplicate(product);

        var newCode = 'ACDS';
        var newDescription = 'test_description_update';
        var newExpirationAd = now();
        var newVariantTypeId = variables.variantTypeSvc.create(  variables.helpers.createVariantType().obj );
        var newVariantType = variables.variantTypeSvc.get( newVariantTypeId );
        var newCategories   = [];
        var i = 1;

        for (i; i<randRange(1,5); i++) {
            
            var productCategoryId =  variables.productCategorySvc.create(  variables.helpers.createProductCategory().obj );
            newCategories.push( variables.productCategorySvc.get( productCategoryId ) );

        }

        updateProduct.setCategories(newCategories);
        updateProduct.setVariantType(newVariantType);
        updateProduct.setExpirationAt(newExpirationAd);
        updateProduct.setDescription( newDescription );
        updateProduct.setCode( newCode );
        
        var newProduct = variables.svc.get( variables.svc.update( updateProduct ) );

        $assert.isTrue( newProduct.getCode() EQ newCode, "code: #newProduct.getCode()# EQ codeRaw: #newCode#" ); 
        $assert.isTrue( newProduct.getDescription() EQ newDescription );
        $assert.isTrue( newProduct.getExpirationAt() EQ newExpirationAd );
        $assert.isTrue( newProduct.getVariantType().getId() EQ newVariantType.getId(), "return: #newProduct.getVariantType().getId()#  expected: #newVariantType.getId()#" ); 
        var categories = newProduct.getCategories();

        $assert.isTrue( len(categories) EQ len(newCategories), "return: #len(categories)#  expected: #len(newCategories)#" ); 

        for (i; i < len(categories); i++) {

            $assert.isTrue( categories[i].getId() EQ newCategories[i].getId(), "return: #categories[i].getId()#  expected: #newCategories[i].getId()#" ); 
            $assert.isTrue( categories[i].getName() EQ newCategories[i].getName(), "return: #categories[i].getId()#  expected: #newCategories[i].getName()#" ); 

        }

        variables.svc.delete( id );
                
    }

    function code_exists_test(){

        var code = 'NFE6';

        var createProduct = variables.helpers.createProduct().obj;
        var variantTypeId =  variables.variantTypeSvc.create(  variables.helpers.createVariantType().obj   );
        var variantType = variables.variantTypeSvc.get( variantTypeId );

        createProduct.setVariantType( variantType );

        var rawProductId = variables.svc.create( createProduct );

        var product = variables.svc.get(rawProductId);

        var exists = variables.svc.codeExists(product.getCode() );
        $assert.isTrue(  exists EQ true, "" ); 

        var existsWithId = variables.svc.codeExists(product.getCode(), product.getId() );
        $assert.isTrue(  existsWithId EQ false, "" ); 


        variables.svc.delete( rawProductId );
        
        var exists = variables.svc.codeExists(product.getCode() );
        $assert.isTrue(  exists EQ false, "" ); 


    }
  
}