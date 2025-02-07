component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.FileKindDAO";
    property name="textService" type="com.apirone.core.model.service.TextService";

    public com.apirone.core.model.bean.AttributeValue function get(
    		required String fileKindId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.fileKindId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.fileKindId );
		
		cm.put( key, bean );
        
		return bean;

	}

    /*
    	private method
	*/

	private com.apirone.core.model.bean.AttributeValue function build(
    		required String fileKindId
    	){

	    var record = getDao().read( arguments.fileKindId );

	    if( record.recordCount ) {

            var bean = super.bean( "AttributeValue" );

            bean.setId( record.attribute_value_id );
			bean.setCode( record.code );
			bean.setAttributeId( record.attribute_id );

			bean.setCreatedAt( record.created_at );
			bean.setOrderBy( record.orderby );
			
			bean.setStatus( getStatusService().get( record.status_id ) );
            bean.setTexts( getTextService().list( fileKindId = record.attribute_value_id ) );
            
            return bean;

	    }

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "attributeValue_#arguments.id#";

  	}

}
