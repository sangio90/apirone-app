component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.AttributeValueDAO";
    property name="textService" type="com.apirone.core.model.service.TextService";
    property name="statusService" type="com.apirone.core.model.service.StatusServive";

    public com.apirone.core.model.bean.Attribute function get(
    		required String attributeValueId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.attributeValueId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.attributeValueId );
		
		cm.put( key, bean );
        
		return bean;

	}

	public com.apirone.core.model.bean.Attribute[] function list() {
		arguments['limit'] = -1;
		
		return search( argumentCollection = arguments).getData();
	
	}


    public com.apirone.core.model.bean.Result function search(
        required String attributeId
    ){
	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.add( get( attributeValueId = record.attribute_value_id ) );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.recordcount ) );

        return result;

    }

	public String function create(
			required com.apirone.core.model.bean.AttributeValue attributeValue
		){

		transaction{

			var newId = getDao().insert( arguments.attributeValue );

			for ( var text in arguments.attributeValue.getTexts() ) {

				var entity = super.bean("Entity");

				entity.setKey( "attributeValue.id" );
				entity.setValue( newId );

				text.setEntity( entity );

				getTextService().create( text );
	
			}

		}

		return newId;

	}

	
	public String function update(
			required com.apirone.core.model.bean.AttributeValue attributeValue
		){
		
            var id = getDao().update( arguments.attribute );

			for ( var text in arguments.attributeValue.getTexts() ) {

				var entity = super.bean("Entity").setId( "attributeValue.id" );

				text.setEntity( entity );

				getTextService().update( text );
	
			}

			getCacheManager().remove( getCachekey( id ) );
			
			return id;
    
	}



    /*
    	private method
	*/

	private com.apirone.core.model.bean.Attribute function build(
    		required String attributeValueId
    	){

	    var record = getDao().read( arguments.attributeValueId );

	    if( record.recordCount ) {

            var bean = super.bean( "AttributeValue" );

            bean.setId( record.attribute_id );

            bean.setTexts( getTextService().list( attributeValueId = record.attribute_value_id ) );

			bean.setCreatedAt( record.created_at );
			
			bean.setStatus( getStatusService().get( record.status_id ) );

            return bean;

	    }

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "attributeValue_#arguments.id#";

  	}

}
