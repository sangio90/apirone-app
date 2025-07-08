component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.AttributeValueDAO";
    property name="textService" type="com.apirone.core.model.service.TextService";
    property name="rawValueService" type="com.apirone.core.model.service.RawValueService";
    property name="statusService" type="com.apirone.core.model.service.StatusServive";
    property name="langService" type="com.apirone.core.model.service.LangService";
    property name="componentService" type="com.apirone.core.model.service.ComponentService";

	property name="cacheScope" type="String" default="AttributeValue.bean";
    
    public com.apirone.core.model.bean.AttributeValue function get(
    		required String attributeValueId
        ){

    	var cm = getCacheManager();

	   	var cache = cm.get( getCacheScope(), arguments.attributeValueId ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.attributeValueId );
		
		cm.put( getCacheScope(), arguments.attributeValueId, bean );
        
		return bean;

	}

	public com.apirone.core.model.bean.AttributeValue[] function list() {
		arguments["limit"] = -1;
		
		return search( argumentCollection = arguments).getData();
	
	}


    public com.apirone.core.model.bean.Result function search( required String attributeId ){
	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.add( get( attributeValueId = record.attribute_raw_value_id ) );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.recordcount ) );

        return result;

    }

	public Numeric function create( required com.apirone.core.model.bean.AttributeValue attributeValue ){

		var newId = getDao().insert( arguments.attributeValue );

		getCacheManager().remove( "Attribute", arguments.attributeValue.getAttributeId() );

		return newId;

	}

	
	public Numeric function update( required com.apirone.core.model.bean.AttributeValue attributeValue ){
		
		var id = arguments.attributeValue.getId();

		getDao().update( arguments.attributeValue );

		removeCache();
		
		return id;
    
	}

	public com.apirone.core.model.bean.Outcome function delete( required Numeric attributeValueId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.attributeValueId );

		outcome.setData( { attributeValueId = arguments.attributeValueId } );

		transaction {

			try {
				var result = getDao().delete( arguments.attributeValueId );
				outcome.setData( { "deletedCount" = result } )

				removeCache();
			
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteAttributeValue" );
				outcome.setMessage( "Cannot delete value [#arguments.attributeValueId#]" );
			}
		
		}

		return outcome;
	}	


    /*
    	private method
	*/

	private Void function removeCache( 
		com.apirone.core.model.bean.AttributeValue attributeValue 
	){

		var cm = super.getCacheManager();
		
		cm.remove( getCacheScope(), arguments.attributeValue.getId() );
		cm.remove( "Attribute.bean", arguments.attributeValue.getAttributeId() );

	}

	private com.apirone.core.model.bean.AttributeValue function build( required String attributeValueId ){

	    var record = getDao().read( arguments.attributeValueId );

	    if( record.recordCount ) {

            var bean = super.bean( "AttributeValue" );

            bean.setId( record.attribute_raw_value_id );
			bean.setAttributeId( record.attribute_id.toString() );

			bean.setCreatedAt( record.created_at );
			bean.setOrderBy( record.orderby );
			bean.setStatus( getStatusService().get( record.status_id ) );
			bean.setRawValue( getRawValueService().get( record.raw_value_id ) );
			
			bean.setAllowNote( record.allow_note ? true : false );
			bean.setAffectToImage( record.affect_to_image ? true : false );
			
			bean.setComponentCount( getComponentService().count( attributeValueId = record.attribute_raw_value_id ) );

            return bean;

	    }

		return nullValue();

  	}

}
