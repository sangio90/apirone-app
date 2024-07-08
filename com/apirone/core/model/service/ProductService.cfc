component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.ProductDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";
	property name="ProductVariantService" type="com.apirone.core.model.service.ProductVariantService";
	property name="ProductTypeService" type="com.apirone.core.model.service.ProductTypeService";
	property name="variantTypeService" type="com.apirone.core.model.service.VariantTypeService";

    public com.apirone.core.model.bean.Product function get(
    		required String productId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.productId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var product = build( arguments.productId );
		cm.put( key, product );
        
		return product;

	}

	public Boolean function codeExists(
		required String code,
		String excludeId =  ""
	){
	
		var products = search( code = arguments.code ).getData();

		return !isNull( products[1] ) AND products[1].getId() NEQ arguments.excludeId 

	}

    public com.apirone.core.model.bean.Result function search(
			required Numeric limit = 20,
			required Numeric offset = 0,
			String employeeId
    	){

	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.add( get( productId = record.arcodart ) );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.total ) );

        return result;

    }

	public Void function addVariants(
		required com.apirone.core.model.bean.Product product
	) {

		if ( isNull( arguments.product.getVariants() ) ) {
			return;
		}
			
		arguments.product
				.getVariants()
				.each(function(variant) {

					variant.setProductId( product.getId() );

					var updateVariant = NullValue();

					if ( Len( variant.getId() ) ) {
						updateVariant = getProductVariantService()
							.get( variant.getId() );
					}

					if ( !isNull( updateVariant ) ) {

						getProductVariantService()
							.update(
								productVariant = variant
							);

					} else {

						getProductVariantService()
							.create(
								productVariant = variant
							);

					}
					
				});

	}

	public String function addCategory(
            required String productId,
			required String productCategoryId
		){	
	
			return getDao()
					.addCategory(
						argumentCollection = arguments
					);
	}


    /*
    	private method
	*/

	private com.apirone.core.model.bean.Product function build(
    		required String productId
    	){

	    var record = getDao().read( arguments.productId );

	    if( record.recordCount ) { 

			var record = trimQueryFields( record );

            var product = super.bean( "Product" );

            product.setId( record.arcodart );
			product.setName( record.ardesart );
			product.setType( getProductTypeService().get( record.artipmat )  );
			
            return product;

	    }

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "Product_#arguments.id#";

  	}

}
