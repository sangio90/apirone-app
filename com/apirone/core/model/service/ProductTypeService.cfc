component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.ProductTypeDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";

    public com.apirone.core.model.bean.ProductType function get(
    		required String typeId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.typeId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	       return  cache.data;
	    
	    }
	    
		var bean = build( arguments.typeId );
		
        cm.put( key, bean );
        
        return bean;

	}
	
    public com.apirone.core.model.bean.Result function search(
		required Numeric limit = 50,
		required Numeric offset = 0,
		required Array orderBy = [ { field='category.name' } ],
				 String str,
				 String productId
    ){

		var rows = [];

        var result = super.getResult()

		arguments['orderby'] = super.createOrderBy( arguments['orderby'] );

    	var records = getDao().find( argumentCollection=arguments );

	    for( var record in records ){

	    	rows.add( 
	    		get( typeId = record.product_category_id )
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
            required com.apirone.core.model.bean.ProductType ProductType
		){		
	
		if ( !Len( arguments.ProductType.getId() ) ) {
			throw( type="apirone.errors.PreateproductType.IdNotProvided", message="ID required" );
		};

		if ( !Len( arguments.ProductType.getName() ) ) {
			throw( type="apirone.errors.PreateproductType.NameNotProvided", message="Name required" );
		};

        return getDao().insert( 
			ProductType = arguments.ProductType 
		);

	}

	public String function update(
            required com.apirone.core.model.bean.ProductType ProductType
		){		
	
		if ( !Len( arguments.ProductType.getId() ) ) {
			throw( type="apirone.errors.PpdateproductType.IdNotProvided", message="ID required" );
		};

		if ( !Len( arguments.ProductType.getName() ) ) {
			throw( type="apirone.errors.PpdateproductType.NameNotProvided", message="Name required" );
		};

        var id = getDao().update( 
			ProductType = arguments.ProductType
		);
		
		var cm = getCacheManager();
		
        cm.remove( arguments.ProductType.getId() );

		return id;

	}

	public Boolean function delete(
			required String typeId
		){
	
		var result = getDao().delete( arguments.typeId );

		var cm = super.getCacheManager();

		cm.remove( getCachekey( arguments.typeId ) );

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

	private com.apirone.core.model.bean.ProductType function build(
    		required String typeId
    	){

	    var record = getDao().read( arguments.typeId );

	    if( record.RecordCount ) { 

			var record = trimDBFields( record );

          	var productType = super.bean( "ProductType" );

            ProductType.setId( record.codtip );
			ProductType.setName( record.destip );

			return productType;
			
	    }

    	return NullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "ProductType_#arguments.id#";

  	}

}
