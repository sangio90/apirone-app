component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.CompanyTypeDAO";
	
	property name="cacheScope" type="String" default="CompanyType.bean";

    public com.apirone.core.model.bean.CompanyType function get(
    		required String companyTypeId
        ){

    	var cm = super.getCacheManager();

	   	var cache = cm.get( getCacheScope(), arguments.companyTypeId ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var obj = build( arguments.companyTypeId );
		
		cm.put( getCacheScope(), arguments.companyTypeId, obj );
        
		return obj;

	}

	public com.apirone.core.model.bean.Result function search(
		required Numeric limit = 50,
		required Numeric offset = 0,
		required Array orderBy = [ { field='category.name' } ],
				 String str
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
		result.setCount( records.RecordCount() );
		result.setData( rows );

        return result;

	}

    public com.apirone.core.model.bean.Result function list(
			required Array orderBy = [ { field='category.name' } ],
					 String str
		){

		arguments["limit"] = -1;

		return search( argumentCollection = arguments );

	}

    /*
    	private method
	*/

	private com.apirone.core.model.bean.CompanyType function build(
    		required String companyTypeId
    	){

	    var record = getDao().read( arguments.companyTypeId );

	    if( record.RecordCount ) { 

          	var obj = super.bean( "CompanyType" );

            obj.setId( record.company_type_id );
			obj.setName( record.company_type );

			return obj;
			
	    }

    	return NullValue();

  	}

}
