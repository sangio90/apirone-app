component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.AttributeDAO";
    property name="textService" type="com.apirone.core.model.service.TextService";

    public com.apirone.core.model.bean.Line function get(
    		required String attributeId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.attributeId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.attributeId );
		cm.put( key, bean );
        
		return bean;

	}

	public com.apirone.core.model.bean.Line[] function list() {
		arguments['limit'] = -1;
		
		return search(argumentCollection = arguments).getData();
	
	}


    public com.apirone.core.model.bean.Result function search(){
	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.add( get( attributeId = record.attribute_id ) );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.recordcount ) );

        return result;

    }


    public Boolean function idExists( required String attributeId ){
		
		var obj = get( attributeId = arguments.attributeId );

		if( IsNull( obj ) ) {
			return false;
		}

        return true;

    }


    /*
    	private method
	*/

	private com.apirone.core.model.bean.Line function build(
    		required String attributeId
    	){

	    var record = getDao().read( arguments.attributeId );

	    if( record.recordCount ) { 

            var bean = super.bean( "Attribute" );

            bean.setId( record.attribute_id );
			//bean.setName( record.attri );

            bean.setTexts( getTextService().list( attributeId = attribute_id ) )

			bean.setCreatedAt( record.created_at );
			bean.setStatus( getStatusService().get( record.status_id ) );

            return bean;

	    }

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "line_#arguments.id#";

  	}

}
