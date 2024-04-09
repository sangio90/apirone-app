component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.ProductDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";
	property name="ProductVariantService" type="com.apirone.core.model.service.ProductVariantService";
	property name="variantTypeService" type="com.apirone.core.model.service.VariantTypeService";
	property name="companyService" type="com.apirone.core.model.service.CompanyService";
	property name="productCategoryService" type="com.apirone.core.model.service.ProductCategoryService";

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
	
		var products = search( code = arguments.code )
							.getData();

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
			rows.add( get( productId = record.product_id ) );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.total ) );

        return result;

    }

	public Void function addCategories( 
		required com.apirone.core.model.bean.Product product
	) {

		if ( isNull( arguments.product.getCategories() ) ) {
			return 
		}

		arguments.product
			.getCategories()
			.each(function(category) {
					addCategory(
						productCategoryId = category.getId(),
						productId = product.getId()
					)
				});

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

	public String function create(
            required com.apirone.core.model.bean.Product product
		){	
			
		transaction {

			var id =  getDao().insert( 
				product = arguments.product
			);

			arguments.product.setId( id );

			addVariants( arguments.product );
			addCategories( arguments.product );	

			return id.toString();

		}

	}

	public String function update(
		required com.apirone.core.model.bean.Product product
	){		

		transaction {

			var prevProduct = get( arguments.product.getId() );

			if ( !isNull( prevProduct.getCategories() ) ) {

				prevProduct.getCategories()
					.each(function(category) {
						removeCategory(
							productCategoryId = category.getId(),
							productId = product.getId()
						)
					});

			}
		
			var id = getDao().update( 
				product = arguments.product
			);

			addCategories( arguments.product );	
			addVariants( arguments.product );

			getCacheManager()
				.remove( getCachekey( id ) );

			return id.toString();
		}

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

	public Boolean function removeCategory(
		required String productId,
		required String productCategoryId
	){	

		return getDao()
			.removeCategory(
				argumentCollection = arguments
			);

	}

	public Boolean function delete(
			required String productId
		){
	
		var result = getDao().delete( arguments.productId );
        getCacheManager().remove( getCachekey( arguments.productId ) );

		return result;

	}

	
    /*
    	private method
	*/

	private com.apirone.core.model.bean.Product function build(
    		required String productId
    	){

	    var record = getDao().read( arguments.productId );

	    if( record.recordCount ) { 

            var product = super.bean( "Product" );

            product.setId( record.product_id.toString() );
            product.setCode( record.code );
			product.setName( record.product );
			product.setDescription( record.description );
			product.setExpirationAt( record.expiration_at );
			product.setPrice( record.price );
			product.setCreatedAt( record.created_at );

			product.setVariantType( getVariantTypeService().get( record.variant_type_id ));
            product.setStatus( getStatusService().get( record.status_id ) );
            product.setCompany( getCompanyService().get( record.company_id ) );

			product.setVariants(
				getProductVariantService()
					.list( productId = record.product_id.toString() ) 
					.getData()
			);

			product.setCategories( 
				getProductCategoryService()
					.list( productId = record.product_id.toString() )
					.getData()
			);

            return product;

	    }

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "Product_#arguments.id#";

  	}

}
