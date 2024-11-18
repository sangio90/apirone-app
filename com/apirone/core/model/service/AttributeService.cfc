component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.AttributeDAO";
    property name="textService" type="com.apirone.core.model.service.TextService";
    property name="statusService" type="com.apirone.core.model.service.StatusServive";
    property name="langService" type="com.apirone.core.model.service.LangService";
    property name="attributeValueService" type="com.apirone.core.model.service.AttributeValueService";
    property name="lineCategoryService" type="com.apirone.core.model.service.LineCategoryService";

    public com.apirone.core.model.bean.Attribute function get(
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

	public com.apirone.core.model.bean.Attribute[] function list() {
		arguments["limit"] = -1;
		
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

	
	public String function create(
			required com.apirone.core.model.bean.Attribute attribute
		){

		transaction{

			var newId = getDao().insert( arguments.attribute );

			for ( var text in attribute.getTexts() ) {

				var entity = super.bean("Entity");

				entity.setKey( "attribute.id" );
				entity.setValue( newId );

				text.setEntity( entity );

			}

			getTextService().bulkCreate( arguments.attribute.getTexts() );

		}

		return newId;

	}

	
	public String function update(
			required com.apirone.core.model.bean.Attribute attribute
		){

			var id = attribute.getId();
		
        	getDao().update( arguments.attribute );

			for ( var text in attribute.getTexts() ) {

				var entity = super.bean("Entity")
				
				entity.setKey( "attribute.id" );
				entity.setValue( id );

				text.setEntity( entity );

				if ( Len( text.getId() ) ) {
					
					getTextService().update( text );
				
				} else {
					
					getTextService().create( text );

				}
	
			}

			getCacheManager().remove( getCachekey( id ) );
			
			return id;
    
	}

	public String function getCacheKey( required String id ) {

		return "attribute_#arguments.id#";

	}

    /*
    	private method
	*/

	private com.apirone.core.model.bean.Attribute function build(
    		required String attributeId
    	){

	    var record = getDao().read( arguments.attributeId );

	    if( record.recordCount ) { 

            var bean = super.bean( "Attribute" );

            bean.setId( record.attribute_id );
			bean.setCreatedAt( record.created_at );
            bean.setTexts( getTextService().list( attributeId = record.attribute_id ) )
			bean.setStatus( getStatusService().get( record.status_id ) );
			bean.setValues( getAttributeValueService().list( attributeId = record.attribute_id ) );
			
			var categories = super.getCategoriesBeanFromIds( record.categories );

			bean.setCategories( categories );

            return bean;

	    }

		return nullValue();

  	}


}
