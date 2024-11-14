component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.LangDAO";

	public com.apirone.core.model.bean.Lang function get(
			required String langId
    	){

			var cm = getCacheManager();

			var key = getCacheKey( arguments.langId );
	
			   var cache = cm.get( key ) ;
	
			if ( cache.status ) {
			
				  return cache.data;
			
			}
			
			var bean = build( arguments.langId );
			
            cm.put( key, bean );
			
            return bean;

	} 
    
    public com.apirone.core.model.bean.Lang[] function list(
		String statusId,
	) {
		arguments["limit"] = -1;
		return search( argumentCollection = arguments).getData()
	}


    private com.apirone.core.model.bean.Result function search(
                     String statusId,
            required Numeric limit = 20,
			required Numeric offset = 0,
    	){

	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.add( get( langId = record.lang_id ) );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.total ) );

        return result;

    }

    
    /**
     * @private
     */
    private com.apirone.core.model.bean.Lang function build(
		required String langId
	){

		var record = getDao().read( langId = arguments.langId );

		if( record.RecordCount ) { 
			
			var bean = super.bean( "Lang" );
			bean.setId( record.lang_id );
			bean.setName( record.lang );	
			
			return bean;
			
		}

		return NullValue();

	}
	  
  	private String function getCacheKey( required String id ) {

  		return "Lang_#arguments.id#";

  	}

}
