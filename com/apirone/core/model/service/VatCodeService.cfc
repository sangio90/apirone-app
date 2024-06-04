component extends="com.apirone.core.model.service.AbsService" accessors="true" {

    property name="dao" type="com.apirone.core.model.dao.VatCodeDAO";

    public com.apirone.core.model.bean.VatCode function get(
    		required String vatCodeId
    	){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.vatCodeId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 

        var vatCode = build( arguments.vatCodeId );
        cm.put( key, vatCode );
        
		return vatCode;

    }

    public com.apirone.core.model.bean.VatCode[] function list(
		String productId,
	) {
		arguments['limit'] = -1;
		return search(argumentCollection = arguments).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		required Numeric limit=50,
		required Numeric offset=0
	){

		var rows = [];
		var result = super.getResult();

		var records = getDao().find( argumentCollection=arguments );

		for( var record in records ){

			rows.add( 
				get( vatCodeId = record.ivacod )
			)

		}

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;

	}

    /**
     * @private
     */
  	private com.apirone.core.model.bean.VatCode function build(
    		required String vatCodeId
    	){

	    var record = getDao().read( vatCodeId = arguments.vatCodeId );

		var bean = nullValue();

	    if( record.RecordCount ) { 

	    	var bean = super.bean( "VatCode" );

		    bean.setId( record.ivacod );
		    bean.setName( record.ivades );
		    bean.setValue( record.ivaper );

	    } 
			
		return bean;
		
  	}

  	private String function getCacheKey( required String id ) {

  		return "VatCode_#arguments.id#";

  	}

}
