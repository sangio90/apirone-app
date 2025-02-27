component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.ProductVariantDAO";
	property name="priceService" type="com.apirone.core.model.service.PriceService";
	property name="statusService" type="com.apirone.core.model.service.StatusService";
	property name="FileService" type="com.apirone.core.model.service.FileService";

    public com.apirone.core.model.bean.RawProductVariant function get(
    		required String productVariantId
        ){
		
		if ( !Len( arguments.productVariantId ) ) return  nullValue();

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.productVariantId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var productVariant = build( arguments.productVariantId );
		cm.put( key, productVariant );
        
		return productVariant;

	}

	public String function create(
            required com.apirone.core.model.bean.RawProductVariant productVariant
		){	
		
		transaction {

			var id =  getDao().insert( 
				productVariant = arguments.productVariant
			);
	
			var price = arguments.productVariant.getPrice();
			price.setVariantId( id );

			getPriceService().create( price = price );
	
			return id;

		}

	}

	public String function update(
            required com.apirone.core.model.bean.RawProductVariant productVariant
		){		

        transaction {

			var id = getDao().update( 
				productVariant = arguments.productVariant
			);

			var price = arguments.productVariant.getPrice();
			
			price.setVariantId( id );
			
			getPriceService().update( price = price );

			getCacheManager().remove( getCachekey( id ) );

			return id;
		}

	}

	public Boolean function delete(
			required String productVariantId
		){
	
		var result = getDao().delete( arguments.productVariantId );
        getCacheManager().remove( getCachekey( arguments.productVariantId ) );

		return result;

	}
	
    public com.apirone.core.model.bean.Result function list(
		String rawProductId,
	) {
		arguments["limit"] = -1;
		return search(argumentCollection = arguments)
	}


    public com.apirone.core.model.bean.Result function search(
			required Numeric limit = 20,
			required Numeric offset = 0,
			String rawProductId,
    	){

    	var result = super.getResult();
		var rows = [];
    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.push( get( productVariantId = record.variant_id ) );
		});

	

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.total ) );

        return result;

    }

    /*
    	private method
	*/

	private com.apirone.core.model.bean.RawProductVariant function build(
    		required String productVariantId
    	){

	    var record = getDao().read( arguments.productVariantId );

	    if( record.recordCount ) { 

            var productVariant = super.bean( "ProductVariant" );

			var variantPrices =  getPriceService()
									.list( variantId = record.variant_id.toString() )
									.getData()

			var price = !isNull( variantPrices[1] ) ? variantPrices[1] : nullValue();

            productVariant.setId( record.variant_id.toString() );
			productVariant.setName( record.variant );
            productVariant.setStatus( getStatusService().get( record.status_id ) );
			productVariant.setProductId( record.raw_product_id.toString() );
			productVariant.setPrice( price );
		
			productVariant.setDescription( record.description );
			productVariant.setImages( getFileService().list( productVariantId = record.variant_id.toString() ).getData() );


            return productVariant;

	    }

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "ProductVariant_#arguments.id#";

  	}

}
