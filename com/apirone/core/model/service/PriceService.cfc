component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.priceDAO";

    public com.apirone.core.model.bean.Price function get(
    		required String priceId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.priceId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var price = build( arguments.priceId );
		cm.put( key, price );
        
		return price;

	}

	
    public com.apirone.core.model.bean.Result function list(
		String variantId,
	) {
		arguments["limit"] = -1;
		return search(argumentCollection = arguments)
	}


    public com.apirone.core.model.bean.Result function search(
			required Numeric limit = 20,
			required Numeric offset = 0,
			String variantId,
    	){

    	var result = super.getResult();
		var rows = [];

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.push( get( priceId = record.price_id ) );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.total ) );

        return result;

    }


	public String function create(
            required com.apirone.core.model.bean.Price price
		){		

	
        return getDao().insert( 
            price = arguments.price
        );

	}

	public String function update(
            required com.apirone.core.model.bean.Price price
		){		
	

		var id = getDao().update( 
			price = arguments.price
		);

		getCacheManager()
			.remove( getCachekey( id ) );

		return id;
	
	}

	public Boolean function delete(
			required String priceId
		){
	
		var result = getDao().delete( arguments.priceId );
        getCacheManager().remove( getCachekey( arguments.priceId ) );

		return result;

	}

    /*
    	private method
	*/

	private com.apirone.core.model.bean.Price function build(
    		required String priceId
    	){

	    var record = getDao().read( arguments.priceId );

	    if( !record.recordCount ) { 

			return nullValue();

		}

		var price = super.bean( "Price" );

		price.setId( record.price_id.toString() );
		price.setValue( record.price );
		price.setDiscount( record.discount_value );
		price.setVariantId( record.variant_id.toString() );
		price.setDiscountType( record.discount_type );
		price.setCreatedAt( record.created_at );

		return price;

  	}

  	private String function getCacheKey( required String id ) {

  		return "Price_#arguments.id#";

  	}

}
