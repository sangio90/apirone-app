component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.ComponentVariationDAO";
	
	property name="cacheScope" type="String" default="ComponentVariation.bean";

    public com.apirone.core.model.bean.Component function get(
    		required String componentVariationId
        ){

    	var cm = getCacheManager();

	   	var cache = cm.get( getCacheScope(), arguments.componentVariationId ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.componentVariationId );
		cm.put( getCacheScope(), arguments.componentVariationId, bean );
        
		return bean;

	}

	public com.apirone.core.model.bean.Component[] function list(
    	required Numeric productItemId,
    	required Numeric componentId,
    ) {
		arguments["limit"] = -1;
		
		return search(argumentCollection = arguments).getData();
	
	}

    public com.apirone.core.model.bean.Result function search(
    	required Numeric productItemId,
    	required Numeric componentId,
    ){

		var rows = [];
		var result = super.getResult();

		var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.add( 
				get( record.component_variation_id ) 
			);
		});

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.recordcount ) );

		return result;

    }

    public com.apirone.core.model.bean.Outcome function delete(
			required String componentVariationId
		){

		var outcome = super.bean("Outcome");

        var obj = get( arguments.componentVariationId );

		outcome.setData( { componentVariationId: arguments.componentVariationId } );

		transaction {
		
		    try  {

                getDao().delete( arguments.componentVariationId );
        
                super.getCacheManager().remove( getCacheScope(), obj.getId() );
                
			} catch ( any error ) {

				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteComponentVariation" );
				outcome.setMessage( "Cannot delete ComponentVariation [#arguments.componentVariationId#]" );
				
			}
			
		}

		return outcome;

	}

	public String function create(
			required com.apirone.core.model.bean.ComponentVariantion ComponentVariantion
		){

		var id = getDao().insert( arguments.component );

		return id;

	}


	public String function update(
			required com.apirone.core.model.bean.Component component
		){

		getDao().update( arguments.component );

		super.getCacheManager().remove( getCacheScope(), component.getId() );

		return arguments.component.getId();

	}

	private com.apirone.core.model.bean.Component function build(
    		required String componentVariationId
    	){

	    var record = getDao().read( arguments.componentVariationId );

	    if( record.recordCount ) { 

            var bean = super.bean( "ComponentVariation" );

            bean.setId( record.component_id );

			bean.setBaseQuantity( record.quantity );
			bean.setCreatedAt( record.created_at );
			bean.setDeleted( record.deleted );

            return bean;

	    }

		return nullValue();

  	}

}
