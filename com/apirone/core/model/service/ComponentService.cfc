component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.ComponentDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";
	property name="rawProductService" type="com.apirone.core.model.service.RawProductService";
	property name="variantService" type="com.apirone.core.model.service.VariantService";
	property name="colorService" type="com.apirone.core.model.service.ColorService";
    /*
	property name="attributeService" type="com.apirone.core.model.service.AttributeService";
	property name="attributeValueService" type="com.apirone.core.model.service.AttributeValueService";
	property name="combinationComponentService" type="com.apirone.core.model.service.CombinationComponentService";
    */

    public com.apirone.core.model.bean.Component function get(
    		required String componentId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.componentId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.componentId );
		cm.put( key, bean );
        
		return bean;

	}

	public com.apirone.core.model.bean.Component[] function list(
    	String lineId,
    	String sizeId,
    	String combinationId,
    	Numeric productItemId
    	Numeric attributeValueId
    ) {
		arguments["limit"] = -1;
		
		return search(argumentCollection = arguments).getData();
	
	}

	/*
    public com.apirone.core.model.bean.CombinationComponent[] function listComponents(
            required Numeric componentId,
        ){

		var result = getCombinationComponentService().list( componentId = componentId );

        return result;

    }

    public Boolean function addComponent(
            required Numeric componentId,
            required com.apirone.core.model.bean.CombinationComponent combinationComponent
        ){

		transaction {
			getDao().deleteComponent( argumentCollection=arguments );
			getDao().insertComponent( argumentCollection=arguments );
		}

        return true;

    }
	*/

    public com.apirone.core.model.bean.Result function search(
            String lineId
        ){

	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.add( 
                get( record.component_id ) 
            );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.recordcount ) );

        return result;

    }

    public com.apirone.core.model.bean.Outcome function delete(
			required String componentId
		){

		var outcome = super.bean("Outcome");

        var obj = get( arguments.componentId );

		outcome.setData( { componentId: arguments.componentId } );

		transaction {
		
		    try  {

                var cm = getCacheManager();

                getDao().delete( arguments.componentId );
        
                cm.remove( "component_#obj.getId()#" );
                
			} catch ( any error ) {

				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteComponent" );
				outcome.setMessage( "Cannot delete component [#arguments.componentId#]" );
				
			}
			
		}

		return outcome;

	}

	public String function create(
			required com.apirone.core.model.bean.Component component
		){

		if( Len( arguments.component.getId() ) ) {
			getDao().delete( arguments.component.getId() );
		}

		var newId = getDao().insert( arguments.component );

		return newId;

	}



    /*
    	private method
	*/

	private com.apirone.core.model.bean.Component function build(
    		required String componentId
    	){

	    var record = getDao().read( arguments.componentId );

	    if( record.recordCount ) { 

            var bean = super.bean( "Component" );

            bean.setId( record.component_id );

			bean.setRawProduct( getRawProductService().get( record.raw_product_id ) );
			
			bean.setVariant( getVariantService().get( record.variant_id ) );
			bean.setColor( getColorService().get( record.color_id ) );

			bean.setQuantity( record.quantity );
			bean.setCreatedAt( record.created_at );

            bean.setStatus( getStatusService().get( record.status_id ) );

            return bean;

	    }

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "component_#arguments.id#";

  	}

}
