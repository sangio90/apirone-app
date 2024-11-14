component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.CombinationsItemDAO";
	property name="CombinationService" type="com.apirone.core.model.service.CombinationService";

    public com.apirone.core.model.bean.Combination function get(
    		required String combinationItemId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.combinationItemId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.combinationItemId );
		cm.put( key, bean );
        
		return bean;

	}

	public com.apirone.core.model.bean.CombinationItem[] function list() {
		arguments["limit"] = -1;
		
		return search(argumentCollection = arguments).getData();
	
	}


    public com.apirone.core.model.bean.Result function search(
            String lineId
        ){

	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.add( 
                get( combinationId = record.combination_item_id ) 
            );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.recordcount ) );

        return result;

    }

    public com.smartvillage.core.model.bean.Outcome function delete(
			required String combinationId
		){

		var outcome = super.bean("Outcome");

        var obj = get( arguments.combinationId );

		outcome.setData( { combinationId: arguments.combinationId } );

		transaction {
		
		    try  {

                var cm = getCacheManager();

                getDao().delete( arguments.combinationId );
        
                cm.remove( "combination_#obj.getId()#" );
                
			} catch ( any error ) {

				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteEvent" );
				outcome.setMessage( "Cannot delete combination [#arguments.combinationId#]" );
				
			}
			
		}

		return outcome;

	}

	public String function create(
			required com.apirone.core.model.bean.CombinationItem combinationItem
		){

		var newId = getDao().insert( arguments.combinationItem );

		return newId;

	}



    /*
    	private method
	*/

	private com.apirone.core.model.bean.Combination function build(
    		required String combinationItemId
    	){

	    var record = getDao().read( arguments.combinationItemId );

	    if( record.recordCount ) { 

            var bean = super.bean( "Combination" );

            bean.setId( record.combination_item_id );
			bean.setName( "" );
			
			bean.setCreatedAt( record.created_at );

            return bean;

	    }

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "combinationItem_#arguments.id#";

  	}

}
