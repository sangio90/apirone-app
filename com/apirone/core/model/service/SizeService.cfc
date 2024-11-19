component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.SizeDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";

    public com.apirone.core.model.bean.Size function get(
    		required String sizeId
        ){

    	var cm = super.getCacheManager();

    	var key = getCacheKey( arguments.sizeId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.sizeId );
		cm.put( key, bean );
        
		return bean;

	}

	public com.apirone.core.model.bean.Size[] function list(
		String lineId,
	) {
		arguments["limit"] = -1;
		return search(argumentCollection = arguments).getData();
	}

    public com.apirone.core.model.bean.Result function search(
		             String lineId,
			required Numeric limit = 20,
			required Numeric offset = 0
    	){

	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function( record ) {
			rows.add( get( sizeId = record.size_id ) );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.total ) );

        return result;

    }

	public String function create(
		required com.apirone.core.model.bean.Size size
	){

		var newId = getDao().insert( arguments.size );

		/*
		transaction {
		
			for ( var text in arguments.size.getTexts() ) {
				var entity = super.bean( "Entity" );

				entity.setKey( "size.id" );
				entity.setValue( newId );

				text.setEntity( entity );
			}

			getTextService().bulkCreate( arguments.size.getTexts() );
		}
		*/

		return newId;
	}

	public String function update(
		required com.apirone.core.model.bean.Size size
	){
		getDao().update( arguments.size );

		super.getCacheManager().remove( "Size_#arguments.size.getId()#" );

		return arguments.size.getId();
	}


	public Boolean function codeExists(
		required String code,
		String excludedId = ""
	){
		var record = getDao().readByCode( arguments.code );

		if (
			record.recordCount
			&& record.size_id != arguments.excludedId
		) {
			return record.code == arguments.code;
		}

		return false;
	}


	public com.apirone.core.model.bean.Outcome function delete(
		required String sizeId
	){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.sizeId );

		outcome.setData( { sizeId = arguments.sizeId } );

		transaction {
			try {
				var result = getDao().delete( arguments.sizeId );
				outcome.setData( { "deletedCount" = result } )

				getCacheManager().remove( "Size_#arguments.sizeId#" );

			} catch ( any error ) {
				
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteSize" );
				outcome.setMessage( "Cannot delete size [#arguments.sizeId#]" );
			
			}
		}

		return outcome;
	}



    /*
    	private method
	*/

	private com.apirone.core.model.bean.Size function build(
    		required String sizeId
    	){

	    var record = getDao().read( arguments.sizeId );

	    if( record.recordCount ) { 

            var bean = super.bean( "Size" );

            bean.setId( record.size_id );
			bean.setName( record.size );
			bean.setCode( record.code );
			bean.setFruitsCount( record.fruits_count );
			bean.setCategories( getCategoriesBeanFromIds( record.categories ) );
			bean.setStatus( getStatusService().get( record.status_id )  );
			bean.setCreatedAt( record.created_at );
			
            return bean;

	    }

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "Size_#arguments.id#";

  	}

}
