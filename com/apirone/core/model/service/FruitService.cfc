component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.FruitDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";
	property name="textService" type="com.apirone.core.model.service.TextService";

    public com.apirone.core.model.bean.Size function get(
    		required String fruitId
        ){

    	var cm = super.getCacheManager();

    	var key = getCacheKey( arguments.fruitId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.fruitId );
		cm.put( key, bean );
        
		return bean;

	}

	public com.apirone.core.model.bean.Fruit[] function list(
		String lineId,
	) {
		arguments["limit"] = -1;
		return search(argumentCollection = arguments).getData();
	}

    public com.apirone.core.model.bean.Result function search(
		             String str,
			required Numeric limit = 20,
			required Numeric offset = 0
    	){

	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function( record ) {
			rows.add( get( fruitId = record.fruit_id ) );
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

		transaction {
		
			for ( var text in arguments.size.getTexts() ) {
				var entity = super.bean( "Entity" );

				entity.setKey( "size.id" );
				entity.setValue( newId );

				text.setEntity( entity );
			}

			getTextService().bulkCreate( arguments.size.getTexts() );
		}

		return newId;
	}

	public String function update(
		required com.apirone.core.model.bean.Fruit fruit
	){
		getDao().update( arguments.size );

		var id = arguments.size.getId();

		for ( var text in arguments.size.getTexts() ) {

			var entity = super.bean("Entity")
			
			entity.setKey( "fruit.id" );
			entity.setValue( id );

			text.setEntity( entity );

			if ( Len( text.getId() ) ) {
				
				getTextService().update( text );
			
			} else {
				
				getTextService().create( text );

			}

		}


		super.getCacheManager().remove( "Fruid_#arguments.size.getId()#" );

		return arguments.size.getId();
	}


	public Boolean function codeExists(
		required String code,
		String excludedId = ""
	){
		var record = getDao().readByCode( arguments.code );

		if (
			record.recordCount
			&& record.fruit_id != arguments.excludedId
		) {
			return record.code == arguments.code;
		}

		return false;
	}


	public com.apirone.core.model.bean.Outcome function delete(
		required String fruitId
	){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.fruitId );

		outcome.setData( { fruitId = arguments.fruitId } );

		transaction {
			try {
				var result = getDao().delete( arguments.fruitId );
				outcome.setData( { "deletedCount" = result } )

				getCacheManager().remove( "Fruit_#arguments.fruitId#" );

			} catch ( any error ) {
				
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteFruit" );
				outcome.setMessage( "Cannot delete fruit [#arguments.fruitId#]" );
			
			}
		}

		return outcome;
	}



    /*
    	private method
	*/

	private com.apirone.core.model.bean.Size function build(
    		required String fruitId
    	){

	    var record = getDao().read( arguments.fruitId );

	    if( record.recordCount ) { 

            var bean = super.bean( "Fruit" );

            bean.setId( record.fruit_id );
			bean.setCode( record.code );
			bean.setPositionsCount( record.positions_count );
			
			bean.setStatus( getStatusService().get( record.status_id ) );
			bean.setTexts( getTextService().list( fruitId = record.fruit_id ) );
			
			bean.setCreatedAt( record.created_at );
			
            return bean;

	    }

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "Size_#arguments.id#";

  	}

}
