component extends="testbox.system.BaseSpec"{

    function setup(){


        variables.wirebox = new wirebox.system.ioc.Injector( "config.WireboxServices" );
        variables.productSvc = variables.wirebox.getInstance( "ProductService" );
        variables.companySvc = variables.wirebox.getInstance( "CompanyService" );
        variables.variantTypeSvc = variables.wirebox.getInstance( "VariantTypeService" );
        var cm = variables.wirebox.getInstance( "CacheManager" );
        variables.helpers = new tests.utils.Helpers();
        variables.random = new tests.utils.RandomData();

        cm.removeAll();

    }

    function teardown( currentMethod ) {

        StructDelete( variables, "wirebox" );

    }

    function create_variant_file_test(){

        var data = variables.helpers.createProduct().obj;
        var company = variables.helpers.createCompany().obj;
        var variantTypeId =  variables.variantTypeSvc.create(  variables.helpers.createVariantType().obj   );
        var variantType = variables.variantTypeSvc.get( variantTypeId );

        //dump(company.getTypes());
        //abort;

        var companyId = variables.companySvc.create( company );
        var companyObj = variables.companySvc.get( companyId );

        data.setVariantType( variantType );
        data.setCompany( companyObj );

        var id = variables.productSvc.create( data );
        //var id = variables.productSvc.create( data );

        var product = variables.productSvc.get( id );

        var variant = product.getVariants()[1]

        variant.setImages(
           [ variables.helpers.createFile().obj ]
        );

        variables.productSvc.delete( id );
                
    }
  
}