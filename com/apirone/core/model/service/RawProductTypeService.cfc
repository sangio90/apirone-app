component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.RawProductTypeDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";

	property name="cacheScope" type="String" default="RawProductType.bean";

    public com.apirone.core.model.bean.RawProductType function get(
    		required String rawProductTypeId
        ){

    	var cm = getCacheManager();

	   	var cache = cm.get( getCacheScope(), arguments.rawProductTypeId ) ;

	    if ( cache.status ) {
	    
	       return  cache.data;
	    
	    }
	    
		var bean = build( arguments.rawProductTypeId );
		
        cm.put( getCacheScope(), arguments.rawProductTypeId, bean );
        
        return bean;

	}
	
    public com.apirone.core.model.bean.Result function search(
		required Numeric limit = 50,
		required Numeric offset = 0,
		required Array orderBy = [ { field="category.name" } ],
				 String str,
				 String rawProductId
    ){

		var rows = [];

        var result = super.getResult()

		arguments["orderby"] = super.createOrderBy( arguments["orderby"] );

    	var records = getDao().find( argumentCollection=arguments );

	    for( var record in records ){

	    	rows.add( 
	    		get( rawProductTypeId = record.product_category_id )
	    	);

	    }

		result.setTotal( records.total );
		result.setCount( records.recordCount() );
		result.setData( rows );

        return result;

	}

    public com.apirone.core.model.bean.Result function list(
			required Array orderBy = [ { field="category.name" } ],
					 String str,
					 String rawProductId
		){

		arguments["limit"] = -1;

		return search( argumentCollection = arguments );

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

	private com.apirone.core.model.bean.RawProductType function build(
    		required String rawProductTypeId
    	){

	    var record = getDao().read( arguments.rawProductTypeId );

	    if( record.RecordCount ) { 

			var record = super.trimQueryFields( record );

          	var bean = super.bean( "RawProductType" );

			bean.setId( record.codtip );
			bean.setName( record.destip );

			return bean;
			
	    }

    	return NullValue();

  	}

}
