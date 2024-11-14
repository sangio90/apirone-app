component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.DocumentItemDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";
	property name="lookupService" type="com.apirone.core.model.service.LookupService";
	property name="productVariantService" type="com.apirone.core.model.service.ProductVariantService";
	property name="productService" type="com.apirone.core.model.service.ProductService";

    public com.apirone.core.model.bean.DocumentItem function get(
    		required String documentItemId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.documentItemId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.documentItemId );
		cm.put( key, bean );
        
		return bean;

	}

	public com.apirone.core.model.bean.Result function list(
		String documentId,
		Date from,
		Date to,
	) {
		arguments["limit"] = -1;
		return search(argumentCollection = arguments)
	}

    public com.apirone.core.model.bean.Result function search(
			  		 String documentId,
			  		 String employeeId,
			  		 Date from,
			  		 Date to,
			required Numeric limit = 20,
			required Numeric offset = 0,
    	){

	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.add( get( documentItemId = record.document_item_id ) );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.total ) );

        return result;

    }


	public String function create(
            required String documentId,
            required com.apirone.core.model.bean.DocumentItem documentItem
		){	
			
        var id =  getDao().insert( 
            documentId = arguments.documentId,
            documentItem = arguments.documentItem 
        );

        return id.toString();

	}

	public Boolean function delete( required String documentItemId ){
	
		var result = getDao().delete( arguments.documentItemId );
        
        getCacheManager().remove( getCachekey( arguments.documentItemId ) );

		return result;

	}

	
    /*
    	private method
	*/

	private com.apirone.core.model.bean.DocumentItem function build(
    		required String documentItemId
    	){

	    var record = getDao().read( arguments.documentItemId );

	    if( record.recordCount ) { 

            var bean = super.bean( "DocumentItem" );

            bean.setId( record.document_item_id.toString() );
            bean.setProductVariant( getProductVariantService().get( record.variant_id ) );
            bean.setProduct( getProductService().get( record.product_id ) );
            bean.setQuantity( record.quantity );
            bean.setPrice( record.price );

            bean.setStatus( getStatusService().get( record.status_id ) );
			bean.setCreatedAt( record.created_at );

            return bean;

	    }

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "DocumentItem_#arguments.id#";

  	}

}
