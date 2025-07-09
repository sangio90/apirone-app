component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.ComponentOverrideDAO";
	property name="cacheScope" type="String" default="ComponentOverride.bean";

    public com.apirone.core.model.bean.ComponentOverride function get(
    		required String ComponentOverrideId
        ){

    	var cm = getCacheManager();

	   	var cache = cm.get( getCacheScope(), arguments.ComponentOverrideId ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.ComponentOverrideId );
		cm.put( getCacheScope(), arguments.ComponentOverrideId, bean );
        
		return bean;

	}

	public com.apirone.core.model.bean.ComponentOverride[] function list(
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

		//TODO: should be only one override with productItemId and componentId. 
		// Add check? DB guarantees uniqueness

		records.each(function(record) {
			rows.add( 
				get( record.component_override_id ) 
			);
		});

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;

    }

    public com.apirone.core.model.bean.Outcome function delete(
			required String ComponentOverrideId
		){

		var outcome = super.bean("Outcome");

        var obj = get( arguments.ComponentOverrideId );

		outcome.setData( { ComponentOverrideId: arguments.ComponentOverrideId } );

		transaction {
		
		    try  {

                getDao().delete( arguments.ComponentOverrideId );
        
                super.getCacheManager().remove( getCacheScope(), obj.getId() );
                
			} catch ( any error ) {

				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteComponentOverride" );
				outcome.setMessage( "Cannot delete ComponentOverride [#arguments.ComponentOverrideId#]" );
				
			}
			
		}

		return outcome;

	}

	public String function create(
			required com.apirone.core.model.bean.ComponentOverride ComponentOverride
		){

		var id = getDao().insert( arguments.ComponentOverride );

		return id;

	}


	public String function update(
			required com.apirone.core.model.bean.ComponentOverride ComponentOverride
		){

		getDao().update( arguments.ComponentOverride );

		super.getCacheManager().remove( getCacheScope(), ComponentOverride.getId() );

		return arguments.ComponentOverride.getId();

	}

	private com.apirone.core.model.bean.ComponentOverride function build(
    		required String ComponentOverrideId
    	){

	    var record = getDao().read( arguments.ComponentOverrideId );

	    if( record.recordCount ) { 

            var bean = super.bean( "ComponentOverride" );

            bean.setId( record.component_id );

			bean.setDeleted( record.deleted );
			bean.setQuantity( record.quantity );
			bean.setCreatedAt( record.created_at );

            return bean;

	    }

		return nullValue();

  	}

}
