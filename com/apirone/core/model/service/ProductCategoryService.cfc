component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.ProductCategoryDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";

    public com.apirone.core.model.bean.ProductCategory function get(
    		required String categoryId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.categoryId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	       return  cache.data;
	    
	    }
	    
		var productCategory = build( arguments.categoryId );
		cm.put( key, productCategory );
        return productCategory;

	}
	
    public com.apirone.core.model.bean.Result function search(
				 String str,
				 String productId,
		required Numeric limit = 50,
		required Numeric offset = 0,
		required Array orderBy = [ { field='category.name' } ],
    ){

		var rows = [];

        var result = super.getResult()

		arguments['orderby'] = super.createOrderBy( arguments['orderby'] );

    	var records = getDao().find( argumentCollection=arguments );

	    for( var record in records ){

	    	rows.add( 
	    		get( categoryId = record.product_category_id )
	    	);

	    }

		result.setTotal( records.total );
		result.setCount( records.recordCount() );
		result.setData( rows );

        return result;

	}

    public com.apirone.core.model.bean.Result function list(
			required Array orderBy = [ { field='category.name' } ],
					 String str,
					 String productId
		){

		arguments['limit'] = -1;

		return search( argumentCollection = arguments );

	}

	public String function create(
            required com.apirone.core.model.bean.ProductCategory productCategory
		){		
	
		if ( !Len( arguments.productCategory.getId() ) ) {
			throw( type="apirone.errors.createProductCategory.IdNotProvided", message="ID required" );
		};

		if ( !Len( arguments.productCategory.getName() ) ) {
			throw( type="apirone.errors.createProductCategory.NameNotProvided", message="Name required" );
		};

        return getDao().insert( 
			productCategory = arguments.productCategory 
		);

	}

	public String function update(
            required com.apirone.core.model.bean.ProductCategory productCategory
		){		
	
		if ( !Len( arguments.productCategory.getId() ) ) {
			throw( type="apirone.errors.updateProductCategory.IdNotProvided", message="ID required" );
		};

		if ( !Len( arguments.productCategory.getName() ) ) {
			throw( type="apirone.errors.updateProductCategory.NameNotProvided", message="Name required" );
		};

        var id = getDao().update( 
			productCategory = arguments.productCategory
		);
		
		var cm = getCacheManager();
		
        cm.remove( arguments.productCategory.getId() );

		return id;

	}

	public Boolean function delete(
			required String categoryId
		){
	
		var result = getDao().delete( arguments.categoryId );

		var cm = super.getCacheManager();

		cm.remove( getCachekey( arguments.categoryId ) );

		return result;

	}


	public Boolean function nameExists(
			required String name
		){
			
		var result = getDao().readByName( arguments.name )
	
		return BooleanFormat(  result.RecordCount );

	}

    /*
    	private methods
	*/

	private com.apirone.core.model.bean.ProductCategory function build(
    		required String categoryId
    	){

	    var record = getDao().read( arguments.categoryId );

	    if( record.RecordCount ) { 

          	var productCategory = super.bean( "ProductCategory" );

            productCategory.setId( record.product_category_id );
			productCategory.setName( record.product_category );
			productCategory.setStatus( getStatusService().get( record.status_id ) );
			productCategory.setCreatedAt( record.created_at );

			return productCategory;
			
	    }

    	return NullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "ProductCategory_#arguments.id#";

  	}

}
