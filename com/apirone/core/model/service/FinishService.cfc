component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.FinishDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";
	property name="LineCategoryService" type="com.apirone.core.model.service.LineCategoryService";
	property name="textService" type="com.apirone.core.model.service.TextService";

    public com.apirone.core.model.bean.Finish function get(
    		required String finishId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.finishId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.finishId );
		cm.put( key, bean );
        
		return bean;

	}

	public com.apirone.core.model.bean.Finish[] function list() {
		arguments["limit"] = -1;
		
		return search(argumentCollection = arguments).getData();
	
	}


    public com.apirone.core.model.bean.Result function search(){
	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.add( get( finishId = record.finish_id ) );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.recordcount ) );

        return result;

    }

	public String function create(
			required com.apirone.core.model.bean.Finish finish
		){

		transaction{

			var newId = getDao().insert( arguments.finish );

			for ( var text in arguments.finish.getTexts() ) {

				var entity = super.bean("Entity");

				entity.setKey( "finish.id" );
				entity.setValue( newId );

				text.setEntity( entity );

			}

			getTextService().bulkCreate( arguments.finish.getTexts() );

		}

		return newId;

	}

	public Boolean function codeExists( 
		required String code,
				 String excludedId=""
	){

		var record = getDao().readByCode( arguments.code );

		if( record.recordCount 
			AND record.finish_id != arguments.excludedId ) {

			return record.code == arguments.code;

		} 

		return false;

	}

    public com.apirone.core.model.bean.Outcome function delete(
			required String finishId
		){

		var outcome = super.bean("Outcome");

        var obj = get( arguments.finishId );

		outcome.setData( { finishId: arguments.finishId } );

		transaction {
		
			try  {

                var result = getDao().delete( arguments.finishId );
				outcome.setData( { "deletedCount":  result }  )
        
                getCacheManager().remove( "Finish_#arguments.finishId#" );
			
			} catch ( any error ) {

				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteFinish" );
				outcome.setMessage( "Cannot delete finish [#arguments.finishId#]" );
				
			}
			
		}

		return outcome;

	}	



    /*
    	private method
	*/

	private com.apirone.core.model.bean.Finish function build(
    		required String finishId
    	){

	    var record = getDao().read( arguments.finishId );

	    if( record.recordCount ) { 

            var bean = super.bean( "Finish" );

            bean.setId( record.finish_id );
            bean.setCode( record.code );
			bean.setCreatedAt( record.created_at );
			bean.setStatus( getStatusService().get( record.status_id ) );
			bean.setTexts( getTextService().list( finishId=record.finish_id ) );

			var categories = DeserializeJSON( record.categories );

			if ( !IsNull( categories ) AND len( categories ) ) {

				var beanCategories = [];

				for( var thisCategory in categories ) {
					beanCategories.add( getLineCategoryService().get( thisCategory ) )
				}
				
				bean.setCategories( beanCategories );
	
			}

            return bean;

	    }

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "Finish_#arguments.id#";

  	}

}
