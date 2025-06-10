component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.AttributeValueDAO";
    property name="textService" type="com.apirone.core.model.service.TextService";
    property name="rawValueService" type="com.apirone.core.model.service.rawValueService";
    property name="statusService" type="com.apirone.core.model.service.StatusServive";
    property name="langService" type="com.apirone.core.model.service.LangService";

    public com.apirone.core.model.bean.AttributeValue function get(
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

	public com.apirone.core.model.bean.AttributeValue[] function list() {
		arguments["limit"] = -1;
		
		return search( argumentCollection = arguments).getData();
	
	}


    public com.apirone.core.model.bean.Result function search(
        required String attributeId
    ){
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

			}

			getTextService().bulkCreate( arguments.attributeValue.getTexts() );

		}

		getCacheManager().remove( "attribute_" & arguments.attributeValue.getAttributeId() );

		return newId;

	}

	
	public String function update(
			required com.apirone.core.model.bean.AttributeValue attributeValue
		){
		
		var id = arguments.attributeValue.getId();

		getDao().update( arguments.attributeValue );

		for ( var text in arguments.attributeValue.getTexts() ) {

			var entity = super.bean("Entity")
			entity.setKey( "attributeValue.id" );
			entity.setValue( id );

			text.setEntity( entity );

			getTextService().update( text );

		}

		getCacheManager().remove( getCachekey( id ) );
		getCacheManager().remove( "attribute_#attributeValue.getAttributeId()#" );
		
		return id;
    
	}

	/*
	public Boolean function codeExists(
		required String code,
				 String excludedId = ""
	){
		var record = getDao().readByCode( arguments.code );

		if (
			record.recordCount
			&& record.attribute_raw_value_id != arguments.excludedId
		) {
			return record.code == arguments.code;
		}

		return false;
	}
	*/

	public com.apirone.core.model.bean.Outcome function delete(
		required Numeric attributeValueId
	){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.attributeValueId );

		outcome.setData( { attributeValueId = arguments.attributeValueId } );

		transaction {

			try {
				var result = getDao().delete( arguments.attributeValueId );
				outcome.setData( { "deletedCount" = result } )

				getCacheManager().remove( "attribute_#obj.getAttributeId()#" );
				getCacheManager().remove( getCacheKey( obj.getId() ) );
			
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

	private com.apirone.core.model.bean.AttributeValue function build(
    		required String attributeValueId
    	){

	    var record = getDao().read( arguments.attributeValueId );

	    if( record.recordCount ) {

            var bean = super.bean( "AttributeValue" );

            bean.setId( record.attribute_raw_value_id );
			//bean.setCode( record.code );
			bean.setAttributeId( record.attribute_id );

			bean.setCreatedAt( record.created_at );
			bean.setOrderBy( record.orderby );
			
			bean.setStatus( getStatusService().get( record.status_id ) );
            //bean.setTexts( getTextService().list( attributeValueId = record.attribute_raw_value_id ) );
            
			bean.setRawValue( getRawValueService().get( record.raw_value_id ) );
            
            return bean;

	    }

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "attributeValue_#arguments.id#";

  	}

}
