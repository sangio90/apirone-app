component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.CombinationsDAO";
	property name="SizeService" type="com.apirone.core.model.dao.SizeService";
	property name="LineService" type="com.apirone.core.model.dao.LineService";
	property name="FinishService" type="com.apirone.core.model.dao.FinishService";
	property name="StatusService" type="com.apirone.core.model.dao.StatusService";
	property name="cacheScope" type="String" default="Combination.bean";

    public com.apirone.core.model.bean.Combination function get(
    		required String combinationId
        ){

    	var cm = getCacheManager();

	   	var cache = cm.get( getCacheScope(), arguments.combinationId );

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.combinationId );
		cm.put( getCacheScope(), arguments.combinationId, bean );
        
		return bean;

	}

    public com.apirone.core.model.bean.Combination function getByParams(
			required String lineId,
			required String finishId,
			required String sizeId
		){

		var record = getDao().find( argumentCollection = arguments );

		if ( record.recordcount == 1) {

			return get( record.combination_id );

		}

		return NullValue();

	}

	public com.apirone.core.model.bean.Combination[] function list() {
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
			rows.add( get( combinationId = record.Combination_id ) );
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
        
                cm.remove( getCacheScope(), arguments.combinationId );
                
			} catch ( any error ) {

				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteEvent" );
				outcome.setMessage( "Cannot delete combination [#arguments.combinationId#]" );
				
			}
			
		}

		return outcome;

	}

    public com.apirone.core.model.bean.Outcome function deleteByParams(
			required String lineId,
			required String finishId,
			required String sizeId
		){

		var outcome = super.bean("Outcome");

        var obj = getByParams( argumentCollection = arguments );

		var combId = obj.getId()

		outcome.setData( { combinationId: combId } );

		transaction {
		
		    try  {

                var cm = getCacheManager();

                getDao().delete( obj.getId() );
        
                cm.remove( getCacheScope(), arguments.obj.getId() );
                
			} catch ( any error ) {

				/*
					set an error 500?
				*/

				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteCombination" );
				outcome.setMessage( "Cannot delete combination [#combId#]" );
				
			}
			
		}

		return outcome;

	}	


	public String function create(
			required com.apirone.core.model.bean.Combination combination
		){

		var newId = getDao().insert( arguments.combination );

		return newId;

	}



    /*
    	private method
	*/

	private com.apirone.core.model.bean.Combination function build(
    		required String combinationId
    	){

	    var record = getDao().read( arguments.combinationId );

	    if( record.recordCount ) { 

            var bean = super.bean( "Combination" );

            bean.setId( record.combination_id );
			bean.setName( "" );
			bean.setCreatedAt( record.created_at );

			bean.setSize( getSizeService().get( record.size_id ) );
			bean.setLine( getLineService().get( record.line_id ) );
			bean.setFinish( getFinishService().get( record.finish_id ) );
			
			//bean.setAttribute( "" );
			
			bean.setStatus( getStatusService().get( record.status_id ) );

            return bean;

	    }

		return nullValue();

  	}

}
