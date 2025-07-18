component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.ProductCategoryTypeDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";
	
	property name="cacheScope" type="String" default="ProductCategoryType.bean";

    public com.apirone.core.model.bean.ProductCategoryType function get(
    		required String productCategoryTypeId
        ){

    	var cm = getCacheManager();

	   	var cache = cm.get( getCacheScope(), arguments.productCategoryTypeId ) ;

	    if ( cache.status ) {
	    
	       return  cache.data;
	    
	    }
	    
		var bean = build( arguments.productCategoryTypeId );
		cm.put( getCacheScope(), arguments.productCategoryTypeId, bean );
        
		return bean;

	}
	
    public Array function list(){

		arguments["limit"] = -1;

		return search( argumentCollection = arguments ).getData();

	}

    /*
    	private methods
	*/

    private com.apirone.core.model.bean.Result function search(
				 String str,
				 String statusId,
		required Numeric limit = 20,
		required Numeric offset = 0,
		required Array orderBy = [ { field="productCategoryType.orderby" } ],
    ){

		var rows = [];

        var result = super.getResult()

		arguments["orderby"] = super.createOrderBy( arguments["orderby"] );

    	var records = getDao().find( argumentCollection=arguments );

	    for( var record in records ){

	    	rows.add( 
	    		get( record.product_category_type_id )
	    	);

	    }

		result.setTotal( records.total );
		result.setCount( records.recordCount() );
		result.setData( rows );

        return result;

	}	

	private com.apirone.core.model.bean.ProductCategoryType function build(
    		required String productCategoryTypeId
    	){

	    var record = getDao().read( arguments.productCategoryTypeId );

	    if( record.RecordCount ) { 

          	var bean = super.bean( "ProductCategoryType" );

            bean.setId( record.product_category_type_id );
			bean.setStatus( getStatusService().get( record.status_id ) );
			bean.setCreatedAt( record.created_at );

            bean.setName( record.product_category_type );

			return bean;
			
	    }

    	return NullValue();

  	}

}
